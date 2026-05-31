import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/prayer_data.dart';
import '../data/prayer_repository.dart';

class ToolDetailScreen extends StatefulWidget {
  final String toolId;
  final String toolTitle;

  const ToolDetailScreen({
    super.key,
    required this.toolId,
    required this.toolTitle,
  });

  @override
  _ToolDetailScreenState createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final PrayerRepository _repository = PrayerRepository();
  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  String _currentAudioUrl = "";
  String _currentTrackName = "";

  // Yakındaki Camiler (Location & GPS State)
  Position? _currentPosition;
  bool _loadingLocation = false;
  List<Map<String, dynamic>> _dynamicMosquesList = [];

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

  void _initMosques() {
    _dynamicMosquesList = [];
  }

  /// Fetches real nearby mosques from OpenStreetMap Overpass API
  Future<void> _fetchNearbyMosques(double lat, double lon) async {
    debugPrint('=== MOSQUE SEARCH: Searching near lat=$lat, lon=$lon ===');
    // Try progressively larger radii until we find enough mosques
    final radii = [3000, 5000, 10000]; // meters
    
    // Multiple Overpass API endpoints for reliability
    final overpassEndpoints = [
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass-api.de/api/interpreter',
      'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    ];

    for (final radius in radii) {
      for (final endpoint in overpassEndpoints) {
        try {
          // Overpass QL query: find nodes and ways tagged as mosque within radius
          final query = '''
[out:json][timeout:15];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lon);
  node["building"="mosque"](around:$radius,$lat,$lon);
  way["building"="mosque"](around:$radius,$lat,$lon);
);
out center body;
''';

          final encodedQuery = Uri.encodeComponent(query);
          final url = Uri.parse('$endpoint?data=$encodedQuery');
          final response = await http.get(
            url,
            headers: {
              'Accept': '*/*',
              'User-Agent': 'NamazVakitleri/1.0',
            },
          ).timeout(const Duration(seconds: 20));

          debugPrint('Overpass API [$endpoint] response: status=${response.statusCode}, radius=$radius');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final elements = data['elements'] as List<dynamic>? ?? [];
            debugPrint('Overpass API response: elements=${elements.length}');

            final List<Map<String, dynamic>> mosques = [];
            final Set<String> seenNames = {}; // avoid duplicates

            for (final el in elements) {
              final tags = el['tags'] as Map<String, dynamic>? ?? {};
              double? mLat, mLon;

              if (el['type'] == 'node') {
                mLat = (el['lat'] as num?)?.toDouble();
                mLon = (el['lon'] as num?)?.toDouble();
              } else if (el['type'] == 'way' && el['center'] != null) {
                mLat = (el['center']['lat'] as num?)?.toDouble();
                mLon = (el['center']['lon'] as num?)?.toDouble();
              }

              if (mLat == null || mLon == null) continue;

              // Determine name
              final name = tags['name'] ?? tags['name:tr'] ?? tags['name:en'] ?? '';
              if (name.toString().isEmpty) continue; // skip unnamed

              // Skip duplicates (same name)
              final nameKey = name.toString().toLowerCase();
              if (seenNames.contains(nameKey)) continue;
              seenNames.add(nameKey);

              // Build address from tags
              final street = tags['addr:street'] ?? '';
              final district = tags['addr:district'] ?? tags['addr:suburb'] ?? '';
              final city = tags['addr:city'] ?? '';
              String address = [street, district, city]
                  .where((s) => s.toString().isNotEmpty)
                  .join(', ');
              if (address.isEmpty) {
                address = tags['addr:full']?.toString() ?? '';
              }

              final dist = _calculateDistance(lat, lon, mLat, mLon);
              final encodedName = Uri.encodeComponent(name.toString());

              mosques.add({
                'ad': name.toString(),
                'adres': address.isNotEmpty ? address : 'Konum: ${mLat.toStringAsFixed(4)}, ${mLon.toStringAsFixed(4)}',
                'harita': 'https://www.google.com/maps/dir/?api=1&destination=$mLat,$mLon',
                'lat': mLat,
                'lon': mLon,
                'mesafeVal': dist,
                'mesafeText': dist < 1
                    ? '${(dist * 1000).toInt()} m'
                    : '${dist.toStringAsFixed(1)} km',
              });
            }

            // Sort by distance
            mosques.sort((a, b) =>
                (a['mesafeVal'] as double).compareTo(b['mesafeVal'] as double));

            if (mosques.isNotEmpty) {
              if (mounted) {
                setState(() {
                  _dynamicMosquesList = mosques;
                });
              }
              debugPrint('Found ${mosques.length} mosques within ${radius}m');
              return; // success – stop expanding radius
            }
            // This endpoint returned 200 but no mosques at this radius, try next radius
            break; // break endpoint loop, try next radius
          }
          // Non-200 status, try next endpoint
          debugPrint('Overpass endpoint returned ${response.statusCode}, trying next...');
        } catch (e) {
          debugPrint('Overpass API error ($endpoint, radius=$radius): $e');
          // Try next endpoint
        }
      }
    }

    // If all radii failed, show a message
    debugPrint('No mosques found from Overpass API');
    if (mounted) {
      setState(() {
        _dynamicMosquesList = [];
      });
    }
  }

  // static map of 81 Turkish cities and coordinates
  static const Map<String, Map<String, double>> _cityCoordinates = {
    "ADANA": {"lat": 36.9914, "lon": 35.3308},
    "ADIYAMAN": {"lat": 37.7648, "lon": 38.2786},
    "AFYONKARAHISAR": {"lat": 38.7507, "lon": 30.5567},
    "AFYON": {"lat": 38.7507, "lon": 30.5567},
    "AGRI": {"lat": 39.7191, "lon": 43.0503},
    "AMASYA": {"lat": 40.6499, "lon": 35.8353},
    "ANKARA": {"lat": 39.9334, "lon": 32.8597},
    "ANTALYA": {"lat": 36.8969, "lon": 30.7133},
    "ARTVIN": {"lat": 41.1828, "lon": 41.8183},
    "AYDIN": {"lat": 37.8444, "lon": 27.8458},
    "BALIKESIR": {"lat": 39.6484, "lon": 27.8826},
    "BILECIK": {"lat": 40.1451, "lon": 29.9799},
    "BINGOL": {"lat": 38.8847, "lon": 40.4939},
    "BITLIS": {"lat": 38.4006, "lon": 42.1095},
    "BOLU": {"lat": 40.7316, "lon": 31.5898},
    "BURDUR": {"lat": 37.7203, "lon": 30.2908},
    "BURSA": {"lat": 40.1885, "lon": 29.0610},
    "CANAKKALE": {"lat": 40.1553, "lon": 26.4142},
    "CANKIRI": {"lat": 40.6013, "lon": 33.6134},
    "CORUM": {"lat": 40.5506, "lon": 34.9556},
    "DENIZLI": {"lat": 37.7765, "lon": 29.0864},
    "DIYARBAKIR": {"lat": 37.9144, "lon": 40.2306},
    "EDIRNE": {"lat": 41.6818, "lon": 26.5623},
    "ELAZIG": {"lat": 38.6810, "lon": 39.2230},
    "ERZINCAN": {"lat": 39.7500, "lon": 39.5000},
    "ERZURUM": {"lat": 39.9000, "lon": 41.2700},
    "ESKISEHIR": {"lat": 39.7767, "lon": 30.5206},
    "GAZIANTEP": {"lat": 37.0662, "lon": 37.3833},
    "GIRESUN": {"lat": 40.9128, "lon": 38.3895},
    "GUMUSHANE": {"lat": 40.4600, "lon": 39.4817},
    "HAKKARI": {"lat": 37.5833, "lon": 43.7333},
    "HATAY": {"lat": 36.4018, "lon": 36.3498},
    "ISPARTA": {"lat": 37.7648, "lon": 30.5566},
    "MERSIN": {"lat": 36.8000, "lon": 34.6333},
    "ICEL": {"lat": 36.8000, "lon": 34.6333},
    "ISTANBUL": {"lat": 41.0082, "lon": 28.9784},
    "IZMIR": {"lat": 38.4192, "lon": 27.1287},
    "KARS": {"lat": 40.6013, "lon": 43.0949},
    "KASTAMONU": {"lat": 41.3887, "lon": 33.7827},
    "KAYSERI": {"lat": 38.7312, "lon": 35.4787},
    "KIRKLARELI": {"lat": 41.7333, "lon": 27.2167},
    "KIRSEHIR": {"lat": 39.1425, "lon": 34.1709},
    "KOCAELI": {"lat": 40.8533, "lon": 29.8815},
    "KONYA": {"lat": 37.8714, "lon": 32.4847},
    "KUTAHYA": {"lat": 39.4167, "lon": 29.9833},
    "MALATYA": {"lat": 38.3552, "lon": 38.3095},
    "MANISA": {"lat": 38.6191, "lon": 27.4287},
    "KAHRAMANMARAS": {"lat": 37.5858, "lon": 36.9371},
    "MARAS": {"lat": 37.5858, "lon": 36.9371},
    "KMARAS": {"lat": 37.5858, "lon": 36.9371},
    "MARDIN": {"lat": 37.3122, "lon": 40.7339},
    "MUGLA": {"lat": 37.2153, "lon": 28.3636},
    "MUS": {"lat": 38.7432, "lon": 41.5064},
    "NEVSEHIR": {"lat": 38.6244, "lon": 34.7144},
    "NIGDE": {"lat": 37.9667, "lon": 34.6833},
    "ORDU": {"lat": 40.9839, "lon": 37.8764},
    "RIZE": {"lat": 41.0201, "lon": 40.5234},
    "SAKARYA": {"lat": 40.7569, "lon": 30.3789},
    "SAMSUN": {"lat": 41.2928, "lon": 36.3313},
    "SIIRT": {"lat": 37.9333, "lon": 41.9500},
    "SINOP": {"lat": 42.0264, "lon": 35.1628},
    "SIVAS": {"lat": 39.7477, "lon": 37.0179},
    "TEKIRDAG": {"lat": 40.9833, "lon": 27.5167},
    "TOKAT": {"lat": 40.3167, "lon": 36.5500},
    "TRABZON": {"lat": 41.0027, "lon": 39.7168},
    "TUNCELI": {"lat": 39.1079, "lon": 39.5401},
    "SANLIURFA": {"lat": 37.1591, "lon": 38.7969},
    "URFA": {"lat": 37.1591, "lon": 38.7969},
    "SURFA": {"lat": 37.1591, "lon": 38.7969},
    "USAK": {"lat": 38.6823, "lon": 29.4082},
    "VAN": {"lat": 38.5012, "lon": 43.3730},
    "YOZGAT": {"lat": 39.8181, "lon": 34.8147},
    "ZONGULDAK": {"lat": 41.4564, "lon": 31.7987},
    "AKSARAY": {"lat": 38.3687, "lon": 34.0370},
    "BAYBURT": {"lat": 40.2561, "lon": 40.2249},
    "KARAMAN": {"lat": 37.1759, "lon": 33.2287},
    "KIRIKKALE": {"lat": 39.8468, "lon": 33.5153},
    "BATMAN": {"lat": 37.8874, "lon": 41.1322},
    "SIRNAK": {"lat": 37.5164, "lon": 42.4594},
    "BARTIN": {"lat": 41.6376, "lon": 32.3338},
    "ARDAHAN": {"lat": 41.1105, "lon": 42.7022},
    "IGDIR": {"lat": 39.9167, "lon": 44.0333},
    "YALOVA": {"lat": 40.6551, "lon": 29.2769},
    "KARABUK": {"lat": 41.2061, "lon": 32.6204},
    "KILIS": {"lat": 36.7161, "lon": 37.1150},
    "OSMANIYE": {"lat": 37.0742, "lon": 36.2467},
    "DUZCE": {"lat": 40.8438, "lon": 31.1565}
  };

  String _normalizeCityName(String name) {
    return name.trim().toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C')
        .replaceAll('Ö', 'O')
        .replaceAll('Ü', 'U');
  }

