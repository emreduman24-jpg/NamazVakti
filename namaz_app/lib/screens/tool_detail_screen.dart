import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_cache_service.dart';
import '../data/prayer_data.dart';
import '../data/prayer_repository.dart';
import '../data/quran_data.dart';
import 'quran_detail_screen.dart';

class ToolDetailScreen extends StatefulWidget {
  final String toolId;
  final String toolTitle;
  final bool isTab;

  const ToolDetailScreen({
    super.key,
    required this.toolId,
    required this.toolTitle,
    this.isTab = false,
  });

  @override
  _ToolDetailScreenState createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final PrayerRepository _repository = PrayerRepository();
  String? _activeToolId;
  String? _activeToolTitle;

  // Color Utility Getters
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _greenColor => _isDark ? const Color(0xFF27A770) : const Color(0xFF1E5E43);
  Color get _textColor => _isDark ? Colors.white : const Color(0xDE000000);
  Color get _subtitleColor => _isDark ? Colors.white70 : const Color(0x8A000000);
  Color get _cardBgColor => _isDark ? const Color(0xFF131D31) : Colors.white;
  Color get _goldColor => const Color(0xFFD4AF37);

  // General state variables
  String _currentLocationName = "";

  Future<void> _loadLocationName() async {
    final savedLoc = await _repository.getSavedLocation();
    final savedCity = savedLoc['cityName'] ?? "İstanbul";
    if (mounted) {
      setState(() {
        _currentLocationName = savedCity;
      });
    }
  }

  // Monthly Times state
  int _monthlyViewMode = 0; // 0 for Liste, 1 for Takvim
  int _selectedCalendarDayIndex = 0;
  List<Map<String, dynamic>> _monthlyPrayerTimes = [];
  bool _loadingMonthlyTimes = true;
  Set<String> _expandedAylikDays = {};

  Future<void> _loadMonthlyTimes() async {
    try {
      final savedLoc = await _repository.getSavedLocation();
      final districtId = savedLoc['districtId'] ?? "9541";
      final List<Map<String, dynamic>> times = await _repository.getPrayerTimes(districtId);
      if (mounted) {
        setState(() {
          _monthlyPrayerTimes = times;
          _loadingMonthlyTimes = false;
        });
      }
    } catch (e) {
      print('Error loading monthly prayer times: $e');
      if (mounted) {
        setState(() {
          _loadingMonthlyTimes = false;
        });
      }
    }
  }

  // Quran V2 State
  int _lastSuraNo = 1;
  String _lastSuraName = "Fatiha";
  int _lastAyahNo = 1;
  int _lastTotalAyahs = 7;
  double _lastPercent = 0.0;
  // Juz Bookmark State
  int _lastJuzNo = 0;
  String _lastJuzTitle = "";
  String _lastJuzRange = "";
  int _lastJuzSuraNo = 0;
  int _lastJuzAyahNo = 0;
  double _lastJuzPercent = 0.0;
  String _quranSearchQuery = "";
  int _quranTab = 0; // 0 for Sureler, 1 for Cüzler
  Set<String> _quranBookmarks = {};

