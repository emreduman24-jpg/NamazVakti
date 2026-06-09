# Redesign Peygamberin Hayatı Tool
import 'dart:convert';
**Goal**: Transform the existing "Peygamberin Hayatı" tool into a premium, modern, and visually stunning experience that aligns with the app's overall design language.
import 'package:flutter/material.dart';
## User Review Required
> [!IMPORTANT]
> The redesign will change navigation flow, UI components, and data presentation. Confirm that the new design direction (timeline with stepper, rich media, animations) aligns with your expectations.
import 'package:audioplayers/audioplayers.dart';
## Open Questions
> [!WARNING]
> 1. Should we include interactive timeline navigation (horizontal scroll) or stick to vertical stepper?
> 2. Preferred color palette for this tool (e.g., dark teal with gold accents, or existing theme)?
> 3. Any specific multimedia (images, audio) to associate with each life event?
> 4. Should we add a "favorites" feature for events?
import 'quran_detail_screen.dart';
## Proposed Changes
---
### Data Model Enhancements (`lib/data/peygamber_data.dart`)
- Create a new data structure `LifeEvent` with fields: `id`, `title`, `date`, `subtitle`, `description`, `imageUrl`, `audioUrl`.
- Populate a list `PEYGEMBER_EVENTS` grouped by chronological phases (e.g., `Childhood`, `Prophethood`, `Hijra`, `Medina` etc.).
- Update `peygamber_repository.dart` to expose this list.
  const ToolDetailScreen({
### UI Redesign (`lib/screens/tool_detail_screen.dart`)
- Add a new widget `PeygamberLifeScreen` replacing the current case.
- Implement a **horizontal timeline** at the top with animated indicator (glassmorphism pill) showing current phase.
- Belo
  });
  - Use **Google Fonts** (e.g., "Inter") for typography.
  - Include smooth micro‑animations on scroll (fade‑in, slide‑up).
- Tap on a card opens a **modal bottom sheet** with full details, larger image, Arabic calligraphy, and audio playback.
- Integrate **Hero animations** for image transition.
- Add a **search bar** to filter events by keyword.
class _ToolDetailScreenState extends State<ToolDetailScreen> {
### Theming & Aesthetics
- Leverage the app's existing dark/light theme but introduce a **premium accent color** (`#D4AF37` gold) for icons and active elements.
- Use **glassmorphism** for the timeline background (blurred translucent container).
- Include **subtle particle animation** in the background of the detail modal for visual flair.
- Ensure all icons are vector (`SVG`) for crisp rendering.
  Color ge
### Audio & Media Handling
- Reuse the existing `AudioPlayer` singleton; ensure each event's `audioUrl` streams correctly.
- Add a **loading skeleton** while audio buffers.
### 4. Code Cleanup and Verification
### Testing & Validation
- Run `flutter analyze` to ensure no lint errors.
- Perform manual UI testing on the Android emulator (Pixel_7) for both dark and light themes.
- Verify that all interactive elements are accessible (tap targets >= 48dp).
      });
## Verification Plan
### Automated Tests
- Add widget tests for `PeygamberLifeScreen` covering timeline navigation and card tap actions.
- Unit test the new data repository to confirm correct grouping.
2. Go to the "Araçlar" (Tools) tab.
### Manual Verification
- Launch app on emulator, navigate to **Araçlar > Peygamberin Hayatı**.
- Verify visual fidelity: gradients, blur, animations.
- Test audio playback for a few events.
- Ensure responsiveness on different screen sizes.
      final savedLoc = await _repository.getSavedLocation();