  Future<void> _getUserLocation({bool forceRefresh = false}) async {
    setState(() {
      _loadingLocation = true;
    });
    try {
      Position? position;

      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      // 2. Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3. Try to get high-accuracy live GPS location first if permitted (tam konum sokağına kadar)
      if (serviceEnabled &&
          (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always)) {
        try {
          debugPrint("Attempting to get fresh live GPS location...");
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high, // High accuracy down to street level
            timeLimit: const Duration(seconds: 7),
          );
          debugPrint("Successfully fetched live high-accuracy GPS: ${position.latitude}, ${position.longitude}");
        } catch (e) {
          debugPrint("Failed to fetch fresh live GPS: $e. Trying cached last known position.");
          try {
            position = await Geolocator.getLastKnownPosition();
            if (position != null) {
              debugPrint("Successfully fetched cached last known GPS: ${position.latitude}, ${position.longitude}");
            }
          } catch (e2) {
            debugPrint("Failed to fetch cached GPS: $e2");
          }
        }
      }

      // 4. Fallback to manually selected city coordinates if live GPS is unavailable/denied/timeout
      if (position == null) {
        final savedLoc = await _repository.getSavedLocation();
        final savedCity = savedLoc['cityName'];
        if (savedCity != null && savedCity.isNotEmpty) {
          final normalized = _normalizeCityName(savedCity);
          if (_cityCoordinates.containsKey(normalized)) {
            final coords = _cityCoordinates[normalized]!;
            position = Position(
              latitude: coords["lat"]!,
              longitude: coords["lon"]!,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
            debugPrint("Live GPS unavailable. Using manual city coordinate fallback: $savedCity -> ${position.latitude}, ${position.longitude}");
          }
        }
      }

      // 5. Ultimate fallback to Büyükçekmece, İstanbul if everything fails
      position ??= Position(
        latitude: 41.0207,
        longitude: 28.585,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final pos = position!;
      debugPrint('=== GPS POSITION: lat=${pos.latitude}, lon=${pos.longitude}, accuracy=${pos.accuracy} ===');
      setState(() {
        _currentPosition = pos;
      });

      // Fetch real nearby mosques from Overpass API using exact location
      await _fetchNearbyMosques(pos.latitude, pos.longitude);

      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint("Location error: $e");
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  // Zikirmatik State
  int _zikirCount = 0;
  int _zikirTarget = 33;
  bool _zikirSoundEnabled = true;
  String _selectedZikirId = 'subhanallah';

  final Map<String, Map<String, dynamic>> _zikirData = {
    'subhanallah': {
      'ad': 'Sübhânallâh',
      'arapca': 'سُبْحَانَ اللَّهِ',
      'anlam': 'Allah noksan sıfatlardan uzaktır.',
      'fazilet': 'Günde 100 defa okuyanın günahları deniz köpüğü kadar da olsa bağışlanır.',
      'hedef': 33
    },
    'elhamdulillah': {
      'ad': 'Elhamdülillâh',
      'arapca': 'الْحَمْدُ لِلَّهِ',
      'anlam': 'Hamd Allah\'a mahsustur.',
      'fazilet': 'Mizanı dolduran en hayırlı hamd cümlesidir.',
      'hedef': 33
    },
    'allahuekber': {
      'ad': 'Allâhu Ekber',
      'arapca': 'اللَّهُ أَكْبَرُ',
      'anlam': 'Allah en büyüktür.',
      'fazilet': 'Allah\'ın büyüklüğünü ve yüceliğini tefekkür zikridir.',
      'hedef': 34
    },
    'lailaheillallah': {
      'ad': 'Lâ ilâhe illallâh',
      'arapca': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'anlam': 'Allah\'tan başka ilah yoktur.',
      'fazilet': 'Zikrin en faziletlisi kelime-i tevhiddir.',
      'hedef': 9999
    }
  };

  // Dini Gunler State
  String _selectedDiniGunlerYear = "2026";
  final Map<String, List<Map<String, String>>> _diniGunlerByYear = {
    "2026": [
      { "ad": "Regaib Kandili", "gun": "Pazartesi", "tarih": "26 Ocak 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Cuma", "tarih": "13 Şubat 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Pazartesi", "tarih": "2 Mart 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Perşembe", "tarih": "19 Mart 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Salı", "tarih": "14 Nisan 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Cuma", "tarih": "17 Nisan 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Cumartesi", "tarih": "18 Nisan 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Pazar", "tarih": "19 Nisan 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Pazartesi", "tarih": "20 Nisan 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Pazartesi", "tarih": "25 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Salı", "tarih": "26 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Çarşamba", "tarih": "27 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Perşembe", "tarih": "28 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Cuma", "tarih": "29 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı (1 Muharrem 1448)", "gun": "Salı", "tarih": "16 Haziran 2026", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Perşembe", "tarih": "25 Haziran 2026", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Pazar", "tarih": "23 Ağustos 2026", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2027": [
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "14 Ocak 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Salı", "tarih": "2 Şubat 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Cuma", "tarih": "19 Şubat 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Pazartesi", "tarih": "8 Mart 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Cumartesi", "tarih": "3 Nisan 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Salı", "tarih": "6 Nisan 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Çarşamba", "tarih": "7 Nisan 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Perşembe", "tarih": "8 Nisan 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Cuma", "tarih": "9 Nisan 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Cuma", "tarih": "14 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Cumartesi", "tarih": "15 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Pazar", "tarih": "16 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Pazartesi", "tarih": "17 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Salı", "tarih": "18 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Cumartesi", "tarih": "5 Haziran 2027", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Pazartesi", "tarih": "14 Haziran 2027", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Perşembe", "tarih": "12 Ağustos 2027", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2028": [
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "3 Ocak 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Pazartesi", "tarih": "24 Ocak 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Salı", "tarih": "8 Şubat 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Cumartesi", "tarih": "26 Şubat 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Çarşamba", "tarih": "22 Mart 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Cumartesi", "tarih": "25 Mart 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Pazar", "tarih": "26 Mart 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Pazartesi", "tarih": "27 Mart 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Salı", "tarih": "28 Mart 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Salı", "tarih": "29 Nisan 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Çarşamba", "tarih": "3 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Perşembe", "tarih": "4 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Cuma", "tarih": "5 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Cumartesi", "tarih": "6 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Çarşamba", "tarih": "24 Mayıs 2028", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Cuma", "tarih": "2 Haziran 2028", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Salı", "tarih": "1 Ağu 2028", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2029": [
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "21 Aralık 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Cumartesi", "tarih": "13 Ocak 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Çarşamba", "tarih": "31 Ocak 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Çarşamba", "tarih": "14 Şubat 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Pazartesi", "tarih": "12 Mart 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Perşembe", "tarih": "15 Mart 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Cuma", "tarih": "16 Mart 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Cumartesi", "tarih": "17 Mart 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Pazar", "tarih": "18 Mart 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Cumartesi", "tarih": "21 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Pazar", "tarih": "22 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Pazartesi", "tarih": "23 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Salı", "tarih": "24 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Çarşamba", "tarih": "25 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Pazartesi", "tarih": "14 Mayıs 2029", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Çarşamba", "tarih": "23 Mayıs 2029", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Salı", "tarih": "22 Temmuz 2029", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2030": [
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "10 Ocak 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Salı", "tarih": "29 Ocak 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Cuma", "tarih": "15 Şubat 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Salı", "tarih": "5 Mart 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Pazar", "tarih": "31 Mart 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Perşembe", "tarih": "4 Nisan 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Cuma", "tarih": "5 Nisan 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Cumartesi", "tarih": "6 Nisan 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Pazar", "tarih": "7 Nisan 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Pazartesi", "tarih": "11 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Salı", "tarih": "12 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Çarşamba", "tarih": "13 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Perşembe", "tarih": "14 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Cuma", "tarih": "15 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Cuma", "tarih": "3 Mayıs 2030", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Pazar", "tarih": "12 Mayıs 2030", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Salı", "tarih": "11 Temmuz 2030", "kat": "Kandil ve Mübarek Geceler" }
    ]
  };

  // Dua Iste State
  List<Map<String, dynamic>> _duaList = [];
  final TextEditingController _duaNameController = TextEditingController();
  final TextEditingController _duaTextController = TextEditingController();

  // Soru Cevap State
  List<Map<String, dynamic>> _questionList = [];
  final TextEditingController _questionNameController = TextEditingController();
  final TextEditingController _qaInputController = TextEditingController();

  // Canli Dini Sohbet State
  final List<Map<String, String>> _chatMessages = [
    {
      'sender': 'other',
      'user': 'Mehmet Kaya',
      'text':
          'Selamün Aleyküm muhterem kardeşlerim, gününüz bereketli geçsin inşallah.',
    },
    {
      'sender': 'other',
      'user': 'Fatma Şahin',
      'text': 'Ve Aleyküm Selam. Hayırlı günler dilerim.',
    },
    {
      'sender': 'other',
      'user': 'Ömer Faruk',
      'text': 'Rabbim namazlarımızı ve dualarımızı kabul eylesin.',
    },
  ];
  final TextEditingController _chatInputController = TextEditingController();
  final List<String> _chatUsers = [
    "Ayşe Yılmaz",
    "Mustafa Demir",
    "Zeynep Çelik",
    "Ahmet Yıldız",
    "Emine Kaya",
  ];
  final List<String> _chatReplies = [
    "Allah hepimizden razı olsun inşallah.",
    "Rabbim bu güzel günün hürmetine dualarımızı kabul eylesin.",
    "Birlik ve beraberliğimiz daim olsun.",
    "Hayırlı, huzurlu vakitler dilerim.",
    "Ve aleyküm selam ve rahmetullah.",
  ];

  // 40 Hadis State
  int _hadisIndex = 0;
  final List<Map<String, dynamic>> _filteredHadisList = [...HADISLER_40];
  final TextEditingController _hadisSearchController = TextEditingController();

  // Namaz Tesbihati State
  int _tesbihStep = 0;
  int _tesbihCount = 0;

  // Zekat Hesaplayici State
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();
  String _zekatResult = "";

  // Date Converter State
  DateTime _selectedDate = DateTime.now();
  String _convertedDateResult = "";
  bool _miladiToHicri = true;

  // Sahabe Hayatlari & Esmaül Hüsna Search State
  String _esmaSearchQuery = "";
  String _sahabeSearchQuery = "";
  String _hadisSearchQuery = "";

  // Compass Manual Rotation Simulation (Fallback for Emulators)
  double _manualCompassHeading = 0.0;
  bool _forceSimulation = true;

  // Prophet Life Tab
  int _prophetLifeTab = 0;

  // Namaz Kilma Tab
  bool _namazKilmaErkek = true;

  // Kaza Namazi State
  int _kazaSabah = 0;
  int _kazaOgle = 0;
  int _kazaIkindi = 0;
  int _kazaAksam = 0;
  int _kazaYatsi = 0;
  int _kazaVitir = 0;

  // Sabah & Aksam Ezkari counts
  final List<int> _sabahEzkarCounts = [0, 0, 0, 0, 0, 0, 0];
  final List<int> _aksamEzkarCounts = [0, 0, 0, 0, 0, 0, 0];
  int _ezkarTab = 0;

  @override
  void initState() {
    super.initState();
    _initMosques();
    if (widget.toolId == 'yakindaki-camiler') {
      _getUserLocation();
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
  }

  Future<void> _loadKazaState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kazaSabah = prefs.getInt('kaza_sabah') ?? 0;
      _kazaOgle = prefs.getInt('kaza_ogle') ?? 0;
      _kazaIkindi = prefs.getInt('kaza_ikindi') ?? 0;
      _kazaAksam = prefs.getInt('kaza_aksam') ?? 0;
      _kazaYatsi = prefs.getInt('kaza_yatsi') ?? 0;
      _kazaVitir = prefs.getInt('kaza_vitir') ?? 0;
    });
  }

  Future<void> _updateKaza(String key, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(key) ?? 0;
    int newValue = math.max(0, current + delta);
    await prefs.setInt(key, newValue);
    setState(() {
      if (key == 'kaza_sabah') _kazaSabah = newValue;
      if (key == 'kaza_ogle') _kazaOgle = newValue;
      if (key == 'kaza_ikindi') _kazaIkindi = newValue;
      if (key == 'kaza_aksam') _kazaAksam = newValue;
      if (key == 'kaza_yatsi') _kazaYatsi = newValue;
      if (key == 'kaza_vitir') _kazaVitir = newValue;
    });
  }

  void _initAudio() {
    _audioPlayer = AudioPlayer();
    _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _duaNameController.dispose();
    _duaTextController.dispose();
    _questionNameController.dispose();
    _qaInputController.dispose();
    _chatInputController.dispose();
    _hadisSearchController.dispose();
    _goldController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }

  // Zikirmatik persistence
  Future<void> _loadZikirState() async {
    final count = await _repository.getZikirCount();
    final target = await _repository.getZikirTarget();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _zikirCount = count;
      _zikirTarget = target;
      _selectedZikirId = prefs.getString('zikir_selected_id') ?? 'subhanallah';
    });
  }

  void _onZikirSelected(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zikir_selected_id', id);
    final target = _zikirData[id]?['hedef'] ?? 33;
    setState(() {
      _selectedZikirId = id;
      _zikirTarget = target;
      _zikirCount = 0;
    });
    await _repository.setZikirTarget(target);
    await _repository.setZikirCount(0);
  }

  Future<void> _incrementZikir() async {
    HapticFeedback.lightImpact();
    if (_zikirSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    setState(() {
      _zikirCount++;
    });
    await _repository.setZikirCount(_zikirCount);

    if (_zikirTarget != 9999 && _zikirCount >= _zikirTarget) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Tebrikler! ${_zikirData[_selectedZikirId]?['ad'] ?? ''} zikrini tamamladınız!",
          ),
          backgroundColor: const Color(0xFF27A770),
        ),
      );
      setState(() {
        _zikirCount = 0;
      });
      await _repository.setZikirCount(0);
    }
  }

  Future<void> _resetZikir() async {
    setState(() {
      _zikirCount = 0;
    });
    await _repository.setZikirCount(0);
  }

  // Dua list persist (approved only)
  Future<void> _loadDuaList() async {
    final list = await _repository.getDuaList();
    if (mounted) {
      setState(() {
        _duaList = list.where((d) => d['durum'] == 'yayinda').toList();
      });
    }
  }

  Future<void> _addDua() async {
    final name = _duaNameController.text.trim();
    final text = _duaTextController.text.trim();
    if (text.isEmpty) return;

    _duaNameController.clear();
    _duaTextController.clear();

    await _repository.addDua(name.isEmpty ? "Anonim" : name, text);
    await _loadDuaList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Dua talebiniz onay için gönderildi. Onaylandıktan sonra yayınlanacaktır."),
        backgroundColor: Color(0xFF27A770),
      ),
    );
  }

  Future<void> _aminDua(int index) async {
    HapticFeedback.lightImpact();
    final int? idVal = _duaList[index]['id'];
    if (idVal != null) {
      await _repository.addAmin(idVal);
    }
    setState(() {
      _duaList[index]['amin'] = (_duaList[index]['amin'] ?? 0) + 1;
    });
  }

  // Question & Answers list persist (answered only)
  Future<void> _loadQuestionList() async {
    final list = await _repository.getQuestionList();
    if (mounted) {
      setState(() {
        _questionList = list
            .where((q) => q['cevap'] != null && q['cevap'].toString().trim().isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _addQuestion() async {
    final name = _questionNameController.text.trim();
    final text = _qaInputController.text.trim();
    if (text.isEmpty) return;

    _questionNameController.clear();
    _qaInputController.clear();

    await _repository.sendQuestion(name.isEmpty ? "Anonim" : name, text);
    await _loadQuestionList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sorunuz onay için gönderildi. Cevaplandıktan sonra burada yayınlanacaktır."),
        backgroundColor: Color(0xFF27A770),
      ),
    );
  }

  // Audio Play helper
  Future<void> _playAudio(String url, String name) async {
    try {
      if (_currentAudioUrl == url && _playerState == PlayerState.playing) {
        await _audioPlayer!.pause();
      } else if (_currentAudioUrl == url &&
          _playerState == PlayerState.paused) {
        await _audioPlayer!.resume();
      } else {
        await _audioPlayer!.stop();
        setState(() {
          _currentAudioUrl = url;
          _currentTrackName = name;
        });
        await _audioPlayer!.play(UrlSource(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ses çalma hatası: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: Text(
          widget.toolTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E5E43),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildToolBody(),
        ),
      ),
    );
  }

  Widget _buildToolBody() {
    switch (widget.toolId) {
      case 'dini-gunler':
        return _buildDiniGunler();
      case 'dua-iste':
        return _buildDuaIste();
      case 'soru-cevap':
        return _buildSoruCevap();
      case 'canli-sohbet':
        return _buildCanliSohbet();
      case 'peygamber-hayati':
        return _buildPeygamberHayati();
      case 'kuran-kerim':
        return _buildKuranKerim();
      case 'esmaul-husna':
        return _buildEsmaulHusna();
      case 'ramazan-hakkinda':
        return _buildRamazanHakkinda();
      case 'oruc-rehberi':
        return _buildOrucRehberi();
      case 'kible-bulucu':
        return _buildKibleBulucu();
      case 'zikirmatik':
        return _buildZikirmatik();
      case 'miladi-hicri':
        return _buildMiladiHicri();
      case 'yasin-suresi':
        return _buildYasinSuresi();
      case 'yakindaki-camiler':
        return _buildYakindakiCamiler();
      case 'hadis-40':
        return _buildHadis40();
      case 'namaz-tesbihati':
        return _buildNamazTesbihati();
      case 'gunluk-dualar':
        return _buildGunlukDualar();
      case 'zekat-hesaplama':
        return _buildZekatHesaplama();
      case 'sahabe-hayatlari':
        return _buildSahabeHayatlari();
      case 'islam-tarihi':
        return _buildIslamTarihi();
      case 'namaz-kilma':
        return _buildNamazKilma();
      case 'vitir-namazi':
        return _buildVitirNamazi();
      case 'abdest-rehberi':
        return _buildAbdestRehberi();
      case 'gusul-rehberi':
      case 'gusul-abdesti':
        return _buildGusulRehberi();
      case 'teyemmum-rehberi':
      case 'teyemmum':
        return _buildTeyemmumRehberi();
      case 'cuma-namazi':
        return _buildCumaNamazi();
      case 'teravih-namazi':
        return _buildTeravihNamazi();
      case 'bayram-namazi':
        return _buildBayramNamazi();
      case 'cenaze-namazi':
        return _buildCenazeNamazi();
      case 'teheccud-namazi':
        return _buildTeheccudNamazi();
      case 'duha-namazi':
        return _buildDuhaNamazi();
      case 'evvabin-namazi':
        return _buildEvvabinNamazi();
      case 'hacet-namazi':
        return _buildHacetNamazi();
      case 'istihare-namazi':
        return _buildIstihareNamazi();
      case 'sehiv-secdesi':
      case 'secdei-sehiv':
        return _buildSehivSecdesi();
      case 'tilavet-secdesi':
      case 'secdei-tilavet':
        return _buildTilavetSecdesi();
      case 'kaza-namazi':
      case 'kaza-namazlari':
        return _buildKazaNamazi();
      case 'sabah-ezkari':
        return _buildSabahEzkari();
      case 'aksam-ezkari':
        return _buildAksamEzkari();
      case 'ezkar':
        return _buildEzkar();
      case 'kunut-duasi':
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildKunutCard("Kunut Duası - 1", VITIR_NAMAZI['kunut1']),
              const SizedBox(height: 16),
              _buildKunutCard("Kunut Duası - 2", VITIR_NAMAZI['kunut2']),
            ],
          ),
        );
      case 'yemek-duasi':
        return _buildYemekDuasi();
      case 'sifa-duasi':
        return _buildSifaDuasi();
      case 'koruyucu-dualar':
        return _buildKoruyucuDualar();
      case 'sikinti-borc-duasi':
        return _buildSikintiBorcDuasi();
      case 'rabbena-dualar':
        return _buildRabbenaDualar();
      case 'hac-umre':
        return _buildHacUmre();
      case 'kurban-rehberi':
        return _buildKurbanRehberi();
      case 'sadaka-bilgileri':
        return _buildSadakaBilgileri();
      case 'islamin-sartlari':
        return _buildIslaminSartlari();
      case 'imanin-sartlari':
        return _buildImaninSartlari();
      case 'farz-32':
        return _buildFarz32();
      case 'farz-54':
        return _buildFarz54();
      case 'buyuk-gunahlar':
        return _buildBuyukGunahlar();
      case 'helal-haram':
        return _buildHelalHaram();
      case 'aile-ahlaki':
        return _buildAileAhlaki();
      case 'ticaret-fikhi':
        return _buildTicaretFikhi();
      case 'miras-fikhi':
        return _buildMirasFikhi();
      case 'anne-baba-haklari':
        return _buildAnneBabaHaklari();
      case 'kul-hakki':
        return _buildKulHakki();
      case 'komsu-haklari':
        return _buildKomsuHaklari();
      case 'cocuk-egitimi':
        return _buildCocukEgitimi();
      case 'selamlasma-adabi':
        return _buildSelamlasmaAdabi();
      case 'misafirlik-adabi':
        return _buildMisafirlikAdabi();
      case 'uc-aylar':
        return _buildUcAylar();
      case 'muharrem-asure':
        return _buildMuharremAsure();
      case 'zilhicce-arefe':
        return _buildZilhicceArefe();
      case 'islam-alimleri':
        return _buildIslamAlimleri();
      case 'islam-cografyasi':
        return _buildIslamCografyasi();
      case 'tevbe-istigfar':
        return _buildTevbeIstigfar();
      case 'sadaka-i-cariye':
        return _buildSadakaICariye();
      case 'tecvid-kurallari':
        return _buildTecvidKurallari();
      default:
        return const Center(
          child: Text("Bu özellik çok yakında eklenecektir."),
        );
    }
  }

  // 1. Dini Günler
  Widget _buildDiniGunler() {
    final list = _diniGunlerByYear[_selectedDiniGunlerYear] ?? [];
    final Map<String, List<Map<String, String>>> grouped = {};
    for (var item in list) {
      final cat = item['kat'] ?? 'Diğer';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    final categoryOrder = [
      "Kandil ve Mübarek Geceler",
      "Ramazan Bayramı",
      "Kurban Bayramı",
      "Hicri Yılbaşı ve Aşure"
    ];

    return Column(
      children: [
        // Year tabs horizontally
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ["2026", "2027", "2028", "2029", "2030"].map((year) {
              final isSelected = _selectedDiniGunlerYear == year;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    year,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1E5E43),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF27A770),
                  backgroundColor: Colors.white,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedDiniGunlerYear = year;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: categoryOrder.map((catName) {
              final items = grouped[catName] ?? [];
              if (items.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27A770).withOpacity(0.08),
                      border: const Border(
                        left: BorderSide(color: Color(0xFF27A770), width: 4),
                      ),
                    ),
                    child: Text(
                      catName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5E43),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Items in this category
                  ...items.map((day) {
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          day['ad'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          day['gun'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27A770).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            day['tarih'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF1E5E43),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 2. Dua İste
  Widget _buildDuaIste() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dua Talebinde Bulun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E5E43),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _duaNameController,
                  decoration: InputDecoration(
                    hintText: "İsminiz (İsteğe bağlı)",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _duaTextController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Dua talebinizi yazın...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addDua,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A770),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Dua Talebi Paylaş",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Dua Bekleyenler",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _duaList.length,
            itemBuilder: (context, index) {
              final item = _duaList[index];
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['yazar'] ?? 'Anonim',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27A770),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['dua'] ?? '',
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item['amin'] ?? 0} kişi Amin dedi",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _aminDua(index),
                            icon: const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Amin de",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1E5E43),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF4FB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Soru Cevap
  Widget _buildSoruCevap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ask Question Form Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Soru Talebinde Bulun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E5E43),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionNameController,
                  decoration: InputDecoration(
                    hintText: "İsminiz (İsteğe bağlı)",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _qaInputController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Dini sorunuzu yazın...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A770),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Soru Talebi Gönder",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Cevaplanan Sorular",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _questionList.isEmpty
              ? const Center(
                  child: Text(
                    "Cevaplanmış soru bulunmuyor.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _questionList.length,
                  itemBuilder: (context, index) {
                    final item = _questionList[index];
                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left border line indicator
                            Container(
                              width: 4,
                              color: const Color(0xFF27A770),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Soru header (Writer & Date)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['yazar'] ?? 'Anonim',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF27A770),
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          item['tarih'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Question
                                    Text(
                                      "Soru: ${item['soru'] ?? ''}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Divider(height: 20),
                                    // Answer box
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF7F1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Cevap:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E5E43),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['cevap'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 4. Canlı Sohbet
  Widget _buildCanliSohbet() {
    return Center(
      child: Card(
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  size: 54,
                  color: Color(0xFFD9534F),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Canlı Dini Sohbet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1E5E43),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Değerli hocalarımızın canlı dini sohbet yayınları çok yakında bu ekranda sizlerle olacaktır.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A770),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  elevation: 1,
                ),
                child: const Text(
                  "Geri Dön",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Peygamberin Hayatı
  Widget _buildPeygamberHayati() {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: PEYGAMBER_HAYATI.length,
            itemBuilder: (context, index) {
              final active = _prophetLifeTab == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    PEYGAMBER_HAYATI[index]['baslik']?.split(' ')[0] ?? '',
                  ),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  labelStyle: TextStyle(
                    color: active ? Colors.white : const Color(0xFF1E5E43),
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() {
                      _prophetLifeTab = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PEYGAMBER_HAYATI[_prophetLifeTab]['baslik'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5E43),
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      PEYGAMBER_HAYATI[_prophetLifeTab]['icerik'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Kuran-ı Kerim Player
  Widget _buildKuranKerim() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27A770).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.music_note, color: Color(0xFF27A770), size: 36),
              const SizedBox(height: 8),
              Text(
                _currentTrackName.isEmpty
                    ? "Cüz seçin ve oynatın"
                    : _currentTrackName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E5E43),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: Icon(
                      _playerState == PlayerState.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: const Color(0xFF27A770),
                    ),
                    onPressed: _currentAudioUrl.isEmpty
                        ? null
                        : () => _playAudio(_currentAudioUrl, _currentTrackName),
                  ),
                  if (_playerState != PlayerState.stopped)
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.stop_circle, color: Colors.red),
                      onPressed: () async {
                        await _audioPlayer?.stop();
                        setState(() {
                          _playerState = PlayerState.stopped;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "30 Cüz Listesi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E5E43),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final url =
                  "https://server8.mp3quran.net/afs/${juzNum.toString().padLeft(3, '0')}.mp3";
              final name = "$juzNum. Cüz Tilaveti - Fatih Çollak";
              final isCurrent = _currentAudioUrl == url;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent
                      ? const Color(0xFF27A770)
                      : Colors.white,
                  foregroundColor: isCurrent
                      ? Colors.white
                      : const Color(0xFF1E5E43),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _playAudio(url, name),
                child: Text(
                  "$juzNum. Cüz",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. Esmaül Hüsna
  Widget _buildEsmaulHusna() {
    final filtered = ESMAUL_HUSNA.where((item) {
      final name = _normalize(item['ad'].toString());
      final meaning = _normalize(item['anlam'].toString());
      final query = _normalize(_esmaSearchQuery);
      return name.contains(query) || meaning.contains(query);
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "İsim ara (Örn: Rahman)...",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF27A770)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            setState(() {
              _esmaSearchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "#${item['no']} ${item['ad']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E5E43),
                            ),
                          ),
                          Text(
                            item['arapca'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Traditional Arabic',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27A770),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        "Anlamı: ${item['anlam']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Fazileti: ${item['fazilet']}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "📿 Zikir: ${item['zikir']}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27A770),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.circle_outlined, size: 14),
                            label: const Text("Zikret"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF4FB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _zikirTarget = item['zikir'] as int;
                                _zikirCount = 0;
                              });
                              _repository.setZikirTarget(_zikirTarget);
                              _repository.setZikirCount(0);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${item['ad']} zikri hedef olarak ayarlandı: ${item['zikir']} adet.",
                                  ),
                                  backgroundColor: const Color(0xFF27A770),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 8. Ramazan Hakkında
  Widget _buildRamazanHakkinda() {
    return ListView.builder(
      itemCount: RAMAZAN_HAKKINDA.length,
      itemBuilder: (context, index) {
        final item = RAMAZAN_HAKKINDA[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🌙", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      item['baslik'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E5E43),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Text(
                  item['icerik'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 9. Oruç Rehberi
  Widget _buildOrucRehberi() {
    final List<String> bozanlar = List<String>.from(ORUC_REHBERI['bozanlar']);
    final List<String> bozmayanlar = List<String>.from(
      ORUC_REHBERI['bozmayanlar'],
    );
    final List<dynamic> cesitler = ORUC_REHBERI['cesitler'];

    return ListView(
      children: [
        ExpansionTile(
          title: const Text(
            "Orucu Bozan Durumlar",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5E43),
            ),
          ),
          leading: const Icon(Icons.cancel, color: Colors.red),
          children: bozanlar
              .map(
                (item) => ListTile(
                  title: Text(item, style: const TextStyle(fontSize: 13)),
                  leading: const Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.grey,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text(
            "Orucu Bozmayan Durumlar",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5E43),
            ),
          ),
          leading: const Icon(Icons.check_circle, color: Colors.green),
          children: bozmayanlar
              .map(
                (item) => ListTile(
                  title: Text(item, style: const TextStyle(fontSize: 13)),
                  leading: const Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.grey,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text(
            "Oruç Çeşitleri",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5E43),
            ),
          ),
          leading: const Icon(Icons.menu_book, color: Color(0xFF27A770)),
          children: cesitler
              .map(
                (item) => ListTile(
                  title: Text(
                    item['ad'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    item['aciklama'] ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // 10. Kıble Bulucu Compass
  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        bool hasSensor = heading != null && !_forceSimulation;

        // Use manual rotation if no sensor is available or simulation is forced
        double finalHeading = hasSensor ? heading : _manualCompassHeading;
        double needleRotation = qiblaAngle - finalHeading;
        double dialRotation = -finalHeading;

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Card(
                color: Color(0xFFFFF7EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Cihazınızı düz zeminde yatay tutun.",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Pusulayı döndürerek seccadeyi Kıble yönüne (🕌) hizalayın.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Custom Visual Compass stack
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass Ring (Dial) rotated by DialRotation
                    Transform.rotate(
                      angle: (dialRotation * math.pi / 180),
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF27A770),
                            width: 5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 15),
                          ],
                        ),
                        child: const Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "K",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "G",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "B",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "D",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Compass Needle (Qibla pointer) pointing to 137° (Prayer rug Seccade)
                    Transform.rotate(
                      angle: (needleRotation * math.pi / 180),
                      child: SizedBox(
                        width: 60,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Prayer rug (Seccade) rectangle pointing UP
                            Positioned(
                              top: 15,
                              child: Container(
                                width: 36,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27A770),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF1E5E43),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        "🕌",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Center dot
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E5E43),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Text(
                "Kıble Açısı: ${qiblaAngle.toInt()}° (İstanbul)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E5E43),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSensor
                    ? "Pusula Yönü: ${finalHeading.round()}°"
                    : "Simüle Yönü: ${finalHeading.round()}°",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SwitchListTile(
                  title: const Text(
                    "Simülasyon Modu",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Pusulayı el ile döndürmek için aktifleştirin",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _forceSimulation,
                  activeThumbColor: const Color(0xFF27A770),
                  onChanged: (val) {
                    setState(() {
                      _forceSimulation = val;
                    });
                  },
                ),
              ),
              if (!hasSensor) ...[
                const SizedBox(height: 8),
                const Text(
                  "Sürgü ile pusula açısını döndürün:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Slider(
                    value: _manualCompassHeading,
                    min: 0,
                    max: 360,
                    activeColor: const Color(0xFF27A770),
                    onChanged: (val) {
                      setState(() {
                        _manualCompassHeading = val;
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // 11. Zikirmatik
  Widget _buildZikirmatik() {
    final zikir = _zikirData[_selectedZikirId] ?? _zikirData['subhanallah']!;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Dhikr Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Zikir Seçin: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E5E43)),
                ),
                DropdownButton<String>(
                  value: _selectedZikirId,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF27A770)),
                  items: const [
                    DropdownMenuItem(value: "subhanallah", child: Text("Sübhânallâh (33)", style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: "elhamdulillah", child: Text("Elhamdülillâh (33)", style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: "allahuekber", child: Text("Allâhu Ekber (34)", style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: "lailaheillallah", child: Text("Lâ ilâhe illallâh (Limitsiz)", style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: _onZikirSelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dhikr Info Card
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    zikir['ad'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27A770),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    zikir['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E5E43),
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF9EDD4)),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Zikir circle button
          GestureDetector(
            onTap: _incrementZikir,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27A770), width: 8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$_zikirCount",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5E43),
                      ),
                    ),
                    Text(
                      _zikirTarget == 9999 ? "/ ∞" : "/ $_zikirTarget",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Zikir actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sıfırla"),
                      content: const Text(
                        "Sayacı sıfırlamak istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetZikir();
                            Navigator.pop(context);
                          },
                          child: const Text("Evet"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Sıfırla", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zikirSoundEnabled ? const Color(0xFF27A770) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _zikirSoundEnabled = !_zikirSoundEnabled;
                  });
                },
                child: Text(
                  _zikirSoundEnabled ? "Ses: Açık" : "Ses: Kapalı",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 12. Miladi - Hicri Çevirici
  Widget _buildMiladiHicri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Çeviri Yönü: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ChoiceChip(
              label: const Text("Miladi -> Hicri"),
              selected: _miladiToHicri,
              onSelected: (val) {
                setState(() {
                  _miladiToHicri = true;
                  _convertedDateResult = "";
                });
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text("Hicri -> Miladi"),
              selected: !_miladiToHicri,
              onSelected: (val) {
                setState(() {
                  _miladiToHicri = false;
                  _convertedDateResult = "";
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text(
            "Tarih Seçin",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}",
          ),
          trailing: const Icon(Icons.calendar_month, color: Color(0xFF27A770)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27A770),
            ),
            onPressed: () {
              setState(() {
                if (_miladiToHicri) {
                  // Rough estimation of Hijri Date
                  final gYear = _selectedDate.year;
                  final gMonth = _selectedDate.month;
                  final gDay = _selectedDate.day;
                  final hYear = ((gYear - 622) * 1.0307).floor();
                  final hijriMonths = [
                    "Muharrem",
                    "Safer",
                    "Rebiülevvel",
                    "Rebiülahir",
                    "Cemaziyelevvel",
                    "Cemaziyelahir",
                    "Recep",
                    "Şaban",
                    "Ramazan",
                    "Şevval",
                    "Zilkade",
                    "Zilhicce",
                  ];
                  final hMonthIndex = (gMonth + 4) % 12;
                  final hDay = (gDay + 15) % 29 + 1;
                  _convertedDateResult =
                      "Hicri: $hDay ${hijriMonths[hMonthIndex]} $hYear";
                } else {
                  // Hicri to Miladi estimation (+30 days)
                  final converted = _selectedDate.add(const Duration(days: 30));
                  _convertedDateResult =
                      "Miladi: ${converted.day}.${converted.month}.${converted.year}";
                }
              });
            },
            child: const Text(
              "Tarihi Çevir",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (_convertedDateResult.isNotEmpty) ...[
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                _convertedDateResult,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E4B85),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 13. Yasin Suresi Player and Arabic Text
  Widget _buildYasinSuresi() {
    const String yasinUrl = "https://server8.mp3quran.net/afs/036.mp3";
    const String yasinName = "Yasin Suresi - Meal ve Tilavet";
    final isCurrent = _currentAudioUrl == yasinUrl;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27A770).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text(
                "💚 Yasin Suresi Dinle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E5E43),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      (isCurrent && _playerState == PlayerState.playing)
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: const Color(0xFF27A770),
                    ),
                    onPressed: () => _playAudio(yasinUrl, yasinName),
                  ),
                  if (isCurrent && _playerState != PlayerState.stopped)
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.stop_circle, color: Colors.red),
                      onPressed: () async {
                        await _audioPlayer?.stop();
                        setState(() {
                          _playerState = PlayerState.stopped;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Yasin-i Şerif İlk Ayetleri",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E5E43),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const SingleChildScrollView(
              child: Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n"
                "يس ﴿١﴾ وَالْقُرْآنِ الْحَكِيمِ ﴿٢﴾ إِنَّكَ لَمِنَ الْمُرْسَلِينَ ﴿٣﴾ عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ ﴿٤﴾ تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ ﴿٥﴾ لِتُنْذِرَ قَوْمًا مَا أُنْdevİRİLMİŞTİR ﴿٦﴾ لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ ﴿٧﴾",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Traditional Arabic',
                  fontSize: 20,
                  height: 2.2,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 14. Yakındaki Camiler
  Widget _buildYakindakiCamiler() {
    return Column(
      children: [
        // Hadith Card at the top
        Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFFEAF7F1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF27A770).withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.mosque,
                      color: Color(0xFF27A770),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Camide Namaz Kılmanın Fazileti",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E5E43),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "“Cemaatle kılınan namaz, tek başına kılınan namazdan yirmi yedi derece daha faziletlidir.”",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "(Buhârî, Ezân 30)",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _loadingLocation
                    ? "Yakındaki camiler aranıyor..."
                    : _currentPosition != null
                        ? "Konumunuza En Yakın ${_dynamicMosquesList.length} Cami"
                        : "Konum alınıyor...",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E5E43),
                  fontSize: 13.5,
                ),
              ),
            ),
            if (_loadingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27A770)),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.my_location, color: Color(0xFF27A770), size: 20),
                onPressed: () => _getUserLocation(forceRefresh: true),
                tooltip: "Konumu Güncelle",
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loadingLocation
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27A770)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Konumunuza yakın camiler aranıyor...",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : _dynamicMosquesList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mosque, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            "Yakınınızda cami bulunamadı.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _getUserLocation(forceRefresh: true),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text("Tekrar Dene"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27A770),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _dynamicMosquesList.length,
                      itemBuilder: (context, index) {
                        final camii = _dynamicMosquesList[index];
                        return Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEAF7F1),
                              child: Icon(Icons.mosque, color: Color(0xFF27A770)),
                            ),
                            title: Text(
                              camii['ad'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "📍 ${camii['adres'] ?? ''}",
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  camii['mesafeText'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF27A770),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Icon(Icons.directions, size: 16, color: Color(0xFF27A770)),
                              ],
                            ),
                            onTap: () async {
                              final urlStr = camii['harita'] ?? '';
                              if (urlStr.isNotEmpty) {
                                final uri = Uri.parse(urlStr);
                                try {
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Harita uygulaması açılamadı."),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint("Launch map error: $e");
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Harita açılırken bir hata oluştu."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // 15. 40 Hadis
  Widget _buildHadis40() {
    final filtered = HADISLER_40.where((h) {
      final text = _normalize(h['metin'].toString());
      final source = _normalize(h['kaynak'].toString());
      final query = _normalize(_hadisSearchQuery);
      return text.contains(query) || source.contains(query);
    }).toList();

    return Column(
      children: [
        TextField(
          controller: _hadisSearchController,
          decoration: InputDecoration(
            hintText: "Hadislerde ara...",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF27A770)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            setState(() {
              _hadisSearchQuery = val;
              _hadisIndex = 0;
            });
          },
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Expanded(
            child: Center(child: Text("Aranan kriterde hadis bulunamadı.")),
          )
        else ...[
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hadis #${filtered[_hadisIndex]['no']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF27A770),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "“${filtered[_hadisIndex]['metin']}”",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Kaynak: ${filtered[_hadisIndex]['kaynak']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _hadisIndex > 0
                    ? () {
                        setState(() {
                          _hadisIndex--;
                        });
                      }
                    : null,
                child: const Text("Geri"),
              ),
              Text(
                "${_hadisIndex + 1} / ${filtered.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _hadisIndex < filtered.length - 1
                    ? () {
                        setState(() {
                          _hadisIndex++;
                        });
                      }
                    : null,
                child: const Text("İleri"),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // 16. Namaz Tesbihatı
  Widget _buildNamazTesbihati() {
    final step = TESBIHAT_STEPS[_tesbihStep];
    int target = 33;
    if (step['ad']!.contains("Salavat") ||
        step['ad']!.contains("Kelime-i Tevhid")) {
      target = 3;
    } else if (step['ad']!.contains("Münciye")) {
      target = 1;
    }

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: TESBIHAT_STEPS.length,
            itemBuilder: (context, index) {
              final active = _tesbihStep == index;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text("Adım ${index + 1}"),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  labelStyle: TextStyle(
                    color: active ? Colors.white : const Color(0xFF1E5E43),
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() {
                      _tesbihStep = index;
                      _tesbihCount = 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    step['ad'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E5E43),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Traditional Arabic',
                      fontSize: 22,
                      color: Color(0xFF27A770),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['okunus'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['anlam'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      SystemSound.play(SystemSoundType.click);
                      setState(() {
                        _tesbihCount++;
                      });
                      if (_tesbihCount >= target) {
                        HapticFeedback.vibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${step['ad']} tamamlandı!"),
                            backgroundColor: const Color(0xFF27A770),
                          ),
                        );
                        setState(() {
                          _tesbihCount = 0;
                          if (_tesbihStep < TESBIHAT_STEPS.length - 1) {
                            _tesbihStep++;
                          } else {
                            _tesbihStep = 0;
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF27A770),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "$_tesbihCount / $target",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E5E43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 17. Günlük Dualar
  Widget _buildGunlukDualar() {
    return ListView.builder(
      itemCount: DUALAR.length,
      itemBuilder: (context, index) {
        final dua = DUALAR[index];
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua['ad'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E5E43),
                  ),
                ),
                const Divider(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dua['arapca'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Traditional Arabic',
                      fontSize: 18,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27A770),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Anlamı: ${dua['anlam']}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 18. Zekat Hesaplayıcı
  Widget _buildZekatHesaplama() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dinen zengin sayılan kişilerin yılda bir kez vermesi gereken zekat miktarını hesaplayın.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goldController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Altın Miktarı (Gram)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nakit Para (TL)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _businessController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Ticari Mal ve Varlıklar (TL)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _debtsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Borçlarınız (Düşülecektir) (TL)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27A770),
              ),
              onPressed: () {
                final gold = double.tryParse(_goldController.text) ?? 0.0;
                final cash = double.tryParse(_cashController.text) ?? 0.0;
                final business =
                    double.tryParse(_businessController.text) ?? 0.0;
                final debts = double.tryParse(_debtsController.text) ?? 0.0;

                const double goldPrice =
                    3000.0; // Current representation gold price
                final totalWealth =
                    (gold * goldPrice) + cash + business - debts;
                const double nisapLimit =
                    80.18 * goldPrice; // 80.18g Gold Nisap threshold

                setState(() {
                  if (totalWealth <= 0) {
                    _zekatResult =
                        "Zekata tabi net varlığınız bulunmamaktadır.";
                  } else if (totalWealth < nisapLimit) {
                    _zekatResult =
                        "Toplam varlığınız (${totalWealth.toStringAsFixed(0)} TL), nisap sınırı olan ${nisapLimit.toStringAsFixed(0)} TL altındadır. Zekat düşmemektedir.";
                  } else {
                    final zekat = totalWealth / 40.0;
                    _zekatResult =
                        "Toplam Varlık: ${totalWealth.toStringAsFixed(0)} TL\n\nÖdemeniz Gereken Zekat (%2.5):\n${zekat.toStringAsFixed(0)} TL";
                  }
                });
              },
              child: const Text(
                "Zekat Hesapla",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_zekatResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF27A770).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _zekatResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E5E43),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 19. Sahabe Hayatları
  Widget _buildSahabeHayatlari() {
    final filtered = SAHABE_HAYATLARI.where((item) {
      final name = _normalize(item['ad'].toString());
      final summary = _normalize(item['ozet'].toString());
      final query = _normalize(_sahabeSearchQuery);
      return name.contains(query) || summary.contains(query);
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Sahabe ara...",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF27A770)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            setState(() {
              _sahabeSearchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['ad'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E5E43),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['unvan'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFFB8860B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        item['ozet'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 20. İslam Tarihi
  Widget _buildIslamTarihi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "İslam Tarihi Önemli Dönemeçleri",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: ISLAM_TARIHI.length,
            itemBuilder: (context, index) {
              final item = ISLAM_TARIHI[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF27A770),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < ISLAM_TARIHI.length - 1)
                        Container(
                          width: 2,
                          height: 70,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item['yil']} - ${item['olay']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E5E43),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['detay'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // 21. Namaz Kılma Rehberi
  Widget _buildNamazKilma() {
    final List<dynamic> steps =
        NAMAZ_KILMA_REHBERI[_namazKilmaErkek ? 'erkek' : 'kadin'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text("Erkek"),
              selected: _namazKilmaErkek,
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = true;
                });
              },
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text("Kadın"),
              selected: !_namazKilmaErkek,
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = false;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF27A770),
                        foregroundColor: Colors.white,
                        child: Text("${index + 1}"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['ad'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E5E43),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['aciklama'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 22. Vitir Namazı
  Widget _buildVitirNamazi() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vitir Namazı Nedir?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E5E43),
                    ),
                  ),
                  const Divider(height: 16),
                  Text(
                    VITIR_NAMAZI['aciklama'] ?? '',
                    style: const TextStyle(fontSize: 13, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildKunutCard("Kunut Duası - 1", VITIR_NAMAZI['kunut1']),
          const SizedBox(height: 16),
          _buildKunutCard("Kunut Duası - 2", VITIR_NAMAZI['kunut2']),
        ],
      ),
    );
  }

  Widget _buildKunutCard(String title, Map<String, dynamic> kunut) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E5E43),
              ),
            ),
            const Divider(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                kunut['arapca'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Traditional Arabic',
                  fontSize: 18,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27A770),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kunut['okunus'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              "Meali: ${kunut['anlam']}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Content Helpers
  Widget _buildInfoSection(String title, String subtitle, String content) {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E5E43),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Divider(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRehberi(String title, List<Map<String, String>> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF27A770),
                        foregroundColor: Colors.white,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (step['baslik'] != null &&
                                step['baslik']!.isNotEmpty)
                              Text(
                                step['baslik']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E5E43),
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              step['icerik']!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.35,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E5E43),
                ),
              ),
              const Divider(height: 16),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          color: Color(0xFF27A770),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDuaCard(
    String name,
    String arabic,
    String okunus,
    String meal,
  ) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E5E43),
              ),
            ),
            const Divider(height: 12),
            if (arabic.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  arabic,
                  style: const TextStyle(
                    fontFamily: 'Traditional Arabic',
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27A770),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (okunus.isNotEmpty) ...[
              Text(
                "Okunuşu: $okunus",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              "Meali: $meal",
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 23. Abdest Rehberi
  Widget _buildAbdestRehberi() {
    return _buildStepRehberi("Abdest Nasıl Alınır?", [
      {
        "baslik": "Niyet ve Besmele",
        "icerik":
            "Niyet ettim Allah rızası için abdest almaya denilerek Euzü-Besmele çekilir, eller bileklere kadar 3 defa yıkanır.",
      },
      {
        "baslik": "Ağıza Su Vermek (Mazmaza)",
        "icerik":
            "Sağ el ile ağıza 3 defa su verilerek ağız içi iyice çalkalanır ve temizlenir.",
      },
      {
        "baslik": "Burna Su Vermek (İstinsak)",
        "icerik":
            "Sağ el ile buruna 3 defa su çekilir, sol el ile burun sümkürülerek temizlenir.",
      },
      {
        "baslik": "Yüzü Yıkamak",
        "icerik":
            "Alın saç bitiminden çene altına ve kulak yumuşaklarına kadar tüm yüz 3 defa yıkanır.",
      },
      {
        "baslik": "Kolları Yıkamak",
        "icerik":
            "Önce sağ kol, sonra sol kol dirseklerle beraber 3 defa yıkanır. Kuru yer kalmamasına dikkat edilir.",
      },
      {
        "baslik": "Başı Meshetmek",
        "icerik":
            "Sağ el ıslatılarak başın en az dörtte biri (üst kısmı) bir defa meshedilir.",
      },
      {
        "baslik": "Kulakları Meshetmek",
        "icerik":
            "Eller tekrar ıslatılarak serçe parmaklarla kulak içi, baş parmaklarla kulak arkası meshedilir.",
      },
      {
        "baslik": "Boynu Meshetmek",
        "icerik":
            "Ellerin kalan üçer parmağının dış kısımlarıyla boynun arkası meshedilir, boğaz kısmı meshedilmez.",
      },
      {
        "baslik": "Ayakları Yıkamak",
        "icerik":
            "Önce sağ ayak, sonra sol ayak parmak aralarından başlanarak topuklarla beraber 3 defa yıkanır.",
      },
    ]);
  }

  // 24. Gusül Rehberi
  Widget _buildGusulRehberi() {
    return _buildStepRehberi("Gusül Abdesti Nasıl Alınır?", [
      {
        "baslik": "Niyet ve Beden Temizliği",
        "icerik":
            "Niyet ettim Allah rızası için gusül abdesti almaya diyerek niyet edilir. Beden üzerindeki necaset ve kirler yıkanır.",
      },
      {
        "baslik": "Namaz Abdesti Almak",
        "icerik":
            "Gusle başlarken normal namaz abdesti gibi abdest alınır, ağız ve burun temizliği daha bol suyla yapılır.",
      },
      {
        "baslik": "Ağza Bolca Su Vermek (Farz)",
        "icerik":
            "Ağza 3 kere bolca su alınarak boğaza kadar çalkalanır (Gargara yapılır, oruçlu değilken).",
      },
      {
        "baslik": "Burna Bolca Su Vermek (Farz)",
        "icerik": "Buruna 3 kere genize kadar bolca su çekilir ve temizlenir.",
      },
      {
        "baslik": "Tüm Bedenin Yıkanması (Farz)",
        "icerik":
            "Önce başa, sonra sağ omuza ve sol omuza üçer defa su dökülerek tüm vücut iğne ucu kadar kuru yer kalmayacak şekilde yıkanır.",
      },
    ]);
  }

  // 25. Teyemmüm Rehberi
  Widget _buildTeyemmumRehberi() {
    return _buildStepRehberi("Teyemmüm Nasıl Yapılır?", [
      {
        "baslik": "Niyet Etmek",
        "icerik":
            "Su bulunmadığında veya kullanılamayacak durumda olduğunda temiz toprağa niyet edilerek yönelinir: Niyet ettim Allah rızası için teyemmüm abdesti almaya.",
      },
      {
        "baslik": "Yüzü Meshetmek",
        "icerik":
            "Eller temiz toprağa veya toprak cinsinden bir şeye vurulur, silkelenir ve tüm yüz bir defa meshedilir.",
      },
      {
        "baslik": "Kolları Meshetmek",
        "icerik":
            "Eller tekrar toprağa vurulur, sol elin içiyle sağ kol dirseğe kadar; sağ elin içiyle de sol kol dirseğe kadar meshedilir.",
      },
    ]);
  }

  // 26. Cuma Namazı
  Widget _buildCumaNamazi() {
    return _buildInfoSection(
      "Cuma Namazı Kılınışı",
      "Farz-ı Ayn olan haftalık ibadet",
      "Cuma namazı, Cuma günü öğle vaktinde cemaatle kılınan ve hür, mukim, erkek Müslümanlara farz olan 10 rekatlık bir namazdır.\n\n"
          "Kılınış Sırası:\n"
          "1. İlk Sünnet: 4 Rekat (Öğle namazının ilk sünneti gibi kılınır)\n"
          "2. Hutbe Dinleme: İmam minbere çıkarak hutbe okur. Hutbe esnasında konuşulmaz ve namaz kılınmaz.\n"
          "3. Farz Namazı: Cemaatle imam eşliğinde kılınan 2 rekatlık farz namazıdır.\n"
          "4. Son Sünnet: 4 Rekat (Öğle namazının son sünneti gibi tek başına kılınır)\n\n"
          "Cuma günü cemaate yetişmek ve hutbeyi dinlemek çok büyük sevaptır.",
    );
  }

  // 27. Teravih Namazı
  Widget _buildTeravihNamazi() {
    return _buildInfoSection(
      "Teravih Namazı",
      "Ramazan ayının gecelerini süsleyen sünnet",
      "Teravih namazı, Ramazan ayına mahsus, yatsı namazından sonra ve vitirden önce kılınan müekked bir sünnettir. Toplam 20 rekat kılınır.\n\n"
          "Önemli Bilgiler:\n"
          "• Genellikle 2'şer veya 4'er rekat halinde cemaatle ya da bireysel kılınabilir.\n"
          "• Dörder kılınırken ikinci rekatta oturulduğunda Salli-Barik duaları okunur, üçüncü rekata kalkıldığında Sübhaneke okunur.\n"
          "• Her selam verildikten sonra salavat-ı şerife getirmek sünnettir.\n"
          "• Peygamberimiz (s.a.v.) 'Kim inanarak ve sevabını Allah'tan umarak teravih namazını kılarsa geçmiş günahları bağışlanır' buyurmuştur.",
    );
  }

  // 28. Bayram Namazı
  Widget _buildBayramNamazi() {
    return _buildInfoSection(
      "Bayram Namazı Nasıl Kılınır?",
      "Ramazan ve Kurban bayramlarında vacip namaz",
      "Yılda iki kez, bayram sabahları güneşin doğuşundan 45-50 dakika sonra kılınan 2 rekatlık cemaatle kılınması vacip bir namazdır. Rükudan önce fazladan alınan 6 tekbir (Zait Tekbirler) ile kılınır.\n\n"
          "1. Rekat Kılınışı:\n"
          "• Niyet edilir: 'Niyet ettim Allah rızası için Bayram namazını kılmaya, uydum hazır olan imama'.\n"
          "• Sübhaneke okunduktan sonra imamla birlikte eller kulaklara götürülerek 3 defa tekbir alınır. İlk iki tekbirde eller yana salınır, üçüncü tekbirde göbek altında bağlanır.\n"
          "• İmam Fatiha ve sure okur, rüku ve secdeye gidilir.\n\n"
          "2. Rekat Kılınışı:\n"
          "• İmam Fatiha ve sure okur. Ardından rükuya gitmeden önce eller kulaklara götürülerek 3 defa tekbir alınır ve eller yana salınır. Dördüncü tekbirde ise rükuya gidilir.\n"
          "• Secdelerden sonra oturulur, dualar okunup selam verilir. Namazdan sonra minbere çıkan imam bayram hutbesini okur.",
    );
  }

  // 29. Cenaze Namazı
  Widget _buildCenazeNamazi() {
    return _buildInfoSection(
      "Cenaze Namazı Rehberi",
      "Vefat eden din kardeşi için son görev (Farz-ı Kifaye)",
      "Cenaze namazı, rükusu ve secdesi olmayan, ayakta kılınan bir duadır. Cemaat halinde kılınması farz-ı kifayedir. Dört tekbir ile eda edilir:\n\n"
          "1. Tekbir (İftitah): Niyet edilir ('Niyet ettim Allah rızası için cenaze namazı kılmaya, er/hatun kişi için duaya, uydum hazır olan imama') ve eller bağlanarak Sübhaneke (ve celle senaük ilavesiyle) okunur.\n"
          "2. Tekbir: Eller kaldırılmadan tekbir alınır ve salli-barik duaları okunur.\n"
          "3. Tekbir: Tekbir alınır ve Cenaze Duası (bilinmiyorsa Kunut duaları veya Rabbena duaları) okunur.\n"
          "4. Tekbir: Tekbir alınır ve eller yana salınarak önce sağa sonra sola selam verilir.",
    );
  }

  // 30. Teheccüd Namazı
  Widget _buildTeheccudNamazi() {
    return _buildInfoSection(
      "Teheccüd Namazı",
      "Gece uykuyu bölüp kılınan en faziletli nafile",
      "Teheccüd namazı, yatsı namazından sonra bir miktar uyunup gece yarısından sonra veya imsak vaktinden önce uyanılarak kılınan çok faziletli nafile bir ibadettir.\n\n"
          "Fazileti ve Kılınışı:\n"
          "• Genellikle ikişer rekat halinde kılınması tavsiye edilir. Toplam 2 rekat kılınabileceği gibi 8 veya 12 rekata kadar da kılınabilir.\n"
          "• Peygamber Efendimiz (s.a.v.) farz namazlardan sonra en faziletli namazın gece namazı olduğunu belirtmiştir.\n"
          "• Rabbimiz İsra suresinde: 'Gecenin bir kısmında uyanıp sana mahsus bir nafile namaz kıl. Umulur ki Rabbin seni övgüye değer bir makama ulaştırır' buyurmuştur.",
    );
  }

  // 31. Duha Namazı
  Widget _buildDuhaNamazi() {
    return _buildInfoSection(
      "Duha (Kuşluk) Namazı",
      "Günün ilk saatlerinde şükür namazı",
      "Güneş doğduktan yaklaşık 45-50 dakika sonra (kerahet vakti çıktıktan sonra) başlayıp, öğle ezanına yaklaşık 45 dakika kalana kadar (kerahet vakti girene kadar) kılınan nafile bir namazdır.\n\n"
          "Kılınışı:\n"
          "• 2, 4, 8 veya 12 rekat kılınabilir. İkişer rekatta bir selam verilmesi daha uygundur.\n"
          "• Peygamberimiz (s.a.v.): 'Her birinizin her bir eklemi için günde bir sadaka vermesi gerekir. Kuşluk vaktinde kılınacak iki rekat namaz bunların yerini tutar' buyurmuştur.",
    );
  }

  // 32. Evvabin Namazı
  Widget _buildEvvabinNamazi() {
    return _buildInfoSection(
      "Evvabin Namazı",
      "Tövbe edenlerin ve Allah'a yönelenlerin namazı",
      "Evvabin namazı, akşam namazı kılındıktan sonra yatsı namazı vakti girene kadar kılınan 6 rekatlık bir nafile namazdır.\n\n"
          "Kılınışı ve Fazileti:\n"
          "• İkişer rekat halinde veya tek bir selamla 6 rekat olarak kılınabilir.\n"
          "• Peygamberimiz (s.a.v.) şöyle buyurmuştur: 'Kim akşam namazından sonra aralarında kötü bir şey konuşmaksızın altı rekat namaz kılarsa, bu namaz kendisi için on iki senelik ibadete denk kılınır.'",
    );
  }

  // 33. Hacet Namazı
  Widget _buildHacetNamazi() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoSection(
            "Hacet Namazı Kılınışı",
            "Maddi ve manevi isteklerin kabulü için",
            "Dünyevi veya uhrevi bir hacetinin, bir dileğinin gerçekleşmesini isteyen kişinin yatsı namazından sonra kıldığı 2 veya 4 rekatlık nafile namazdır.\n\n"
                "Kılınışı:\n"
                "• İlk rekatta Sübhaneke, Fatiha ve 3 Ayetel Kürsi okunur.\n"
                "• Diğer rekatlarda Fatiha'dan sonra İhlas, Felak ve Nas sureleri okunur.\n"
                "• Namaz bittikten sonra Allah'a hamd edilir, Peygamberimize salavat getirilir ve ardından Hacet Duası okunur.",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Hacet Duası",
            "لَا إِلٰهَ إِلَّا اللهُ الْحَلِيمُ الْكَرِيمُ سُبْحَانَ اللهِ رَبِّ الْعَرْشِ الْعَظِيمِ الْحَمْدُ للهِ رَبِّ الْعَالَمِينَ",
            "La ilahe illallahül halimül kerim. Sübhanallahü Rabbil arşil azim. Elhamdülillahi Rabbil alemin. Es'elüke mucibati rahmetike ve azaime mağfiretike vel ganimete min külli birrin vesselamete min külli ismin la tede' li zenben illa ğafertehu vela hemmen illa ferrectehu vela haceten hiye leke rıdan illa kadayteha ya erhamer rahimin.",
            "Halim ve Kerim olan Allah'tan başka ilah yoktur. Arş-ı Azim'in Rabbi olan Allah'ı noksan sıfatlardan tenzih ederim. Hamd alemlerin Rabbi Allah'a mahsustur. Ey Rabbim! Rahmetinin vesilelerini, bağışlamanın azametini, her türlü iyiliğe ulaşmayı ve her türlü günahtan esen kalmayı senden dilerim. Benim için bağışlamadığın hiçbir günah, feraha kavuşturmadığın hiçbir sıkıntı ve senin rızana uygun olup da yerine getirmediğin hiçbir ihtiyaç bırakma, ey merhametlilerin en merhametlisi!",
          ),
        ],
      ),
    );
  }

  // 34. İstihare Namazı
  Widget _buildIstihareNamazi() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoSection(
            "İstihare Namazı",
            "Hayırlı olanı Allah'tan isteme namazı",
            "Bir işe teşebbüs ederken o işin kendisi hakkında hayırlı olup olmadığını anlamak üzere kılınan 2 rekatlık nafile namazdır.\n\n"
                "Uygulanışı:\n"
                "• Niyet edilir: 'Niyet ettim Allah rızası için 2 rekat İstihare namazı kılmaya'.\n"
                "• 1. rekatta Fatiha ve Kafirun, 2. rekatta Fatiha ve İhlas suresi okunur.\n"
                "• Namaz sonrasında İstihare Duası okunur. Ardından abdestli olarak, kıbleye yönelerek yatılır. Rüyada beyaz veya yeşil görmek hayra, siyah veya kırmızı görmek şerre yorulur.",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "İstihare Duası",
            "اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقDIRُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ",
            "Allahümme inni estehiruke bi-ilmike ve estakdiruke bi-kudretike ve es'elüke min fadlikel azim. Feinneke takdiru vela akdiru ve ta'lemü vela a'lemü ve ente allamül guyub...",
            "Allah'ım! Senin ilminle senden hayır diliyorum, senin gücünle senden güç istiyorum ve senin büyük lütfundan istiyorum. Çünkü senin gücün yeter, benim yetmez; sen bilirsin, ben bilmem; sen gizlileri en iyi bilensin. Allah'ım! Eğer bu işin benim dinim, dünyam ve ahiretim için hayırlı olduğunu biliyorsan bunu bana takdir et, kolaylaştır ve mübarek eyle...",
          ),
        ],
      ),
    );
  }

  // 35. Sehiv Secdesi
  Widget _buildSehivSecdesi() {
    return _buildInfoSection(
      "Sehiv Secdesi (Yanılma Secdesi)",
      "Namazdaki eksiklikleri telafi etme secdesi",
      "Namazda unutarak vaciplerden birinin terk edilmesi veya geciktirilmesi, ya da farzlardan birinin geciktirilmesi durumlarında, namazın sonunda yapılan iki secdeye sehiv secdesi denir.\n\n"
          "Nasıl Yapılır?\n"
          "1. Namazın son rekatında Ettahiyyatü duası okunur.\n"
          "2. Sağa doğru selam verilir (bazı görüşlere göre iki tarafa da selam verilebilir).\n"
          "3. Selamdan hemen sonra tekbir getirilerek secdeye gidilir. Secdede 3 kez 'Sübhane Rabbiyel Ala' denir. Baş kaldırılıp oturulur, sonra ikinci kez secdeye gidilir.\n"
          "4. Secdeden kalkılarak oturulur. Ettahiyyatü, Salli, Barik ve Rabbena duaları okunarak her iki tarafa da selam verilerek namaz tamamlandır.",
    );
  }

  // 36. Tilavet Secdesi
  Widget _buildTilavetSecdesi() {
    return Column(
      children: [
        Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tilavet Secdesi Nedir?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E5E43),
                  ),
                ),
                Divider(height: 16),
                Text(
                  "Kuran-ı Kerim'de geçen 14 secde ayetinden birini okuyan veya işiten her mükellef Müslümanın yapması vacip olan bir secdedir.\n\n"
                  "Nasıl Yapılır?\n"
                  "• Abdestli bir şekilde kıbleye yönelerek ayakta durulur.\n"
                  "• Niyet edilir: 'Niyet ettim Allah rızası için tilavet secdesi yapmaya'.\n"
                  "• Eller kaldırılmaksızın doğrudan 'Allahu Ekber' diyerek secdeye varılır.\n"
                  "• Secdede 3 defa 'Sübhane Rabbiyel Ala' denir.\n"
                  "• Tekrar 'Allahu Ekber' denilerek ayağa kalkılır. Ayağa kalkarken 'Gufraneke Rabbena ve ileykel masir' denmesi sünnettir.",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildListSection("Kuran-ı Kerim'deki Secde Ayetleri", [
            "A'raf Suresi 206. Ayet",
            "Ra'd Suresi 15. Ayet",
            "Nahl Suresi 49. Ayet",
            "İsra Suresi 107. Ayet",
            "Meryem Suresi 58. Ayet",
            "Hac Suresi 18. Ayet",
            "Furkan Suresi 60. Ayet",
            "Neml Suresi 25. Ayet",
            "Secde Suresi 15. Ayet",
            "Sad Suresi 24. Ayet",
            "Fussilet Suresi 37. Ayet",
            "Necm Suresi 62. Ayet",
            "İnşikak Suresi 21. Ayet",
            "Alak Suresi 19. Ayet",
          ]),
        ),
      ],
    );
  }

  // 37. Kaza Namazı Tracker
  Widget _buildKazaNamazi() {
    final Map<String, int> kazalar = {
      'Sabah': _kazaSabah,
      'Öğle': _kazaOgle,
      'İkindi': _kazaIkindi,
      'Akşam': _kazaAksam,
      'Yatsı': _kazaYatsi,
      'Vitir': _kazaVitir,
    };

    final Map<String, String> keys = {
      'Sabah': 'kaza_sabah',
      'Öğle': 'kaza_ogle',
      'İkindi': 'kaza_ikindi',
      'Akşam': 'kaza_aksam',
      'Yatsı': 'kaza_yatsi',
      'Vitir': 'kaza_vitir',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kaza Namazı Takip Çizelgesi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Geçmiş namaz borçlarınızı kaydetmek ve düzenlemek için +/- butonlarını kullanın.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: kazalar.keys.map((name) {
              final count = kazalar[name] ?? 0;
              final key = keys[name]!;
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E5E43),
                            ),
                          ),
                          Text(
                            "Toplam Kaza Borcu: $count",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[755],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            onPressed: () => _updateKaza(key, -1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27A770).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E5E43),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF27A770),
                              size: 28,
                            ),
                            onPressed: () => _updateKaza(key, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 38. Sabah Ezkarı
  Widget _buildSabahEzkari() {
    final List<Map<String, dynamic>> ezkar = [
      {
        "dua": "Ayetel Kürsi",
        "arapca": "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱlْحَىُّ ٱlْقَيُّومُ",
        "anlam": "Evden çıkarken, sabah ve akşam korunmak için okunur.",
        "hedef": 1,
      },
      {
        "dua": "İhlas, Felak, Nas sureleri",
        "arapca": "قُلْ هُوَ ٱlلَّهُ أَحَدٌ ...",
        "anlam": "Her türlü şerden, büyüden ve nazardan korunmak için okunur.",
        "hedef": 3,
      },
      {
        "dua": "Bismillahillezi La Yedurru",
        "arapca": "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ",
        "anlam":
            "İsmiyle yerde ve gökte hiçbir şeyin zarar veremeyeceği Allah'ın adıyla.",
        "hedef": 3,
      },
      {
        "dua": "Sübhanallahi ve Bihamdihi",
        "arapca": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
        "anlam":
            "Allah'ı noksan sıfatlardan tenzih eder, O'na hamd ederim. Günahları siler.",
        "hedef": 100,
      },
      {
        "dua": "Seyyidül İstiğfar",
        "arapca":
            "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي",
        "anlam":
            "En büyük tövbe duasıdır. Sabah okuyan akşama kadar cennetlik olur.",
        "hedef": 1,
      },
    ];

    return _buildEzkarInteractive(
      "Sabah Zikirleri ve Duaları",
      ezkar,
      _sabahEzkarCounts,
    );
  }

  // 39. Akşam Ezkarı
  Widget _buildAksamEzkari() {
    final List<Map<String, dynamic>> ezkar = [
      {
        "dua": "Amenerrasulü",
        "arapca": "آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ",
        "anlam": "Gece okuyana her türlü musibetten korunmak için kafi gelir.",
        "hedef": 1,
      },
      {
        "dua": "Hasbiyallahü la ilahe illa hu",
        "arapca": "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ",
        "anlam":
            "Allah bana kafidir, O'ndan başka ilah yoktur. Dünya ve ahiret işlerine kafi gelir.",
        "hedef": 7,
      },
      {
        "dua": "Euzü bikelimatillahittammati",
        "arapca": "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ",
        "anlam":
            "Yarattığı şeylerin şerrinden Allah'ın kusursuz kelimelerine sığınırım.",
        "hedef": 3,
      },
      {
        "dua": "Estağfirullah el-Azim",
        "arapca": "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ",
        "anlam": "Bağışlanma ve tövbe dilemek için okunur.",
        "hedef": 100,
      },
      {
        "dua": "Salavat-ı Şerife",
        "arapca": "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ",
        "anlam": "Peygamber Efendimize salat ve selam getirmek.",
        "hedef": 100,
      },
    ];

    return _buildEzkarInteractive(
      "Akşam Zikirleri ve Duaları",
      ezkar,
      _aksamEzkarCounts,
    );
  }

  Widget _buildEzkar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ezkarTab == 0 ? const Color(0xFF27A770) : Colors.white,
                  foregroundColor: _ezkarTab == 0 ? Colors.white : const Color(0xFF1E5E43),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => setState(() => _ezkarTab = 0),
                child: const Text("Sabah Zikirleri"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ezkarTab == 1 ? const Color(0xFF27A770) : Colors.white,
                  foregroundColor: _ezkarTab == 1 ? Colors.white : const Color(0xFF1E5E43),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => setState(() => _ezkarTab = 1),
                child: const Text("Akşam Zikirleri"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _ezkarTab == 0 ? _buildSabahEzkari() : _buildAksamEzkari(),
        ),
      ],
    );
  }

  Widget _buildEzkarInteractive(
    String title,
    List<Map<String, dynamic>> ezkar,
    List<int> countList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Kartların üzerine dokunarak zikirlerinizi çekebilirsiniz.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: ezkar.length,
            itemBuilder: (context, index) {
              final zikir = ezkar[index];
              final String name = zikir['dua'] ?? '';
              final String arapca = zikir['arapca'] ?? '';
              final String anlam = zikir['anlam'] ?? '';
              final int hedef = zikir['hedef'] ?? 33;
              final currentCount = countList[index];

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (_zikirSoundEnabled) {
                      SystemSound.play(SystemSoundType.click);
                    }
                    setState(() {
                      if (countList[index] < hedef) {
                        countList[index]++;
                      } else {
                        countList[index] = 0;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("'$name' zikrini tamamladınız!"),
                            backgroundColor: const Color(0xFF27A770),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E5E43),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: currentCount >= hedef
                                    ? const Color(0xFF27A770)
                                    : const Color(0xFF27A770).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$currentCount / $hedef",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: currentCount >= hedef
                                      ? Colors.white
                                      : const Color(0xFF1E5E43),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            arapca,
                            style: const TextStyle(
                              fontFamily: 'Traditional Arabic',
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27A770),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          anlam,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 40. Yemek Duası
  Widget _buildYemekDuasi() {
    return _buildSimpleDuaCard(
      "Sofra / Yemek Duası",
      "الْحَمْدُ للهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
      "Elhamdülillahillezi et'amena ve sekana ve cealena minel müslimin.",
      "Bizleri yediren, içiren ve Müslümanlardan kılan Allah'a hamd olsun.",
    );
  }

  // 41. Şifa Duası
  Widget _buildSifaDuasi() {
    return _buildSimpleDuaCard(
      "Şifa Duası (Peygamberimizin Hastalara Okuduğu Dua)",
      "أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ اشْفِ وَأَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا",
      "Ezhibil-be'se Rabben-nasişfi ve enteş-Şafi la şifae illa şifaüke şifaen la yugadiru sekama.",
      "Sıkıntıyı gider ey insanların Rabbi! Şifa ver, çünkü şifa veren sensin. Senin şifandan başka şifa yoktur. Öyle bir şifa ver ki, hiçbir hastalık bırakmasın.",
    );
  }

  // 42. Koruyucu Dualar
  Widget _buildKoruyucuDualar() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSimpleDuaCard(
            "Ayetel Kürsi",
            "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُ—ُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ",
            "Allâhü lâ ilâhe illâ hüvel hayyül kayyûm, lâ te'huzühû sinetün velâ nevm...",
            "Allah kendisinden başka hiçbir ilah olmayandır. Diridir, kayyumdur. O'nu ne bir uyuklama tutar, ne de bir uyku. Göklerdeki her şey, yerdeki her şey O'nundur...",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Felak Suresi",
            "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِنْ شَرِّ مَا خَلَقَ",
            "Kul eûzü birabbil felak. Min şerri mâ halak...",
            "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyenlerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden sabahın Rabbine sığınırım.",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Nas Suresi",
            "قُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَهِ النَّاسِ",
            "Kul eûzü birabbin nâs. Melikin nâs. İlâhin nâs...",
            "De ki: İnsanların Rabbine, insanların malikine, insanların ilahına sığınırım; sinsi vesvesecinin şerrinden ki o, insanların göğüslerine vesvese verir, gerek cinden gerekse insandan.",
          ),
        ],
      ),
    );
  }

  // 43. Sıkıntı ve Borç Duası
  Widget _buildSikintiBorcDuasi() {
    return _buildSimpleDuaCard(
      "Sıkıntı ve Borçtan Kurtulma Duası",
      "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ",
      "Allahümme inni euzü bike minel-hemmi vel-hazen, vel-aczi vel-kesel, vel-buhli vel-cübn, ve dalei'd-deyni ve galebeti'r-rical.",
      "Allah'ım! Gam ve kederden, acizlik ve tembellikten, cimrilik ve korkaklıktan, borcun belimi bükmesinden ve insanların bana galebe çalmasından sana sığınırım.",
    );
  }

  // 44. Rabbena Duaları
  Widget _buildRabbenaDualar() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSimpleDuaCard(
            "Rabbena Atina",
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            "Rabbena atina fiddünya haseneten ve fil ahireti haseneten ve kına azabennar.",
            "Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver. Bizi cehennem azabından koru.",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Rabbenağfirli",
            "رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
            "Rabbenağfirli velivalideyye velil mü'minine yevme yekumül hisab.",
            "Rabbimiz! Hesabın görüleceği gün beni, anne-babamı ve bütün müminleri bağışla.",
          ),
        ],
      ),
    );
  }

  // 45. Hac ve Umre Rehberi
  Widget _buildHacUmre() {
    return _buildStepRehberi("Adım Adım Hac ve Umre", [
      {
        "baslik": "İhrama Girmek",
        "icerik":
            "Mikat sınırında niyet edilerek ihram kıyafetleri giyilir ve iki rekat ihram namazı kılınarak Telbiye getirilir.",
      },
      {
        "baslik": "Kabe'yi Tavaf Etmek",
        "icerik":
            "Hacerül Esved hizasından başlanarak Kabe etrafında dualarla 7 defa dönülür (1 Tavaf tamamlanır).",
      },
      {
        "baslik": "Safa ve Merve Arasında Sa'y",
        "icerik":
            "Safa tepesinden başlanıp Merve tepesine 4 gidiş ve Merve'den Safa'ya 3 dönüş olmak üzere 7 şavt yürünür.",
      },
      {
        "baslik": "Arafat Vakfesi (Hac Farzı)",
        "icerik":
            "Arife günü Arafat tepesinde öğle ile gün batımı arasında bir müddet durulur ve dualar edilir.",
      },
      {
        "baslik": "Müzdelife ve Mina (Hac Farzı)",
        "icerik":
            "Şeytan taşlamak için taş toplanır, Mina'da kurban kesilir ve şeytan taşlanır.",
      },
      {
        "baslik": "Saç Traşı ve İhramdan Çıkış",
        "icerik":
            "Saçlar tamamen kesilir veya kısaltılır. Böylece ihram yasakları son bulur.",
      },
    ]);
  }

  // 46. Kurban Rehberi
  Widget _buildKurbanRehberi() {
    return _buildListSection("Kurban İbadeti Kuralları", [
      "Kurban kesmek, akıl sağlığı yerinde, hür ve dinen zenginlik nisabına (80.18 gram altın değerine) malik her Müslümana vaciptir.",
      "Kurban edilecek hayvanlar; koyun, keçi (en az 1 yaşını doldurmuş), sığır ve manda (en az 2 yaşını doldurmuş) veya deve (en az 5 yaşını doldurmuş) olmalıdır.",
      "Hayvanın kurban edilmesine engel olacak derecede kör, topal, çok zayıf veya hasta olmaması gerekir.",
      "Kurban kesim vakti, Bayram namazı kılındıktan sonra başlar ve bayramın üçüncü günü güneş batana kadar devam eder.",
      "Kurban eti genel olarak üç kısma ayrılır: Bir kısmı ev halkı için ayrılır, bir kısmı akraba ve komşulara ikram edilir, kalan kısmı ise yoksullara dağıtılır.",
    ]);
  }

  // 47. Sadaka Bilgileri
  Widget _buildSadakaBilgileri() {
    return _buildListSection("Sadakanın Faziletleri ve Çeşitleri", [
      "Sadaka, sadece maddi yardım demek değildir. Din kardeşine tebessüm etmek, yol göstermek, yoldaki eziyet veren bir taşı kaldırmak da sadakadır.",
      "Fıtır Sadakası (Fitre): Ramazan ayında cemaatle yardımlaşmak ve bayrama kavuşmanın şükrü olarak yoksullara verilen vacip sadakadır.",
      "Sadaka-i Cariye: İnsanların sürekli istifade edeceği okul, cami, çeşme gibi kalıcı eserler bırakmaktır. Kişi ölse bile sevabı devam eder.",
      "Sadaka belaları defeder, ömrü bereketlendirir ve rızkın artmasına vesile olur.",
    ]);
  }

  // 48. İslam'ın Şartları
  Widget _buildIslaminSartlari() {
    return _buildListSection("İslam'ın 5 Temel Şartı", [
      "1. Kelime-i Şehadet Getirmek: 'Eşhedü en lâ ilâhe illallah ve eşhedü enne Muhammeden abdühû ve resûlüh' diyerek Allah'ın birliğini ve Hz. Muhammed'in O'nun elçisi olduğunu kalben onaylayıp dil ile ikrar etmek.",
      "2. Namaz Kılmak: Günde 5 vakit namazı vaktinde ve şartlarına uygun olarak kılmak.",
      "3. Zekat Vermek: Dinen zengin sayılan kişilerin yılda bir kez mallarının %2.5'ini yoksul Müslümanlara vermesi.",
      "4. Oruç Tutmak: Ramazan ayında imsak vaktinden akşam vaktine kadar ibadet niyetiyle yemekten, içmekten ve nefsani arzulardan uzak durmak.",
      "5. Hacca Gitmek: Maddi ve fiziki durumu yeten Müslümanların ömründe bir kez Mekke'deki Kabe'yi ve kutsal mekanları ziyaret etmesi.",
    ]);
  }

  // 49. İmanın Şartları
  Widget _buildImaninSartlari() {
    return _buildListSection("İmanın 6 Temel Şartı", [
      "1. Allah'ın Varlığına ve Birliğine İnanmak: Allah'ın eşi, benzeri ve ortağı olmadığına, her şeyi O'nun yarattığına inanmak.",
      "2. Allah's Meleklerine İnanmak: Nurdan yaratılmış, günahsız ve gözle görülmeyen nurani varlıkların varlığına inanmak.",
      "3. Allah'ın Kitaplarına İnanmak: Allah'ın peygamberlerine gönderdiği ilahi kitaplara (Tevrat, Zebur, İncil ve son kitap Kuran-ı Kerim'e) inanmak.",
      "4. Allah'ın Peygamberlerine İnanmak: İnsanları doğru yola iletmek için seçilen elçilere inanmak (İlk peygamber Hz. Adem, son peygamber Hz. Muhammed'dir).",
      "5. Ahiret Gününe İnanmak: Ölümden sonra dirilerek dünyada yapılanların hesabının verileceğine, cennet ve cehennemin varlığına inanmak.",
      "6. Kader ve Kazaya İnanmak: Hayır ve şer her şeyin Allah'ın takdiri, bilgisi ve yaratmasıyla gerçekleştiğine inanmak.",
    ]);
  }

  // 50. 32 Farz
  Widget _buildFarz32() {
    return _buildListSection("Her Müslümanın Bilmesi Gereken 32 Farz", [
      "İmanın Şartları: 6 Farz",
      "İslam'ın Şartları: 5 Farz",
      "Namazın Dışındaki Farzları (Şartları): 6 Farz\n(Hadesten taharet, Necasetten taharet, Setr-i avret, İstikbal-i kıble, Vakit, Niyet)",
      "Namazın İçindeki Farzları (Rükünleri): 6 Farz\n(İftitah tekbiri, Kıyam, Kıraat, Rüku, Secde, Ka'de-i ahire)",
      "Abdestin Farzları: 4 Farz\n(Yüzü yıkamak, Kolları yıkamak, Başın 1/4'ünü meshetmek, Ayakları yıkamak)",
      "Guslün Farzları: 3 Farz\n(Ağza su vermek, Burna su vermek, Bütün bedeni yıkamak)",
      "Teyemmümün Farzları: 2 Farz\n(Niyet etmek, İki defa elleri toprağa vurup yüzü ve kolları meshetmek)",
    ]);
  }

  // 51. 54 Farz
  Widget _buildFarz54() {
    return _buildListSection("İslam Ahlakının Temeli: 54 Farz", [
      "1. Allah'ı bir bilip zikretmek",
      "2. Helal yemek ve içmek",
      "3. Abdest almak",
      "4. Beş vakit namaz kılmak",
      "5. Cünüplükten gusletmek",
      "6. Rızkın Allah'tan olduğuna inanmak",
      "7. Helalinden temiz elbise giymek",
      "8. Tevekkül etmek (Allah'a güvenmek)",
      "9. Kanaat etmek",
      "10. Nimetlere şükretmek",
      "11. Kaza ve kadere rıza göstermek",
      "12. Belalara sabretmek",
      "13. Günahlardan tövbe etmek",
      "14. İhlasla ibadet etmek",
      "15. Şeytanı düşman bilmek",
      "16. Kuran-ı Kerim'i düstur edinmek",
      "17. Ölüme hazırlanmak",
      "18. İyiliği emredip kötülükten sakındırmak (Emr-i bi'l-ma'rûf)",
      "19. Gıybet etmemek",
      "20. Anne ve babaya itaat etmek",
      "21. Akrabayı ziyaret etmek (Sıla-i rahim)",
      "22. Emanete hıyanet etmemek",
      "23. Kul hakkı yememek ve adil olmak",
    ]);
  }

  // 52. Büyük Günahlar
  Widget _buildBuyukGunahlar() {
    return _buildListSection("İslam'da Büyük Günahlar (Kebair)", [
      "1. Şirk Koşmak: Allah'a ortak koşmak (En büyük günahtır ve tövbe edilmeden affedilmez).",
      "2. Haksız Yere Can Kıymak: Suçsuz bir insanı öldürmek.",
      "3. Sihir ve Büyü Yapmak veya Yaptırmak.",
      "4. Yetim Malı Yemek: Yetimlerin hakkını gasbetmek.",
      "5. Faiz (Riba) Alıp Vermek.",
      "6. Savaştan Kaçmak: Vatan müdafaasını terk etmek.",
      "7. İffetli Kadınlara İftira Atmak: Zina isnadında bulunmak.",
      "8. Anne ve Babaya Asi Olmak.",
      "9. Zina Yapmak ve Gayriahlaki İlişkiler Yaşamak.",
      "10. Yalan Yere Yemin Etmek ve Yalancı Şahitlik Yapmak.",
    ]);
  }

  // 53. Helal ve Haramlar
  Widget _buildHelalHaram() {
    return _buildListSection("Helal ve Haram Sınırları", [
      "Helal: Allah'ın yapılmasını, yenmesini ve kullanılmasını serbest bıraktığı temiz ve faydalı şeylerdir.",
      "Haram: Allah'ın kesin ve bağlayıcı olarak yasakladığı, zararlı ve pis olan şeylerdir.",
      "Yiyeceklerde Haramlar: Domuz eti, leş (ölen hayvan), akıtılmış kan, Allah'tan başkası adına kesilen hayvanlar ve alkollü içecekler.",
      "Kazançta Haramlar: Hırsızlık, gasp, rüşvet, faiz, kumar ve aldatma yoluyla elde edilen gelirler.",
      "Şüpheli Şeyler: Net olarak helal veya haram olduğu bilinmeyen konulardan kaçınmak dinin korunması açısından tavsiye edilmiştir.",
    ]);
  }

  // 54. Aile Ahlakı
  Widget _buildAileAhlaki() {
    return _buildInfoSection(
      "İslam'da Aile Ahlakı",
      "Toplumun temel taşı olan aile yuvası",
      "İslam dini aileye çok büyük bir önem verir. Aile, sevgi, şefkat, merhamet ve adalete dayalı kutsal bir müessesedir.\n\n"
          "Temel İlkeler:\n"
          "• Eşlerin Karşılıklı Saygısı: Peygamberimiz (s.a.v.) 'Sizin en hayırlınız, ailesine karşı en hayırlı olanınızdır' buyurmuştur.\n"
          "• Çocukların Terbiyesi: Anne-babanın evladına verebileceği en güzel miras güzel ahlaktır.\n"
          "• Geçim ve Sorumluluk: Aile reisinin ailenin helal geçimini sağlaması ibadet derecesindedir.\n"
          "• Sabır ve Anlayış: Aile içindeki ufak tefek pürüzleri anlayış, hoşgörü ve istişare ile çözmek esastır.",
    );
  }

  // 55. Ticaret Fıkhı
  Widget _buildTicaretFikhi() {
    return _buildListSection("İslam'da Ticaret ve Kazanç Ahlakı", [
      "Dürüstlük Esastır: Doğru ve dürüst tüccar, ahirette peygamberler, sıddıklar ve şehitlerle beraber olacaktır.",
      "Ölçü ve Tartıda Adalet: Rabbimiz Mutaffifin suresinde ölçü ve tartıda hile yapanları şiddetle uyarmaktadır.",
      "Faiz, Kumar ve Karaborsacılık (İhtikar) Yasaktır: Ürünleri stoklayıp fiyatını suni olarak artırmak haramdır.",
      "Müşteriyi Aldatmamak: Malın kusurunu gizleyerek satmak haramdır. Peygamberimiz 'Bizi aldatan bizden değildir' buyurmuştur.",
      "Borçluya Kolaylık Göstermek: Durumu sıkışık olan borçluya süre tanımak büyük bir sevaptır.",
    ]);
  }

  // 56. Miras Fıkhı
  Widget _buildMirasFikhi() {
    return _buildInfoSection(
      "İslam'da Miras Hukuku (Feraiz)",
      "Adil ve ilahi paylaşım kuralları",
      "İslamiyet'te vefat eden bir kişinin geride bıraktığı mal ve hakların kimlere, ne oranda dağıtılacağı Kuran-ı Kerim'de (Nisa Suresi 11, 12 ve 176. ayetlerinde) bizzat Allah tarafından belirlenmiştir. Buna Feraiz ilmi denir.\n\n"
          "Miras Paylaşımından Önce Yapılması Gerekenler:\n"
          "1. Cenaze Masrafları: Vefat edenin cenaze ve teçhiz masrafları terekesinden karşılanır.\n"
          "2. Borçların Ödenmesi: Vefat edenin kul ve Allah borçları ödenir.\n"
          "3. Vasiyetin Yerine Getirilmesi: Vefat edenin vasiyeti, malının en fazla 1/3'ünü aşmayacak şekilde yerine getirilir.\n"
          "4. Kalan Terekenin Dağıtılması: Kalan mal, mirasçılar (Ashab-ı Feraiz) arasında şer'i ölçülere göre paylaştırılır.",
    );
  }

  // 57. Anne-Baba Hakları
  Widget _buildAnneBabaHaklari() {
    return _buildInfoSection(
      "Anne ve Baba Hakları",
      "Cennetin anahtarı: Ebeveyne iyilik",
      "Kuran-ı Kerim'de Allah'a ibadetten hemen sonra anne ve babaya iyi davranılması emredilmiştir (İsra Suresi 23. ayet).\n\n"
          "Temel Görevlerimiz:\n"
          "• Onlara 'Öf' bile dememek, tatlı dille hitap etmek.\n"
          "• Yaşlandıklarında şefkat kanatlarını germek ve ihtiyaçlarını karşılamak.\n"
          "• Onlar için dua etmek: 'Rabbim! Onlar beni küçükken nasıl sevgiyle yetiştirdilerse, sen de onlara merhamet et'.\n"
          "• Günahı emretmedikleri sürece meşru isteklerine itaat etmek.\n"
          "• Peygamberimiz (s.a.v.) 'Cennet, annelerin ayakları altındadır' buyurmuştur.",
    );
  }

  // 58. Kul Hakkı
  Widget _buildKulHakki() {
    return _buildInfoSection(
      "Kul Hakkı ve Kefareti",
      "Allah'ın affını kulun helalliğine bıraktığı günah",
      "Kul hakkı, bir insanın diğer bir insanın malına, canına, namusuna veya manevi haklarına tecavüz etmesidir. İslam'da en tehlikeli günahlardan biridir.\n\n"
          "Bilmeniz Gerekenler:\n"
          "• Allah Teala kul hakkı dışındaki günahları dilerse affeder, fakat kul hakkını hak sahibi helal etmedikçe bağışlamaz.\n"
          "• Kul hakkının kefareti; öncelikle haksızlığı gidermek (çalınan malı geri vermek vb.), hak sahibinden bizzat helallik istemek ve tövbe etmektir.\n"
          "• Eğer hak sahibi vefat etmişse veya ulaşılamıyorsa, onun adına hayırlar yapmak, sadakalar vermek ve onun için dua etmek gerekir.",
    );
  }

  // 59. Komşu Hakları
  Widget _buildKomsuHaklari() {
    return _buildListSection("Komşuluk İlişkileri ve Hakları", [
      "Peygamberimiz (s.a.v.) şöyle buyurmuştur: 'Cebrail bana komşu hakkında o kadar çok tavsiyede bulundu ki, komşuyu komşuya mirasçı kılacak sandım.'",
      "Komşuya zarar vermemek, gürültü yapmamak, onun huzurunu kaçırmamak en temel vazifedir.",
      "Komşusu açken tok yatan bizden değildir ilkesiyle hareket ederek yardıma muhtaç olan komşuya el uzatmak gerekir.",
      "Komşu hastalandığında ziyaret etmek, sevincine ortak olmak, acısını paylaşmak ahlaki bir görevdir.",
      "Evde pişen yemekten veya ikramlardan komşuya da ikram etmek komşuluk bağlarını güçlendirir.",
    ]);
  }

  // 60. Çocuk Eğitimi
  Widget _buildCocukEgitimi() {
    return _buildInfoSection(
      "İslam'da Çocuk Eğitimi",
      "Çocuklarımız: Bize emanet edilen fidanlar",
      "Çocuklar, anne ve babaya Allah'ın birer emanetidir. Onların hem bedensel hem de ruhsal olarak sağlıklı, ahlaklı ve topluma faydalı bireyler olarak yetiştirilmesi ebeveynin görevidir.\n\n"
          "Çocuk Eğitiminde Metotlar:\n"
          "• Güzel Örnek Olmak: Çocuklar söylenenlerden ziyade gördüklerini taklit ederler.\n"
          "• Sevgi ve Şefkat Göstermek: Peygamberimiz çocukları kucaklar, öper ve onlarla şakalaşırdı.\n"
          "• Dini Bilgileri Küçük Yaşta Öğretmek: Abdest, namaz ve Kuran sevgisi tatlılıkla aşılanmalıdır.\n"
          "• Adaletli Davranmak: Çocuklar arasında hiçbir konuda ayrımcılık yapılmamalıdır.",
    );
  }

  // 61. Selamlaşma Adabı
  Widget _buildSelamlasmaAdabi() {
    return _buildListSection("Selamlaşma Kuralları ve Adabı", [
      "Selam vermek sünnet, verilen selamı almak ise farzdır.",
      "Selamlaşma kelimesi: 'Es-selâmü aleyküm' (Selam üzerinize olsun) ve cevabı: 'Ve aleykümü's-selâm' şeklindedir.",
      "Binek üzerinde olan yürüyene, yürüyen oturana, az olan grup çok olan gruba, küçük büyüğe selam verir.",
      "Peygamberimiz (s.a.v.) 'Aranızda selamı yayın ki birbirinizi sevesiniz' buyurmuştur.",
      "Eve girerken ev halkına, bir meclise girerken ve ayrılırken oradakilere selam vermek adabdandır.",
    ]);
  }

  // 62. Misafirlik Adabı
  Widget _buildMisafirlikAdabi() {
    return _buildListSection("Misafir Ağırlama ve Ziyaret Adabı", [
      "Misafire ikram etmek, Allah'a ve ahiret gününe iman etmenin bir gereğidir.",
      "Ziyarete gitmeden önce ev sahibinden izin almak (randevulaşmak) esastır.",
      "Kapı çalındığında kapının tam karşısında durulmamalı, sağında veya solunda beklenmelidir (Mahremiyet açısından).",
      "Ev sahibi misafirine güler yüz göstermeli, temiz ve lezzetli ikramlarda bulunmalıdır.",
      "Misafir de ev sahibini zora sokacak isteklerde bulunmamalı, ikram edilenleri memnuniyetle kabul etmelidir.",
    ]);
  }

  // 63. Üç Aylar Rehberi
  Widget _buildUcAylar() {
    return _buildInfoSection(
      "Mübarek Üç Aylar",
      "Recep, Şaban ve Ramazan ayları",
      "Üç aylar, Hicri takvime göre Recep, Şaban ve Ramazan aylarını kapsayan, manevi bereketin ve ibadetlerin zirveye ulaştığı mübarek bir zaman dilimidir.\n\n"
          "Ayların Faziletleri:\n"
          "• Recep Ayı: Allah'ın ayı olarak nitelendirilir. Regaib ve Mirac kandilleri bu aydadır.\n"
          "• Şaban Ayı: Peygamberimizin (s.a.v.) ayı olarak bilinir. Berat kandili bu aydadır. Peygamberimiz bu ayda çokça oruç tutardı.\n"
          "• Ramazan Ayı: Kuran-ı Kerim'in indirildiği, farz olan oruç ibadetinin eda edildiği ve içinde bin aydan hayırlı Kadir Gecesi'ni barındıran on bir ayın sultanıdır.\n"
          "• Üç Aylar Duası: 'Allahümme barik lena fi Recebe ve Şaban ve belliğna Ramazan' (Allah'ım! Recep ve Şaban'ı bize mübarek kıl ve bizi Ramazan'a ulaştır).",
    );
  }

  // 64. Muharrem ve Aşure
  Widget _buildMuharremAsure() {
    return _buildInfoSection(
      "Muharrem Ayı ve Aşure Günü",
      "Hicri takvimin ilk ayı ve bereket günü",
      "Muharrem ayı, Hicri yılın başlangıcı olup Allah katında hürmet edilen dört haram aydan biridir.\n\n"
          "Önemi ve Fazileti:\n"
          "• Aşure Günü: Muharrem ayının 10. günüdür. Bu günde Hz. Nuh'un gemisinin tufandan kurtulması, Hz. Musa'nın Kızıldeniz'i geçmesi gibi birçok tarihi mucize gerçekleşmiştir.\n"
          "• Aşure Orucu: Peygamberimiz Muharrem'in 9 ve 10. ya da 10 ve 11. günlerinde oruç tutmayı tavsiye etmiştir.\n"
          "• Paylaşma Kültürü: Aşure günü evlerde pişirilen aşure tatlısı komşu ve akrabalarla paylaşılarak bereket ve kardeşlik bağları canlandırılır.",
    );
  }

  // 65. Zilhicce ve Arefe
  Widget _buildZilhicceArefe() {
    return _buildInfoSection(
      "Zilhicce Ayı ve Arefe Günü",
      "Yılın en hayırlı ilk 10 günü",
      "Zilhicce, Hicri yılın son ayı olup içinde Hac ibadetini ve Kurban bayramını barındıran mübarek bir aydır.\n\n"
          "Önemli Günler ve İbadetler:\n"
          "• İlk 10 Günün Fazileti: Peygamberimiz (s.a.v.) 'Allah katında Zilhicce'nin ilk on gününde yapılan amellerden daha sevimli bir amel yoktur' buyurmuştur. Bu günlerde oruç tutmak, zikir ve istiğfar etmek çok sevaptır.\n"
          "• Arefe Günü: Zilhicce'nin 9. günüdür (Kurban bayramından bir önceki gün). Arefe günü tutulan orucun geçmiş ve gelecek birer yıllık günahlara kefaret olacağı müjdelenmiştir.\n"
          "• Teşrik Tekbirleri: Kurban bayramının arefe günü sabah namazından başlayıp bayramın dördüncü günü ikindi namazına kadar (toplam 23 vakit) farz namazlardan sonra tekbir getirmek vaciptir.",
    );
  }

  // 66. İslam Alimleri
  Widget _buildIslamAlimleri() {
    return _buildListSection("Büyük İslam Alimleri", [
      "İmam-ı Azam Ebu Hanife (699-767): Hanefi mezhebinin kurucusu, büyük fıkıh alimi ve müctehid.",
      "İmam Şafiî (767-820): Şafii mezhebinin kurucusu, fıkıh ve usul alimi.",
      "İmam Gazalî (1058-1111): Hüccetü'l-İslam unvanlı, tasavvuf, felsefe ve fıkıh alimi. En ünlü eseri İhya-u Ulumiddin'dir.",
      "İmam Buhari (810-870): En sahih hadis kitabı olan Sahih-i Buhari'nin yazarı, hadis otoritelerinin en büyüğü.",
      "Mevlânâ Celâleddîn-i Rûmî (1207-1273): Gönüller sultanı, tasavvuf şairi ve Mesnevi'nin müellifi.",
    ]);
  }

  // 67. İslam Coğrafyası
  Widget _buildIslamCografyasi() {
    return _buildListSection("Mukaddes Şehirler ve İslam Coğrafyası", [
      "Mekke-i Mükerreme: İslam'ın doğduğu şehir. Kabe ve Mescid-i Haram buradadır. Müslümanların kıblesidir.",
      "Medine-i Münevvere: Peygamberimizin hicret ettiği ve kabrinin (Ravza-i Mutahhara) bulunduğu nurlu şehir.",
      "Kudüs (Mescid-i Aksa): Müslümanların ilk kıblesi ve Peygamberimizin Mirac'a yükseldiği kutsal mekan.",
      "Bağdat, Şam ve Kahire: İslam medeniyetinin, bilim, kültür ve hilafet merkezleri olmuş tarihi şehirler.",
      "Buhara ve Semerkand: Orta Asya'da yetişen büyük alimlerin, mimari ve ilmin beşiği olan Türk-İslam şehirleri.",
      "Endülüs (Kurtuba/Gırnata): Avrupa'da bilim, sanat ve hoşgörünün zirvesine ulaşmış İslam medeniyeti havzası.",
    ]);
  }

  // 68. Tövbe ve İstiğfar
  Widget _buildTevbeIstigfar() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoSection(
            "Tövbe ve İstiğfar Nedir?",
            "Günahlardan pişmanlık duyup Allah'a sığınma",
            "Tövbe, insanın yaptığı hata ve günahlardan vazgeçerek Allah'a yönelmesi, istiğfar ise bu günahların bağışlanmasını Allah'tan talep etmesidir.\n\n"
                "Tövbenin Kabul Şartları:\n"
                "1. Günahı hemen terk etmek.\n"
                "2. Yapılan günahtan dolayı samimi bir şekilde pişmanlık duymak.\n"
                "3. O günaha bir daha asla dönmemeye kesin karar vermek.\n"
                "4. Eğer kul hakkı varsa, hak sahibiyle helalleşmek.",
          ),
          const SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Seyyidül İstiğfar Duası",
            "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ",
            "Allahümme ente Rabbi la ilahe illa ente halakteni ve ene abdüke ve ene ala ahdike ve va'dike mesteta'tü. Euzü bike min şerri ma sana'tü, ebu'ü leke bi-ni'metike aleyye ve ebu'ü bi-zenbi fağfirli fe-innehû la yağfiruz-zünube illa ente.",
            "Allah'ım! Sen benim Rabbimsin. Senden başka hiçbir ilah yoktur. Beni sen yarattın, ben senin kulunum. Gücüm yettiğince sana verdiğim söz ve ahd üzereyim. Yaptıklarımın şerrinden sana sığınırım. Üzerimdeki nimetini itiraf ederim, günahımı da itiraf ederim. Beni bağışla, çünkü günahları senden başka bağışlayacak kimse yoktur.",
          ),
        ],
      ),
    );
  }

  // 69. Sadaka-i Cariye
  Widget _buildSadakaICariye() {
    return _buildInfoSection(
      "Sadaka-i Cariye",
      "Ölümden sonra da sevabı devam eden yatırımlar",
      "Sadaka-i Cariye, etkisi ve faydası kalıcı olan sürekli iyiliklerdir. Kişi vefat etse dahi, geride bıraktığı bu hayırlı eserlerden insanlar faydalandığı sürece amel defterine sevap yazılmaya devam eder.\n\n"
          "Sadaka-i Cariye Örnekleri:\n"
          "• Çeşme, su kuyusu açtırmak veya su yolları yaptırmak.\n"
          "• Okul, cami, kütüphane, hastane veya aşevi yaptırmak veya yapımına destek olmak.\n"
          "• İnsanlığa faydalı bilimsel icatlar yapmak, kitaplar yazmak, faydalı dijital kaynaklar üretmek.\n"
          "• Yol kenarlarına, ormanlara ağaç dikmek.\n"
          "• Hayırlı bir evlat yetiştirmek (vefat eden ana-babasına dua eden evlat da sadaka-i cariye hükmündedir).",
    );
  }

  // 70. Tecvid Kuralları
  Widget _buildTecvidKurallari() {
    return _buildListSection("Temel Tecvid Kuralları", [
      "Tecvid: Kuran-ı Kerim'i harflerin mahreçlerine (çıkış yerlerine) dikkat ederek, kurallarına uygun ve güzel okuma ilmidir.",
      "Med Harfleri (Uzatma): Elif (ا), Vav (و), Ya (ي) harfleridir. Önündeki harfi uzatarak okuturlar.",
      "Tenvin ve Sakin Nun Kuralları: Sakin nun (نْ) veya tenvin (ً ٍ ٌ) işaretlerinden sonra gelen harflere göre şekillenir.",
      "İzhar: Sakin nun veya tenvinden sonra boğaz harfleri (ء, هـ, ح, خ, ع, غ) gelirse, ses genizden getirilmeden açıkça okunur.",
      "İdgam-ı Mealgunne: Sakin nun veya tenvinden sonra (ي, م, ن, و) harfleri gelirse, ses burundan (genizden) verilerek şeddeli gibi okunur.",
      "İhfa: Sakin nun veya tenvinden sonra izhar ve idgam harfleri dışındaki 15 harf gelirse, nun sesi genizden gizlenerek okunur.",
      "Kalkale (Yankılama): (ق, ط, b, ج, د) harfleri sakin (cezimli) geldiğinde kuvvetli bir ses vurgusuyla yankılatılarak okunur.",
    ]);
  }
}
