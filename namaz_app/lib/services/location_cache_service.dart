import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class LocationCacheService {
  static final LocationCacheService _instance = LocationCacheService._internal();
  factory LocationCacheService() => _instance;
  LocationCacheService._internal();

  Position? currentPosition;
  List<Map<String, dynamic>> dynamicMosquesList = [];
  bool _isFetching = false;
  bool _hasError = false;

  bool get isFetching => _isFetching;
  bool get hasError => _hasError;

  // Start pre-fetching location and mosques
  Future<void> prefetchLocationAndMosques() async {
    if (_isFetching) {
      debugPrint("LocationCacheService: Prefetch already in progress.");
      return;
    }
    _isFetching = true;
    _hasError = false;

    debugPrint("=== LocationCacheService: Starting prefetch ===");
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("LocationCacheService: Location services disabled.");
        _isFetching = false;
        return;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // We do not request permission automatically at startup if it's denied
        // because we don't want to show a permission prompt unless the user is on the screen.
        debugPrint("LocationCacheService: Permission denied, not requesting at startup.");
        _isFetching = false;
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("LocationCacheService: Permission denied forever.");
        _isFetching = false;
        return;
      }

      // 3. Try to get last known position (fast)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition = position;
        debugPrint("LocationCacheService: Found last known position: ${position.latitude}, ${position.longitude}");
        // Fetch mosques in background
        _fetchNearbyMosquesInBackground(position.latitude, position.longitude);
      }

      // 4. Try to get a fresh position in the background
      Position? freshPosition;
      try {
        freshPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        debugPrint("LocationCacheService: High accuracy fetch failed, trying low accuracy: $e");
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e2) {
          debugPrint("LocationCacheService: Low accuracy fetch failed: $e2");
        }
      }

      if (freshPosition != null) {
        debugPrint("LocationCacheService: Fresh position obtained: ${freshPosition.latitude}, ${freshPosition.longitude}");
        
        bool shouldUpdate = false;
        if (position == null) {
          shouldUpdate = true;
        } else {
          final double distance = _calculateDistance(
            position.latitude,
            position.longitude,
            freshPosition.latitude,
            freshPosition.longitude,
          );
          if (distance > 0.15) { // If user moved > 150m, refresh
            shouldUpdate = true;
          }
        }

        if (shouldUpdate) {
          currentPosition = freshPosition;
          await _fetchNearbyMosquesInBackground(freshPosition.latitude, freshPosition.longitude);
        }
      }
    } catch (e) {
      debugPrint("LocationCacheService: Prefetch error: $e");
      _hasError = true;
    } finally {
      _isFetching = false;
      debugPrint("=== LocationCacheService: Prefetch completed ===");
    }
  }

  // Distance calculation helper
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return r * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  Future<void> _fetchNearbyMosquesInBackground(double lat, double lon) async {
    debugPrint('=== LocationCacheService: Searching mosques near lat=$lat, lon=$lon ===');
    final radii = [3000, 5000, 10000, 20000]; // meters
    final overpassEndpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.osm.ch/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final radius in radii) {
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lon);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lon);
  node["building"="mosque"](around:$radius,$lat,$lon);
  way["building"="mosque"](around:$radius,$lat,$lon);
  node["amenity"="place_of_worship"](around:$radius,$lat,$lon);
  way["amenity"="place_of_worship"](around:$radius,$lat,$lon);
);
out center body;
''';

      for (final endpoint in overpassEndpoints) {
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'NamazVakitleri/1.0',
            },
            body: 'data=${Uri.encodeComponent(query)}',
          ).timeout(const Duration(seconds: 12));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final elements = data['elements'] as List<dynamic>? ?? [];
            final List<Map<String, dynamic>> mosques = [];
            final Set<String> seenCoords = {};
            int unnamedCount = 0;

            for (final el in elements) {
              final tags = el['tags'] as Map<String, dynamic>? ?? {};
              double? mLat, mLon;

              if (el['type'] == 'node') {
                mLat = (el['lat'] as num?)?.toDouble();
                mLon = (el['lon'] as num?)?.toDouble();
              } else if ((el['type'] == 'way' || el['type'] == 'relation') && el['center'] != null) {
                mLat = (el['center']['lat'] as num?)?.toDouble();
                mLon = (el['center']['lon'] as num?)?.toDouble();
              }

              if (mLat == null || mLon == null) continue;

              final religion = tags['religion']?.toString().toLowerCase() ?? '';
              final building = tags['building']?.toString().toLowerCase() ?? '';
              final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
              if (religion.isNotEmpty && religion != 'muslim') continue;
              if (religion.isEmpty && building != 'mosque' && amenity != 'place_of_worship') continue;

              final coordKey = '${mLat.toStringAsFixed(4)},${mLon.toStringAsFixed(4)}';
              if (seenCoords.contains(coordKey)) continue;
              seenCoords.add(coordKey);

              String name = (tags['name'] ?? tags['name:tr'] ?? tags['name:en'] ?? '').toString();
              if (name.isEmpty) {
                unnamedCount++;
                name = 'Cami #$unnamedCount';
              }

              final street = tags['addr:street'] ?? '';
              final district = tags['addr:district'] ?? tags['addr:suburb'] ?? tags['addr:neighbourhood'] ?? '';
              final city = tags['addr:city'] ?? '';
              String address = [street, district, city]
                  .where((s) => s.toString().isNotEmpty)
                  .join(', ');
              if (address.isEmpty) {
                address = tags['addr:full']?.toString() ?? '';
              }

              final dist = _calculateDistance(lat, lon, mLat, mLon);

              mosques.add({
                'ad': name,
                'adres': address.isNotEmpty ? address : 'Konum: ${mLat.toStringAsFixed(4)}, ${mLon.toStringAsFixed(4)}',
                'harita': 'https://www.google.com/maps/dir/?api=1&destination=$mLat,$mLon',
                'lat': mLat,
                'lon': mLon,
                'mesafeVal': dist,
                'mesafeText': dist < 1.0 
                    ? '${(dist * 1000).round()} m' 
                    : '${dist.toStringAsFixed(1)} km',
              });
            }

            // Sort by distance
            mosques.sort((a, b) => (a['mesafeVal'] as double).compareTo(b['mesafeVal'] as double));
            
            dynamicMosquesList = mosques;
            debugPrint("LocationCacheService: Successfully cached ${dynamicMosquesList.length} mosques");
            return; // Exit if success
          }
        } catch (e) {
          debugPrint("LocationCacheService: Error from endpoint $endpoint: $e");
        }
      }
    }
  }
}