---
*Please review the open questions and confirm the design direction.*
      if (mounted) {
        // Find today's index
        final now = DateTime.now();
        final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
        int todayIdx = 0;
        for (int i = 0; i < times.length; i++) {
          if (times[i]['MiladiTarihKisa'] == todayStr) {
            todayIdx = i;
            break;
          }
        }
        setState(() {
          _monthlyPrayerTimes = times;
          _loadingMonthlyTimes = false;
          _selectedCalendarDayIndex = todayIdx;
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
  PlayerState _playerState = PlayerState.stopped;
  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  String _currentAudioUrl = "";
  String _currentTrackName = "";
  int _quranTab = 0; // 0: Sureler, 1: Cüzler
  int _lastSuraNo = 1;
  String _lastSuraName = "Fâtiha";
  int _lastAyahNo = 1;
  int _lastTotalAyahs = 7;
  int _lastPercent = 0;
  int _lastJuzNo = 1;
  String _lastJuzTitle = "1. Cüz";
  String _lastJuzRange = "Fâtiha 1 - Bakara 141";
  int _lastJuzSuraNo = 1;
  int _lastJuzAyahNo = 1;
  int _lastJuzPercent = 0;
  List<String> _quranBookmarks = [];
  String _quranSearchQuery = "";
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // Yakındaki Camiler (Location & GPS State)
  Position? _currentPosition;
  bool _loadingLocation = false;
  List<Map<String, dynamic>> _dynamicMosquesList = [];
    return degree * math.pi / 180;
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
    final radii = [3000, 5000, 10000]; // meters
  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
      'https://overpass.kumi.systems/api/interpreter',
  void _initMosques() {
    _dynamicMosquesList = [];
  }
              // Build address from tags
  /// Fetches real nearby mosques from OpenStreetMap Overpass API
  Future<void> _fetchNearbyMosques(double lat, double lon) async {
    debugPrint('=== MOSQUE SEARCH: Searching near lat=$lat, lon=$lon ===');
    // Try progressively larger radii until we find enough mosques
    final radii = [3000, 5000, 10000]; // meters
[out:json][timeout:15];
    // Multiple Overpass API endpoints for reliability
    final overpassEndpoints = [
      'https://overpass.kumi.systems/api/interpreter',
  node["building"="mosque"](around:$radius,$lat,$lon);
  way["building"="mosque"](around:$radius,$lat,$lon);
);
out center body;
''';
                'ad': name.toString(),
          final encodedQuery = Uri.encodeComponent(query);
          final url = Uri.parse('$endpoint?data=$encodedQuery');
          final response = await http.get(
            url,
                'mesafeVal': dist,
                'mesafeText': dist < 1
                    ? '${(dist * 1000).toInt()} m'
                    : '${dist.toStringAsFixed(1)} km',
              });
            }
            // Sort by distance
            // Sort by distance
            mosques.sort((a, b) =>
                (a['mesafeVal'] as double).compareTo(b['mesafeVal'] as double));
            if (mosques.isNotEmpty) {
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
            ScaffoldMessenger.of(context).showSnackBar(
    // If all radii failed, show a message
    debugPrint('No mosques found from Overpass API');
    if (mounted) {
      setState(() {
        _dynamicMosquesList = [];
      });
    }
  }
      }
  // static map of 81 Turkish cities and coordinates
  static const Map<String, Map<String, double>> _cityCoordinates = {
    "ADANA": {"lat": 36.9914, "lon": 35.3308},
    "ADIYAMAN": {"lat": 37.7648, "lon": 38.2786},
    "AFYONKARAHISAR": {"lat": 38.7507, "lon": 30.5567},
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _loadingLocation = false;
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F8F5),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF27A770),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
      if (permission == LocationPermission.denied) {
  // Dark Theme Definition
  ThemeData get _darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF27A770),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF27A770),
        primary: const Color(0xFF27A770),
        secondary: const Color(0xFF4CAF50),
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF27A770),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
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
                      "Kıble-i Şerif Yönü",
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
            );
  String _nor
        }
      }
  Future<void> _updateKaza(String key, int delta) async {
      position ??= Position(
        // Fallback mock coordinates (Büyükçekmece, İstanbul) if GPS service hangs or fails
        latitude: 41.0207,
        longitude: 28.585,
        .replaceAll('Ü', 'U');
  }
  Future<void> _getUserLocation({bool forceRefresh = false}) async {
  Future<void> _getUserLocation({bool forceRefresh = false}) async {
    setState(() {
      _loadingLocation = true;
    });
    try {
      Position? position;
      // 1. Check if location services are enabled
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      // 2. Request permission if denied
      // 2. Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // 3. Try to get high-accuracy live GPS location first if permitted (tam konum sokağına kadar)
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
          BottomNavigationBarItem(
          BottomNavigationBarItem(
            if (position != null) {
              debugPrint("Successfully fetched cached last known GPS: ${position.latitude}, ${position.longitude}");
            }
          } catch (e2) {
            debugPrint("Failed to fetch cached GPS: $e2");
          }
        }
      }
          ),
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
              ),
              SizedBox(height: 24),
              Text(
                "Erişiminiz Engellendi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Kullanım şartlarını ihlal ettiğiniz için İslami Rehber uygulamasına erişiminiz yönetici tarafından engellenmiştir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
      setState(() {
        _loadingLocation = false;
      });
    }
  }
      { "ad": "Kurban Bayramı (2. Gün)", "gun": "Pazar", "tarih": "16 Mayıs 2027", "kat": "Kurban Bayramı" },
  // Zikirmatik State
  int _zikirCount = 0;
  int _zikirTarget = 33;
  bool _zikirSoundEnabled = true;
  String _selectedZikirId = 'subhanallah';
            try {
  final Map<String, Map<String, dynamic>> _zikirData = {
    'subhanallah': {
      'ad': 'Sübhânallâh',
      'arapca': 'سُبْحَانَ اللَّهِ',
      'anlam': 'Allah noksan sıfatlardan uzaktır.',
      'fazilet': 'Günde 100 defa okuyanın günahları deniz köpüğü kadar da olsa bağışlanır.',
      'hedef': 33
      }
      _kazaAksam = prefs.getInt('kaza_aksam') ?? 0;
      position ??= Position(
        // Fallback mock coordinates (Büyükçekmece, İstanbul) if GPS service hangs or fails
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
    _initAudio();
      final pos = position!;
      debugPrint('=== GPS POSITION: lat=${pos.latitude}, lon=${pos.longitude}, accuracy=${pos.accuracy} ===');
      setState(() {
        _currentPosition = pos;
      });
        content: Text("Dua talebiniz paylaşıldı."),
      // Fetch real nearby mosques from Overpass API
      'fazilet': 'Zikrin en faziletlisi kelime-i tevhiddir.',
      'hedef': 9999
    }
  };
          _loadingLocation = false;
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
      // Fetch real nearby mosques from Overpass API using exact location
      await _fetchNearbyMosques(pos.latitude, pos.longitude);
      case 'aile-ahlaki':
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
  int _ezkarTab = 0;
  // Zikirmatik State
  int _zikirCount = 0;
  int _zikirTarget = 33;
  bool _zikirSoundEnabled = true;
  String _selectedZikirId = 'subhanallah';
    if (widget.toolId == 'yakindaki-camiler') {
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
        ..blendMode = BlendMode.dstOut;
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
      { "ad": "Hicri Yılbaşı (1 Muharrem 1448)", "gun": "Salı", "tarih": "16 Haziran 2026", "kat": "Hicri Yılbaşı ve Aşure" },
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawRRect(innerRRect, innerBorderPaint);
    final targetPaint = Paint()
      // Draw mihrab arch
      final mihrabPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(mihrabPath, mihrabPaint);
      ..lineTo(center.dx - bracketW, 0)
      // Draw hanging lamp
      final lampPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(lampPath, lampPaint);
  @override
      final lampLinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(const Offset(12.0, 8.5), const Offset(12.0, 11.5), lampLinePaint);
    }
  }
  print('Qibla Radar Redesign applied successfully!');
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  int _ezkarTab = 0;
        return _buildCenazeNamazi();
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
        return _buildTilavetSecdesi();
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
        return _buildKoruyucuDualar();
  Future<void> _updateKaza(String key, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(key) ?? 0;
    int newValue = math.max(0, current + delta);
    await prefs.setInt(key, newValue);
    setState(() {
      if (key == 'kaza_sabah') _kazaSaba
      if (key == 'kaza_ogle') _kazaOgle = newValue;
      if (key == 'kaza_ikindi') _kazaIkindi = newValue;
      if (key == 'kaza_aksam') _kazaAksam = newValue;
      if (key == 'kaza_yatsi') _kazaYatsi = newValue;
      if (key == 'kaza_vitir') _kazaVitir = newValue;
  // Zekat Hesaplayici State
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();
  String _zekatResult = "";
      if (mounted) {
  // Date Converter State
  DateTime _selectedDate = DateTime.now();
      { "ad": "Mevlid Kandili", "gun": "Cuma", "tarih": "12 Temmuz 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Regaib Kandili", "gun": "Perşembe", "tarih": "31 Ekim 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Miraç Kandili", "gun": "Cuma", "tarih": "22 Kasım 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Berat Kandili", "gun": "Pazartesi", "tarih": "9 Aralık 2030", "kat": "Kandil ve Mübarek Geceler" },
      { "ad": "Ramazan Başlangıcı", "gun": "Perşembe", "tarih": "26 Aralık 2030", "kat": "Kandil ve Mübarek Geceler" }
    ]
  };
        .toLowerCase()
  // Dua Iste State
  List<Map<String, dynamic>> _duaList = [];
  final TextEditingController _duaNameController = TextEditingController();
  final TextEditingController _duaTextController = TextEditingController();
  // Prophet Life Tab
  // Soru Cevap State
  List<Map<String, dynamic>> _questionList = [];
  final TextEditingController _questionNameController = TextEditingController();
  final TextEditingController _qaInputController = TextEditingController();
  void dispose() {
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
  // Dini Hoca State
  List<Map<String, dynamic>> _diniHocaMessages = [];
  bool _diniHocaIsTyping = false;
  final ScrollController _diniHocaScrollController = ScrollController();
  final TextEditingController _diniHocaInputController = TextEditingController();
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
  // Namaz Tesbihati State
  // Dini Hoca AI State
  final List<Map<String, String>> _diniHocaMessages = [
    {
      'sender': 'ai',
      'text': 'Selamün Aleyküm mümin kardeşim. Ben Dini Hoca Yapay Zeka Danışmanıyım. İslam fıkhı, inanç, ibadetler (abdest, namaz, zekat vb.), hadis-i şerifler veya ahlak adabı hakkında aklına takılan her soruyu bana sorabilirsin. Sana hayırla rehberlik etmek için buradayım.',
    }
  ];
  final TextEditingController _diniHocaInputController = TextEditingController();
  final ScrollController _diniHocaScrollController = ScrollController();
  bool _diniHocaIsTyping = false;
  // Date Converter State
  // 40 Hadis State
  String _convertedDateResult = "";
  bool _miladiToHicri = true;
    }
  // Sahabe Hayatlari & Esmaül Hüsna Search State
  String _esmaSearchQuery = "";
  String _sahabeSearchQuery = "";
  String _hadisSearchQuery = "";
  int _kazaAksam = 0;
  // Compass Manual Rotation Simulation (Fallback for Emulators)
  double _manualCompassHeading = 0.0;
  // Kaza Namazi State
  int _kazaSabah = 0;
  int _kazaOgle = 0;
  int _kazaIkindi = 0;
  int _kazaAksam = 0;
  int _kazaYatsi = 0;
  int _kazaVitir = 0;
  void initState() {
  // Sabah & Aksam Ezkari counts
  int _kazaSabah = 0;
  int _kazaOgle = 0;
  int _kazaIkindi = 0;
  int _kazaAksam = 0;
  int _kazaYatsi = 0;
  int _kazaVitir = 0;
        ..blendMode = BlendMode.dstOut;
  // Sabah & Aksam Ezkari counts
  final List<int> _sabahEzkarCounts = [0, 0, 0, 0, 0, 0, 0];
  final List<int> _aksamEzkarCounts = [0, 0, 0, 0, 0, 0, 0];
  int _ezkarTab = 0;
      // OUTLINE SECCADE DESIGN
  @override
  void initState() {
    super.initState();
    _initMosques();
    _loadLocationName();
    if (widget.toolId == 'yakindaki-camiler' || widget.toolId == 'kible-bulucu') {
      _getUserLocation();
    }
    if (widget.toolId == 'namaz-vakitleri-aylik') {
      _loadMonthlyTimes();
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
    _loadQuranLastRead();
  }
    final prefs = await SharedPreferences.getInstance();
  Future<void> _loadQuranLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastSuraNo = prefs.getInt('quran_last_sura_no') ?? 1;
        _lastSuraName = prefs.getString('quran_last_sura_name') ?? "Fâtiha";
        _lastAyahNo = prefs.getInt('quran_last_ayah_no') ?? 1;
        _lastTotalAyahs = prefs.getInt('quran_last_total_ayahs') ?? 7;
        _lastPercent = prefs.getInt('quran_last_percent') ?? 0;
    }
        _lastJuzNo = prefs.getInt('quran_last_juz_no') ?? 1;
        _lastJuzTitle = prefs.getString('quran_last_juz_title') ?? "1. Cüz";
        _lastJuzRange = prefs.getString('quran_last_juz_range') ?? "Fâtiha 1 - Bakara 141";
        _lastJuzSuraNo = prefs.getInt('quran_last_juz_sura_no') ?? 1;
        _lastJuzAyahNo = prefs.getInt('quran_last_juz_ayah_no') ?? 1;
        _lastJuzPercent = prefs.getInt('quran_last_juz_percent') ?? 0;
  }
        _quranBookmarks = prefs.getStringList('quran_bookmarks') ?? [];
      });
    }
  }
      {'sura': 2, 'ayah': 142},
  Future<void> _toggleQuranBookmark(String suraNoStr) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_quranBookmarks.contains(suraNoStr)) {
        _quranBookmarks.remove(suraNoStr);
      } else {
        _quranBookmarks.add(suraNoStr);
      }
    });
    await prefs.setStringList('quran_bookmarks', _quranBookmarks);
  }
      {'sura': 15, 'ayah': 1},
  Map<String, int> _getJuzStartInfo(int juzNumber) {
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
    _loadQuranLastRead();
    _loadFavoriteDualar();
  }
      {'sura': 41, 'ayah': 47},
  Future<void> _loadQuranLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastSuraNo = prefs.getInt('quran_last_sura_no') ?? 1;
        _lastSuraName = prefs.getString('quran_last_sura_name') ?? "Fâtiha";
        _lastAyahNo = prefs.getInt('quran_last_ayah_no') ?? 1;
        _lastTotalAyahs = prefs.getInt('quran_last_total_ayahs') ?? 7;
        _lastPercent = prefs.getInt('quran_last_percent') ?? 0;
    return {'sura': 1, 'ayah': 1};
        _lastJuzNo = prefs.getInt('quran_last_juz_no') ?? 1;
        _lastJuzTitle = prefs.getString('quran_last_juz_title') ?? "1. Cüz";
        _lastJuzRange = prefs.getString('quran_last_juz_range') ?? "Fâtiha 1 - Bakara 141";
        _lastJuzSuraNo = prefs.getInt('quran_last_juz_sura_no') ?? 1;
        _lastJuzAyahNo = prefs.getInt('quran_last_juz_ayah_no') ?? 1;
        _lastJuzPercent = prefs.getInt('quran_last_juz_percent') ?? 0;
    setState(() {
        _quranBookmarks = prefs.getStringList('quran_bookmarks') ?? [];
      });
    }
  }
      _kazaYatsi = prefs.getInt('kaza_yatsi') ?? 0;
  Future<void> _toggleQuranBookmark(String suraNoStr) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_quranBookmarks.contains(suraNoStr)) {
        _quranBookmarks.remove(suraNoStr);
      } else {
        _quranBookmarks.add(suraNoStr);
      }
    });
    await prefs.setStringList('quran_bookmarks', _quranBookmarks);
  }
      if (key == 'kaza_ogle') _kazaOgle = newValue;
  Map<String, int> _getJuzStartInfo(int juzNumber) {
      {'sura': 3, 'ayah': 93},
      {'sura': 4, 'ayah': 24},
      {'sura': 4, 'ayah': 148},
      {'sura': 5, 'ayah': 82},
      {'sura': 6, 'ayah': 111},
      {'sura': 7, 'ayah': 88},
      {'sura': 8, 'ayah': 41},
      {'sura': 9, 'ayah': 93},
      {'sura': 11, 'ayah': 6},
      {'sura': 12, 'ayah': 53},
      {'sura': 15, 'ayah': 1},
      {'sura': 17, 'ayah': 1},
      {'sura': 18, 'ayah': 75},
      {'sura': 21, 'ayah': 1},
      {'sura': 23, 'ayah': 1},
      {'sura': 25, 'ayah': 21},
      {'sura': 27, 'ayah': 56},
      {'sura': 29, 'ayah': 46},
      {'sura': 33, 'ayah': 31},
      {'sura': 36, 'ayah': 28},
      {'sura': 39, 'ayah': 32},
      {'sura': 41, 'ayah': 47},
      {'sura': 46, 'ayah': 1},
      {'sura': 51, 'ayah': 31},
      {'sura': 57, 'ayah': 1},
      {'sura': 67, 'ayah': 1},
      {'sura': 78, 'ayah': 1},
    ];
    if (juzNumber >= 1 && juzNumber <= 30) {
      return list[juzNumber - 1];
    }
    return {'sura': 1, 'ayah': 1};
  }
  String _normalize(String text) {
    return text
        .toLowerCase()
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
      if (key == 'kaza_yatsi') _kazaYatsi = newValue;
  Future<void> _updateKaza(String key, int delta) async {
    final prefs = await SharedPreferences.getInstance();
  }
                    padding: const EdgeInsets.all(12),
  void _initAudio() {
    _audioPlayer = AudioPlayer();
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
    return text
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
  void dispose() {
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
  void dispose() {
  @override
    _duaNameController.dispose();
    _duaTextController.dispose();
    _questionNameController.dispose();
    _qaInputController.dispose();
    _chatInputController.dispose();
    _hadisSearchController.dispose();
    _dualarSearchController.dispose();
    _goldController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }
            "Tebrikler! ${_zikirData[_selectedZikirId]?['ad'] ?? ''} zikrini tamamladınız!",
  // Zikirmatik persistence
  Future<void> _loadZikirState() async {
    final count = await _repository.getZikirCount();
    final target = await _repository.getZikirTarget();
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('zikir_completed_dates') ?? [];
    setState(() {
      _zikirCount = count;
    }
  }
    setState(() {
  Future<void> _resetZikir() async {
    setState(() {
      _zikirCount = 0;
    });
    await _repository.setZikirCount(0);
  }
  Future<void> _loadDuaList() async {
  // Dua list persist (approved only)
  Future<void> _loadDuaList() async {
    final list = await _repository.getDuaList();
    if (mounted) {
      setState(() {
    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: Text(
          widget.toolTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: _isDark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !widget.isTab,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildToolBody(),
        ),
      ),
    );
  }
      case 'dini-gunler':
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
      case 'namaz-vakitleri-aylik':
        return _buildAylikNamazVakitleri();
      case 'zikirmatik':
        return _buildZikirmatik();
      case 'miladi-hicri':
        return _buildMiladiHicri();
      case 'yasin-suresi':
      case 'namaz-tesbihati':
        return _buildNamazTesbihati();
      case 'gunluk-dualar':
        return _buildGunlukDualar();
      case 'zekat-hesaplama':
        return _buildZekatHesaplama();
      case 'sahabe-hayatlari':
        return _buildSahabeHayatlari();
      case 'islam-tarihi':
        await _audioPlayer!.play(UrlSource(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ses çalma hatası: $e")));
    }
  }
      case 'hac-umre':
  @override
      ),
    );
  }
      backgroundColor: isQuran ? const Color(0xFF0C1524) : (_isDark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5)),
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
      ),
  @override
  Widget build(BuildContext context) {
    final isQuran = widget.toolId == 'kuran-kerim';
        backgroundColor: Color(0xFF27A770),
      ),
    );
  }
          widget.toolTitle,
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
        backgroundColor: Color(0xFF27A770),
      ),
    );
  }
        await _audioPlayer!.play(UrlSource(url));
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
        centerTitle: true,
  @override
  Widget build(BuildContext context) {
    final isQuran = widget.toolId == 'kuran-kerim';
    return Scaffold(
      backgroundColor: isQuran ? const Color(0xFF0C1524) : (_isDark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5)),
      appBar: AppBar(
        title: widget.toolId == 'gunluk-dualar' && _isSearchingDualar
      appBar: AppBar(
        title: widget.toolId == 'gunluk-dualar' && _isSearchingDualar
            ? TextField(
                controller: _dualarSearchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Dua ara...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _dualarSearchQuery = val;
                  });
                },
              )
            : Text(
                widget.toolTitle == 'Günlük Dualar' ? 'Dualar' : widget.toolTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
        backgroundColor: isQuran ? const Color(0xFF0C1524) : (_isDark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !widget.isTab,
        actions: widget.toolId == 'gunluk-dualar'
            ? [
                IconButton(
                  icon: Icon(_isSearchingDualar ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                        _dualarSearchQuery = "";
                        _dualarSearchController.clear();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                    color: _showOnlyFavorites ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showOnlyFavorites = !_showOnlyFavorites;
                    setState(() {
                      _showOnlyFavorites = !_showOnlyFavorites;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: isQuran
            ? _buildKuranKerim()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildToolBody(),
              ),
      ),
    );
  }
    switch (widget.toolId) {
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
      case 'dini-hoca':
        return _buildDiniHoca();
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
      case 'namaz-vakitleri-aylik':
        return _buildAylikNamazVakitleri();
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
        return _buildEvvabinNamazi();
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
              SizedBox(height: 16),
              _buildKunutCard("Kunut Duası - 2", VITIR_NAMAZI['kunut2']),
            ],
          ),
        );
      case 'yemek-duasi':
        return _buildYemekDuasi();
      case 'sifa-duasi':
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
        return Center(
          child: Text("Bu özellik çok yakında eklenecektir."),
        );
    }
  }

  // 1. Dini Günler
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutExcept






















































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
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
    );
Performing hot restart...
lib/screens/tool_detail_screen.dart:5449:48: Error: Couldn't find constructor 'EdgeInsets.bottom'.
                      margin: const EdgeInsets.bottom(15),
                                               ^^^^^^
Restarted application in 652ms.
Try again after fixing the above error(s).
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
      ],
Performing hot restart...
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
Restarted application in 2.615ms.
D/FlutterJNI( 6315): Sending viewport metrics to the engine.
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
D/FlutterJNI( 6315): Sending viewport metrics to the engine.
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
D/WindowOnBackDispatcher( 6315): setTopOnBackInvokedCallback (unwrapped): io.flutter.embedding.android.FlutterActivity$1@3d352e
D/WindowOnBackDispatcher( 6315): setTopOnBackInvokedCallback (unwrapped): android.view.ImeBackAnimationController@e7a922f
I/flutter ( 6315): Attempting to get fresh live GPS location...
I/flutter ( 6315): Error fetching duas: TimeoutException after 0:00:02.000000: Future not completed. Using cache.
I/flutter ( 6315): Error fetching questions: TimeoutException after 0:00:02.000000: Future not completed. Using cache.
I/flutter ( 6315): Error fetching tools: TimeoutException after 0:00:02.000000: Future not completed. Using cache.
I/flutter ( 6315): Error getting block status: TimeoutException after 0:00:02.000000: Future not completed
I/flutter ( 6315): Successfully fetched live high-accuracy GPS: 40.8241017, 29.3170133
I/flutter ( 6315): === GPS POSITION: lat=40.8241017, lon=29.3170133, accuracy=5.0 ===
I/flutter ( 6315): === MOSQUE SEARCH: Searching near lat=40.8241017, lon=29.3170133 ===
              children: [
                Text(
                  "Soru Talebinde Bulun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _greenColor,
                  ),
                ),
                SizedBox(height: 8),
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
                  alignment: Alignment.center,
                  children: [
                    // Compass Ring (Dial) rotated by DialR
                    Transform.rotate(
                      an

















                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item['amin'] ?? 0} kişi Amin dedi",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _aminDua(index),
                            icon: Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Amin de",
                              style: TextStyle(
                                fontSize: 11,
                                color: _greenColor,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF4FB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                          ),
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
                    // Compass Needle (Qibla pointer) pointing to 137°
                    Transform.rotate(
                      angle: (needleRotation * math.pi / 180),
                      child: SizedBox(
                        width: 50,
                        height: 150,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.arrow_upward,
                              color: Color(0xFF27A770),
                              size: 42,
                            ),
                            const Spacer(),
                            // Small Kaaba center representation
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "🕌",
                                  style: TextStyle(fontSize: 11),
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
  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        bool hasSensor = heading != null && !_forceSimulation;
                  subtitle: const Text(
        // Use manual rotation if no sensor is available or simulation is forced
        double finalHeading = hasSensor ? heading : _manualCompassHeading;
        double needleRotation = qiblaAngle - finalHeading;
        double dialRotation = -finalHeading;
                  activeThumbColor: const Color(0xFF27A770),
    );
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
                      margin: EdgeInsets.only(bottom: 12),
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
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Soru header (Writer & Date)
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        chi
  // 11. Zikirmatik
  Widget _buildZikirmatik() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hedef Zikir: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: _zikirTarget,
              items: const [
                DropdownMenuItem(value: 33, child: Text("33")),
                DropdownMenuItem(value: 99, child: Text("99")),
                DropdownMenuItem(value: 100, child: Text("100")),
                DropdownMenuItem(value: 1000, child: Text("1000")),
                DropdownMenuItem(value: 9999, child: Text("Limitsiz")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _zikirTarget = val;
                    _zikirCount = 0;
                  });
                  _repository.setZikirTarget(val);
                  _repository.setZikirCount(0);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _incrementZik
          child: Container(
            width: 200,
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
                      angle: (needleRotation * math.p
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
            ),
          ),
        ),
      ],
    );
  }
                                        "🕌",
  // 6. Kuran-ı Kerim Player
  Widget _buildKuranKerim() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27A770).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.music_note, color: Color(0xFF27A770), size: 36),
              SizedBox(height: 8),
              Text(
                _currentTrackName.isEmpty
                    ? "Cüz seçin ve oynatın"
                                              fontWeight: FontWeight.bold,
                                              color: _greenColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            item['cevap'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _textColor,
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
  Widget _buildCanliSohbet() {
  // 4. Canlı Sohbet
  Widget _buildCanliSohbet() {
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
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFBEAEA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  size: 54,
                  color: Color(0xFFD9534F),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Canlı Dini Sohbet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: _greenColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Değerli hocalarımızın canlı dini sohbet yayınları çok yakında bu ekranda sizlerle olacaktır.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A770),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  elevation: 1,
                ),
                child: Text(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _diniHocaMessages.length + (_diniHocaIsTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _diniHocaMessages.length) {
                // Typing indicator
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.menu_book_rounded, color: Color(0xFFC5A059), size: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Dini Hoca yazıyor ",
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
                            chil
              final msg = _diniHocaMessages[index];
              final bool isMe = msg['isMe'] ?? false;
              final String text = msg['text'] ?? "";
                      Text(
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E5E43),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque_rounded,
                          color: Color(0xFFC5A059),
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
                              : (_isDark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9)),
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
                          color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: _isDark ? Colors.white70 : Colors.black54,
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
                              targetAyah: _lastJuzAyahNo,
        // Suggestion Chips
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
                  backgroundColor: _isDark ? const Color(0xFF1E2D4A) : Colors.white,
                  side: BorderSide(
                    color: _isDark ? const Color(0xFF2E3D5A) : const Color(0xFFCBD5E1),
                  ),
                  label: Text(
                    suggestions[index],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    _handleDiniHocaSend(suggestions[index].replaceAll(RegExp(r'\s\S+$'), '')); // Strip emoji
                  },
                ),
              );
            },
          ),
        ),
                          decoration: BoxDecoration(
        // Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0C1524) : Colors.grey[50],
            bor
                            style: TextStyle(
                              color: _quranTab == 1 ? Colors.white : (_isDark ? Colors.white60 : Colors.black54),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search Bar
              TextField(
                style: TextStyle(color: _isDark ? Colors.white : Colors.black87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _playAudio(url, name),
                child: Text(
                  "$juzNum. Cüz",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
      ],
                            onSubmitted: _handleDiniHocaSend,
                          ),
                        ),
                      ],
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
            color: _isDark ? const Color(0xFF131F35) : Colors.white,
  Widget _buildMessageText(String text, bool isMe) {
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;
                : [
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
              Navigator.push(
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
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
                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                surah.number.toString(),
                style: const TextStyle(
                  color: Color(0xFFC5A059),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              surah.name,
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              "${surah.versesCount} Ayet • ${surah.revelationPlace}",
              style: TextStyle(
                color: _isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah.arabicName,
                  style: const TextStyle(
                    color: Color(0xFF27A770),
                    fontFamily: 'Traditional Arabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isBookmarked ? const Color(0xFFC5A059) : (_isDark ? Colors.white38 : Colors.black26),
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
                ),
  Widget _buildCuzlerList(List<QuranJuz> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Cüz bulunamadı.",
          style: TextStyle(color: _isDark ? Colors.white54 : Colors.black54, fontSize: 14),
        ),
      );
    }
        ),
        // Dynamic List Rows
        Expanded(
          child: _quranTab == 0
              ? _buildSurelerList(filteredSuras)
              : _buildCuzlerList(filteredJuzs),
        ),
      ],
    );
  }

  Widget _buildSurelerList(List<QuranSurah> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Sure bulunamadı.",
          style: TextStyle(color: _isDark ? Colors.white54 : Color


                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
              const SizedBox(height: 12),
            ],
          ),
        ),

        // Dynamic List Rows
        Expanded(
          child: _quranTab == 0
              ? _buildSurelerList(filteredSuras)
              : _buildCuzlerList(filteredJuzs),
        ),
      ],
    );
  }
                      style: TextStyle(
  Widget _buildSurelerList(List<QuranSurah> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Sure bulunamadı.",
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final surah = list[index];
        final isBookmarked = _quranBookmarks.contains(surah.number.toString());
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF131F35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2D4A)),
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
              ).then((_) => _loadQur
                              ? const Color(0xFF27A770).withOpacity(0.8)
            borderRadius: BorderRadius.circular(16),
          ),
                    "Pusulayı el ile döndürmek için aktifleştirin",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _forceSimulation,
                  activeThumbColor: const Color(0xFF27A770),
                  onChanged: (val) {
                    setState(() {
                      _forceSimulation = val;
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF131F35) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
            boxShadow: _isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
    return """Değerli mümin kardeşim, sorduğunuz konuyu tam olarak anlayamadım veya kelime haznemde yer almıyor olabilir.
                      offset: const Offset(0, 2),
Lütfen sorunuzu daha açık kelimelerle sorunuz. Örneğin; **abdest alışı, guslün farzları, namazın farzları, sehiv secdesi, zekat verilecek kişiler, orucu bozan şeyler veya kaza namazları** gibi konularda doğrudan anahtar kelimeler kullanarak sorarsanız size çok daha detaylı bilgi aktarabilirim.
                  ],
Fıkhi konulardaki en doğru ve kesin hükümler için Diyanet İşleri Başkanlığı'nın resmi fetvalarına veya muteber fıkıh kitaplarına başvurmanızı tavsiye ederim.""";
  }
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  void _handleDiniHocaSend(String text) {
    if (text.trim().isEmpty) return;
              final targetSurah = QURAN_SURAHS.firstWhere(
    final userMsg = text.trim();
    _diniHocaInputController.clear();
              );
    setState(() {
      _diniHocaMessages.add({
        'isMe': true,
        'text': userMsg,
        'time': DateTime.now(),
      });
      _diniHocaIsTyping = true;
    });
                  ),
    _scrollToBottomDiniHoca();
              ).then((_) => _loadQuranLastRead());
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
              width: 36,
      final reply = _getDiniHocaResponse(userMsg);
      setState(() {
        _diniHocaIsTyping = false;
        _diniHocaMessages.add({
          'isMe': false,
          'text': reply,
          'time': DateTime.now(),
        });
      });
      _scrollToBottomDiniHoca();
    });
  }
              final targetSurah = QURAN_SURAHS.firstWhere(
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
                  ),
                ),
              ).then((_) => _loadQuranLastRead());
            },
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                juz.number.toString(),
                style: const TextStyle(
                  color: Color(0xFFC5A059),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            subtitle: Text(
              juz.range,
              style: TextStyle(
                color: _isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  juz.arabicLabel,
                  style: const TextStyle(
                    color: Color(0xFF27A770),
                    fontFamily: 'Traditional Arabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isDark ? Colors.white38 : Colors.black38,
                  size: 22,
                ),
              ],
            ),
          ),
        );
        ),
    );
        // Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0C1524) : Colors.grey[50],
            border: Border(
              top: BorderSide(
                color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _diniHocaInputController,
                            style: TextStyle(color: _textColor, fontSize: 14.5),
                            decoration: const InputDecoration(

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "İsim ara (Örn: Rahman)...",
            prefixIcon: Icon(Icons.search, color: Color(0xFF27A770)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            setState(() {


















            itemBuilder: (context, index) {
              final camii = MOCK_CAMILER[index];
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("📍 ${camii['adres'] ?? ''}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        camii['mesafe'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27A770),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "mesafe",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                        Text("Kıble Açısı:", style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.grey[800])),
                        Text("${qiblaAngle.toInt()}° (${_currentLocationName.isNotEmpty ? _currentLocationName : 'İstanbul'})",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      ],
          leading: Icon(Icons.check_circle, color: Colors.green),
          children: bozmayanlar
              .map(
                (item) => ListTile(
                  title: Text(item, style: TextStyle(fontSize: 13)),
                  leading: Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.grey,
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 8),
        ExpansionTile(
          title: Text(
            "Oruç Çeşitleri",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _greenColor,
            ),
          ),
          leading: Icon(Icons.menu_book, color: Color(0xFF27A770)),
          children: cesitler
              .map(
                (item) => ListTile(
                  title: Text(
                    item['ad'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    item['aciklama'] ?? '',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
                      const SizedBox(width: 10),
  // 10. Kıble Bulucu Compass
  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.
                      ),
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
            Text(
  Widget _buildAylikNamazVakitleri() {
    final bool dark = _isDark;
                fontSize: 14,
    if (_loadingMonthlyTimes) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
    {'name': 'Yatsı', 'key': 'Yatsi', 'icon': Icons.brightness_3, 'color': Color(0xFF3F51B5)},
  ];
    {'name': 'Akşam', 'key': 'Aksam', 'icon': Icons.flare, 'color': Color(0xFFFF7043)},
    {'name': 'Yatsı', 'key': 'Yatsi', 'icon': Icons.brightness_3, 'color': Color(0xFF3F51B5)},
  ];
                fontSize: 14,
  Widget _buildAylikNamazVakitleri() {
    final bool dark = _isDark;
        child: Column(
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
        child: Padding(
    if (_monthlyPrayerTimes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.grey,
                size: 64,
              ),
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
                offset: const Offset(0, 2),
    // Get today's date formatted as dd.MM.yyyy
    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
          child: Row(
    return Column(
      children: [
        // Premium Header Card showing selected location
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: dark
                  ? [const Color(0xFF131D31), const Color(0xFF0F1B2A)]
                  : [Colors.white, const Color(0xFFF0F4F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0xFF27A
                    Text(
                      "${_current
                    ? "Konumunuza Göre Sıralanmış Camiler"
                    : "Konumunuza En Yakın Camiler (Fatih/İstanbul)",
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
  // 14. Yakındaki Camiler
  Widget _buildYakindakiCamiler() {
    return Column(
                ),
              ),
            ],
          ),
        ),
            borderRadius: BorderRadius.circular(16),
        // Custom Column Headers Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1C2C42) : const Color(0xFFEAF7F1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Tarih",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.white70 : const Color(0xFF1E5E43),
                  ),
                ),
              ),
              ...['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'].map(
                (vakit) => Expanded(
                  flex: 1,
                  child: Text(
                    vakit,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white70 : const Color(0xFF1E5E43),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Scrollable List of days
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: ListView.builder(
              itemCount: _monthlyPrayerTimes.length,
              itemBuilder: (context, index) {
                final day = _monthlyPrayerTimes[index];
                final String dateStr = day['MiladiTarihKisa'] ?? '';
                final isToday = dateStr == todayStr;
                ),
                // Format short date (e.g. "21 May Per")
                final String dateUzun = day['MiladiTarihUzun'] ?? '';
        );
      }
    });
  }
                  final String m = dateParts[1].substring(0, math.min(3, dateParts[1].length));
  Widget _buildMiniTypingIndicator() {
    return _MiniDotAnimator(color: _subtitleColor);
  }
                            size: 15,
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
                padding: EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    PEYGAMBER_HAYATI[index]['baslik']?.split(' ')[0] ?? '',
                  ),
                  selected: active,
                  selectedColor: const Color(0xFF27A770),
                  labelStyle: TextStyle(
                    color: active ? Colors.white : _greenColor,
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
        SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PEYGAMBER_HAYATI[_prophetLifeTab]['baslik'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _greenColor,
                      ),
                    ),
                    Divider(height: 24),
                    Text(
                      PEYGAMBER_HAYATI[_prophetLifeTab]['icerik'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF27A770).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27A770).withOpacity(dark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          day['Ikindi'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: _textColor,
                          ),
                        ),
                      ),
                      Expanded(
                      Expanded(
                        flex: 1,
                        child: Text(
                          day['Ikindi'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: _textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          day['Aksam'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: _textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          day['Yatsi'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: _textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
                final String dateStr = day['MiladiTarihKisa'] ?? '';
                final isToday = dateStr == todayStr;
    final zikir = _zikirData[_selectedZikirId] ?? _zikirData['subhanallah']!;
                // Format short date (e.g. "21 May Per")
                final String dateUzun = day['MiladiTarihUzun'] ?? '';
                final List<String> dateParts = dateUzun.split(' ');
                String shortDate = dateStr;
                if (dateParts.length >= 4) {
                  final String d = dateParts[0];
                  final String m = dateParts[1].substring(0, math.min(3, dateParts[1].length));
                  final String dayName = dateParts[3].substring(0, math.min(3, dateParts[3].length));
                  shortDate = "$d $m $dayName";
                }
                  border: Border.all(
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF27A770).withOpacity(dark ? 0.15 : 0.08)
                        : (index % 2 == 0
                            ? (dark ? const Color(0xFF131D31).withOpacity(0.4) : Colors.white)
                            : (dark ? const Color(0xFF0F1B2A).withOpacity(0.2) : const Color(0xFFF9FBF9))),
                    border: Border(
                      bottom: BorderSide(
                        color: dark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                        width: 1,
                      ),
                      left: isToday
                          ? const BorderSide(color: Color(0xFF27A770), width: 4.5)
                          : BorderSide.none,
                            color: dark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                      ),
                    ),
                  ],
                ),
                                      : (dark ? Colors.white.withOpacity(0.9) : Colors.black87),
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Bugün",
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Times
                      ...vakitMeta.map(
                        (meta) => Expanded(
                          flex: 1,
                          child: Text(
                            day[meta['key']] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? const Color(0xFF27A770)
                                  : (dark ? Colors.white.withOpacity(0.85) : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
                    Text(
  // Spiritual Calendar Sheet Grid View
  Widget _buildMonthlyCalendarView(bool dark, String todayStr) {
    DateTime? firstDate;
    if (_monthlyPrayerTimes.isNotEmpty) {
      final parts = _monthlyPrayerTimes[0]['MiladiTarihKisa']?.split('.');
      if (parts != null && parts.length == 3) {
        firstDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
    int startOffset = firstDate != null ? firstDate.weekday - 1 : 0;
    final daysCount = _monthlyPrayerTimes.length;
    final totalCells = startOffset + daysCount;

    // Selected day data
    final selectedDayData = _monthlyPrayerTimes.isNotEmpty &&
            _selectedCalendarDayIndex >= 0 &&
            _selectedCalendarDayIndex < _monthlyP






















































                      bottom: BorderSide(
                        color: dark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                        width: 1,
                      ),
                      left: isToday
                          ? const BorderSide(color: Color(0xFF27A770), width: 4.5)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Date
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              shortDate,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday
                                    ? const Color(0xFF27A770)
                                    : (dark ? Colors.white.withOpacity(0.9) : Colors.black87),
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Bugün",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Times
                      ...vakitMeta.map(
                        (meta) => Expanded(
                          flex: 1,
                          child: Text(
                            day[meta['key']] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? const Color(0xFF27A770)
                                  : (dark ? Colors.white.withOpacity(0.85) : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
              title,
  // Spiritual Calendar Sheet Grid View
  Widget _buildMonthlyCalendarView(bool dark, String todayStr) {
    DateTime? firstDate;
    if (_monthlyPrayerTimes.isNotEmpty) {
      final parts = _monthlyPrayerTimes[0]['MiladiTarihKisa']?.split('.');
      if (parts != null && parts.length == 3) {
        firstDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
    int startOffset = firstDate != null ? firstDate.weekday - 1 : 0;
    final daysCount = _monthlyPrayerTimes.length;
    final totalCells = startOffset + daysCount;
                  color: Color(0xFF27A770),
                          child: Text(
                            "Cüzler",
                            style: TextStyle(
                              color: _quranTab == 1 ? Colors.white : (_isDark ? Colors.white60 : Colors.black54),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search Bar
              TextField(
                style: TextStyle(color: _isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: _quranTab == 0 ? "Sure ara (Örn: Yasin)..." : "Cüz ara...",
                  hintStyle: TextStyle(color: _isDark ? Colors.white38 : Colors.black45),
                  prefixIcon: Icon(Icons.search_rounded, color: _isDark ? Colors.white54 : Colors.black45),
                  suffixIcon: _quranSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: _isDark ? Colors.white54 : Colors.black45),
                          onPressed: () {
                            setState(() {
                              _quranSearchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: _isDark ? const Color(0xFF131F35) : Colors.white,













































































































































































































































































































































































































































































































  Widget _buildYasinSuresi() {
    const String yasinUrl = "https://server8.mp3quran.net/afs/036.mp3";
    const String yasinName = "Yasin Suresi - Meal ve Tilavet";
    final isCurrent = _currentAudioUrl == yasinUrl;

    return Column(
      children: [
                    final isToday = dateStr == todayStr;
                    final isSelected = dayIndex == _selectedCalendarDayIndex;
          decoration: BoxDecoration(
                    // Extract day number (e.g. "21")
                    String dayNum = "";
                    final parts = dateStr.split('.');
                    if (parts.isNotEmpty) {
                      dayNum = int.parse(parts[0]).toString();
                    }
              Text(
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCalendarDayIndex = dayIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF27A770).withOpacity(dark ? 0.18 : 0.08)
                              : (isSelected
                                  ? const Color(0xFFD4AF37).withOpacity(dark ? 0.15 : 0.08)
                                  : (dark ? const Color(0xFF0F1B2A).withOpacity(0.3) : const Color(0xFFF9FBF9))),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF27A770)
                                : (isSelected
                                    ? const Color(0xFFD4AF37)
                                    : (dark ? Colors.white.withOpacity(0.04) :
                          : Icons.play_circle_filled,
                      color: const Color(0xFF27A770),
                    ),













        SizedBox(height: 16),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Yasin-i Şerif İlk Ayetleri",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _greenColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n"
                "يس ﴿١﴾ وَالْقُرْآنِ الْحَكِيمِ ﴿٢﴾ إِنَّكَ لَمِنَ الْمُرْسَلِينَ ﴿٣﴾ عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ ﴿٤﴾ تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ ﴿٥﴾ لِتُنْذِرَ قَوْمًا مَا أُنْdevİRİLMİŞTİR ﴿٦﴾ لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ ﴿٧﴾",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Traditional Arabic',
                  fontSize: 20,
                  height: 2.2,
                  color: _textColor,
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
            "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِ
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
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
                        "• ",
  Widget _buildWeekViewChart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
        children: [
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: const Color(0xFF27A770), size: 20),
              SizedBox(width: 8),
              Text(
                "Bu Haftanın Zikir Takibi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _greenColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.g
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    zikir['ad'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27A770),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    zikir['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: _isDark ? Colors.white60 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF9EDD4)),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
          SizedBox(height: 20),
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
                  BoxShadow(color: Colors.black12, blurRad

























          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBgColor,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Sıfırla"),
                      content: Text(
                        "Sayacı sıfırlamak istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: _isDark ? Colors.white60 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF9EDD4)),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
          SizedBox(height: 20),
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
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _greenColor,
                      ),
                    ),
                    Text(
                      _zikirTarget == 9999 ? "/ ∞" : "/ $_zikirTarget",
                      style: TextStyle(fontSize: 13, color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildWeekViewChart(),
          SizedBox(height: 16),
          // Zikir actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBgColor,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Sıfırla"),
                      content: Text(
                        "Sayacı sıfırlamak istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetZikir();
                            Navigator.pop(context);
                          },
                          child: Text("Evet"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text("Sıfırla", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zikirSoundEnabled ? const Color(0xFF27A770) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _zikirSoundEnabled = !_zikirSoundEnabled;
                  });
                },
                child: Text(







































































































































































































































              ? Center(
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
                          Icon(Icons.mosque, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            "Yakınınızda cami bulunamadı.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _getUserLocation(forceRefresh: true),
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text("Tekrar Dene"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27A770),
                              foregroundColor: Colors.white,








































































































































































































                              backgroundColor: Color(0xFFEAF7F1),
                              child: Icon(Icons.mosque, color: Color(0xFF27A770)),
                            ),
                            title: Text(
                              camii['ad'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "📍 ${camii['adres'] ?? ''}",
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  camii['mesafeText'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF27A770),
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Icon(Icons.directions, size: 16, color: Color(0xFF27A770)),





































































































































































































































































































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
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua['ad'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _greenColor,
                  ),
                ),
                Divider(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dua['arapca'] ?? '',
                    style: TextStyle(
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _greenColor,
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
                borderSide: BorderSide.none,
  // 17. Günlük Dualar
  // 17. Günlük Dualar
  Widget _buildGunlukDualar() {
    final totalKuran = KURAN_DUALARI.length;
    final totalHadis = HADIS_DUALARI.length;
        final dua = DUALAR[index];
    final rawList = _dualarTab == 0 ? KURAN_DUALARI : HADIS_DUALARI;
    final filteredList = rawList.where((dua) {
      final matchesSearch = _dualarSearchQuery.isEmpty ||
          _normalize(dua['ad'] ?? '').contains(_normalize(_dualarSearchQuery)) ||
          _normalize(dua['sure'] ?? '').contains(_normalize(_dualarSearchQuery)) ||
          _normalize(dua['anlam'] ?? '').contains(_normalize(_dualarSearchQuery));
          child: Padding(
      final matchesFavorite = !_showOnlyFavorites || _favoriteDualar.contains(dua['id']);
            child: Column(
      return matchesSearch && matchesFavorite;
    }).toList();
                Text(
    final Map<String, List<Map<String, String>>> grouped = {
      'sabah_aksam': [],
      'namaz': [],
      'yemek': [],
      'uyku': [],
      'yolculuk': [],
      'genel': [],
    };
    for (var dua in filteredList) {
    for (var dua in filteredList) {
      final cat = dua['kategori'] ?? 'genel';
      grouped[cat]?.add(dua);
    }
    final categories = [
    final categories = [
      {'key': 'sabah_aksam', 'title': 'Sabah & Akşam Ezkarı', 'emoji': '☀️'},
      {'key': 'namaz', 'title': 'Namaz Duaları', 'emoji': '🕌'},
      {'key': 'yemek', 'title': 'Yemek Duaları', 'emoji': '🍴'},
      {'key': 'uyku', 'title': 'Uyku Duaları', 'emoji': '🌙'},
      {'key': 'yolculuk', 'title': 'Yolculuk Duaları', 'emoji': '🚗'},
      {'key': 'genel', 'title': 'Genel Dualar', 'emoji': '✨'},
    ];
                SizedBox(height: 8),
    bool isPlaying(String url) => _currentAudioUrl == url && _playerState == PlayerState.playing;
      final isSelected = _dualarTab == index;
    Widget buildSegmentButton(int index, String label, int count) {
      final isSelected = _dualarTab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _dualarTab = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDeco
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,


              border: isSelected
                  ? Border.all(color: const Color(0xFFC19E67), width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFC19E67)
                        : (_isDark ? Colors.grey : Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC19E67).withOpacity(0.15)
                        : (_isDark ? Colors.grey[850] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFC19E67)
                          : (_isDark ? Colors.grey : Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    ]);
    final tabRow = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1E1613) : const Color(0xFFEDF2F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          buildSegmentButton(0, "Kur'an Duaları", totalKuran),
          buildSegmentButton(1, "Hadis Duaları", totalHadis),
        ],
      ),
    );

    List<Widget> items = [];
    bool hasAnyItems = false;
    for (var cat in categories) {
      final key = cat['key']!;
      final list = grouped[key] ?? [];
      if (list.isEmpty) continue;

      hasAnyItems = true;

      // Section Header
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Row(
            children: [
              Text(
                "${cat['emoji']} ${cat['title']}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC19E67),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.
      "Med Harfleri (Uzatma): Elif (ا), Vav (و), Ya (ي) harfleridir. Önündeki harfi uzatarak okuturlar.",
      "Tenvin ve Sakin Nun Kuralları: Sakin nun (نْ) veya tenvin (ً ٍ ٌ) işaretlerinden sonra gelen harflere göre şekillenir.",
      "İzhar: Sakin nun veya tenvinden sonra boğaz harfler
      "İdgam-ı Mealgunne: Sakin nun veya tenvinden sonra (ي, م, ن, و) harfleri gelirse, ses burundan (genizden) verilerek şeddeli gibi okunur.",
      "İhfa: Sakin nun veya tenvinden sonra izhar ve idgam harfleri dışındaki 15 harf gelirse, nun sesi genizden gizlenerek okunur.",
      "Kalkale (Yankılama): (ق, ط, b, ج, د) harfleri sakin (cezimli) geldiğinde kuvvetli bir ses vurgusuyla yankılatılarak okunur.",
    ]);
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
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.3) : const Color(0xFF27A770).w
























                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Play Button
                    GestureDetector(
                      onTap: () {
                        if (url.isNotEmpty) {
                          _playAudio(url, title);
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDark ? const Color(0xFF302820) : const Color(0xFFEAF7F1),
                        ),
                        child: Icon(
                          isPlaying(url)
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: const Color(0xFFC19E67),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorite Heart Button
                    GestureDetector(
                      onTap: () => _toggleFavoriteDua(id),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : (_isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    final double bracketW = 16;
    return Column(
      children: [
        tabRow,
        Expanded(
          child: hasAnyItems
              ? ListView(
                  physics: const BouncingScrollPhysics(),
                  children: items,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showOnlyFavorites ? Icons.favorite_border : Icons.search_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showOnlyFavorites
                            ? "Favori duanız bulunmuyor."
                            : "Aramanızla eşleşen dua bulunamadı.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _showDuaDetailBottomSheet(Map<String, String> dua) {
    final title = dua['ad'] ?? '';
    final source = dua['sure'] ?? '';
    final arabic = dua['arapca'] ?? '';
    final trans = dua['okunus'] ?? '';
    final translation = dua['anlam'] ?? '';
    final url = dua['
      "İhfa: Sakin nun veya tenvinden sonra izhar ve idgam harfleri dışındaki 15 harf gelirse, nun sesi genizden gizlenerek okunur.",
      "Kalkale (Yankılama): (ق, ط, b, ج, د) harfleri sakin (cezimli) geldiğinde kuvvetli bir ses vurgusuyla yankılatılarak okunur.",
    ]);
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
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.bottom(15),
                      decoration: BoxDecoration(
                        color: _isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(











                            Text(
                              step['ad'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _greenColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: _isDark ? Colors.white70 : Colors.black54,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.format_size, size: 16, color: Color(0xFFC19E67)),
                      const SizedBox(width: 8),
                      const Text(
                        "Yazı Boyutu",
                        style: TextStyle(fontSize: 12, color: Color(0xFFC19E67)),
                      ),
                      Expanded(
                        child: Slider(
                          value: arabicFontSize,
                          min: 16.0,
                          max: 36.0,
                          activeColor: const Color(0xFFC19E67),
                          inactiveColor: _isDark ? Colors.grey[800] : Colors.grey[200],
                          onChanged: (val) {
                            setModalState(() {
                              arabicFontSize = val;
                              translationFontSize = val - 10.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (arabic.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isDark ? const Color(0xFF1E1715) : const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isDark ? const Color(0xFF2C221F) : Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                              child: SelectionArea(
                                child: Text(
                                  arabic,
                                  style: TextStyle(
                                    fontFamily: 'Traditional Arabic',
                                    fontSize: arabicFontSize,
                                    height: 1.8,
                                    fontWeight: FontWeight.b








































                            ),
                            const SizedBox(height: 6),
                            SelectionArea(
                              child: Text(
                                translation,
                                style: TextStyle(
                                  fontSize: translationFontSize,
                                  height: 1.5,
                                  color: _isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  if (url.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _playAudio(url, title);
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC19E67),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPlaying() ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isPlaying() ? "Durdur" : "Dinle",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          StatefulBuilder(
                            builder: (context, setFavState) {
                              final isFav = _favoriteDualar.contains(id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : (_isDark ? Colors.white70 : Colors.black54),
                                ),
                                iconSize: 28,
                                onPressed: () async {
                                  await _toggleFavoriteDua(id);
                                  setFavState(() {});
                                  setModalState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],












  Widget _buildZekatHesaplama() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dinen zengin sayılan kişilerin yılda bir kez vermesi gereken zekat miktarını hesaplayın.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 12),
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
          SizedBox(height: 8),
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
              child: Text(
                "Zekat Hesapla",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_zekatResult.isNotEmpty) ...[
            SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF27A770).withOpacity(0.3),
                  ),
                ),



















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
            prefixIcon: Icon(Icons.search, color: Color(0xFF27A770)),
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
        SizedBox(height: 12),
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
                margin: EdgeInsets.only(bot








































                          fontSize: 13,
                          height: 1.45,
                          color: _textColor,
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
        Text(
          "İslam Tarihi Önemli Dönemeçleri",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _greenColor,
          ),
        ),
        SizedBox(height: 12),
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
                        decoration: BoxDecoration(
                          color: Color(0xFF27A770),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < ISLAM_TARIHI.length - 1)
                        Container(
                          width: 2,
                          height: 70,







































  Widget _buildNamazKilma() {
    final List<dynamic> steps =
        NAMAZ_KILMA_REHBERI[_namazKilmaErkek ? 'erkek' : 'kadin'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: Text("Erkek"),
              selected: _namazKilmaErkek,
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = true;
                });
              },
            ),
            SizedBox(width: 12),
            ChoiceChip(
              label: Text("Kadın"),
              selected: !_namazKilmaErkek,
              onSelected: (val) {
                setState(() {
                  _namazKilmaErkek = false;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 12),
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
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(



















                                color: _greenColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              step['aciklama'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: _textColor,
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vitir Namazı Nedir?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _greenColor,
                    ),

















































































































  Widget _buildStepRehberi(String title, List<Map<String, String>> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _greenColor,
          ),
        ),
        SizedBox(height: 12),
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
                margin: EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF27A770),
                        foregroundColor: Colors.white,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (step['baslik'] != null &&
  }
}

class _KibleSanatsalPusulaPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;

  _KibleSanatsalPusulaPainter({
    required this.isDark,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);




































    path.lineTo(center.dx - diagonalRadius, center.dy - diagonalRadius);
    path.lineTo(center.dx + diagonalRadius, center.dy - diagonalRadius);
    path.close();

    canvas.drawPath(path, starPaint);
    canvas.drawPath(path, starBorderPaint);

    // Draw small inner decorative circles
    canvas.drawCircle(center, starRadius * 0.4, starBorderPaint);
    canvas.drawCircle(center, starRadius * 0.2, starBorderPaint);

    // 3. Elegant Ticks (every 10 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * math.pi / 180;
      final bool isMajor = i % 30 == 0;
      final bool isCardinal = i % 90 == 0;

      final double tickLength = isCardinal ? 12 : (isMajor ? 8 : 4);
      final double startR = radius - 16;
      final double endR = startR - tickLength;

      tickPaint.color = isCardinal
          ? const Color(0xFFD4AF37)
          : (isDark ? Colors.white30 : Colors.black26);
      tickPaint.strokeWidth = isCardinal ? 2.0 : (isMajor ? 1.5 : 1.0);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}























































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
            "Eller tekrar ıslatılarak serçe parmaklarla kulak içi, b










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
        Text(
          "Kaza Namazı Takip Çizelgesi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _greenColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Geçmiş namaz borçlarınızı kaydetmek ve düzenlemek için +/- butonlarını kullanın.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: kazalar.keys.map((name) {
              final count = kazalar[name] ?? 0;
              final key = keys[name]!;
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(





































                              size: 28,
                            ),
                            onPressed: () => _updateKaza(key, -1),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27A770).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$count",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _greenColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
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
                  foregroundColor: _ezkarTab == 0 ? Colors.white : _greenColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => setState(() => _ezkarTab = 0),
                child: Text("Sabah Zikirleri"),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ezkarTab == 1 ? const Color(0xFF27A770) : Colors.white,
                  foregroundColor: _ezkarTab == 1 ? Colors.white : _greenColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => setState(() => _ezkarTab = 1),
                child: Text("Akşam Zikirleri"),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Expanded(
          child: _ezkarTab == 0














































































                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _greenColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
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
                                      : _greenColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(













































































































































































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
      "4. Allah'ın Peygamberl












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



















































































































































































































































































































































            "Ayetel Kürsi",
            "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُ—ُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ",
            "Allâhü lâ ilâhe illâ hüvel hayyül kayyûm, lâ te'huzühû sinetün velâ nevm...",
            "Allah kendisinden başka hiçbir ilah olmayandır. Diridir, kayyumdur. O'nu ne bir uyuklama tutar, ne de bir uyku. Göklerdeki her şey, yerdeki her şey O'nundur...",
          ),
          SizedBox(height: 12),
          _buildSimpleDuaCard(
            "Felak Suresi",
            "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِنْ شَرِّ مَا خَلَقَ",
            "Kul eûzü birabbil felak. Min şerri mâ halak...",
            "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyenlerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden sabahın Rabbine sığınırım.",
          ),
          SizedBox(height: 12),
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



















































































































































































































































































































































































































































































      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * math.pi / 180;
      final bool isMajor = i % 30 == 0;
      final bool isCardinal = i % 90 == 0;

      final double tickLength = isCardinal ? 12 : (isMajor ? 8 : 4);
      final double startR = radius - 16;
      final double endR = startR - tickLength;

      tickPaint.color = isCardinal
          ? const Color(0xFFD4AF37)
          : (isDark ? Colors.white30 : Colors.black26);
      tickPaint.strokeWidth = isCardinal ? 2.0 : (isMajor ? 1.5 : 1.0);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



























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
        String dots = ".";
        if (_controller.value > 0.33) dots = "..";
        if (_controller.value > 0.66) dots = "...";
        return Text(
          dots,
          style: TextStyle(
            color: widget.color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
      },
    );
  }
}





























































































































































































































































































































































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
        String dots = ".";
        if (_controller.value > 0.33) dots = "..";
        if (_controller.value > 0.66) dots = "...";
        return Text(
          dots,
          style: TextStyle(
            color: widget.color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
      },
    );
  }
}