  Future<void> _loadQuranLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList = prefs.getStringList('quran_bookmarks') ?? [];
    if (mounted) {
      setState(() {
        _lastSuraNo = prefs.getInt('quran_last_sura_no') ?? 1;
        _lastSuraName = prefs.getString('quran_last_sura_name') ?? "Fatiha";
        _lastAyahNo = prefs.getInt('quran_last_ayah_no') ?? 1;
        _lastTotalAyahs = prefs.getInt('quran_last_total_ayahs') ?? 7;
        _lastPercent = _lastTotalAyahs > 0 ? (_lastAyahNo / _lastTotalAyahs) : 0.0;
        _quranBookmarks = Set<String>.from(bookmarkedList);

        _lastJuzNo = prefs.getInt('quran_last_juz_no') ?? 0;
        _lastJuzTitle = prefs.getString('quran_last_juz_title') ?? "";
        _lastJuzRange = prefs.getString('quran_last_juz_range') ?? "";
        _lastJuzSuraNo = prefs.getInt('quran_last_juz_sura_no') ?? 0;
        _lastJuzAyahNo = prefs.getInt('quran_last_juz_ayah_no') ?? 0;
        final int juzPercentVal = prefs.getInt('quran_last_juz_percent') ?? 0;
        _lastJuzPercent = juzPercentVal / 100.0;
      });
    }
  }

  Future<void> _toggleQuranBookmark(String surahNo) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_quranBookmarks.contains(surahNo)) {
        _quranBookmarks.remove(surahNo);
      } else {
        _quranBookmarks.add(surahNo);
      }
    });
    await prefs.setStringList('quran_bookmarks', _quranBookmarks.toList());
  }

  // Zikirmatik V2 State
  Set<String> _zikirCompletedDates = {};
  double _counterScale = 1.0;

  Future<void> _loadZikirCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('zikir_completed_dates') ?? [];
    if (mounted) {
      setState(() {
        _zikirCompletedDates = Set<String>.from(completed);
      });
    }
  }

  Future<void> _markZikirCompletedToday() async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    setState(() {
      _zikirCompletedDates.add(todayStr);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('zikir_completed_dates', _zikirCompletedDates.toList());
  }

  // Dualar V2 State
  int _dualarTab = 0; // 0 for Kur'an, 1 for Hadis
  bool _showOnlyFavorites = false;
  Set<String> _favoriteDualar = {};
  String _dualarSearchQuery = "";
  Set<String> _expandedDualar = {};

  Future<void> _loadDualarFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorite_dualar') ?? [];
    if (mounted) {
      setState(() {
        _favoriteDualar = Set<String>.from(list);
      });
    }
  }

  Future<void> _toggleDuaFavorite(String duaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteDualar.contains(duaId)) {
        _favoriteDualar.remove(duaId);
      } else {
        _favoriteDualar.add(duaId);
      }
    });
    await prefs.setStringList('favorite_dualar', _favoriteDualar.toList());
  }

  // Dini Danışman State
  List<Map<String, dynamic>> _diniHocaMessages = [];
  bool _diniHocaIsTyping = false;
  final ScrollController _diniHocaScrollController = ScrollController();
  final TextEditingController _diniHocaInputController = TextEditingController();
  
  // Geliştirici Gemini API Anahtarı (Gemini'ı aktifleştirmek için anahtarınızı buraya yazabilirsiniz)
  static const String _geminiApiKey = "";
  bool get _useGeminiAI => _geminiApiKey.isNotEmpty;

  void _initDiniHoca() {
    if (_diniHocaMessages.isEmpty) {
      _diniHocaMessages = [
        {
          'isMe': false,
          'text': "Selamün Aleyküm mümin kardeşim. Ben yapay zeka Dini Danışman asistanınızım. İslamiyet, ibadetler (namaz, abdest, gusül, oruç, zekat vb.), dualar ve sureler hakkında sormak istediğiniz soruları cevaplamaktan mutluluk duyarım. Nasıl yardımcı olabilirim?",
          'time': DateTime.now(),
        }
      ];
    }
  }

  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  String _currentAudioUrl = "";
  String _currentTrackName = "";

  // Yakındaki Camiler (Location & GPS State)
  Position? _currentPosition;
  bool _loadingLocation = false;
  bool _qiblaWasAligned = false; // Track Qibla alignment for haptic feedback
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

  double _calculateQiblaAngle(double lat, double lon) {
    final double latRad = lat * math.pi / 180.0;
    final double lonRad = lon * math.pi / 180.0;
    final double meccaLatRad = 21.4225 * math.pi / 180.0;
    final double meccaLonRad = 39.8262 * math.pi / 180.0;

    final double lonDiff = meccaLonRad - lonRad;

    final double y = math.sin(lonDiff);
    final double x = math.cos(latRad) * math.tan(meccaLatRad) - math.sin(latRad) * math.cos(lonDiff);

    double qiblaAngle = math.atan2(y, x);
    qiblaAngle = qiblaAngle * 180.0 / math.pi;

    return (qiblaAngle + 360.0) % 360.0;
  }

  void _initMosques() {
    _dynamicMosquesList = [];
  }

  /// Fetches real nearby mosques from OpenStreetMap Overpass API
  Future<void> _fetchNearbyMosques(double lat, double lon) async {
    debugPrint('=== MOSQUE SEARCH: Searching near lat=$lat, lon=$lon ===');
    // Try progressively larger radii until we find enough mosques
    final radii = [3000, 5000, 10000, 20000]; // meters

    // Multiple Overpass API endpoints for reliability
    final overpassEndpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.osm.ch/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final radius in radii) {
      // Broader Overpass QL query: find ALL mosque-related features
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
          // Use POST for reliability with complex queries
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'NamazVakitleri/1.0',
            },
            body: 'data=${Uri.encodeComponent(query)}',
          ).timeout(const Duration(seconds: 12));

          debugPrint('Overpass API [$endpoint] response: status=${response.statusCode}, radius=$radius');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final elements = data['elements'] as List<dynamic>? ?? [];
            debugPrint('Overpass API response: elements=${elements.length}');

            final List<Map<String, dynamic>> mosques = [];
            final Set<String> seenCoords = {}; // avoid duplicates by coordinate
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

              // Filter: only Muslim places of worship (skip churches etc.)
              final religion = tags['religion']?.toString().toLowerCase() ?? '';
              final building = tags['building']?.toString().toLowerCase() ?? '';
              final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
              if (religion.isNotEmpty && religion != 'muslim') continue;
              // If no religion tag, only include if building=mosque or amenity matches
              if (religion.isEmpty && building != 'mosque' && amenity != 'place_of_worship') continue;

              // Skip duplicates by coordinate proximity (within ~10m)
              final coordKey = '${mLat.toStringAsFixed(4)},${mLon.toStringAsFixed(4)}';
              if (seenCoords.contains(coordKey)) continue;
              seenCoords.add(coordKey);

              // Determine name - accept unnamed mosques too
              String name = (tags['name'] ?? tags['name:tr'] ?? tags['name:en'] ?? '').toString();
              if (name.isEmpty) {
                unnamedCount++;
                name = 'Cami #$unnamedCount';
              }

              // Build address from tags
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
              // Update LocationCacheService cache
              final cacheService = LocationCacheService();
              cacheService.dynamicMosquesList = mosques;
              if (_currentPosition != null) {
                cacheService.currentPosition = _currentPosition;
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
    final cacheService = LocationCacheService();
    bool canUseCache = false;
    if (!forceRefresh && cacheService.currentPosition != null) {
      if (_activeToolId == 'kible-bulucu') {
        canUseCache = true;
      } else if (_activeToolId == 'yakindaki-camiler' && cacheService.dynamicMosquesList.isNotEmpty) {
        canUseCache = true;
      }
    }

    if (canUseCache) {
      debugPrint("Using pre-fetched location/mosques from LocationCacheService immediately!");
      setState(() {
        _currentPosition = cacheService.currentPosition;
        if (cacheService.dynamicMosquesList.isNotEmpty) {
          _dynamicMosquesList = List.from(cacheService.dynamicMosquesList);
        }
        _loadingLocation = false;
      });
      return;
    }

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

      // 3. Try to get last known position first (instantaneous, under 10ms)
      if (serviceEnabled &&
          (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always)) {
        try {
          position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            debugPrint("Using last known position immediately: ${position.latitude}, ${position.longitude}");
            _currentPosition = position;
            // Fetch mosques and WAIT for results before hiding loading
            await _fetchNearbyMosques(position.latitude, position.longitude);
            _loadingLocation = false;
            if (mounted) setState(() {});
          }
        } catch (e) {
          debugPrint("Failed to get last known position: $e");
        }

        // 4. Try to get fresh location in parallel/background
        try {
          debugPrint("Attempting to get fresh live GPS location...");
          Position? freshPosition;
          try {
            freshPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );
          } catch (e) {
            debugPrint("High accuracy GPS failed: $e, trying low accuracy...");
            try {
              freshPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                timeLimit: const Duration(seconds: 8),
              );
            } catch (e2) {
              debugPrint("Low accuracy GPS also failed: $e2");
            }
          }

          if (freshPosition != null) {
            debugPrint("Successfully fetched live GPS: ${freshPosition.latitude}, ${freshPosition.longitude}");
          
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
              position = freshPosition;
              _currentPosition = position;
              // Re-fetch mosques with fresh coordinates
              await _fetchNearbyMosques(position.latitude, position.longitude);
            }
          }
        } catch (e) {
          debugPrint("Failed to fetch fresh live GPS: $e");
        }
      }

      // 5. Fallback to manually selected city coordinates if live GPS is unavailable/denied/timeout
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

      // 6. Ultimate fallback to Büyükçekmece, İstanbul if everything fails
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
      debugPrint('=== FINAL GPS POSITION: lat=${pos.latitude}, lon=${pos.longitude}, accuracy=${pos.accuracy} ===');
      
      // Update UI state
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _loadingLocation = false;
        });
      }

      // If we haven't loaded mosques yet (meaning lastKnownPosition was null), fetch them now
      if (_dynamicMosquesList.isEmpty) {
        await _fetchNearbyMosques(pos.latitude, pos.longitude);
      }
      
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
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
      { "ad": "Miraç Kandili", "gun": "Perşembe", "tarih": "15 Ocak 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Pazartesi", "tarih": "2 Şubat 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Perşembe", "tarih": "19 Şubat 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Pazartesi", "tarih": "16 Mart 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Perşembe", "tarih": "19 Mart 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Cuma", "tarih": "20 Mart 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Cumartesi", "tarih": "21 Mart 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Pazar", "tarih": "22 Mart 2026", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Salı", "tarih": "26 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Çarşamba", "tarih": "27 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Perşembe", "tarih": "28 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Cuma", "tarih": "29 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Cumartesi", "tarih": "30 Mayıs 2026", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Salı", "tarih": "16 Haziran 2026", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Perşembe", "tarih": "25 Haziran 2026", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Pazartesi", "tarih": "24 Ağustos 2026", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "10 Aralık 2026", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2027": [
      { "ad": "Miraç Kandili", "gun": "Pazartesi", "tarih": "4 Ocak 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Cuma", "tarih": "22 Ocak 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Pazartesi", "tarih": "8 Şubat 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Cuma", "tarih": "5 Mart 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Pazartesi", "tarih": "8 Mart 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Salı", "tarih": "9 Mart 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Çarşamba", "tarih": "10 Mart 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Perşembe", "tarih": "11 Mart 2027", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Cumartesi", "tarih": "15 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Pazar", "tarih": "16 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Pazartesi", "tarih": "17 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Salı", "tarih": "18 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Çarşamba", "tarih": "19 Mayıs 2027", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Pazar", "tarih": "6 Haziran 2027", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Salı", "tarih": "15 Haziran 2027", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Cuma", "tarih": "13 Ağustos 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "2 Aralık 2027", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Cuma", "tarih": "24 Aralık 2027", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2028": [
      { "ad": "Berat Kandili", "gun": "Salı", "tarih": "11 Ocak 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Cuma", "tarih": "28 Ocak 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Salı", "tarih": "22 Şubat 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Cuma", "tarih": "25 Şubat 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Cumartesi", "tarih": "26 Şubat 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Pazar", "tarih": "27 Şubat 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Pazartesi", "tarih": "28 Şubat 2028", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Perşembe", "tarih": "4 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Cuma", "tarih": "5 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Cumartesi", "tarih": "6 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Pazar", "tarih": "7 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Pazartesi", "tarih": "8 Mayıs 2028", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Perşembe", "tarih": "25 Mayıs 2028", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Cumartesi", "tarih": "3 Haziran 2028", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Çarşamba", "tarih": "2 Ağustos 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "23 Kasım 2028", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Çarşamba", "tarih": "13 Aralık 2028", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2029": [
      { "ad": "Ramazan Başlangıcı", "gun": "Salı", "tarih": "16 Ocak 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Cumartesi", "tarih": "10 Şubat 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Salı", "tarih": "13 Şubat 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Çarşamba", "tarih": "14 Şubat 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Perşembe", "tarih": "15 Şubat 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Cuma", "tarih": "16 Şubat 2029", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Pazartesi", "tarih": "23 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Salı", "tarih": "24 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Çarşamba", "tarih": "25 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Perşembe", "tarih": "26 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Cuma", "tarih": "27 Nisan 2029", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Pazartesi", "tarih": "14 Mayıs 2029", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Çarşamba", "tarih": "23 Mayıs 2029", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Pazartesi", "tarih": "23 Temmuz 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "8 Kasım 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Pazar", "tarih": "2 Aralık 2029", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Perşembe", "tarih": "20 Aralık 2029", "kat": "Kandil ve Mübarek Geceler" }
    ],
    "2030": [
      { "ad": "Ramazan Başlangıcı (1. Ramazan)", "gun": "Cumartesi", "tarih": "5 Ocak 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Kadir Gecesi", "gun": "Çarşamba", "tarih": "30 Ocak 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Bayramı Arefesi", "gun": "Cumartesi", "tarih": "2 Şubat 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (1. Gün)", "gun": "Pazar", "tarih": "3 Şubat 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (2. Gün)", "gun": "Pazartesi", "tarih": "4 Şubat 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Ramazan Bayramı (3. Gün)", "gun": "Salı", "tarih": "5 Şubat 2030", "kat": "Ramazan Bayramı" },
      { "ad": "Kurban Bayramı Arefesi", "gun": "Cuma", "tarih": "12 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (1. Gün)", "gun": "Cumartesi", "tarih": "13 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Pazar", "tarih": "14 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (3. Gün)", "gun": "Pazartesi", "tarih": "15 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Kurban Bayramı (4. Gün)", "gun": "Salı", "tarih": "16 Nisan 2030", "kat": "Kurban Bayramı" },
      { "ad": "Hicri Yılbaşı", "gun": "Cumartesi", "tarih": "4 Mayıs 2030", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Aşure Günü", "gun": "Pazartesi", "tarih": "13 Mayıs 2030", "kat": "Hicri Yılbaşı ve Aşure" },
      { "ad": "Mevlid Kandili", "gun": "Cuma", "tarih": "12 Temmuz 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "31 Ekim 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Cuma", "tarih": "22 Kasım 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Pazartesi", "tarih": "9 Aralık 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı (2. Ramazan)", "gun": "Perşembe", "tarih": "26 Aralık 2030", "kat": "Kandil ve Mübarek Geceler" }
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
  late PageController _hadisPageController;

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
  int _prophetSubSection = 0; // 0: Donemler, 1: Semail, 2: Ahlak, 3: Aile, 4: Gazveler, 5: Sunnet/Hadisler

  // Namaz Kilma Tab
  bool _namazKilmaErkek = true;
  int _namazStepIndex = 0;

  // Abdest & Gusul Steps State
  int _abdestStepIndex = 0;
  int _gusulStepIndex = 0;
  int _abdestTab = 0;
  int _gusulTab = 0;

  // Live Quran Radio State
  bool _isRadioLoading = false;

  // Expanded Sahabe ID
  String? _expandedSahabeAd;

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
    _activeToolId = widget.toolId;
    _activeToolTitle = widget.toolTitle;
    _initMosques();
    _loadLocationName();
    _loadQuranLastRead();
    _loadZikirCompletedDates();
    _loadDualarFavorites();
    _initDiniHoca();
    if (widget.toolId == 'namaz-vakitleri-aylik') {
      _loadMonthlyTimes();
    }
    if (widget.toolId == 'yakindaki-camiler' || widget.toolId == 'kible-bulucu') {
      _getUserLocation();
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
    _hadisPageController = PageController(initialPage: _hadisIndex);
  }

  @override
  void didUpdateWidget(covariant ToolDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toolId != widget.toolId || oldWidget.toolTitle != widget.toolTitle) {
      _activeToolId = widget.toolId;
      _activeToolTitle = widget.toolTitle;
    }
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
          if (state == PlayerState.playing || state == PlayerState.stopped || state == PlayerState.paused) {
            _isRadioLoading = false;
          }
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
    _diniHocaInputController.dispose();
    _diniHocaScrollController.dispose();
    _goldController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    _hadisPageController.dispose();
    super.dispose();
  }

  // Zikirmatik persistence
  Future<void> _loadZikirState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load custom Esma zikirs if they exist
    final customIds = prefs.getStringList('zikir_custom_ids') ?? [];
    for (final customId in customIds) {
      final customAd = prefs.getString('zikir_custom_ad_$customId') ?? '';
      final customArapca = prefs.getString('zikir_custom_arapca_$customId') ?? '';
      final customAnlam = prefs.getString('zikir_custom_anlam_$customId') ?? '';
      final customFazilet = prefs.getString('zikir_custom_fazilet_$customId') ?? '';
      final customHedef = prefs.getInt('zikir_custom_hedef_$customId') ?? 33;
      _zikirData[customId] = {
        'ad': customAd,
        'arapca': customArapca,
        'anlam': customAnlam,
        'fazilet': customFazilet,
        'hedef': customHedef,
      };
    }

    final selectedId = prefs.getString('zikir_selected_id') ?? 'subhanallah';
    final count = prefs.getInt('zikir_count_$selectedId') ?? 0;
    final target = prefs.getInt('zikir_target_$selectedId') ?? (_zikirData[selectedId]?['hedef'] ?? 33);
    
    setState(() {
      _selectedZikirId = selectedId;
      _zikirCount = count;
      _zikirTarget = target;
    });
  }

  void _onZikirSelected(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    
    // Save current count of the old zikir first
    await prefs.setInt('zikir_count_$_selectedZikirId', _zikirCount);
    
    await prefs.setString('zikir_selected_id', id);
    
    final target = prefs.getInt('zikir_target_$id') ?? (_zikirData[id]?['hedef'] ?? 33);
    final count = prefs.getInt('zikir_count_$id') ?? 0;
    
    setState(() {
      _selectedZikirId = id;
      _zikirTarget = target;
      _zikirCount = count;
    });
    
    await _repository.setZikirTarget(target);
    await _repository.setZikirCount(count);
  }

  Future<void> _resetZikir() async {
    setState(() {
      _zikirCount = 0;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('zikir_count_$_selectedZikirId', 0);
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

  // Radio stream toggle helper
  Future<void> _toggleRadio(String url) async {
    try {
      if (_currentAudioUrl == url && _playerState == PlayerState.playing) {
        await _audioPlayer!.stop();
        setState(() {
          _playerState = PlayerState.stopped;
        });
      } else {
        setState(() {
          _isRadioLoading = true;
          _currentAudioUrl = url;
          _currentTrackName = "Canlı Kur'an Radyosu";
        });
        await _audioPlayer!.stop();
        await _audioPlayer!.play(UrlSource(url));
      }
    } catch (e) {
      setState(() {
        _isRadioLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Radyo yayını başlatılamadı: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark;
    return PopScope(
      canPop: _activeToolId == widget.toolId,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_activeToolId != widget.toolId) {
          setState(() {
            _activeToolId = widget.toolId;
            _activeToolTitle = widget.toolTitle;
          });
        }
      },
      child: Scaffold(
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isTab,
          leading: widget.isTab
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_activeToolId != widget.toolId) {
                      setState(() {
                        _activeToolId = widget.toolId;
                        _activeToolTitle = widget.toolTitle;
                      });
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
          title: Text(
            _activeToolTitle ?? widget.toolTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: dark ? const Color(0xFF111A2E) : const Color(0xFF1E5E43),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildToolBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildToolBody() {
    switch (_activeToolId ?? widget.toolId) {
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
      case 'dini-hoca':
        return _buildDiniHoca();
      case 'namaz-vakitleri-aylik':
        return _buildAylikNamazVakitleri();
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
      case 'islam-sartlari':
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

  // 1. Dini Günler Helpers
  DateTime? _parseTurkishDate(String tarihStr) {
    try {
      final parts = tarihStr.trim().split(' ');
      if (parts.length < 3) return null;
      
      final dayNum = int.tryParse(parts[0]) ?? 1;
      final monthName = parts[1].toLowerCase();
      final monthsMap = {
        'ocak': 1, 'şubat': 2, 'mart': 3, 'nisan': 4,
        'mayıs': 5, 'haziran': 6, 'temmuz': 7, 'ağustos': 8, 'ağu': 8,
        'eylül': 9, 'ekim': 10, 'kasım': 11, 'aralık': 12
      };
      final monthNum = monthsMap[monthName] ?? 1;
      final yearNum = int.tryParse(parts[2]) ?? DateTime.now().year;
      
      return DateTime(yearNum, monthNum, dayNum);
    } catch (_) {
      return null;
    }
  }

  Map<String, String>? _getNextReligiousDay() {
    try {
      final now = DateTime.now();
      final currentYear = now.year.toString();
      final days = _diniGunlerByYear[currentYear];
      if (days == null || days.isEmpty) return null;

      Map<String, String>? closestDay;
      int minDiffDays = 99999;

      for (var day in days) {
        final tarihStr = day['tarih'] ?? '';
        if (tarihStr.isEmpty) continue;

        final dt = _parseTurkishDate(tarihStr);
        if (dt == null) continue;

        final todayMidnight = DateTime(now.year, now.month, now.day);
        final diff = dt.difference(todayMidnight).inDays;
        if (diff >= 0 && diff < minDiffDays) {
          minDiffDays = diff;
          closestDay = {
            'ad': day['ad'] ?? '',
            'tarih': tarihStr,
            'gun': day['gun'] ?? '',
            'kalan': diff == 0 ? "Bugün" : "$diff gün kaldı",
          };
        }
      }
      return closestDay;
    } catch (_) {
      return null;
    }
  }

  Widget _buildDiniGunler() {
    final bool dark = _isDark;
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

    final nextDay = _getNextReligiousDay();
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // 1. Dynamic Next Upcoming Religious Day Banner
        if (nextDay != null && _selectedDiniGunlerYear == now.year.toString())
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF131D31), const Color(0xFF0F1B2A)]
                    : [Colors.white, const Color(0xFFEAF7F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dark ? const Color(0xFF1E2D4A) : const Color(0xFF27A770).withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.05 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _goldColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: _goldColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Yaklaşan Dini Gün",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _goldColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          nextDay['ad']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${nextDay['tarih']} • ${nextDay['gun']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: _subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _greenColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nextDay['kalan']!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: _greenColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 2. Custom Year Selector Horizontal Scroll Strip
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ["2026", "2027", "2028", "2029", "2030"].map((year) {
              final isSelected = _selectedDiniGunlerYear == year;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDiniGunlerYear = year;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [_greenColor, _greenColor.withOpacity(0.8)],
                            )
                          : null,
                      color: isSelected ? null : (dark ? const Color(0xFF131D31) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _greenColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      year,
                      style: TextStyle(
                        color: isSelected ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // 3. Redesigned Category Sections and Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 24.0),
            itemCount: categoryOrder.length,
            itemBuilder: (context, catIdx) {
              final catName = categoryOrder[catIdx];
              final items = grouped[catName] ?? [];
              if (items.isEmpty) return const SizedBox.shrink();

              IconData catIcon;
              Color catAccentColor;
              switch (catName) {
                case "Kandil ve Mübarek Geceler":
                  catIcon = Icons.nights_stay;
                  catAccentColor = const Color(0xFF5C6BC0);
                  break;
                case "Ramazan Bayramı":
                  catIcon = Icons.mosque;
                  catAccentColor = const Color(0xFF27A770);
                  break;
                case "Kurban Bayramı":
                  catIcon = Icons.favorite;
                  catAccentColor = const Color(0xFFFF7043);
                  break;
                default:
                  catIcon = Icons.auto_awesome;
                  catAccentColor = const Color(0xFFFFB300);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header Row
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, top: 16.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(catIcon, color: catAccentColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          catName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: catAccentColor,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Cards List
                  ...items.map((day) {
                    final String tarihStr = day['tarih'] ?? '';
                    final dt = _parseTurkishDate(tarihStr);
                    
                    String statusText = "";
                    Color statusColor = Colors.grey;
                    bool isFuture = false;

                    if (dt != null) {
                      final diff = dt.difference(todayMidnight).inDays;
                      if (diff < 0) {
                        statusText = "Geçti";
                        statusColor = dark ? Colors.white30 : Colors.black26;
                      } else if (diff == 0) {
                        statusText = "Bugün";
                        statusColor = _goldColor;
                      } else {
                        statusText = "$diff gün kaldı";
                        statusColor = _greenColor;
                        isFuture = true;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: _cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dt != null && dt.difference(todayMidnight).inDays == 0
                              ? _goldColor
                              : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                          width: dt != null && dt.difference(todayMidnight).inDays == 0 ? 1.8 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.05 : 0.01),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: catAccentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(catIcon, color: catAccentColor, size: 18),
                        ),
                        title: Text(
                          day['ad'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _textColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              Text(
                                day['gun'] ?? '',
                                style: TextStyle(
                                  color: _subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                              if (statusText.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: _subtitleColor.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFuture
                                ? _greenColor.withOpacity(0.12)
                                : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFuture
                                  ? _greenColor.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            tarihStr,
                            style: TextStyle(
                              color: isFuture ? _greenColor : _textColor.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
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

  // 4. Canlı Sohbet (Canlı Kur'an Radyosu)
  Widget _buildCanliSohbet() {
    final bool dark = _isDark;
    const String streamUrl = "https://eustr73.mediatriple.net/videoonlylive/mtikoimxnztxlive/broadcast_5e3c14192aa92.smil/playlist.m3u8";
    final bool isCurrentPlaying = _currentAudioUrl == streamUrl && _playerState == PlayerState.playing;

    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: dark ? 4 : 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: dark
                ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                : BorderSide.none,
          ),
          color: dark ? const Color(0xFF131D31) : Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF131D31), const Color(0xFF0D1625)]
                    : [Colors.white, const Color(0xFFF2FAF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Live Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCurrentPlaying ? Colors.redAccent : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: isCurrentPlaying
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCurrentPlaying ? "CANLI YAYIN" : "YAYIN DURDURULDU",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isCurrentPlaying ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Radio Symbol
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF1B2A47) : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF27A770).withOpacity(dark ? 0.2 : 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.radio_rounded,
                      size: 56,
                      color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Diyanet Kur'an Radyo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.5,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Kesintisiz Kur'an-ı Kerim Meali ve Tilaveti",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _subtitleColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                // Wave Equalizer
                QuranEqualizer(isPlaying: isCurrentPlaying),
                const SizedBox(height: 24),
                // Play / Stop Controls
                if (_isRadioLoading)
                  const SizedBox(
                    width: 70,
                    height: 70,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                        strokeWidth: 4,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _toggleRadio(streamUrl),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isCurrentPlaying ? const Color(0xFFD9534F) : const Color(0xFF27A770),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isCurrentPlaying ? const Color(0xFFD9534F) : const Color(0xFF27A770)).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        isCurrentPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                // Open Web Link button
                TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse("https://diyanetkuranradyo.com/canli-dinle");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text(
                    "Diyanet Web Sayfasını Aç",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Peygamberin Hayatı
  Widget _buildPeygamberHayati() {
    final bool dark = _isDark;
    final List<String> sections = [
      "Dönemler",
      "Ahlakı",
      "Şemaili",
      "Ailesi",
      "Gazveler",
      "Sünnetleri"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-section tabs
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final active = _prophetSubSection == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    sections[index],
                    style: TextStyle(
                      color: active ? Colors.white : (dark ? Colors.white70 : const Color(0xFF1E5E43)),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  backgroundColor: dark ? const Color(0xFF1B2A47) : const Color(0xFFE8F5E9),
                  onSelected: (val) {
                    setState(() {
                      _prophetSubSection = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildProphetSectionContent(),
        ),
      ],
    );
  }

  Widget _buildProphetSectionContent() {
    final bool dark = _isDark;
    final Map<String, dynamic> rehber = PEYGAMBER_REHBERI;

    switch (_prophetSubSection) {
      case 0: // Dönemler
        final List<dynamic> donemler = rehber['donemler'];
        final current = donemler[_prophetLifeTab];
        final List<String> milestones = current['ek_bilgi'].toString().split(' • ');

        return Column(
          children: [
            // Period selector
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: donemler.length,
                itemBuilder: (context, idx) {
                  final active = _prophetLifeTab == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        donemler[idx]['baslik'].toString().split(' (')[0],
                        style: TextStyle(
                          color: active ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                          fontSize: 11.5,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: active,
                      selectedColor: const Color(0xFFD4AF37),
                      backgroundColor: dark ? const Color(0xFF152238) : Colors.grey[200],
                      onSelected: (val) {
                        setState(() {
                          _prophetLifeTab = idx;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Period card
            Expanded(
              child: Card(
                color: dark ? const Color(0xFF131D31) : Colors.white,
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                current['baslik'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27A770),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                current['yil'],
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          current['icerik'],
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.6,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Ayet box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFFD4AF37)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "İlgili Ayet",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD4AF37),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                current['ayet'],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  height: 1.45,
                                  color: dark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Milestones
                        Text(
                          "Önemli Detaylar",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : const Color(0xFF1E5E43),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: milestones.map((m) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: dark ? const Color(0xFF1B2A47) : const Color(0xFFF0F9F4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: dark ? Colors.white70 : const Color(0xFF1E5E43),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case 1: // Ahlakı
        final List<dynamic> ahlak = rehber['ahlak'];
        return ListView.builder(
          itemCount: ahlak.length,
          itemBuilder: (context, idx) {
            final item = ahlak[idx];
            return Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                iconColor: const Color(0xFFD4AF37),
                collapsedIconColor: const Color(0xFF27A770),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF27A770).withOpacity(0.12),
                  child: const Icon(Icons.star_border_rounded, color: Color(0xFF27A770)),
                ),
                title: Text(
                  item['baslik'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: dark ? Colors.white : const Color(0xFF1E5E43),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
                    child: Text(
                      item['detay'],
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case 2: // Şemaili
        final List<dynamic> semail = rehber['semail'];
        return ListView.builder(
          itemCount: semail.length,
          itemBuilder: (context, idx) {
            final item = semail[idx];
            return Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          idx == 0
                              ? Icons.face_rounded
                              : idx == 1
                                  ? Icons.directions_walk_rounded
                                  : Icons.blur_on_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['baslik'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: dark ? Colors.white : const Color(0xFF1E5E43),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      item['detay'],
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      case 3: // Ailesi
        final Map<String, dynamic> aile = rehber['aile'];
        final List<dynamic> ebeveyn = aile['anne_baba'];
        final List<dynamic> esleri = aile['esleri'];
        final List<dynamic> cocuklar = aile['cocuklari'];

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: "Büyükleri"),
                  Tab(text: "Eşleri"),
                  Tab(text: "Çocukları"),
                ],
                labelColor: const Color(0xFF27A770),
                unselectedLabelColor: _subtitleColor,
                indicatorColor: const Color(0xFF27A770),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    // Anne Baba
                    ListView.builder(
                      itemCount: ebeveyn.length,
                      itemBuilder: (context, idx) {
                        final p = ebeveyn[idx];
                        return Card(
                          color: dark ? const Color(0xFF131D31) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF27A770).withOpacity(0.12),
                              foregroundColor: const Color(0xFF27A770),
                              child: Text(p['rol'][0]),
                            ),
                            title: Text(
                              "${p['ad']} (${p['rol']})",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                p['bilgi'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Eşleri
                    ListView.builder(
                      itemCount: esleri.length,
                      itemBuilder: (context, idx) {
                        final e = esleri[idx];
                        return Card(
                          color: dark ? const Color(0xFF131D31) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.12),
                              foregroundColor: const Color(0xFFD4AF37),
                              child: Text((idx + 1).toString()),
                            ),
                            title: Text(
                              e['ad'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                e['bilgi'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Çocukları
                    ListView.builder(
                      itemCount: cocuklar.length,
                      itemBuilder: (context, idx) {
                        final c = cocuklar[idx];
                        return Card(
                          color: dark ? const Color(0xFF131D31) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF27A770).withOpacity(0.12),
                              foregroundColor: const Color(0xFF27A770),
                              child: const Icon(Icons.child_care_rounded, size: 20),
                            ),
                            title: Text(
                              c['ad'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                c['bilgi'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4: // Savaşlar
        final List<dynamic> gazveler = rehber['gazveler'];
        return ListView.builder(
          itemCount: gazveler.length,
          itemBuilder: (context, idx) {
            final g = gazveler[idx];
            return Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                iconColor: const Color(0xFFD4AF37),
                collapsedIconColor: const Color(0xFF27A770),
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                  child: const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 20),
                ),
                title: Text(
                  g['ad'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: dark ? Colors.white : const Color(0xFF1E5E43),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['detay'],
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: dark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF27A770)),
                            const SizedBox(width: 8),
                            Text(
                              "Sonuç: ${g['sonuc']}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF27A770),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)),
                          ),
                          child: Text(
                            "Çıkarılan Ders: ${g['ders']}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

      default: // Sünnetleri
        final List<dynamic> sunnetler = rehber['hadis_sunnet'];
        return ListView.builder(
          itemCount: sunnetler.length,
          itemBuilder: (context, idx) {
            final s = sunnetler[idx];
            final List<dynamic> detaylar = s['detaylar'];
            return Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                iconColor: const Color(0xFFD4AF37),
                collapsedIconColor: const Color(0xFF27A770),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF27A770).withOpacity(0.12),
                  child: const Icon(Icons.spa_outlined, color: Color(0xFF27A770), size: 20),
                ),
                title: Text(
                  s['kategori'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: dark ? Colors.white : const Color(0xFF1E5E43),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      children: detaylar.map<Widget>((d) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF27A770))),
                              Expanded(
                                child: Text(
                                  d.toString(),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: dark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  // 6. Kuran-ı Kerim V2
  Widget _buildKuranKerim() {
    final bool dark = _isDark;

    // Filter surahs/juzs
    final queryNormalized = _normalize(_quranSearchQuery);
    final List<QuranSurah> filteredSuras = QURAN_SURAHS.where((s) {
      return _normalize(s.name).contains(queryNormalized) ||
          _normalize(s.arabicName).contains(queryNormalized) ||
          s.number.toString().contains(queryNormalized);
    }).toList();

    // Filter Juz list
    final List<QuranJuz> filteredJuzs = QURAN_JUZS.where((j) {
      return j.number.toString().contains(queryNormalized) ||
          "${j.number}. cüz".contains(queryNormalized);
    }).toList();

    return Column(
      children: [
        // Kaldığın Yer bookmark progress card
        if (_quranTab == 0 && _lastSuraName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              elevation: dark ? 0 : 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: dark
                    ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  final targetSurah = QURAN_SURAHS.firstWhere(
                    (s) => s.number == _lastSuraNo,
                    orElse: () => QURAN_SURAHS[0],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranDetailScreen(
                        surah: targetSurah,
                        targetAyah: _lastAyahNo,
                      ),
                    ),
                  ).then((_) => _loadQuranLastRead());
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _greenColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_rounded, color: _goldColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "KALDIĞIN YER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: _goldColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_lastSuraName Suresi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                            Text(
                              "Ayet $_lastAyahNo / $_lastTotalAyahs",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _lastPercent,
                                backgroundColor: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: _greenColor, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_quranTab == 1 && _lastJuzNo > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              elevation: dark ? 0 : 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: dark
                    ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  final targetJuz = QURAN_JUZS.firstWhere(
                    (j) => j.number == _lastJuzNo,
                    orElse: () => QURAN_JUZS[0],
                  );
                  final startInfo = _getJuzStartInfo(_lastJuzNo);
                  final targetSurah = QURAN_SURAHS.firstWhere(
                    (s) => s.number == (_lastJuzSuraNo > 0 ? _lastJuzSuraNo : startInfo['sura']),
                    orElse: () => QURAN_SURAHS[0],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranDetailScreen(
                        surah: targetSurah,
                        isJuz: true,
                        juz: targetJuz,
                        targetAyah: _lastJuzAyahNo > 0 ? _lastJuzAyahNo : startInfo['ayah']!,
                      ),
                    ),
                  ).then((_) => _loadQuranLastRead());
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _greenColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_rounded, color: _goldColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "KALDIĞIN YER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: _goldColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_lastJuzNo. Cüz",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                            Text(
                              "Sure $_lastJuzSuraNo, Ayet $_lastJuzAyahNo",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _lastJuzPercent,
                                backgroundColor: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: _greenColor, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Tabs switcher & search row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _quranTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quranTab == 0
                                ? _greenColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Sureler",
                            style: TextStyle(
                              color: _quranTab == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _quranTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quranTab == 1
                                ? _greenColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Cüzler",
                            style: TextStyle(
                              color: _quranTab == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: _quranTab == 0 ? "Sure adı veya no ara..." : "Cüz no ara...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: _greenColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _quranSearchQuery = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // List builder
        Expanded(
          child: _quranTab == 0
              ? _buildSurelerList(filteredSuras)
              : _buildCuzlerList(filteredJuzs),
        ),
      ],
    );
  }

  Widget _buildSurelerList(List<QuranSurah> list) {
    final bool dark = _isDark;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Eşleşen sure bulunamadı.",
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final surah = list[index];
        final isBookmarked = _quranBookmarks.contains(surah.number.toString());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranDetailScreen(
                    surah: surah,
                    targetAyah: 1,
                  ),
                ),
              ).then((_) => _loadQuranLastRead());
            },
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: _goldColor, width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: _goldColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              surah.name,
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              "${surah.versesCount} Ayet • ${surah.revelationPlace}",
              style: TextStyle(
                color: _subtitleColor,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah.arabicName,
                  style: TextStyle(
                    color: _greenColor,
                    fontFamily: 'Traditional Arabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isBookmarked ? _goldColor : (dark ? Colors.white38 : Colors.black26),
                    size: 22,
                  ),
                  onPressed: () => _toggleQuranBookmark(surah.number.toString()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCuzlerList(List<QuranJuz> list) {
    final bool dark = _isDark;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Eşleşen cüz bulunamadı.",
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final juz = list[index];
        return Card(
          elevation: dark ? 0 : 1,
          color: _cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            onTap: () {
              final startInfo = _getJuzStartInfo(juz.number);
              final targetSurah = QURAN_SURAHS.firstWhere(
                (s) => s.number == startInfo['sura'],
                orElse: () => QURAN_SURAHS[0],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranDetailScreen(
                    surah: targetSurah,
                    isJuz: true,
                    juz: juz,
                    targetAyah: startInfo['ayah']!,
                  ),
                ),
              ).then((_) => _loadQuranLastRead());
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🕋",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${juz.number}. Cüz",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _getJuzStartInfo(int juzNumber) {
    const juzStarts = {
      1: {'sura': 1, 'ayah': 1},
      2: {'sura': 2, 'ayah': 142},
      3: {'sura': 2, 'ayah': 253},
      4: {'sura': 3, 'ayah': 93},
      5: {'sura': 4, 'ayah': 24},
      6: {'sura': 4, 'ayah': 148},
      7: {'sura': 5, 'ayah': 82},
      8: {'sura': 6, 'ayah': 111},
      9: {'sura': 7, 'ayah': 88},
      10: {'sura': 8, 'ayah': 41},
      11: {'sura': 9, 'ayah': 93},
      12: {'sura': 11, 'ayah': 6},
      13: {'sura': 12, 'ayah': 53},
      14: {'sura': 15, 'ayah': 1},
      15: {'sura': 17, 'ayah': 1},
      16: {'sura': 18, 'ayah': 75},
      17: {'sura': 21, 'ayah': 1},
      18: {'sura': 23, 'ayah': 1},
      19: {'sura': 25, 'ayah': 21},
      20: {'sura': 27, 'ayah': 56},
      21: {'sura': 29, 'ayah': 46},
      22: {'sura': 33, 'ayah': 31},
      23: {'sura': 36, 'ayah': 28},
      24: {'sura': 39, 'ayah': 32},
      25: {'sura': 41, 'ayah': 47},
      26: {'sura': 46, 'ayah': 1},
      27: {'sura': 51, 'ayah': 31},
      28: {'sura': 58, 'ayah': 1},
      29: {'sura': 67, 'ayah': 1},
      30: {'sura': 78, 'ayah': 1},
    };
    return juzStarts[juzNumber] ?? {'sura': 1, 'ayah': 1};
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
                            onPressed: () async {
                              final String customZikirId = 'esma_${item['no']}';
                              final int target = item['zikir'] as int;
                              
                              final prefs = await SharedPreferences.getInstance();
                              
                              // Save custom Esma details persistently
                              await prefs.setString('zikir_custom_ad_$customZikirId', item['ad'].toString());
                              await prefs.setString('zikir_custom_arapca_$customZikirId', item['arapca']?.toString() ?? '');
                              await prefs.setString('zikir_custom_anlam_$customZikirId', item['anlam'].toString());
                              await prefs.setString('zikir_custom_fazilet_$customZikirId', item['fazilet'].toString());
                              await prefs.setInt('zikir_custom_hedef_$customZikirId', target);

                              // Add custom ID to set of custom zikir IDs
                              final customIds = prefs.getStringList('zikir_custom_ids') ?? [];
                              if (!customIds.contains(customZikirId)) {
                                customIds.add(customZikirId);
                                await prefs.setStringList('zikir_custom_ids', customIds);
                              }

                              // Add to active data map
                              _zikirData[customZikirId] = {
                                'ad': item['ad'],
                                'arapca': item['arapca'] ?? '',
                                'anlam': item['anlam'] ?? '',
                                'fazilet': item['fazilet'] ?? '',
                                'hedef': target,
                              };

                              // Load previous count if they already started it
                              final previousCount = prefs.getInt('zikir_count_$customZikirId') ?? 0;

                              setState(() {
                                _selectedZikirId = customZikirId;
                                _zikirTarget = target;
                                _zikirCount = previousCount;
                                _activeToolId = 'zikirmatik';
                                _activeToolTitle = 'Zikirmatik';
                              });

                              await prefs.setString('zikir_selected_id', customZikirId);
                              await _repository.setZikirTarget(target);
                              await _repository.setZikirCount(previousCount);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${item['ad']} zikri zikirmatik hedefi olarak ayarlandı ve aktif edildi.",
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
  // 10. Kıble Bulucu V2 (Qibla Radar)
  Widget _buildKibleBulucu() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        final bool dark = _isDark;

        double qiblaAngle = 137.0;
        String qiblaCityName = "İstanbul";
        if (_currentPosition != null) {
          qiblaAngle = _calculateQiblaAngle(_currentPosition!.latitude, _currentPosition!.longitude);
          qiblaCityName = _currentLocationName.isNotEmpty ? _currentLocationName : "Konumunuz";
        }

        // If no sensor detected, display a beautiful fallback message
        if (heading == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_off_outlined,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Pusula Sensörü Bulunamadı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cihazınızda manyetik pusula sensörü tespit edilemedi. Kıble Radar özelliğini kullanabilmek için lütfen pusula desteği olan bir mobil cihaz kullanın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        double needleRotation = qiblaAngle - heading;

        // Calculate difference for direction instructions
        double diff = (qiblaAngle - heading) % 360;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        
        bool isAligned = diff.abs() < 3;

        // Haptic feedback when first aligning to Qibla
        if (isAligned && !_qiblaWasAligned) {
          HapticFeedback.mediumImpact();
          _qiblaWasAligned = true;
        } else if (!isAligned) {
          _qiblaWasAligned = false;
        }

        // Blip coordinates on the radar grid
        final double angleRad = (needleRotation - 90) * 3.141592653589793 / 180;
        final double radarRadius = 90.0; // Half of 180
        final double blipX = 120.0 + radarRadius * math.cos(angleRad) - 16;
        final double blipY = 120.0 + radarRadius * math.sin(angleRad) - 16;

        // Real distance to Kaaba from user's current GPS, fallback to Istanbul
        double meccaDistance = 2400.0;
        if (_currentPosition != null) {
          meccaDistance = _calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, 21.4225, 39.8262);
        }

        Widget instructionWidget;
        if (isAligned) {
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF27A770).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF27A770), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27A770).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27A770),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "KIBLE KİLİTLENDİ 🕋",
                  style: TextStyle(
                    color: Color(0xFF27A770),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          );
        } else {
          String dirText = diff > 0 
              ? "SAĞA DÖNÜN: ${diff.round()}° ↪️" 
              : "SOLA DÖNÜN: ${diff.abs().round()}° ↩️";
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
            ),
            child: Text(
              dirText,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Card(
                color: dark ? const Color(0xFF1E2E4A).withOpacity(0.2) : const Color(0xFFEAF7F1).withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(
                    color: dark ? const Color(0xFF27A770).withOpacity(0.15) : const Color(0xFF27A770).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar_rounded, color: _greenColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Kıble Radar Arayüzü",
                            style: TextStyle(
                              fontSize: 14.5, 
                              fontWeight: FontWeight.bold, 
                              color: _greenColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Telefonunuzu yatay tutup kendi etrafınızda dönün. Parıldayan Kabe hedefini (🕋) en üstteki kırmızı hedef çizgisine yerleştirin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: _subtitleColor, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Futuristic Qibla Radar Screen
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isAligned
                                ? const Color(0xFF27A770).withOpacity(0.1)
                                : (dark ? Colors.black45 : Colors.black12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _KibleRadarPainter(
                          needleRotation: needleRotation,
                          isAligned: isAligned,
                          isDark: dark,
                        ),
                      ),
                    ),
                    Positioned(
                      left: blipX,
                      top: blipY,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAligned ? const Color(0xFF27A770) : _cardBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAligned ? Colors.white : (dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAligned ? const Color(0xFF27A770).withOpacity(0.8) : Colors.black26,
                              blurRadius: isAligned ? 12 : 4,
                              spreadRadius: isAligned ? 2 : 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "🕋",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              instructionWidget,
              
              const SizedBox(height: 24),
              
              // HUD Information Panel
              Card(
                color: _cardBgColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KIBLE RADAR VERİLERİ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: _subtitleColor,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Hedef Açısı:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${qiblaAngle.round()}° ($qiblaCityName)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _greenColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cihaz Yönü:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${heading.round()}°", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kabe'ye Uzaklık:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${meccaDistance.round()} km", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Konum:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text(_currentLocationName.isNotEmpty ? _currentLocationName : "İstanbul", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // 11. Zikirmatik
  // 11. Zikirmatik V2
  Widget _buildZikirmatik() {
    final zikir = _zikirData[_selectedZikirId] ?? _zikirData['subhanallah']!;
    final bool dark = _isDark;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _zikirData.length,
              itemBuilder: (context, index) {
                final key = _zikirData.keys.elementAt(index);
                final item = _zikirData[key]!;
                final isSelected = _selectedZikirId == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _onZikirSelected(key),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? _greenColor : _cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _greenColor
                              : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _greenColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['ad'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : _textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['hedef'] == 9999 ? "∞" : "Hedef: ${item['hedef']}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white70 : _subtitleColor,
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
          const SizedBox(height: 12),

          Card(
            color: _cardBgColor,
            elevation: dark ? 0 : 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: dark
                  ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1)
                  : BorderSide.none,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    zikir['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFFFF9F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dark ? const Color(0xFF2E3D5A) : const Color(0xFFFFECE0),
                      ),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: dark ? const Color(0xFFE2B04E) : Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _counterScale = 0.92;
              });
            },
            onTapUp: (_) {
              setState(() {
                _counterScale = 1.0;
              });
            },
            onTapCancel: () {
              setState(() {
                _counterScale = 1.0;
              });
            },
            onTap: () async {
              HapticFeedback.lightImpact();
              if (_zikirSoundEnabled) {
                SystemSound.play(SystemSoundType.click);
              }
              setState(() {
                _zikirCount++;
              });
              await _repository.setZikirCount(_zikirCount);
              
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('zikir_count_$_selectedZikirId', _zikirCount);

              final now = DateTime.now();
              final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
              if (!_zikirCompletedDates.contains(todayStr)) {
                await _markZikirCompletedToday();
              }

              if (_zikirTarget != 9999 && _zikirCount >= _zikirTarget) {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Tebrikler! ${zikir['ad']} zikrini tamamladınız!",
                    ),
                    backgroundColor: const Color(0xFF27A770),
                  ),
                );
                setState(() {
                  _zikirCount = 0;
                });
                await _repository.setZikirCount(0);
                await prefs.setInt('zikir_count_$_selectedZikirId', 0);
              }
            },
            child: AnimatedScale(
              scale: _counterScale,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _cardBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _greenColor, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: _greenColor.withOpacity(dark ? 0.2 : 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$_zikirCount",
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: _greenColor,
                        ),
                      ),
                      Text(
                        _zikirTarget == 9999 ? "/ ∞" : "/ $_zikirTarget",
                        style: TextStyle(
                          fontSize: 13,
                          color: _subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sayaç Sıfırlansın mı?"),
                      content: const Text("Zikir sayacınızı sıfırlamak istediğinize emin misiniz?"),
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
                          child: const Text("Sıfırla", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Sıfırla", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zikirSoundEnabled ? _greenColor : Colors.grey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _zikirSoundEnabled = !_zikirSoundEnabled;
                  });
                },
                icon: Icon(_zikirSoundEnabled ? Icons.volume_up : Icons.volume_off, size: 18),
                label: Text(
                  _zikirSoundEnabled ? "Ses: Açık" : "Ses: Kapalı",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildWeekViewChart(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeekViewChart() {
    final bool dark = _isDark;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = List.generate(7, (i) => monday.add(Duration(days: i)));
    final List<String> dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Card(
      color: _cardBgColor,
      elevation: dark ? 0 : 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: dark
            ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: _goldColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Bu Haftanın Zikir Takibi",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = daysOfWeek[index];
                final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                final bool isCompleted = _zikirCompletedDates.contains(dayStr);
                final bool isToday = day.year == now.year && day.month == now.month && day.day == now.day;

                return Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday ? _greenColor : _subtitleColor,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF27A770)
                            : (isToday
                                ? _greenColor.withOpacity(0.15)
                                : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9))),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: _greenColor, width: 2)
                            : Border.all(
                                color: isCompleted
                                    ? const Color(0xFF27A770)
                                    : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                                width: 1.5,
                              ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                "${day.day}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? _greenColor : _textColor,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
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

    // Ensure _hadisIndex is within bounds after filtering
    if (_hadisIndex >= filtered.length) {
      _hadisIndex = 0;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // 1. Background image
          Positioned.fill(
            child: Image.asset(
              'assets/hadis_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Koyu maske
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // 3. İçerik
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Cam-morfik arama çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _hadisSearchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Hadislerde ara...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _hadisSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    setState(() {
                                      _hadisSearchController.clear();
                                      _hadisSearchQuery = "";
                                      _hadisIndex = 0;
                                      if (_hadisPageController.hasClients) {
                                        _hadisPageController.jumpToPage(0);
                                      }
                                    });
                                  },
                                )
                              : null,
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _hadisSearchQuery = val;
                            _hadisIndex = 0;
                            if (_hadisPageController.hasClients) {
                              _hadisPageController.jumpToPage(0);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hadis alanı
                if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Text(
                              "Aranan kriterde hadis bulunamadı.",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  // PageView area
                  Expanded(
                    child: PageView.builder(
                      controller: _hadisPageController,
                      itemCount: filtered.length,
                      onPageChanged: (index) {
                        setState(() {
                          _hadisIndex = index;
                        });
                      },
                      itemBuilder: (context, idx) {
                        final hadis = filtered[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      // Hadis No Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF27A770).withOpacity(0.8),
                                              const Color(0xFF1E5E43).withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: Text(
                                          "HADİS-İ ŞERİF #${hadis['no']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Quote Icon
                                      Icon(
                                        Icons.format_quote_rounded,
                                        size: 36,
                                        color: const Color(0xFF27A770).withOpacity(0.7),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Hadis Text (Scrollable if too long)
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics: const BouncingScrollPhysics(),
                                          child: Text(
                                            "“${hadis['metin']}”",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w400,
                                              height: 1.6,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black38,
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      const Divider(color: Colors.white24, thickness: 1, indent: 20, endIndent: 20),
                                      const SizedBox(height: 12),
                                      
                                      // Kaynak
                                      Text(
                                        "Kaynak: ${hadis['kaynak']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.75),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Actions Panel (Copy)
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: "${hadis['metin']}\n\nKaynak: ${hadis['kaynak']}"),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: const [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Text("Hadis panoya kopyalandı!"),
                                                ],
                                              ),
                                              backgroundColor: const Color(0xFF27A770),
                                              duration: const Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(color: Colors.white12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                "Hadisi Kopyala",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Alt Kontrol Barları
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Geri
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                              onPressed: _hadisIndex > 0
                                  ? () {
                                      _hadisPageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                            ),
                            
                            // Sayfa ve Karıştır Butonu
                            InkWell(
                              onTap: () {
                                if (filtered.length > 1) {
                                  final random = math.Random();
                                  int nextIdx = _hadisIndex;
                                  while (nextIdx == _hadisIndex) {
                                    nextIdx = random.nextInt(filtered.length);
                                  }
                                  _hadisPageController.animateToPage(
                                    nextIdx,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shuffle_rounded, color: Colors.white70, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${_hadisIndex + 1} / ${filtered.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // İleri
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                              onPressed: _hadisIndex < filtered.length - 1
                                  ? () {
                                      _hadisPageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
  // 17. Günlük Dualar (Dualar V2)
  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'sabah_aksam':
        return "☀️ Sabah & Akşam Ezkarı";
      case 'namaz':
        return "🕋 Namaz Duaları";
      case 'uyku':
        return "🛌 Uyku Duaları";
      case 'yolculuk':
        return "🚗 Yolculuk Duaları";
      case 'yemek':
        return "🍽️ Yemek Duaları";
      case 'genel':
      default:
        return "🤲 Genel Dualar";
    }
  }

  Widget _buildGunlukDualar() {
    final bool dark = _isDark;
    final List<Map<String, String>> sourceList = _dualarTab == 0 ? KURAN_DUALARI : HADIS_DUALARI;

    final queryNormalized = _normalize(_dualarSearchQuery);
    final List<Map<String, String>> filteredDualar = sourceList.where((d) {
      final matchesSearch = _normalize(d['ad'] ?? '').contains(queryNormalized) ||
          _normalize(d['anlam'] ?? '').contains(queryNormalized) ||
          _normalize(d['okunus'] ?? '').contains(queryNormalized);
      final isFav = _favoriteDualar.contains(d['id'] ?? '');
      if (_showOnlyFavorites) {
        return matchesSearch && isFav;
      }
      return matchesSearch;
    }).toList();

    final Map<String, List<Map<String, String>>> groupedDualar = {};
    for (final dua in filteredDualar) {
      final cat = dua['kategori'] ?? 'genel';
      groupedDualar.putIfAbsent(cat, () => []).add(dua);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _dualarTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _dualarTab == 0 ? _greenColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Kur'an Duaları",
                            style: TextStyle(
                              color: _dualarTab == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _dualarTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _dualarTab == 1 ? _greenColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Hadis Duaları",
                            style: TextStyle(
                              color: _dualarTab == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF131D31) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: _textColor),
                        decoration: InputDecoration(
                          hintText: "Dua ara...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: _greenColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _dualarSearchQuery = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites ? Colors.red : (dark ? const Color(0xFF131D31) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showOnlyFavorites ? Colors.red : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                        color: _showOnlyFavorites ? Colors.white : Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredDualar.isEmpty
              ? Center(
                  child: Text(
                    _showOnlyFavorites ? "Favorilere eklenmiş dua bulunamadı." : "Eşleşen dua bulunamadı.",
                    style: TextStyle(color: _subtitleColor, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
                  itemCount: groupedDualar.keys.length,
                  itemBuilder: (context, catIndex) {
                    final cat = groupedDualar.keys.elementAt(catIndex);
                    final prayers = groupedDualar[cat]!;
                    final catTitle = _getCategoryTitle(cat);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                          child: Text(
                            "$catTitle (${prayers.length})",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _goldColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...List.generate(prayers.length, (duaIndex) {
                          final dua = prayers[duaIndex];
                          final id = dua['id'] ?? '';
                          final title = dua['ad'] ?? '';
                          final source = dua['sure'] ?? dua['kaynak'] ?? '';
                          final arabic = dua['arapca'] ?? '';
                          final mean = dua['anlam'] ?? '';
                          final reading = dua['okunus'] ?? '';
                          final audio = dua['ses'] ?? '';
                          
                          final isExpanded = _expandedDualar.contains(id);
                          final isFav = _favoriteDualar.contains(id);
                          final isPlaying = _currentAudioUrl == audio && _playerState == PlayerState.playing;

                          return Card(
                            color: _cardBgColor,
                            elevation: dark ? 0 : 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedDualar.remove(id);
                                  } else {
                                    _expandedDualar.add(id);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (audio.isNotEmpty && _dualarTab != 1)
                                          GestureDetector(
                                            onTap: () => _playAudio(audio, title),
                                            child: Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: isPlaying ? _greenColor : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1)),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isPlaying ? Icons.pause : Icons.play_arrow,
                                                color: isPlaying ? Colors.white : _greenColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        if (audio.isNotEmpty && _dualarTab != 1) const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: _textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                source,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: _subtitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          onPressed: () => _toggleDuaFavorite(id),
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(height: 20),
                                      if (arabic.isNotEmpty) ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            arabic,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _greenColor,
                                              fontFamily: 'Traditional Arabic',
                                              height: 1.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (reading.isNotEmpty) ...[
                                        Text(
                                          "Okunuşu:",
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldColor),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          reading,
                                          style: TextStyle(fontSize: 13, color: _textColor, height: 1.35),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        "Anlamı:",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldColor),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        mean,
                                        style: TextStyle(fontSize: 13, color: _textColor, height: 1.4),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 18. Zekat Hesaplayıcı
  Widget _buildZekatInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Color iconColor,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          color: _textColor,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: _subtitleColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: _greenColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(prefixIcon, color: iconColor, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? _textColor : _subtitleColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              color: isRed ? const Color(0xFFFF7043) : (isBold ? _greenColor : _textColor),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZekatResultBoard(bool dark, double goldPrice, double nisapLimit) {
    final gold = double.tryParse(_goldController.text) ?? 0.0;
    final cash = double.tryParse(_cashController.text) ?? 0.0;
    final business = double.tryParse(_businessController.text) ?? 0.0;
    final debts = double.tryParse(_debtsController.text) ?? 0.0;
    final totalWealth = (gold * goldPrice) + cash + business - debts;

    final String resultStr = _zekatResult;
    final bool zekatDue = resultStr.startsWith("ZEKAT_ODENECEK:");
    final bool nisapUnder = resultStr.startsWith("TOPLAM_YOKSA_NISAP_ALTI:");
    
    String statusTitle = "";
    String statusDesc = "";
    Color statusBorderColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    if (zekatDue) {
      statusTitle = "Zekat Vermeniz Farzdır";
      statusDesc = "Toplam net varlığınız nisap sınırının üzerindedir. Vermeniz gereken yıllık zekat tutarı aşağıda gösterilmiştir.";
      statusBorderColor = _greenColor;
      statusIcon = Icons.check_circle_rounded;
    } else if (nisapUnder) {
      statusTitle = "Zekat Düşmemektedir";
      statusDesc = "Toplam net varlığınız nisap sınırının (${nisapLimit.toStringAsFixed(0)} TL) altındadır. Zekat mükellefi değilsiniz.";
      statusBorderColor = _goldColor;
      statusIcon = Icons.info_rounded;
    } else {
      statusTitle = "Zekat Düşmemektedir";
      statusDesc = "Zekata tabi net bir varlığınız bulunmamaktadır.";
      statusBorderColor = Colors.grey;
      statusIcon = Icons.remove_circle_outline_rounded;
    }

    final double zekatAmount = zekatDue ? totalWealth / 40.0 : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusBorderColor.withOpacity(dark ? 0.3 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.05 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: zekatDue ? _greenColor : (nisapUnder ? _goldColor : Colors.grey), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusDesc,
              style: TextStyle(
                fontSize: 12,
                color: _subtitleColor,
                height: 1.4,
              ),
            ),
            const Divider(height: 24),

            _buildResultRow("Altın Varlık Değeri", "${(gold * goldPrice).toStringAsFixed(0)} TL"),
            _buildResultRow("Nakit ve Döviz", "${cash.toStringAsFixed(0)} TL"),
            _buildResultRow("Ticari Varlıklar", "${business.toStringAsFixed(0)} TL"),
            _buildResultRow("Borçlar (Düşülen)", "-${debts.toStringAsFixed(0)} TL", isRed: true),
            const Divider(height: 16),
            _buildResultRow(
              "Net Varlık", 
              "${totalWealth.toStringAsFixed(0)} TL", 
              isBold: true,
            ),
            _buildResultRow("Nisap Sınırı", "${nisapLimit.toStringAsFixed(0)} TL"),
            
            if (zekatDue) ...[
              const Divider(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _greenColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _greenColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "ÖDENMESİ GEREKEN ZEKAT (%2.5)",
                      style: TextStyle(
                        fontSize: 11,
                        color: _greenColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${zekatAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} TL",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _goldColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Center(
              child: Text(
                "\"Namazı kılın, zekatı verin... Kendiniz için önden gönderdiğiniz her iyiliği Allah katında bulacaksınız.\"\n(Bakara Suresi, 110. Ayet)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: _subtitleColor,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZekatHesaplama() {
    final bool dark = _isDark;
    const double goldPrice = 3000.0;
    const double nisapLimit = 80.18 * goldPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nisap Limit Banner Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF131D31), const Color(0xFF0F1B2A)]
                    : [Colors.white, const Color(0xFFFFFDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dark ? const Color(0xFF2E2413) : const Color(0xFFD4AF37).withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.05 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _goldColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.monetization_on_rounded, color: _goldColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "2026 Yılı Nisap Miktarı",
                          style: TextStyle(
                            fontSize: 12,
                            color: _goldColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${nisapLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} TL",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "80.18 gram altın veya karşılığı. Net varlığı bu sınırın üstünde olan Müslümanların zekat vermesi farzdır.",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _subtitleColor,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Input Fields Section
          Text(
            "Zekata Tabi Varlıklarınızı Girin",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _greenColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildZekatInputField(
            controller: _goldController,
            labelText: "Altın Miktarı (Gram)",
            prefixIcon: Icons.brightness_5_rounded,
            iconColor: _goldColor,
            dark: dark,
          ),
          _buildZekatInputField(
            controller: _cashController,
            labelText: "Nakit Para ve Döviz (TL)",
            prefixIcon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF27A770),
            dark: dark,
          ),
          _buildZekatInputField(
            controller: _businessController,
            labelText: "Ticari Mal ve Varlıklar (TL)",
            prefixIcon: Icons.shopping_bag_rounded,
            iconColor: const Color(0xFF5C6BC0),
            dark: dark,
          ),
          _buildZekatInputField(
            controller: _debtsController,
            labelText: "Borçlarınız (Düşülecektir) (TL)",
            prefixIcon: Icons.remove_circle_outline_rounded,
            iconColor: const Color(0xFFFF7043),
            dark: dark,
          ),
          const SizedBox(height: 8),

          // 3. Calculate Action Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_greenColor, _greenColor.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _greenColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final gold = double.tryParse(_goldController.text) ?? 0.0;
                final cash = double.tryParse(_cashController.text) ?? 0.0;
                final business = double.tryParse(_businessController.text) ?? 0.0;
                final debts = double.tryParse(_debtsController.text) ?? 0.0;

                final totalWealth = (gold * goldPrice) + cash + business - debts;

                setState(() {
                  if (totalWealth <= 0) {
                    _zekatResult = "Zekata tabi net varlığınız bulunmamaktadır.";
                  } else if (totalWealth < nisapLimit) {
                    _zekatResult = "TOPLAM_YOKSA_NISAP_ALTI:${totalWealth.toStringAsFixed(0)}";
                  } else {
                    final zekat = totalWealth / 40.0;
                    _zekatResult = "ZEKAT_ODENECEK:${totalWealth.toStringAsFixed(0)}:${zekat.toStringAsFixed(0)}";
                  }
                });
              },
              child: const Text(
                "Zekat Hesapla",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // 4. Detailed Structured Result Card
          if (_zekatResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildZekatResultBoard(dark, goldPrice, nisapLimit),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 19. Sahabe Hayatları
  Widget _buildSahabeHayatlari() {
    final bool dark = _isDark;
    final filtered = SAHABE_HAYATLARI.where((item) {
      final name = _normalize(item['ad'].toString());
      final summary = _normalize(item['ozet'].toString());
      final query = _normalize(_sahabeSearchQuery);
      return name.contains(query) || summary.contains(query);
    }).toList();

    return Column(
      children: [
        // Premium Search bar
        TextField(
          style: TextStyle(color: _textColor),
          decoration: InputDecoration(
            hintText: "Sahabe ara...",
            hintStyle: TextStyle(color: _subtitleColor),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF27A770)),
            filled: true,
            fillColor: dark ? const Color(0xFF131D31) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: dark ? BorderSide(color: Colors.white.withOpacity(0.08)) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: dark ? BorderSide(color: Colors.white.withOpacity(0.08)) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF27A770), width: 1.5),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _sahabeSearchQuery = val;
            });
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final String name = item['ad'] ?? '';
              final String unvan = item['unvan'] ?? '';
              final bool isExpanded = _expandedSahabeAd == name;

              // Extract initials
              final cleanName = name.replaceAll("Hz. ", "").replaceAll(" (r.a.)", "").replaceAll(" (r.anha)", "").trim();
              final parts = cleanName.split(" ");
              final String initials = parts.length >= 2
                  ? "${parts[0][0]}${parts[1][0]}"
                  : (parts.isNotEmpty && parts[0].isNotEmpty ? parts[0].substring(0, math.min(2, parts[0].length)) : "S");

              return Card(
                elevation: dark ? 2 : 4,
                shadowColor: Colors.black12,
                color: dark ? const Color(0xFF131D31) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: dark ? BorderSide(color: Colors.white.withOpacity(0.06)) : BorderSide.none,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey<String>(name),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedSahabeAd = expanded ? name : null;
                      });
                    },
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF27A770).withOpacity(0.12),
                      foregroundColor: const Color(0xFF27A770),
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        unvan,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            // Özet
                            Text(
                              item['ozet'] ?? '',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontStyle: FontStyle.italic,
                                color: dark ? Colors.white70 : Colors.black87,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Hayatı
                            _buildSahabeDetailSection(
                              icon: Icons.history_edu_rounded,
                              title: "Hayatı",
                              text: item['hayat'] ?? '',
                              dark: dark,
                            ),
                            const SizedBox(height: 20),

                            // Faziletleri
                            _buildSahabeDetailSection(
                              icon: Icons.star_purple500_rounded,
                              title: "Faziletleri ve Önemli Hadiseler",
                              text: item['fazilet'] ?? '',
                              dark: dark,
                            ),
                            const SizedBox(height: 20),

                            // Efendimiz ile ilişkisi
                            _buildSahabeDetailSection(
                              icon: Icons.favorite_rounded,
                              title: "Resûlullah (s.a.v.) ile İlişkisi",
                              text: item['iliskisi'] ?? '',
                              dark: dark,
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

  Widget _buildSahabeDetailSection({
    required IconData icon,
    required String title,
    required String text,
    required bool dark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF27A770)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: dark ? Colors.white : const Color(0xFF1E5E43),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1B2A47).withOpacity(0.5) : const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: dark ? Colors.white.withOpacity(0.04) : const Color(0xFF27A770).withOpacity(0.08),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: _textColor,
            ),
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
    final bool dark = _isDark;
    final List<dynamic> steps = NAMAZ_KILMA_REHBERI[_namazKilmaErkek ? 'erkek' : 'kadin'];

    return Column(
      children: [
        // Gender Toggle Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text("Erkek Rehberi"),
              selected: _namazKilmaErkek,
              selectedColor: const Color(0xFF27A770),
              backgroundColor: dark ? const Color(0xFF1B2A47) : Colors.grey[200],
              labelStyle: TextStyle(
                color: _namazKilmaErkek ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = true;
                });
              },
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text("Kadın Rehberi"),
              selected: !_namazKilmaErkek,
              selectedColor: const Color(0xFF27A770),
              backgroundColor: dark ? const Color(0xFF1B2A47) : Colors.grey[200],
              labelStyle: TextStyle(
                color: !_namazKilmaErkek ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = false;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Vertical Step List
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Card(
                elevation: dark ? 2 : 3,
                shadowColor: Colors.black12,
                color: dark ? const Color(0xFF131D31) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: dark ? BorderSide(color: Colors.white.withOpacity(0.06)) : BorderSide.none,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Number Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF27A770),
                        foregroundColor: Colors.white,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title and Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['ad'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: dark ? Colors.white : const Color(0xFF1E5E43),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step['aciklama'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: dark ? Colors.white70 : Colors.black87,
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
    final bool dark = _isDark;
    final List<String> sections = [
      "Nasıl Alınır?",
      "Farzları",
      "Sünnetleri",
      "Bozan Durumlar"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab selector chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final active = _abdestTab == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    sections[index],
                    style: TextStyle(
                      color: active ? Colors.white : (dark ? Colors.white70 : const Color(0xFF1E5E43)),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  backgroundColor: dark ? const Color(0xFF1B2A47) : const Color(0xFFE8F5E9),
                  onSelected: (val) {
                    setState(() {
                      _abdestTab = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildAbdestTabContent(),
        ),
      ],
    );
  }

  Widget _buildAbdestTabContent() {
    final bool dark = _isDark;
    switch (_abdestTab) {
      case 0: // Nasıl Alınır? (Dikey adım listesi)
        final List<Map<String, dynamic>> steps = [
          {
            "baslik": "Niyet ve Besmele",
            "icerik": "Niyet ettim Allah rızası için abdest almaya denilerek Euzü-Besmele çekilir, eller bileklere kadar 3 defa yıkanır.",
            "farz": false,
          },
          {
            "baslik": "Ağıza Su Vermek (Mazmaza)",
            "icerik": "Sağ el ile ağıza 3 defa su verilerek ağız içi iyice çalkalanır ve temizlenir.",
            "farz": false,
          },
          {
            "baslik": "Burna Su Vermek (İstinsak)",
            "icerik": "Sağ el ile buruna 3 defa su çekilir, sol el ile burun sümkürülerek temizlenir.",
            "farz": false,
          },
          {
            "baslik": "Yüzü Yıkamak",
            "icerik": "Alın saç bitiminden çene altına ve kulak yumuşaklarına kadar tüm yüz 3 defa yıkanır.",
            "farz": true,
          },
          {
            "baslik": "Kolları Yıkamak",
            "icerik": "Önce sağ kol, sonra sol kol dirseklerle beraber 3 defa yıkanır. Kuru yer kalmamasına dikkat edilir.",
            "farz": true,
          },
          {
            "baslik": "Başı Meshetmek",
            "icerik": "Sağ el ıslatılarak başın en az dörtte biri (üst kısmı) bir defa meshedilir.",
            "farz": true,
          },
          {
            "baslik": "Kulakları Meshetmek",
            "icerik": "Eller tekrar ıslatılarak serçe parmaklarla kulak içi, baş parmaklarla kulak arkası meshedilir.",
            "farz": false,
          },
          {
            "baslik": "Boynu Meshetmek",
            "icerik": "Ellerin kalan üçer parmağının dış kısımlarıyla boynun arkası meshedilir, boğaz kısmı meshedilmez.",
            "farz": false,
          },
          {
            "baslik": "Ayakları Yıkamak",
            "icerik": "Önce sağ ayak, sonra sol ayak parmak aralarından başlanarak topuklarla beraber 3 defa yıkanır.",
            "farz": true,
          },
        ];

        return ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final bool isFarz = step['farz'] == true;
            return Card(
              elevation: dark ? 2 : 3,
              shadowColor: Colors.black12,
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: dark ? BorderSide(color: Colors.white.withOpacity(0.06)) : BorderSide.none,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Number Avatar
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isFarz ? const Color(0xFFD9534F) : const Color(0xFF27A770),
                      foregroundColor: Colors.white,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title and Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step['baslik']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: dark ? Colors.white : const Color(0xFF1E5E43),
                                  ),
                                ),
                              ),
                              if (isFarz)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9534F).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFD9534F).withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    "FARZ",
                                    style: TextStyle(
                                      color: Color(0xFFD9534F),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['icerik']!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: dark ? Colors.white70 : Colors.black87,
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
        );

      case 1: // Farzları
        final List<Map<String, String>> farzlar = [
          {
            "baslik": "Yüzü Yıkamak",
            "icerik": "Alın saç bitiminden çene altına ve kulak yumuşaklarına kadar tüm yüzün bir defa yıkanması farzdır."
          },
          {
            "baslik": "Kolları Yıkamak",
            "icerik": "Dirseklerle beraber her iki kolun bir defa yıkanması farzdır. Kuru yer kalmamasına dikkat edilmelidir."
          },
          {
            "baslik": "Başı Meshetmek",
            "icerik": "Başın en az dörtte birinin ıslak el ile meshedilmesi farzdır."
          },
          {
            "baslik": "Ayakları Yıkamak",
            "icerik": "Topuklarla beraber her iki ayağın bir defa yıkanması farzdır."
          }
        ];
        return ListView.builder(
          itemCount: farzlar.length,
          itemBuilder: (context, index) {
            final farz = farzlar[index];
            return Card(
              elevation: dark ? 2 : 3,
              color: dark ? const Color(0xFF131D31) : const Color(0xFFFDF7F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: const Color(0xFFD9534F).withOpacity(dark ? 0.2 : 0.1),
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFFD9534F),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farz['baslik']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: dark ? Colors.white : const Color(0xFFAC2925),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            farz['icerik']!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: dark ? Colors.white70 : Colors.black87,
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
        );

      case 2: // Sünnetleri
        final List<String> sunnetler = [
          "Abdeste eûzü-besmele ile başlamak.",
          "Niyet etmek (Kalben niyet sünnettir, dil ile söylemek müstehaptır).",
          "Yıkamaya elleri bileklere kadar yıkayarak başlamak.",
          "Dişleri misvak veya fırça ile, yoksa parmaklarla ovuşturarak temizlemek.",
          "Ağza ve burna üçer defa su vermek, ağızda suyu çalkalamak (mazmaza) ve burna su çekip sol elle temizlemek (istinsak).",
          "Uzvun her birini üçer defa yıkamak (üçten fazla yıkamak veya eksik yapmak mekruhtur).",
          "Uzvun her birini yıkarken ovalamak.",
          "Yıkamaya sağ taraftan başlamak.",
          "Sırayı (tertibi) gözetmek; yani önce elleri, sonra yüzü, kolları, başı meshedip ayakları yıkamak.",
          "Başın tamamını meshetmek (Kaplama mesh).",
          "Kulakları ve boynu ıslak elin dışıyla meshetmek.",
          "Uzvun biri kurumadan diğerini yıkamak (Muvâlât).",
          "Parmak aralarını hilallemek (ovuşturarak yıkamak)."
        ];
        return _buildBulletListCard(sunnetler, dark);

      case 3: // Bozan Durumlar
        final List<String> bozanlar = [
          "Ön ve arkadan idrar, dışkı, gaz, meni veya mezi gibi bir necasetin çıkması.",
          "Vücudun herhangi bir yerinden kan, irin veya sarı su gibi bir sıvının çıkıp akması (Çıktığı yerin çevresine dağılacak miktarda olması gerekir).",
          "Ağız dolusu kusmak (Safra, yemek veya kan).",
          "Uyumak (Yan yatarak veya bağdaş kurarak yaslanıp, bilincini kaybedecek şekilde uyumak).",
          "Bayılmak, delirmek veya sarhoş olmak.",
          "Namaz kılan bir kişinin, yanındakiler duyacak şekilde sesli olarak gülmesi (Namazı da abdesti de bozar).",
          "Ağlamak, inlemek veya sızlanmak gibi durumlarda namaz dışı sözler çıkması (Sadece namazı bozar, abdesti bozmaz; ancak dünyevi bir kederden dolayı ağlanmışsa abdest de bozulur)."
        ];
        return _buildBulletListCard(bozanlar, dark);

      default:
        return const SizedBox();
    }
  }

  Widget _buildBulletListCard(List<String> items, bool dark) {
    return Card(
      elevation: dark ? 2 : 3,
      color: dark ? const Color(0xFF131D31) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: dark ? BorderSide(color: Colors.white.withOpacity(0.06)) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: const Color(0xFF27A770),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 24. Gusül Rehberi
  Widget _buildGusulRehberi() {
    final bool dark = _isDark;
    final List<String> sections = [
      "Guslün Alınışı",
      "Guslün Farzları",
      "Guslün Sünnetleri",
      "Gerektiren Haller"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab selector chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final active = _gusulTab == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    sections[index],
                    style: TextStyle(
                      color: active ? Colors.white : (dark ? Colors.white70 : const Color(0xFF1E5E43)),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  backgroundColor: dark ? const Color(0xFF1B2A47) : const Color(0xFFE8F5E9),
                  onSelected: (val) {
                    setState(() {
                      _gusulTab = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildGusulTabContent(),
        ),
      ],
    );
  }

  Widget _buildGusulTabContent() {
    final bool dark = _isDark;
    switch (_gusulTab) {
      case 0: // Guslün Alınışı
        final List<Map<String, dynamic>> steps = [
          {
            "baslik": "Niyet ve Beden Temizliği",
            "icerik": "Niyet ettim Allah rızası için gusül abdesti almaya diyerek niyet edilir. Beden üzerindeki necaset ve kirler iyice yıkanır.",
            "farz": false,
          },
          {
            "baslik": "Elleri Yıkamak ve Namaz Abdesti Almak",
            "icerik": "Önce eller yıkanır. Ardından normal namaz abdesti gibi abdest alınır, ağız ve burun temizliği daha bol suyla yapılır.",
            "farz": false,
          },
          {
            "baslik": "Ağza Bolca Su Vermek",
            "icerik": "Ağza 3 kere bolca su alınarak boğaza kadar çalkalanır (Gargara yapılır, oruçlu değilken). Bu işlem guslün farzlarındandır.",
            "farz": true,
          },
          {
            "baslik": "Burna Bolca Su Vermek",
            "icerik": "Buruna 3 kere genize kadar bolca su çekilir ve temizlenir. Bu işlem guslün farzlarındandır.",
            "farz": true,
          },
          {
            "baslik": "Tüm Bedenin Yıkanması",
            "icerik": "Önce başa, sonra sağ omuza ve sol omuza üçer defa su dökülerek tüm vücut iğne ucu kadar kuru yer kalmayacak şekilde yıkanır. Bu işlem guslün farzlarındandır.",
            "farz": true,
          },
        ];

        return ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final bool isFarz = step['farz'] == true;
            return Card(
              elevation: dark ? 2 : 3,
              shadowColor: Colors.black12,
              color: dark ? const Color(0xFF131D31) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: dark ? BorderSide(color: Colors.white.withOpacity(0.06)) : BorderSide.none,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isFarz ? const Color(0xFFD9534F) : const Color(0xFF27A770),
                      foregroundColor: Colors.white,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step['baslik']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: dark ? Colors.white : const Color(0xFF1E5E43),
                                  ),
                                ),
                              ),
                              if (isFarz)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9534F).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFD9534F).withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    "FARZ",
                                    style: TextStyle(
                                      color: Color(0xFFD9534F),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['icerik']!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: dark ? Colors.white70 : Colors.black87,
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
        );

      case 1: // Guslün Farzları
        final List<Map<String, String>> farzlar = [
          {
            "baslik": "Ağza Su Vermek (Mazmaza)",
            "icerik": "Ağız içini suyla iyice yıkayıp çalkalamak ve suyu boğaza kadar ulaştırmaktır (Oruçlu olmayanların gargara yapması sünnettir)."
          },
          {
            "baslik": "Burna Su Vermek (İstinsak)",
            "icerik": "Genize kadar su çekip burnu temizlemektir. Suyun genizi sızlatacak derecede çekilmesi gerekir."
          },
          {
            "baslik": "Bütün Bedeni Yıkamak",
            "icerik": "Tepeden tırnağa tüm vücudu, saç dipleri ve kulak kıvrımları dahil olmak üzere iğne ucu kadar kuru yer kalmayacak şekilde yıkamaktır."
          }
        ];
        return ListView.builder(
          itemCount: farzlar.length,
          itemBuilder: (context, index) {
            final farz = farzlar[index];
            return Card(
              elevation: dark ? 2 : 3,
              color: dark ? const Color(0xFF131D31) : const Color(0xFFFDF7F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: const Color(0xFFD9534F).withOpacity(dark ? 0.2 : 0.1),
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFFD9534F),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farz['baslik']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: dark ? Colors.white : const Color(0xFFAC2925),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            farz['icerik']!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: dark ? Colors.white70 : Colors.black87,
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
        );

      case 2: // Guslün Sünnetleri
        final List<String> sunnetler = [
          "Gusle besmele ve niyet ile başlamak.",
          "Elleri bileklere kadar yıkamak.",
          "Avret yerlerini yıkamak ve bedende varsa pislikleri temizlemek.",
          "Gusletmeden önce normal namaz abdesti gibi abdest almak.",
          "Suyu dökünmeye baştan başlamak, sonra sağ omza ve sol omza dökmek.",
          "Başa ve omuzlara dökülen suyu üçer defa tekrarlamak.",
          "Başa ve omuzlara dökülen suyu ovalamak (Dalk yapmak).",
          "Gusül sırasında fazla su israf etmemek.",
          "Guslederken kıbleye doğru dönmemek.",
          "Gusül yaparken konuşmamak."
        ];
        return _buildBulletListCard(sunnetler, dark);

      case 3: // Gerektiren Haller
        final List<String> gerektirenler = [
          "Cünüplük hali: İster uyku halinde (rüyalanma) ister uyanıkken şehvetle meninin gelmesi.",
          "Cinsel ilişki (Meni gelmese dahi sünnet yerlerinin birleşmesiyle gusül farz olur).",
          "Kadınlarda adet (hayız) kanamasının sona ermesi.",
          "Kadınlarda lohusalık (nifas) durumunun sona ermesi."
        ];
        return _buildBulletListCard(gerektirenler, dark);

      default:
        return const SizedBox();
    }
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
    final bool dark = _isDark;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ezkarTab == 0 ? const Color(0xFF27A770) : (dark ? const Color(0xFF1F2E47) : Colors.white),
                  foregroundColor: _ezkarTab == 0 ? Colors.white : (dark ? Colors.white70 : const Color(0xFF1E5E43)),
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
                  backgroundColor: _ezkarTab == 1 ? const Color(0xFF27A770) : (dark ? const Color(0xFF1F2E47) : Colors.white),
                  foregroundColor: _ezkarTab == 1 ? Colors.white : (dark ? Colors.white70 : const Color(0xFF1E5E43)),
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
    final bool dark = _isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : const Color(0xFF1E5E43),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Kartların üzerine dokunarak zikirlerinizi çekebilirsiniz.",
          style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.grey),
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
                color: dark ? const Color(0xFF131D31) : Colors.white,
                elevation: dark ? 0 : 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent,
                    width: 1,
                  ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: dark ? Colors.white : const Color(0xFF1E5E43),
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
                                    : (dark ? const Color(0xFF27A770).withOpacity(0.2) : const Color(0xFF27A770).withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$currentCount / $hedef",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: currentCount >= hedef
                                      ? Colors.white
                                      : (dark ? const Color(0xFF81C784) : const Color(0xFF1E5E43)),
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
                          style: TextStyle(
                            fontSize: 11.5,
                            color: dark ? Colors.white70 : Colors.black54,
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
    final bool dark = _isDark;
    
    final List<Map<String, dynamic>> sartlar = [
      {
        "no": "1",
        "baslik": "Kelime-i Şehadet Getirmek",
        "kisa": "İslam'ın kapısını açan, Allah'ın birliğini ve Hz. Muhammed'in elçiliğini ikrar eden şahadet sözüdür.",
        "detay": "Kelime-i Şehadet: \"Eşhedü en lâ ilâhe illallah ve eşhedü enne Muhammeden abdühû ve resûlüh\" demektir.\n\n"
            "Anlamı: \"Ben şehadet ederim ki, Allah'tan başka hiçbir ilah yoktur. Ve yine şehadet ederim ki, Hz. Muhammed O'nun kulu ve elçisidir.\"\n\n"
            "Önemi: İslam dinine girmenin ilk ve en temel şartıdır. Kalp ile inanıp dil ile ikrar edilmesi gerekir. Müslüman olan kişi, Allah'ın tek yaratıcı olduğunu ve Hz. Muhammed'in (s.a.v.) O'nun son peygamberi olduğunu kabul etmiş olur.",
        "icon": "✨",
        "color": "0xFFEAF4FB",
        "arapca": "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ"
      },
      {
        "no": "2",
        "baslik": "Namaz Kılmak",
        "kisa": "Günde 5 vakit Rabbimizin huzuruna çıkarak secde ettiğimiz, dinin direği olan ibadettir.",
        "detay": "Namaz, akıl sağlığı yerinde ve ergenlik çağına gelmiş her Müslümana farz-ı ayındır.\n\n"
            "Namaz Vakitleri:\n"
            "• Sabah Namazı: Gün ağarmadan kılınır.\n"
            "• Öğle Namazı: Güneş tepe noktasını geçince kılınır.\n"
            "• İkindi Namazı: Öğle vakti bitip akşam vaktine kadar olan sürede kılınır.\n"
            "• Akşam Namazı: Güneş battıktan hemen sonra kılınır.\n"
            "• Yatsı Namazı: Akşam karanlığı tamamen çöktüğünde kılınır.\n\n"
            "Önemi: Peygamberimiz (s.a.v.) 'Namaz dinin direğidir' buyurmuştur. Kul ile Allah arasındaki en yakın bağ secde anıdır. Namaz insanı kötülüklerden ve hayasızlıktan korur.",
        "icon": "🕌",
        "color": "0xFFEAF7F1",
      },
      {
        "no": "3",
        "baslik": "Zekat Vermek",
        "kisa": "Yılda bir kez, dinen zengin sayılan Müslümanların mallarının %2.5'ini yoksullarla paylaşmasıdır.",
        "detay": "Zekat, dinen zengin (nisap miktarına ulaşmış) olan kişilerin yılda bir kez mallarının yüzde 2.5'ini (kırkta birini) yoksul Müslümanlara vermesidir.\n\n"
            "Zekatın Şartları:\n"
            "• Müslüman, akıllı ve ergen olmak.\n"
            "• Nisap miktarı (80.18 gram altın veya eşdeğeri) mala sahip olmak.\n"
            "• Malın üzerinden 1 tam yıl geçmiş olması.\n"
            "• Borçtan ve temel ihtiyaçlardan fazla olması.\n\n"
            "Önemi: Toplumdaki gelir adaletsizliğini giderir, zengin ile fakir arasında sevgi köprüsü kurar. Malı temizler ve bereketlendirir.",
        "icon": "💰",
        "color": "0xFFFFF7EA",
      },
      {
        "no": "4",
        "baslik": "Oruç Tutmak",
        "kisa": "Ramazan ayında, imsak vaktinden akşam vaktine kadar yeme, içme ve nefsani arzulardan uzak durmaktır.",
        "detay": "Oruç, Ramazan ayında imsak vaktinden akşam ezanına kadar niyet ederek yemekten, içmekten ve orucu bozan davranışlardan uzak durmaktır.\n\n"
            "Orucun Faydaları:\n"
            "• Nefsi terbiye eder, iradeyi güçlendirir.\n"
            "• Yoksulların ve aç kalanların halini anlamamızı sağlar, merhamet duygusunu geliştirir.\n"
            "• Vücudu dinlendirir, maddi ve manevi temizlik sağlar.\n\n"
            "Önemi: Kuran-ı Kerim bu ayda indirilmiştir. Oruç ibadeti, sadece bedensel bir açlık değil, dilimizi yalandan, elimizi haramdan koruyarak ahlakımızı güzelleştirdiğimiz külli bir ibadettir.",
        "icon": "🌙",
        "color": "0xFFFBEAEA",
      },
      {
        "no": "5",
        "baslik": "Hacca Gitmek",
        "kisa": "Maddi ve bedeni gücü yetenlerin, ömründe bir kez kutsal toprakları ziyaret edip tavaf etmesidir.",
        "detay": "Hac, durumu yeten Müslümanların ömürlerinde bir defa Zilhicce ayında Mekke'deki Kabe-i Muazzama'yı ve kutsal mekanları ziyaret ederek ibadet etmesidir.\n\n"
            "Haccın Temel Rükünleri:\n"
            "• İhrama Girmek: Belirli yasaklara uymak üzere ihram kıyafetine bürünmek.\n"
            "• Kabe'yi Tavaf Etmek: Kabe'nin etrafında dualarla 7 kez dönmek.\n"
            "• Arafat'ta Vakfe Yapmak: Arafat tepesinde dua ve yakarışta bulunmak.\n\n"
            "Önemi: Dünyanın dört bir yanından gelen milyonlarca Müslümanı ırk, dil, renk ayrımı gözetmeksizin eşitlik içinde bir araya getirir. Birlik ve beraberlik şuurunu en üst seviyeye taşır.",
        "icon": "🕋",
        "color": "0xFFEAF4FB",
      }
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF1E2D4A), const Color(0xFF131D31)]
                    : [const Color(0xFFEAF7F1), const Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF27A770).withOpacity(dark ? 0.3 : 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  "⭐",
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "İslam'ın Şartları",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : const Color(0xFF1E5E43),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "İslam dininin üzerine kurulduğu beş temel esası ve hükümlerini buradan inceleyebilirsiniz.",
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white70 : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pillars list
          ...sartlar.map((sart) {
            final String no = sart['no'];
            final String baslik = sart['baslik'];
            final String kisa = sart['kisa'];
            final String detay = sart['detay'];
            final String iconStr = sart['icon'];
            final String? arapca = sart['arapca'];
            final String colorVal = sart['color'];
            final Color baseBgColor = Color(int.parse(colorVal));

            return Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              elevation: dark ? 0 : 1.5,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: dark 
                      ? baseBgColor.withOpacity(0.15)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: const Color(0xFF27A770),
                  collapsedIconColor: dark ? Colors.white60 : Colors.black54,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: dark 
                          ? Colors.white.withOpacity(0.08)
                          : baseBgColor.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      iconStr,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    "$no. $baslik",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: dark ? Colors.white : const Color(0xFF1E5E43),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      kisa,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: dark ? Colors.white60 : Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ),
                  children: [
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.white10),
                    if (arapca != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF3F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF27A770).withOpacity(dark ? 0.3 : 0.15),
                          ),
                        ),
                        child: Text(
                          arapca,
                          style: const TextStyle(
                            fontFamily: 'Traditional Arabic',
                            fontSize: 18,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27A770),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      child: Text(
                        detay,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
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

  // 21. Dini Danışman AI Chat
  Widget _buildDiniHoca() {
    _initDiniHoca();
    final bool dark = _isDark;

    final List<String> suggestions = [
      "Abdest nasıl alınır? 💧",
      "Namazın farzları nelerdir? 🕋",
      "Gusül abdesti farzları 🚿",
      "Sehiv secdesi nedir? 🙇",
      "Zekat kimlere verilir? 💰",
      "Orucu bozan şeyler 🍽️",
      "Kaza namazı nasıl kılınır? 🕰️",
    ];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF131D31) : const Color(0xFFEBF5F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFC2E3D2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1E2D4A) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_rounded, color: _goldColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dini Danışman",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _useGeminiAI
                          ? "Yapay Zeka Modu Aktif."
                          : "Sorularınıza fıkıh kaynaklı yapay zeka yanıtları alın.",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _diniHocaScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _diniHocaMessages.length + (_diniHocaIsTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _diniHocaMessages.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _greenColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1A263B) : const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Dini Danışman yazıyor ",
                              style: TextStyle(
                                fontSize: 13,
                                color: _subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildMiniTypingIndicator(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final msg = _diniHocaMessages[index];
              final bool isMe = msg['isMe'] ?? false;
              final String text = msg['text'] ?? "";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _greenColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? _greenColor
                              : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: _buildMessageText(text, isMe),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: dark ? Colors.white70 : Colors.black54,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
                  side: BorderSide(
                    color: dark ? const Color(0xFF2E3D5A) : const Color(0xFFCBD5E1),
                  ),
                  label: Text(
                    suggestions[index],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: dark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    _handleDiniHocaSend(suggestions[index].replaceAll(RegExp(r'\s\S+$'), ''));
                  },
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0C1524) : Colors.grey[50],
            border: Border(
              top: BorderSide(color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _diniHocaInputController,
                      style: TextStyle(color: _textColor),
                      decoration: const InputDecoration(
                        hintText: "Dini Danışman'a sor...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleDiniHocaSend,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleDiniHocaSend(_diniHocaInputController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _greenColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _greenColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText(String text, bool isMe) {
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final Match match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: isMe ? Colors.white : _textColor,
        ),
      ),
    );
  }

  void _addDiniHocaReply(String reply) {
    if (!mounted) return;
    setState(() {
      _diniHocaIsTyping = false;
      _diniHocaMessages.add({
        'isMe': false,
        'text': reply,
        'time': DateTime.now(),
      });
    });
    _scrollToBottomDiniHoca();
  }

  Future<void> _callGeminiApi(String prompt) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey");
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "systemInstruction": {
            "parts": [
              {
                "text":
                    "Sen saygın, bilgili ve fıkıh kaynaklarına hakim bir İslam Dini Danışmanısın. Kullanıcıların ibadetler (namaz, abdest, oruç, zekat vb.), dualar, sureler ve dini hayat hakkındaki sorularını ehli sünnet itikadına uygun, saygılı, açıklayıcı ve güvenilir kaynaklara (Kur'an, sahih hadisler, muteber fıkıh kitapları) dayandırarak Türkçe olarak yanıtla. Siyasi, tartışmalı veya din dışı konularda yorum yapmaktan kaçın. Yanıtlarında Markdown kalın yazı (**kalın**) gibi biçimlendirmeleri güzelce kullan."
              }
            ]
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String text = data['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString() ?? "";
        if (text.isNotEmpty) {
          _addDiniHocaReply(text);
          return;
        }
      }
      
      String errorMsg = "Bilinmeyen hata";
      try {
        final Map<String, dynamic> errData = json.decode(response.body);
        errorMsg = errData['error']?['message']?.toString() ?? "API status: ${response.statusCode}";
      } catch (_) {}
      
      throw Exception("API status ${response.statusCode}: $errorMsg");
    } catch (e) {
      debugPrint("Gemini error: $e");
      final fallbackReply = _getDiniHocaResponse(prompt);
      _addDiniHocaReply(fallbackReply);
    }
  }

  void _handleDiniHocaSend(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _diniHocaInputController.clear();

    setState(() {
      _diniHocaMessages.add({
        'isMe': true,
        'text': userMsg,
        'time': DateTime.now(),
      });
      _diniHocaIsTyping = true;
    });

    _scrollToBottomDiniHoca();

    if (_useGeminiAI && _geminiApiKey.isNotEmpty) {
      _callGeminiApi(userMsg);
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        final reply = _getDiniHocaResponse(userMsg);
        _addDiniHocaReply(reply);
      });
    }
  }

  void _scrollToBottomDiniHoca() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_diniHocaScrollController.hasClients) {
        _diniHocaScrollController.animateTo(
          _diniHocaScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMiniTypingIndicator() {
    return _MiniDotAnimator(color: _subtitleColor);
  }

  String _getDiniHocaResponse(String query) {
    final q = _normalize(query);

    if (q.contains("selam") ||
        q.contains("merhaba") ||
        q.contains("hey") ||
        q.contains("nasilsin") ||
        q.contains("nasılsın") ||
        q == "sa" ||
        q == "as" ||
        q.contains("aleykum") ||
        q.contains("aleyküm")) {
      return """Ve Aleyküm Selam mümin kardeşim, hoş geldin. 😊 

Sana nasıl yardımcı olabilirim? İslamiyet, ibadetler (abdest, namaz, oruç, zekat vb.), dualar veya sureler hakkında merak ettiğin konuları bana sorabilirsin.""";
    }

    if (q.contains("peygamber") || q.contains("muhammed") || q.contains("resulullah") || q.contains("cocuk") || q.contains("çocuk")) {
      return """**Peygamber Efendimiz Hz. Muhammed (s.a.v.)'in Çocukları ve Hayatı** 🌹

Peygamber Efendimizin Hz. Hatice (r.anha) annemizden 6 çocuğu, Hz. Mâriye (r.anha) annemizden ise 1 çocuğu (İbrahim) olmak üzere toplam **7 çocuğu** olmuştur.

*Erkek Çocukları:*
1. **Kasım** (İlk çocuğudur, küçük yaşta vefat etmiştir.)
2. **Abdullah** (Küçük yaşta vefat etmiştir.)
3. **İbrahim** (Medine'de doğmuş ve küçük yaşta vefat etmiştir.)

*Kız Çocukları:*
4. **Zeynep** (En büyük kız çocuğudur.)
5. **Rukiye** (Hz. Osman ile evlenmiştir.)
6. **Ümmü Gülsüm** (Rukiye'nin vefatından sonra Hz. Osman ile evlenmiştir.)
7. **Fatıma** (Peygamberimizin soyunu devam ettiren, Hz. Ali ile evlenen en sevgili kızıdır.)""";
    }

    if (q.contains("sart") || q.contains("şart") || q.contains("iman") || q.contains("islam")) {
      return """**İslam'ın ve İmanın Şartları** 🕌

**A) İslam'ın Şartları (5'tir):**
1. Kelime-i Şehadet getirmek.
2. Namaz kılmak.
3. Zekat vermek.
4. Oruç tutmak.
5. Hacca gitmek.

**B) İmanın Şartları (6'dır):**
1. Allah'ın varlığına ve birliğine inanmak.
2. Meleklere inanmak.
3. Kitaplara inanmak.
4. Peygamberlere inanmak.
5. Ahiret gününe inanmak.
6. Kadere, hayır ve şerrin Allah'tan geldiğine inanmak.""";
    }

    if (q.contains("abdest")) {
      return """**Abdest Nasıl Alınır?** 💧

Abdest, belirli uzuvları usulüne uygun yıkamak ve mesh etmekten ibaret ibadet temizliğidir. Sırasıyla şu şekildedir:

1. **Niyet ve Besmele**: "Niyet ettim Allah rızası için abdest almaya" denir ve Eûzü-Besmele çekilir.
2. **Elleri Yıkamak**: Eller bileklere kadar üç defa yıkanır. Parmak araları hilallenir.
3. **Ağza Su Vermek**: Sağ el ile ağıza üç kere su verilip çalkalanır.
4. **Buruna Su Vermek**: Sağ el ile buruna üç kere su çekilip sol el ile temizlenir.
5. **Yüzü Yıkamak**: Alından çene altına, kulak yumuşaklarına kadar yüzün tamamı üç kere yıkanır.
6. **Kolları Yıkamak**: Önce sağ, sonra sol kol dirseklerle beraber üç kere yıkanır.
7. **Başı Mesh Etmek**: Sağ elin içi ıslatılarak başın dörtte biri mesh edilir.
8. **Kulak ve Boynu Mesh Etmek**: Parmaklar ıslatılarak kulakların içi ve arkası mesh edilir, elin dışı ile boyun mesh edilir.
9. **Ayakları Yıkamak**: Önce sağ, sonra sol ayak topuklarla birlikte, parmak aralarından başlanarak üç kere yıkanır.

**Abdestin Farzları (4'tür):**
1. Yüzü bir kere yıkamak.
2. Kolları dirseklerle beraber bir kere yıkamak.
3. Başın dörtte birini mesh etmek.
4. Ayakları topuklarla beraber bir kere yıkamak.""";
    }

    if (q.contains("gusul") || q.contains("gusül") || q.contains("boy abdesti")) {
      return """**Gusül Abdesti (Boy Abdesti) Nasıl Alınır?** 🚿

Gusül, bütün vücudun temiz suyla iğne ucu kadar kuru yer kalmayacak şekilde yıkanmasıdır.

**Guslün Farzları (3'tür):**
1. **Ağıza Bolca Su Vermek (Mazmaza)**: Boğaza kadar su götürüp çalkalamak (3 defa).
2. **Buruna Bolca Su Vermek (İstinşak)**: Burun kemiği sızlayacak kadar derine su çekmek (3 defa).
3. **Bütün Vücudu Yıkamak**: Tepeden tırnağa kuru yer kalmayacak şekilde yıkanmak.

**Sünnete Uygun Gusül Alınışı:**
- Niyet edilir: *"Niyet ettim Allah rızası için boy abdesti almaya."* Besmele çekilir.
- Önce eller ve avret yerleri yıkanır, varsa vücuttaki kirler temizlenir.
- Namaz abdesti gibi tam bir abdest alınır (ağız ve buruna su bolca verilir).
- Önce başa, sonra sağ omuza, sonra sol omuza üçer defa su dökülür. Her su döküşte vücut ovulur.
- Vücutta iğne ucu kadar kuru yer kalmamasına dikkat edilir (göbek çukuru, küpe delikleri vb. ıslatılmalıdır).""";
    }

    if (q.contains("namaz")) {
      return """**Namazın Farzları Nelerdir?** 🕋

Namazın dışındaki (şartları) ve içindeki (rüknü) olmak üzere toplam **12 farzı** vardır.

**A) Dışındaki Farzlar (Şartlar):**
1. **Hadesten Taharet**: Abdest veya gusül almak.
2. **Necasetten Taharet**: Vücut, elbise ve namaz kılınacak yerin temiz olması.
3. **Setr-i Avret**: Vücudun örtülmesi gereken yerlerini örtmek.
4. **İstikbal-i Kıble**: Namaz kılarken Kıble'ye (Kabe'ye) dönmek.
5. **Vakit**: Namazı kendi vakti içinde kılmak.
6. **Niyet**: Kılınacak namaza niyet etmek.

**B) İçindeki Farzlar (Rükünler):**
1. **İftitah Tekbiri**: Namaza "Allahu Ekber" diyerek başlamak.
2. **Kıyam**: Ayakta durmak (ayakta duramayanlar oturarak kılabilir).
3. **Kıraat**: Namazda ayaktayken Kur'an okumak (Fatiha ve sure).
4. **Rükû**: Elleri dizlere koyup eğilmek ve üç defa *"Sübhane Rabbiye'l-Azîm"* demek.
5. **Secde**: Alnı ve burnu yere koyup iki kez secde etmek ve *"Sübhane Rabbiye'l-A'lâ"* demek.
6. **Ka'de-i Âhire**: Son rekatta Ettehiyyatü duasını okuyacak kadar oturmak.""";
    }

    if (q.contains("oruc") || q.contains("oruç")) {
      return """**Orucu Bozan ve Bozmayan Şeyler** 🌙

**A) Orucu Bozan Şeyler (Hem Kaza Hem Keffaret Gerektirenler):**
- Bilerek bir şey yemek, içmek.
- İlaç yutmak veya sigara içmek.

**B) Orucu Bozan Ama Sadece Kaza Gerektirenler (1 Gün Kaza):**
- Unutarak yiyip içtikten sonra orucun bozulduğunu sanarak bilerek yemeye devam etmek.
- Buruna ilaç damlatmak veya kulağa ağrı kesici damla damlatmak.
- İmsak vaktinin girmediğini veya iftar vaktinin geldiğini sanarak hataen yiyip içmek.

**C) Orucu Bozmayan Şeyler:**
- Unutarak yemek, içmek (hatırlayınca hemen ağız çalkalanıp oruca devam edilir).
- Ağza giren yağmur damlasını istem dışı yutmak.
- Diş fırçalamak (macun yutulmamak kaydıyla).
- Kan vermek, banyo yapmak, göze damla damlatmak.
- Parfüm veya kolonya koklamak.""";
    }

    if (q.contains("zekat") || q.contains("zekât")) {
      return """**Zekat Kimlere Verilir ve Miktarı Nedir?** 💰

Zekat, dinen zengin sayılan Müslümanların, yılda bir kez mallarının belirli bir kısmını fakirlere vermesidir.

**Zekat Kimlere Verilir? (Tevbe Suresi 60. Ayet):**
1. Fakirler ve miskinler (hiçbir şeyi olmayanlar).
2. Borçlular (borcunu ödeyemeyecek durumda olanlar).
3. Yolda kalmış yolcular.
4. Allah yolunda olanlar (ilim talebeleri, cihat edenler).

**Zekat Kimlere Verilmez?**
- Anneye, babaya, büyükanne ve büyükbabalara.
- Çocuklara ve torunlara.
- Gayrimüslimlere.
- Zengin kişilere.
- Eşlerin birbirine zekat vermesi caiz değildir.

**Zekat Miktarı ve Şartları:**
- Kişinin temel ihtiyaçları ve borçları dışında **80.18 gram altın** veya muadili para/ticaret malına (Nisap miktarı) sahip olması gerekir.
- Bu malın üzerinden **1 tam kameri yıl** geçmiş olmalıdır.
- Zekat oranı genelde **1/40 yani %2.5**'tir.""";
    }

    if (q.contains("sehiv")) {
      return """**Sehiv Secdesi Nedir ve Nasıl Yapılır?** 🙇

Sehiv secdesi (yanılma secdesi), namaz kılarken farzların geciktirilmesi veya vaciplerin unutularak terk edilmesi veya geciktirilmesi durumunda namazın sonunda yapılan secdedir. Namazdaki eksikliği tamamlar.

**Nasıl Yapılır?**
1. Son rekatta oturup sadece **Ettehiyyatü** duası okunur.
2. Sağ tarafa selam verilir. (Bazı görüşlere göre iki tarafa da selam verilebilir.)
3. Selamdan hemen sonra *"Allahu Ekber"* denilerek secdeye gidilir.
4. Secdede üç defa *"Sübhane Rabbiye'l-A'lâ"* denir, doğrulunur ve tekrar secdeye gidilir.
5. İkinci secdeden sonra oturulur ve **Ettehiyyatü, Salli, Barik ve Rabbena** duaları okunarak her iki tarafa da selam verilerek namaz tamamlanır.""";
    }

    if (q.contains("kaza")) {
      return """**Kaza Namazı Nasıl Kılınır?** 🕰️

Kaza namazı, vaktinde kılınamamış olan farz namazların sonradan kılınmasıdır.

**Kaza Namazının Şartları ve Kılınışı:**
- Sadece **farz namazlar ve vitir namazı** kaza edilir (Sünnetlerin kazası olmaz, sadece sabah namazı o günün öğle vaktine kadar kaza edilirse sünneti de kılınabilir).
- Niyet edilirken hangi vaktin kazası olduğu belirtilir: *"Niyet ettim Allah rızası için en son kazaya kalan Sabah namazının farzını kılmaya."*
- Sırasıyla kılınır. Kaza namazları kılınırken kerahat vakitleri (güneş doğarken, tam tepedeyken ve batarken) dışında her vakit kılınabilir.
- Günlük kaçırılan namaz miktarı:
  - Sabah: 2 rekat farz.
  - Öğle: 4 rekat farz.
  - İkindi: 4 rekat farz.
  - Akşam: 3 rekat farz.
  - Yatsı: 4 rekat farz + 3 rekat Vitir vacip.""";
    }

    if (q.contains("dua") || q.contains("zikir")) {
      return """**Dua ve Zikir Kavramları** 🤲

**Dua**: Kulun halini Yaradan'a arz etmesi, isteklerini O'ndan dilemesidir. Kur'an-ı Kerim'de *"Bana dua edin, size cevap vereyim"* (Mü'min, 60) buyurulmuştur. Dua, ibadetin özüdür.

**Zikir**: Allah'ı anmak, hatırlamak ve kalpte canlı tutmaktır. Kalpler ancak Allah'ı anmakla huzur bulur.

**Önemli Zikirlerin Faziletleri:**
- **Sübhanallah**: Allah'ı tüm noksanlıklardan tenzih etmektir.
- **Elhamdülillah**: Nimete karşı hamd etmektir, mizanı doldurur.
- **Allahu Ekber**: Allah'ın her şeyden büyük ve yüce olduğunu ikrar etmektir.
- **La ilahe illallah**: Zikrin en faziletlisidir, tevhid beyanıdır.""";
    }

    return """Değerli mümin kardeşim, sorduğunuz konuyu tam olarak anlayamadım veya kelime haznemde yer almıyor olabilir. 

Lütfen sorunuzu daha açık kelimelerle sorunuz. Örneğin; **abdest alışı, guslün farzları, namazın farzları, sehiv secdesi, zekat verilecek kişiler, orucu bozan şeyler veya kaza namazları** gibi konularda doğrudan anahtar kelimeler kullanarak sorarsanız size çok daha detaylı bilgi aktarabilirim. 

Fıkhi konulardaki en doğru ve kesin hükümler için Diyanet İşleri Başkanlığı'nın resmi fetvalarına veya muteber fıkıh kitaplarına başvurmanızı tavsiye ederim.""";
  }

  // 22. Aylık Namaz Vakitleri V2
  static const List<Map<String, dynamic>> vakitMeta = [
    {'name': 'İmsak', 'key': 'Imsak', 'icon': Icons.nights_stay, 'color': Color(0xFF5C6BC0)},
    {'name': 'Güneş', 'key': 'Gunes', 'icon': Icons.wb_twilight, 'color': Color(0xFFFFB300)},
    {'name': 'Öğle', 'key': 'Ogle', 'icon': Icons.wb_sunny, 'color': Color(0xFFF57C00)},
    {'name': 'İkindi', 'key': 'Ikindi', 'icon': Icons.wb_sunny_outlined, 'color': Color(0xFF8D6E63)},
    {'name': 'Akşam', 'key': 'Aksam', 'icon': Icons.flare, 'color': Color(0xFFFF7043)},
    {'name': 'Yatsı', 'key': 'Yatsi', 'icon': Icons.brightness_3, 'color': Color(0xFF3F51B5)},
  ];

  Map<String, String> _getNextPrayerInfo(Map<String, dynamic> todayTimes) {
    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final times = [
        {'name': 'İmsak', 'time': todayTimes['Imsak'] ?? ''},
        {'name': 'Güneş', 'time': todayTimes['Gunes'] ?? ''},
        {'name': 'Öğle', 'time': todayTimes['Ogle'] ?? ''},
        {'name': 'İkindi', 'time': todayTimes['Ikindi'] ?? ''},
        {'name': 'Akşam', 'time': todayTimes['Aksam'] ?? ''},
        {'name': 'Yatsı', 'time': todayTimes['Yatsi'] ?? ''},
      ];

      for (final t in times) {
        final timeStr = t['time'] as String;
        if (timeStr.isEmpty) continue;
        final parts = timeStr.split(':');
        if (parts.length < 2) continue;
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final prayerMinutes = hour * 60 + minute;

        if (prayerMinutes > currentMinutes) {
          final diff = prayerMinutes - currentMinutes;
          final diffHours = diff ~/ 60;
          final diffMins = diff % 60;
          final remainingStr = diffHours > 0 
              ? "$diffHours saat $diffMins dk" 
              : "$diffMins dk";
          return {
            'name': t['name']!,
            'time': timeStr,
            'remaining': remainingStr,
          };
        }
      }

      // If all prayer times of today have passed, the next prayer is tomorrow's İmsak
      return {
        'name': 'İmsak',
        'time': '',
        'remaining': 'Yarın sabah',
      };
    } catch (e) {
      return {'name': '', 'time': '', 'remaining': ''};
    }
  }

  Widget _buildAylikNamazVakitleri() {
    final bool dark = _isDark;

    if (_loadingMonthlyTimes) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Namaz Vakitleri Yükleniyor...",
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_monthlyPrayerTimes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              Text(
                "Namaz Vakitleri Alınamadı",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lütfen internet bağlantınızı kontrol edip tekrar deneyin veya konum ayarlarınızı güncelleyin.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: _subtitleColor, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";

    // Find today's times for countdown
    final todayIndex = _monthlyPrayerTimes.indexWhere((t) => (t['MiladiTarihKisa'] ?? '') == todayStr);
    final todayTimes = todayIndex != -1 ? _monthlyPrayerTimes[todayIndex] : null;
    final nextPrayer = todayTimes != null ? _getNextPrayerInfo(todayTimes) : null;
    final String hicriBugun = todayTimes != null ? (todayTimes['HicriTarihUzun'] ?? '') : '';

    return Column(
      children: [
        // Redesigned Location & Countdown Header Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: dark
                  ? [const Color(0xFF131D31), const Color(0xFF0F1B2A)]
                  : [Colors.white, const Color(0xFFEAF7F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFF27A770).withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.05 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _greenColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on, color: _greenColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentLocationName.isNotEmpty ? _currentLocationName : "İstanbul",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hicriBugun.isNotEmpty ? hicriBugun : "Aylık Namaz Vakitleri",
                            style: TextStyle(
                              fontSize: 12,
                              color: _goldColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.mosque_rounded, color: _goldColor.withOpacity(0.4), size: 36),
                  ],
                ),
                if (nextPrayer != null && nextPrayer['name']!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_filled, color: _goldColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "Sıradaki Vakit: ",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${nextPrayer['name']}",
                            style: TextStyle(
                              fontSize: 13,
                              color: _textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _greenColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          nextPrayer['remaining'] == 'Yarın sabah'
                              ? "Yarın sabah"
                              : "${nextPrayer['remaining']} kaldı",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _greenColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Sliding Mode Switcher Pill
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Container(
            height: 46,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _monthlyViewMode = 0),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _monthlyViewMode == 0 ? _greenColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Liste Görünümü",
                        style: TextStyle(
                          color: _monthlyViewMode == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _monthlyViewMode = 1;
                        final idx = _monthlyPrayerTimes.indexWhere((t) => (t['MiladiTarihKisa'] ?? '') == todayStr);
                        _selectedCalendarDayIndex = idx != -1 ? idx : 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _monthlyViewMode == 1 ? _greenColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Takvim Görünümü",
                        style: TextStyle(
                          color: _monthlyViewMode == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        Expanded(
          child: _monthlyViewMode == 0
              ? _buildMonthlyListView(dark, todayStr)
              : _buildMonthlyCalendarView(dark, todayStr),
        ),
      ],
    );
  }

  Widget _buildMonthlyListView(bool dark, String todayStr) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
      itemCount: _monthlyPrayerTimes.length,
      itemBuilder: (context, index) {
        final day = _monthlyPrayerTimes[index];
        final String dateStr = day['MiladiTarihKisa'] ?? '';
        final isToday = dateStr == todayStr;

        final String dateUzun = day['MiladiTarihUzun'] ?? '';
        final String hicriStr = day['HicriTarihUzun'] ?? '';
        
        final isExpanded = _expandedAylikDays.contains(dateStr) || 
            (isToday && !_expandedAylikDays.contains("${dateStr}_collapsed"));

        // Format nice card date display
        final List<String> dateParts = dateUzun.split(' ');
        String dayNum = dateStr.split('.')[0];
        if (dayNum.startsWith('0')) dayNum = dayNum.substring(1);
        
        String monthAndDay = "";
        if (dateParts.length >= 4) {
          final String mName = dateParts[1];
          final String dName = dateParts[3];
          monthAndDay = "$mName, $dName";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isToday
                  ? _greenColor
                  : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
              width: isToday ? 2.0 : 1.0,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: _greenColor.withOpacity(dark ? 0.2 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.05 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: [
              // Day Card Header (Tap to Expand)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isToday) {
                      if (_expandedAylikDays.contains("${dateStr}_collapsed")) {
                        _expandedAylikDays.remove("${dateStr}_collapsed");
                      } else {
                        _expandedAylikDays.add("${dateStr}_collapsed");
                      }
                    } else {
                      if (_expandedAylikDays.contains(dateStr)) {
                        _expandedAylikDays.remove(dateStr);
                      } else {
                        _expandedAylikDays.add(dateStr);
                      }
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      // Date Number Icon Badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isToday 
                              ? _greenColor 
                              : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1)),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayNum,
                          style: TextStyle(
                            color: isToday ? Colors.white : _greenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date descriptions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isToday ? "Bugün" : monthAndDay,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? _greenColor : _textColor,
                                  ),
                                ),
                                if (isToday) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _goldColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Bugün",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hicriStr,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Anchor Summary (İmsak & Akşam times show collapsed)
                      if (!isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Text(
                                "İ: ${day['Imsak']}",
                                style: TextStyle(fontSize: 11.5, color: _subtitleColor, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "A: ${day['Aksam']}",
                                style: TextStyle(fontSize: 11.5, color: _greenColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: isToday ? _greenColor : _subtitleColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Symmetrical 6-Grid View
              if (isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: vakitMeta.map((meta) {
                      final String value = day[meta['key']] ?? '';
                      final IconData icon = meta['icon'];
                      final Color color = meta['color'];

                      return Container(
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E2D4A).withOpacity(0.5) : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dark ? const Color(0xFF2E3D5A) : const Color(0xFFF1F5F9),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon, color: color, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  meta['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyCalendarView(bool dark, String todayStr) {
    final headerColor = dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9);
    const colWidths = {
      0: FlexColumnWidth(1.2), // Tarih
      1: FlexColumnWidth(1.0), // İmsak
      2: FlexColumnWidth(1.0), // Güneş
      3: FlexColumnWidth(1.0), // Öğle
      4: FlexColumnWidth(1.0), // İkindi
      5: FlexColumnWidth(1.0), // Akşam
      6: FlexColumnWidth(1.0), // Yatsı
    };

    return Card(
      color: _cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: dark ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Table(
                columnWidths: colWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      _buildTableHeaderCell("Tarih", dark),
                      _buildTableHeaderCell("İmsak", dark),
                      _buildTableHeaderCell("Güneş", dark),
                      _buildTableHeaderCell("Öğle", dark),
                      _buildTableHeaderCell("İkindi", dark),
                      _buildTableHeaderCell("Akşam", dark),
                      _buildTableHeaderCell("Yatsı", dark),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            
            // Table Body (Scrollable)
            Expanded(
              child: ListView.builder(
                itemCount: _monthlyPrayerTimes.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final day = _monthlyPrayerTimes[index];
                  final String dateStr = day['MiladiTarihKisa'] ?? '';
                  final bool isToday = dateStr == todayStr;
                  
                  // Format date nice & short (e.g. "04 Haz")
                  final String dateUzun = day['MiladiTarihUzun'] ?? '';
                  final List<String> parts = dateUzun.split(' ');
                  String formattedDate = dateStr; // Fallback
                  if (parts.length >= 4) {
                    final String dayNum = parts[0].padLeft(2, '0');
                    String monthName = parts[1];
                    if (monthName.length > 3) monthName = monthName.substring(0, 3);
                    formattedDate = "$dayNum $monthName";
                  }
                  
                  // Row backgrounds
                  final Color rowBg = isToday
                      ? _greenColor.withOpacity(dark ? 0.15 : 0.1)
                      : (index % 2 == 0
                          ? (dark ? const Color(0xFF1E2D4A).withOpacity(0.3) : const Color(0xFFF8FAFC))
                          : Colors.transparent);
                          
                  final BorderSide borderSide = isToday
                      ? BorderSide(color: _greenColor, width: 1.5)
                      : BorderSide(color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9), width: 0.5);

                  return Container(
                    decoration: BoxDecoration(
                      color: rowBg,
                      border: Border(
                        bottom: borderSide,
                        top: isToday ? borderSide : BorderSide.none,
                        left: isToday ? borderSide : BorderSide.none,
                        right: isToday ? borderSide : BorderSide.none,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Table(
                      columnWidths: colWidths,
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                formattedDate,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday ? _goldColor : _textColor,
                                ),
                              ),
                            ),
                            _buildTableCell(day['Imsak'] ?? '', isToday, dark),
                            _buildTableCell(day['Gunes'] ?? '', isToday, dark),
                            _buildTableCell(day['Ogle'] ?? '', isToday, dark),
                            _buildTableCell(day['Ikindi'] ?? '', isToday, dark),
                            _buildTableCell(day['Aksam'] ?? '', isToday, dark),
                            _buildTableCell(day['Yatsi'] ?? '', isToday, dark),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String title, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: dark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(String value, bool isToday, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: isToday ? _greenColor : _textColor,
        ),
      ),
    );
  }

}


class _MiniDotAnimator extends StatefulWidget {
  final Color color;

  const _MiniDotAnimator({required this.color});

  @override
  State<_MiniDotAnimator> createState() => _MiniDotAnimatorState();
}

class _MiniDotAnimatorState extends State<_MiniDotAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double animVal = math.sin((_controller.value * math.pi * 2) - (index * math.pi / 2));
            final double scale = 0.5 + 0.5 * (animVal + 1.0) / 2.0;
            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _KibleRadarPainter extends CustomPainter {
  final double needleRotation;
  final bool isAligned;
  final bool isDark;

  _KibleRadarPainter({
    required this.needleRotation,
    required this.isAligned,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Paint radar background
    final bgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0F1B2A).withOpacity(0.4)
          : const Color(0xFFEAF7F1).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Paint concentric radar rings
    final ringPaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.3)
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.3) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.45, ringPaint);

    // 3. Paint crosshairs
    final linePaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.4)
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.25) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // 4. Draw radar angle scale ticks (every 10 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * math.pi / 180;
      final bool isMajor = i % 30 == 0;

      final double tickLength = isMajor ? 8 : 4;
      final double startR = radius;
      final double endR = radius - tickLength;

      tickPaint.color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.5)
          : (isDark ? Colors.white24 : Colors.black12);
      tickPaint.strokeWidth = isMajor ? 1.5 : 1.0;

      final Offset startPoint = Offset(
        center.dx + startR * math.cos(angle),
        center.dy + startR * math.sin(angle),
      );
      final Offset endPoint = Offset(
        center.dx + endR * math.cos(angle),
        center.dy + endR * math.sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // 5. Draw active radar scanning beam
    final double radAngle = (needleRotation - 90) * math.pi / 180;

    final sweepPaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.15)
          : (isDark ? const Color(0xFFD4AF37).withOpacity(0.08) : const Color(0xFF27A770).withOpacity(0.08))
      ..style = PaintingStyle.fill;

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        radAngle - 0.2,
        0.4,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    // 6. Draw outer target marker (red bracket at the top)
    final targetPaint = Paint()
      ..color = isAligned ? const Color(0xFF27A770) : Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double bracketW = 16;
    final double bracketH = 8;
    final bracketPath = Path()
      ..moveTo(center.dx - bracketW, bracketH)
      ..lineTo(center.dx - bracketW, 0)
      ..lineTo(center.dx + bracketW, 0)
      ..lineTo(center.dx + bracketW, bracketH);
    canvas.drawPath(bracketPath, targetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// YENİ EKLENEN YARDIMCI BİLEŞENLER VE ÇİZİCİLER
// ==========================================

class QuranEqualizer extends StatefulWidget {
  final bool isPlaying;
  const QuranEqualizer({super.key, required this.isPlaying});

  @override
  State<QuranEqualizer> createState() => _QuranEqualizerState();
}

class _QuranEqualizerState extends State<QuranEqualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heightMultiplier = List.generate(10, (index) => 0.2 + (index * 0.08));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant QuranEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(10, (index) {
              final double value = widget.isPlaying
                  ? math.sin(_controller.value * math.pi * 2 + (index * 0.8))
                  : 0.0;
              final double height = 10 + (value.abs() * 35 * (0.5 + 0.5 * _heightMultiplier[index]));
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27A770), Color(0xFFD4AF37)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class NamazPosturePainter extends CustomPainter {
  final String posture;
  final bool isErkek;
  final bool isDark;

  NamazPosturePainter({
    required this.posture,
    required this.isErkek,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    // Background Grid
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;
    const double gridSize = 20.0;
    for (double i = 0; i < w; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), gridPaint);
    }
    for (double i = 0; i < h; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(w, i), gridPaint);
    }

    // Floor Line
    final floorPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black26
      ..strokeWidth = 2;
    canvas.drawLine(Offset(10, h - 20), Offset(w - 10, h - 20), floorPaint);

    final strokeColor = const Color(0xFF27A770);
    final accentColor = const Color(0xFFD4AF37);

    final linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final clothesPaint = Paint()
      ..color = strokeColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final headPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final headOutlinePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double headRadius = 14.0;

    if (posture.contains('Tekbir') || posture.contains('Niyet')) {
      final headCenter = Offset(cx, 40);
      final shoulderY = 60.0;
      final hipY = 110.0;
      final footY = h - 20.0;

      final Path clothesPath = Path()
        ..moveTo(cx - 15, shoulderY)
        ..lineTo(cx + 15, shoulderY)
        ..lineTo(cx + 20, hipY)
        ..lineTo(cx + 25, footY)
        ..lineTo(cx - 25, footY)
        ..lineTo(cx - 20, hipY)
        ..close();
      canvas.drawPath(clothesPath, clothesPaint);

      canvas.drawLine(Offset(cx, shoulderY), Offset(cx, hipY), linePaint);
      canvas.drawLine(Offset(cx - 10, hipY), Offset(cx - 12, footY), linePaint);
      canvas.drawLine(Offset(cx + 10, hipY), Offset(cx + 12, footY), linePaint);

      if (isErkek) {
        canvas.drawLine(Offset(cx - 15, shoulderY), Offset(cx - 30, shoulderY - 10), linePaint);
        canvas.drawLine(Offset(cx - 30, shoulderY - 10), Offset(cx - 25, headCenter.dy), linePaint);
        canvas.drawLine(Offset(cx + 15, shoulderY), Offset(cx + 30, shoulderY - 10), linePaint);
        canvas.drawLine(Offset(cx + 30, shoulderY - 10), Offset(cx + 25, headCenter.dy), linePaint);
      } else {
        canvas.drawLine(Offset(cx - 15, shoulderY), Offset(cx - 22, shoulderY + 5), linePaint);
        canvas.drawLine(Offset(cx - 22, shoulderY + 5), Offset(cx - 18, shoulderY - 10), linePaint);
        canvas.drawLine(Offset(cx + 15, shoulderY), Offset(cx + 22, shoulderY + 5), linePaint);
        canvas.drawLine(Offset(cx + 22, shoulderY + 5), Offset(cx + 18, shoulderY - 10), linePaint);
      }

      canvas.drawCircle(headCenter, headRadius, headPaint);
      canvas.drawCircle(headCenter, headRadius, headOutlinePaint);

    } else if (posture.contains('Kıyam') || posture.contains('Kıraat') || posture.contains('Ayakta')) {
      final headCenter = Offset(cx, 40);
      final shoulderY = 60.0;
      final hipY = 110.0;
      final footY = h - 20.0;

      final Path clothesPath = Path()
        ..moveTo(cx - 15, shoulderY)
        ..lineTo(cx + 15, shoulderY)
        ..lineTo(cx + 20, hipY)
        ..lineTo(cx + 25, footY)
        ..lineTo(cx - 25, footY)
        ..lineTo(cx - 20, hipY)
        ..close();
      canvas.drawPath(clothesPath, clothesPaint);

      canvas.drawLine(Offset(cx, shoulderY), Offset(cx, hipY), linePaint);
      canvas.drawLine(Offset(cx - 10, hipY), Offset(cx - 10, footY), linePaint);
      canvas.drawLine(Offset(cx + 10, hipY), Offset(cx + 10, footY), linePaint);

      final handsY = isErkek ? 90.0 : 72.0;
      canvas.drawLine(Offset(cx - 15, shoulderY), Offset(cx, handsY), linePaint);
      canvas.drawLine(Offset(cx + 15, shoulderY), Offset(cx - 2, handsY), linePaint);

      canvas.drawCircle(headCenter, headRadius, headPaint);
      canvas.drawCircle(headCenter, headRadius, headOutlinePaint);

    } else if (posture.contains('Rükû') || posture.contains('Eğilmek')) {
      final double shoulderX = isErkek ? cx - 35 : cx - 25;
      final double shoulderY = isErkek ? 85 : 80;
      final double headX = isErkek ? shoulderX - 18 : shoulderX - 14;
      final double headY = isErkek ? shoulderY : shoulderY - 8;
      final double hipX = cx + 20;
      final double hipY = 85;
      final double footY = h - 20.0;

      final Path clothesPath = Path()
        ..moveTo(shoulderX, shoulderY)
        ..lineTo(hipX, hipY)
        ..lineTo(hipX - 10, footY)
        ..lineTo(hipX - 25, footY)
        ..close();
      canvas.drawPath(clothesPath, clothesPaint);

      canvas.drawLine(Offset(shoulderX, shoulderY), Offset(hipX, hipY), linePaint);
      canvas.drawLine(Offset(hipX - 10, hipY), Offset(hipX - 15, footY), linePaint);

      final double kneeX = hipX - 15;
      final double kneeY = (hipY + footY) / 2;
      canvas.drawLine(Offset(shoulderX, shoulderY), Offset(kneeX - 10, kneeY), linePaint);

      canvas.drawCircle(Offset(headX, headY), headRadius, headPaint);
      canvas.drawCircle(Offset(headX, headY), headRadius, headOutlinePaint);

    } else if (posture.contains('Secde') || posture.contains('Yere')) {
      final double headX = cx - 50;
      final double headY = h - 28;
      final double shoulderX = cx - 28;
      final double shoulderY = h - 42;
      final double hipX = cx + 22;
      final double hipY = isErkek ? h - 55 : h - 35;
      final double kneeX = cx + 15;
      final double kneeY = h - 20;

      final Path clothesPath = Path()
        ..moveTo(shoulderX, shoulderY)
        ..lineTo(hipX, hipY)
        ..lineTo(kneeX, kneeY)
        ..close();
      canvas.drawPath(clothesPath, clothesPaint);

      canvas.drawLine(Offset(shoulderX, shoulderY), Offset(hipX, hipY), linePaint);
      canvas.drawLine(Offset(hipX, hipY), Offset(kneeX, kneeY), linePaint);
      canvas.drawLine(Offset(kneeX, kneeY), Offset(cx + 38, h - 20), linePaint);

      if (isErkek) {
        canvas.drawLine(Offset(shoulderX, shoulderY), Offset(shoulderX - 10, h - 35), linePaint);
        canvas.drawLine(Offset(shoulderX - 10, h - 35), Offset(headX + 10, h - 20), linePaint);
      } else {
        canvas.drawLine(Offset(shoulderX, shoulderY), Offset(shoulderX - 5, h - 20), linePaint);
        canvas.drawLine(Offset(shoulderX - 5, h - 20), Offset(headX + 10, h - 20), linePaint);
      }

      canvas.drawCircle(Offset(headX, headY), headRadius, headPaint);
      canvas.drawCircle(Offset(headX, headY), headRadius, headOutlinePaint);

    } else {
      // Oturuş
      final headCenter = Offset(cx - 10, 50);
      final double shoulderX = cx - 8;
      final double shoulderY = 70;
      final double hipX = cx + 10;
      final double hipY = h - 45;
      final double kneeX = cx - 25;
      final double kneeY = h - 20;

      final Path clothesPath = Path()
        ..moveTo(shoulderX, shoulderY)
        ..lineTo(hipX, hipY)
        ..lineTo(kneeX, kneeY)
        ..close();
      canvas.drawPath(clothesPath, clothesPaint);

      canvas.drawLine(Offset(shoulderX, shoulderY), Offset(hipX, hipY), linePaint);
      canvas.drawLine(Offset(hipX, hipY), Offset(kneeX, kneeY), linePaint);
      canvas.drawLine(Offset(kneeX, kneeY), Offset(cx + 10, h - 20), linePaint);
      canvas.drawLine(Offset(shoulderX, shoulderY), Offset(kneeX + 10, kneeY - 8), linePaint);

      canvas.drawCircle(headCenter, headRadius, headPaint);
      canvas.drawCircle(headCenter, headRadius, headOutlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant NamazPosturePainter oldDelegate) {
    return oldDelegate.posture != posture || oldDelegate.isErkek != isErkek || oldDelegate.isDark != isDark;
  }
}

class AbdestIconPainter extends CustomPainter {
  final String stepTitle;
  final bool isDark;

  AbdestIconPainter({required this.stepTitle, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final paintMain = Paint()
      ..color = const Color(0xFF27A770)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = const Color(0xFF27A770).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final paintAccent = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintAccentFill = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), cx - 10, paintFill);
    canvas.drawCircle(Offset(cx, cy), cx - 10, Paint()..color = const Color(0xFF27A770).withOpacity(0.25)..strokeWidth = 1..style = PaintingStyle.stroke);

    if (stepTitle.contains("Niyet") || stepTitle.contains("El") || stepTitle.contains("Temizlik")) {
      canvas.drawCircle(Offset(cx, cy - 25), 4, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx - 15, cy - 18), 3, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx + 15, cy - 18), 3, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);

      final leftHand = Path()
        ..moveTo(cx - 25, cy + 15)
        ..quadraticBezierTo(cx - 25, cy - 5, cx - 10, cy - 5)
        ..quadraticBezierTo(cx - 5, cy - 5, cx - 5, cy + 5)
        ..lineTo(cx - 5, cy + 15);
      canvas.drawPath(leftHand, paintMain);

      final rightHand = Path()
        ..moveTo(cx + 25, cy + 15)
        ..quadraticBezierTo(cx + 25, cy - 5, cx + 10, cy - 5)
        ..quadraticBezierTo(cx + 5, cy - 5, cx + 5, cy + 5)
        ..lineTo(cx + 5, cy + 15);
      canvas.drawPath(rightHand, paintMain);
    } else if (stepTitle.contains("Ağız") || stepTitle.contains("Ağıza") || stepTitle.contains("ağız")) {
      final mouthPath = Path()
        ..moveTo(cx - 20, cy)
        ..quadraticBezierTo(cx, cy - 12, cx + 20, cy)
        ..quadraticBezierTo(cx, cy + 12, cx - 20, cy)
        ..close();
      canvas.drawPath(mouthPath, paintMain);
      canvas.drawPath(mouthPath, paintAccentFill);

      canvas.drawArc(Rect.fromCircle(center: Offset(cx + 12, cy - 15), radius: 6), 0, 4, false, paintAccent);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx - 12, cy - 15), radius: 6), 1, 4, false, paintAccent);
    } else if (stepTitle.contains("Burun") || stepTitle.contains("Burna") || stepTitle.contains("burun")) {
      final nosePath = Path()
        ..moveTo(cx - 8, cy - 15)
        ..lineTo(cx - 8, cy + 5)
        ..quadraticBezierTo(cx, cy + 15, cx + 8, cy + 5)
        ..lineTo(cx + 8, cy - 15);
      canvas.drawPath(nosePath, paintMain);

      final dropPath = Path()
        ..moveTo(cx, cy + 18)
        ..quadraticBezierTo(cx - 5, cy + 26, cx, cy + 30)
        ..quadraticBezierTo(cx + 5, cy + 26, cx, cy + 18)
        ..close();
      canvas.drawPath(dropPath, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
    } else if (stepTitle.contains("Yüzü") || stepTitle.contains("Yüz") || stepTitle.contains("Beden")) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 34, height: 44), paintMain);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - 12), width: 30, height: 18), 3.14, 3.14, false, paintAccent);
      canvas.drawLine(Offset(cx - 10, cy - 2), Offset(cx - 4, cy - 2), paintMain);
      canvas.drawLine(Offset(cx + 4, cy - 2), Offset(cx + 10, cy - 2), paintMain);
    } else if (stepTitle.contains("Kol") || stepTitle.contains("Kolları")) {
      final armPath = Path()
        ..moveTo(cx - 25, cy - 15)
        ..lineTo(cx + 15, cy - 15)
        ..quadraticBezierTo(cx + 25, cy - 15, cx + 25, cy)
        ..quadraticBezierTo(cx + 25, cy + 15, cx + 15, cy + 15)
        ..lineTo(cx - 25, cy + 15);
      canvas.drawPath(armPath, paintMain);
      canvas.drawCircle(Offset(cx + 10, cy), 5, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
    } else if (stepTitle.contains("Baş") || stepTitle.contains("Başı") || stepTitle.contains("bütün")) {
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 10), width: 44, height: 44), 3.14, 3.14, false, paintMain);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 8), width: 52, height: 52), 3.4, 2.5, false, paintAccent);
    } else if (stepTitle.contains("Kulak") || stepTitle.contains("Kulakları")) {
      final earPath = Path()
        ..moveTo(cx - 10, cy - 20)
        ..cubicTo(cx + 15, cy - 25, cx + 15, cy + 5, cx - 5, cy + 15)
        ..quadraticBezierTo(cx - 15, cy + 20, cx - 12, cy + 5);
      canvas.drawPath(earPath, paintMain);
      canvas.drawCircle(Offset(cx + 2, cy - 3), 4, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
    } else if (stepTitle.contains("Boyun") || stepTitle.contains("Boynu")) {
      final neckPath = Path()
        ..moveTo(cx - 25, cy + 20)
        ..lineTo(cx - 15, cy + 10)
        ..lineTo(cx - 15, cy - 15)
        ..lineTo(cx + 15, cy - 15)
        ..lineTo(cx + 15, cy + 10)
        ..lineTo(cx + 25, cy + 20);
      canvas.drawPath(neckPath, paintMain);
      canvas.drawLine(Offset(cx - 8, cy - 5), Offset(cx - 8, cy + 5), paintAccent);
      canvas.drawLine(Offset(cx + 8, cy - 5), Offset(cx + 8, cy + 5), paintAccent);
    } else {
      // Ayaklar veya diğer
      final footPath = Path()
        ..moveTo(cx - 20, cy - 10)
        ..lineTo(cx - 5, cy - 10)
        ..lineTo(cx + 15, cy + 15)
        ..lineTo(cx - 15, cy + 15)
        ..close();
      canvas.drawPath(footPath, paintMain);
      canvas.drawCircle(Offset(cx + 5, cy + 5), 4, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant AbdestIconPainter oldDelegate) {
    return oldDelegate.stepTitle != stepTitle || oldDelegate.isDark != isDark;
  }
}
