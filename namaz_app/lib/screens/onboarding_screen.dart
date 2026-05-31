import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../data/prayer_repository.dart';
import '../services/notification_service.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onThemeChanged;
  final VoidCallback onLocationReset;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.onThemeChanged,
    required this.onLocationReset,
  });

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PrayerRepository _repository = PrayerRepository();
  final NotificationService _notificationService = NotificationService();

  int _currentStep = 1; // 1: Profile/Welcome, 2: Permissions, 3: Location
  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = 'erkek';
  bool _gpsPermissionGranted = false;
  bool _notificationPermissionGranted = false;

  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];

  Map<String, dynamic>? _selectedCity;
  Map<String, dynamic>? _selectedDistrict;

  bool _loadingCities = true;
  bool _loadingDistricts = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _checkExistingPermissions();
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final gender = prefs.getString('user_gender');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _nameController.text = name;
        if (gender != null) {
          _selectedGender = gender;
        }
        _currentStep = 3;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingPermissions() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
      setState(() {
        _gpsPermissionGranted = true;
      });
    }
  }

  String normalizeString(String str) {
    return str
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
    });
    final cities = await _repository.getCities();
    setState(() {
      _cities = cities;
      _loadingCities = false;
    });
  }

  Future<void> _loadDistricts(String cityId) async {
    setState(() {
      _loadingDistricts = true;
      _selectedDistrict = null;
      _districts = [];
    });
    final districts = await _repository.getDistricts(cityId);
    setState(() {
      _districts = districts;
      _loadingDistricts = false;
    });
  }

  Future<void> _requestGpsPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      setState(() {
        _gpsPermissionGranted = true;
      });
      _showSnackBar("Konum izni başarıyla verildi.", success: true);
    } else {
      _showSnackBar("Konum izni reddedildi.");
    }
  }

  Future<void> _requestNotificationPermission() async {
    await _notificationService.init();
    setState(() {
      _notificationPermissionGranted = true;
    });
    _showSnackBar("Bildirim izni başarıyla talep edildi.", success: true);
  }

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF27A770) : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleGpsLocation() async {
    setState(() {
      _saving = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _saving = false);
        _showSnackBar("Lütfen telefonunuzun konum servisini (GPS) açın.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _saving = false);
          _showSnackBar("Konum izni verilmedi.");
          return;
        }
      }

      Position? position;
      try {
        debugPrint("Attempting to get fresh live GPS location...");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
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
      
      if (position == null) {
        throw Exception("Konum bilgisi alınamadı.");
      }

      final geoUri = Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=tr');
      final geoResponse = await http.get(geoUri);
      
      if (geoResponse.statusCode == 200) {
        final Map<String, dynamic> geoData = json.decode(geoResponse.body);
        
        final List<dynamic> adminList = geoData['localityInfo']?['administrative'] ?? [];
        final List<String> geoNames = adminList.map((item) => normalizeString(item['name']?.toString() ?? '')).toList();
        
        if (geoData['city'] != null) geoNames.add(normalizeString(geoData['city']));
        if (geoData['locality'] != null) geoNames.add(normalizeString(geoData['locality']));
        if (geoData['principalSubdivision'] != null) geoNames.add(normalizeString(geoData['principalSubdivision']));

        final cities = await _repository.getCities();
        
        Map<String, dynamic> matchedCity = cities.firstWhere(
          (city) => geoNames.contains(normalizeString(city['SehirAdi'] ?? '')),
          orElse: () => <String, dynamic>{},
        );

        if (matchedCity.isEmpty && geoData['principalSubdivision'] != null) {
          final normSub = normalizeString(geoData['principalSubdivision']);
          matchedCity = cities.firstWhere(
            (city) => normalizeString(city['SehirAdi'] ?? '').contains(normSub) || normSub.contains(normalizeString(city['SehirAdi'] ?? '')),
            orElse: () => <String, dynamic>{},
          );
        }

        if (matchedCity.isNotEmpty) {
          final String cityId = matchedCity['SehirID'].toString();
          final String cityName = matchedCity['SehirAdi'];
          
          final districts = await _repository.getDistricts(cityId);
          
          Map<String, dynamic> matchedDistrict = districts.firstWhere(
            (dist) => geoNames.contains(normalizeString(dist['IlceAdi'] ?? '')),
            orElse: () => <String, dynamic>{},
          );

          if (matchedDistrict.isEmpty) {
            matchedDistrict = districts.isNotEmpty ? districts[0] : <String, dynamic>{};
          }

          if (matchedDistrict.isNotEmpty) {
            final String districtId = matchedDistrict['IlceID'].toString();
            final String districtName = matchedDistrict['IlceAdi'];

            final times = await _repository.getPrayerTimes(
              districtId,
              forceRefresh: true,
            );

            await _repository.saveLocation(cityName, cityId, districtName, districtId);

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', _nameController.text.trim());
            await prefs.setString('user_gender', _selectedGender);

            await _notificationService.schedulePrayerAlarms(times);

            setState(() {
              _saving = false;
            });

            _showSnackBar("Konum GPS ile belirlendi: $cityName/$districtName", success: true);
            widget.onComplete();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MainAppContainerWrapper(
                    onThemeChanged: widget.onThemeChanged,
                    onLocationReset: widget.onLocationReset,
                  ),
                ),
              );
            }
            return;
          }
        }
      }
      
      setState(() => _saving = false);
      _showSnackBar("Konum otomatik eşleşmedi. Lütfen listeden manuel seçin.");
    } catch (e) {
      debugPrint("GPS auto-detect error: $e");
      setState(() => _saving = false);
      _showSnackBar("Konum alınırken hata oluştu. Lütfen listeden manuel seçin.");
    }
  }

  Future<void> _handleSave() async {
    if (_selectedCity == null || _selectedDistrict == null) return;
    setState(() {
      _saving = true;
    });

    final String cityName = _selectedCity!['SehirAdi'];
    final String cityId = _selectedCity!['SehirID'].toString();
    final String districtName = _selectedDistrict!['IlceAdi'];
    final String districtId = _selectedDistrict!['IlceID'].toString();

    final times = await _repository.getPrayerTimes(
      districtId,
      forceRefresh: true,
    );

    await _repository.saveLocation(cityName, cityId, districtName, districtId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_gender', _selectedGender);

    await _notificationService.schedulePrayerAlarms(times);

    setState(() {
      _saving = false;
    });

    widget.onComplete();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainAppContainerWrapper(
            onThemeChanged: widget.onThemeChanged,
            onLocationReset: widget.onLocationReset,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E5E43), // Rich dark green
              Color(0xFF27A770), // Islamic primary green
              Color(0xFFEAF7F1), // Very light soft green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(theme),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 2:
        return _buildStep2(theme);
      case 3:
        return _buildStep3(theme);
      case 1:
      default:
        return _buildStep1(theme);
    }
  }

  // STEP 1: WELCOME & PROFILE INFO
  Widget _buildStep1(ThemeData theme) {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF27A770).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text("🕌", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Ezan Vakitleri",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E5E43),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Uygulamamıza hoş geldiniz! Size özel bir deneyim sunabilmemiz için lütfen bilgilerinizi giriniz.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Adınız Soyadınız",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Color(0xFF27A770),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Cinsiyetiniz (Rehber uyumu için):",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5E43),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGender == 'erkek'
                      ? const Color(0xFF27A770)
                      : Colors.grey[200],
                  foregroundColor:
                      _selectedGender == 'erkek' ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _selectedGender = 'erkek';
                  });
                },
                child: const Text("👨 Erkek"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGender == 'kadin'
                      ? const Color(0xFFE5A93B)
                      : Colors.grey[200],
                  foregroundColor:
                      _selectedGender == 'kadin' ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _selectedGender = 'kadin';
                  });
                },
                child: const Text("👩 Kadın"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF27A770),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27A770),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                _showSnackBar("Lütfen adınızı giriniz.");
                return;
              }
              setState(() {
                _currentStep = 2;
              });
            },
            child: const Text(
              "Sonraki Adım ➡️",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: PERMISSIONS REQUESTS
  Widget _buildStep2(ThemeData theme) {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF27A770).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text("🛡️", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "İzinleri Yapılandır",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E5E43),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Uygulamanın tam işlevsel çalışabilmesi için lütfen aşağıdaki sistem izinlerini etkinleştirin.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),

        // GPS Card
        Card(
          elevation: 0,
          color: _gpsPermissionGranted ? const Color(0xFFF0FCF7) : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _gpsPermissionGranted ? const Color(0xFF27A770) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("🛰️", style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Konum İzni",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "En yakın camileri listelemek ve vakitleri GPS üzerinden bulmak için.",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gpsPermissionGranted
                        ? const Color(0xFF27A770)
                        : const Color(0xFF1E5E43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _requestGpsPermission,
                  child: Text(_gpsPermissionGranted ? "✓ Etkin" : "İzin Ver", style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Notification Card
        Card(
          elevation: 0,
          color: _notificationPermissionGranted ? const Color(0xFFF0FCF7) : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _notificationPermissionGranted ? const Color(0xFF27A770) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("🔔", style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bildirim İzni",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ezan vakitlerinde alarm çalmak ve dini paylaşımlar göndermek için.",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _notificationPermissionGranted
                        ? const Color(0xFF27A770)
                        : const Color(0xFF1E5E43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _requestNotificationPermission,
                  child: Text(_notificationPermissionGranted ? "✓ Etkin" : "İzin Ver", style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF27A770),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: const Text("Geri"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A770),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 3;
                  });
                },
                child: const Text(
                  "Sonraki ➡️",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: LOCATION SELECTION
  Widget _buildStep3(ThemeData theme) {
    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF27A770).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text("📍", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Konum Seçimi",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E5E43),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Doğru namaz vakitleri için lütfen konumunuzu seçin. Diyanet İşleri Başkanlığı verilerine göre vakitleriniz hesaplanacaktır.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),

        // GPS button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27A770),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _saving ? null : _handleGpsLocation,
            icon: const Icon(Icons.gps_fixed),
            label: const Text(
              "Konumumu Otomatik Bul (GPS)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "veya manuel olarak seçin:",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        // City Dropdown
        if (_loadingCities)
          const CircularProgressIndicator(
            color: Color(0xFF27A770),
          )
        else
          DropdownButtonFormField<Map<String, dynamic>>(
            decoration: InputDecoration(
              labelText: "Şehir Seçin",
              labelStyle: const TextStyle(
                color: Color(0xFF1E5E43),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.location_city,
                color: Color(0xFF27A770),
              ),
            ),
            value: _selectedCity,
            items: _cities.map((city) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: city,
                child: Text(city['SehirAdi'] ?? ''),
              );
            }).toList(),
            onChanged: _saving
                ? null
                : (val) {
                    setState(() {
                      _selectedCity = val;
                      _selectedDistrict = null;
                    });
                    if (val != null) {
                      _loadDistricts(val['SehirID'].toString());
                    }
                  },
          ),
        const SizedBox(height: 16),

        // District Dropdown
        if (_selectedCity != null) ...[
          if (_loadingDistricts)
            const CircularProgressIndicator(
              color: Color(0xFF27A770),
            )
          else
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: "İlçe Seçin",
                labelStyle: const TextStyle(
                  color: Color(0xFF1E5E43),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.map,
                  color: Color(0xFF27A770),
                ),
              ),
              value: _selectedDistrict,
              items: _districts.map((dist) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: dist,
                  child: Text(dist['IlceAdi'] ?? ''),
                );
              }).toList(),
              onChanged: _saving
                  ? null
                  : (val) {
                      setState(() {
                        _selectedDistrict = val;
                      });
                    },
            ),
          const SizedBox(height: 24),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF27A770),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saving
                    ? null
                    : () {
                        setState(() {
                          _currentStep = 2;
                        });
                      },
                child: const Text("Geri"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A770),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (_selectedCity == null ||
                        _selectedDistrict == null ||
                        _saving)
                    ? null
                    : _handleSave,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Başla 🕋",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
