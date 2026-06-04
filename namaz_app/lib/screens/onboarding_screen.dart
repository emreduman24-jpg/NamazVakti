import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/prayer_repository.dart';
import '../services/notification_service.dart';
import 'splash_screen.dart';
import 'premium_screen.dart';

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

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PrayerRepository _repository = PrayerRepository();
  final NotificationService _notificationService = NotificationService();
  final PageController _pageController = PageController();

  // Animation controller for the rotating gears on setup screen
  late AnimationController _gearAnimationController;

  int _activePage = 0;
  bool _saving = false;
  bool _loadingLocation = false;

  // Setup/Loading states
  String _setupStatusText = "Namaz vakitleri hesaplanıyor ...";

  // Selected Method (Screen 4)
  String _selectedMethod = 'diyanet'; // 'diyanet', 'bae', 'bask'

  // Notification Reminder customization (Screen 7)
  String _selectedReminderTime = 'vaktinde'; // '30', '15', 'vaktinde', 'kapali'

  // Rating Dialog State (Popup Overlay)
  bool _showRatingDialog = false;
  int _selectedStars = 0;

  // Location details (Screen 3)
  Map<String, String?> _location = {};
  List<Map<String, dynamic>> _prayerTimes = [];
  List<Map<String, dynamic>> _originalPrayerTimes = []; // Backup of original fetched times
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];
  Map<String, dynamic>? _selectedCity;
  Map<String, dynamic>? _selectedDistrict;
  bool _loadingCities = true;
  bool _loadingDistricts = false;

  // Preview notifications settings (Feedback 2)
  final Map<String, String> _previewNotifications = {
    'İmsak': 'sesli',
    'Güneş': 'kapali',
    'Öğle': 'sesli',
    'İkindi': 'sesli',
    'Akşam': 'sesli',
    'Yatsı': 'sesli',
  };

  @override
  void initState() {
    super.initState();
    _loadCities();

    // Set up continuous rotation for gears
    _gearAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gearAnimationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_activePage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevPage() {
    if (_activePage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? const Color(0xFF27A770) : const Color(0xFFE53935),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _varyPrayerTimes({required int offsetMinutes}) {
    if (_originalPrayerTimes.isEmpty) return;
    
    setState(() {
      _prayerTimes = _originalPrayerTimes.map((timeMap) {
        final newMap = Map<String, dynamic>.from(timeMap);
        
        String offsetTime(String? timeStr) {
          if (timeStr == null || !timeStr.contains(':')) return timeStr ?? '';
          try {
            final parts = timeStr.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            
            final totalMinutes = hour * 60 + minute + offsetMinutes;
            final newHour = (totalMinutes ~/ 60) % 24;
            final newMinute = totalMinutes % 60;
            
            return "${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}";
          } catch (e) {
            return timeStr;
          }
        }
        
        newMap['Imsak'] = offsetTime(timeMap['Imsak']);
        newMap['Gunes'] = offsetTime(timeMap['Gunes']);
        newMap['Ogle'] = offsetTime(timeMap['Ogle']);
        newMap['Ikindi'] = offsetTime(timeMap['Ikindi']);
        newMap['Aksam'] = offsetTime(timeMap['Aksam']);
        newMap['Yatsi'] = offsetTime(timeMap['Yatsi']);
        
        return newMap;
      }).toList();
    });
  }

  Future<void> _launchStore() async {
    final Uri url = Uri.parse("https://play.google.com/store/apps/details?id=com.example.namazvakitleri.namaz_app");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Launch store error: $e");
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
    setState(() => _loadingCities = true);
    final cities = await _repository.getCities();
    setState(() {
      _cities = cities;
      _loadingCities = false;
    });
  }



  String _formatTurkishCity(String city) {
    if (city.isEmpty) return '';
    return city
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ş', 'Ş')
        .replaceAll('ç', 'Ç')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ü', 'Ü')
        .replaceAll('ö', 'Ö')
        .toUpperCase();
  }

  String _formatTurkishDistrict(String district) {
    if (district.isEmpty) return '';
    
    String lower = district
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ç', 'ç')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ö', 'ö')
        .toLowerCase();
        
    List<String> words = lower.split(' ');
    List<String> formattedWords = [];
    
    for (var word in words) {
      if (word.isEmpty) continue;
      
      String firstChar = word.substring(0, 1);
      String rest = word.substring(1);
      
      String upperFirst = firstChar
          .replaceAll('i', 'İ')
          .replaceAll('ı', 'I')
          .replaceAll('ş', 'Ş')
          .replaceAll('ç', 'Ç')
          .replaceAll('ğ', 'Ğ')
          .replaceAll('ü', 'Ü')
          .replaceAll('ö', 'Ö')
          .toUpperCase();
          
      formattedWords.add(upperFirst + rest);
    }
    
    return formattedWords.join(' ');
  }

  // Request Location Permissions & Autodetect Location
  Future<void> _requestLocationAndDetect() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showSnackBar("Lütfen telefonunuzun konum servisini (GPS) açın.");
          setState(() => _loadingLocation = false);
          _goToNextPage();
          return;
        }

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
        } catch (e) {
          position = await Geolocator.getLastKnownPosition();
        }

        if (position != null) {
          final geoUri = Uri.parse(
              'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=tr');
          final geoResponse = await http.get(geoUri);

          if (geoResponse.statusCode == 200) {
            final Map<String, dynamic> geoData = json.decode(geoResponse.body);
            final List<dynamic> adminList = geoData['localityInfo']?['administrative'] ?? [];
            final List<String> geoNames =
                adminList.map((item) => normalizeString(item['name']?.toString() ?? '')).toList();

            if (geoData['city'] != null) geoNames.add(normalizeString(geoData['city']));
            if (geoData['locality'] != null) geoNames.add(normalizeString(geoData['locality']));
            if (geoData['principalSubdivision'] != null) {
              geoNames.add(normalizeString(geoData['principalSubdivision']));
            }

            final cities = await _repository.getCities();
            Map<String, dynamic> matchedCity = cities.firstWhere(
              (city) => geoNames.contains(normalizeString(city['SehirAdi'] ?? '')),
              orElse: () => <String, dynamic>{},
            );

            if (matchedCity.isEmpty && geoData['principalSubdivision'] != null) {
              final normSub = normalizeString(geoData['principalSubdivision']);
              matchedCity = cities.firstWhere(
                (city) => normalizeString(city['SehirAdi'] ?? '').contains(normSub) ||
                    normSub.contains(normalizeString(city['SehirAdi'] ?? '')),
                orElse: () => <String, dynamic>{},
              );
            }

            if (matchedCity.isNotEmpty) {
              final String cityId = matchedCity['SehirID'].toString();
              final String cityName = matchedCity['SehirAdi'];

              final districts = await _repository.getDistricts(cityId);
              
              // Robust Tuzla / Merkez matching logic to avoid "İSTANBUL" district overtaking specific sub-localities
              Map<String, dynamic> matchedDistrict = <String, dynamic>{};
              final String normalizedCityName = normalizeString(cityName);
              
              // 1. Try exact match for geoData's specific locality (e.g., "tuzla") ONLY if it's not the same as the city name
              final String? locality = geoData['locality'] != null ? normalizeString(geoData['locality']) : null;
              if (locality != null && locality != normalizedCityName) {
                matchedDistrict = districts.firstWhere(
                  (dist) => normalizeString(dist['IlceAdi'] ?? '') == locality,
                  orElse: () => <String, dynamic>{},
                );
              }
              
              // 2. Prioritize sub-locality names in geoNames that are NOT equal to the city-level name matching
              if (matchedDistrict.isEmpty) {
                matchedDistrict = districts.firstWhere(
                  (dist) => geoNames.contains(normalizeString(dist['IlceAdi'] ?? '')) &&
                            normalizeString(dist['IlceAdi'] ?? '') != normalizedCityName,
                  orElse: () => <String, dynamic>{},
                );
              }
              
              // 3. Fallback to any geoNames match
              if (matchedDistrict.isEmpty) {
                matchedDistrict = districts.firstWhere(
                  (dist) => geoNames.contains(normalizeString(dist['IlceAdi'] ?? '')),
                  orElse: () => <String, dynamic>{},
                );
              }

              // 4. Default fallback to districts[0]
              if (matchedDistrict.isEmpty) {
                matchedDistrict = districts.isNotEmpty ? districts[0] : <String, dynamic>{};
              }

              if (matchedDistrict.isNotEmpty) {
                final String districtId = matchedDistrict['IlceID'].toString();
                final String districtName = matchedDistrict['IlceAdi'];

                // Prefetch times to display in preview screen
                final times = await _repository.getPrayerTimes(districtId);

                setState(() {
                  _location = {
                    'cityName': cityName,
                    'cityId': cityId,
                    'districtName': districtName,
                    'districtId': districtId,
                  };
                  _prayerTimes = times;
                  _originalPrayerTimes = List<Map<String, dynamic>>.from(times.map((item) => Map<String, dynamic>.from(item)));
                  _loadingLocation = false;
                });

                _showSnackBar("Konum başarıyla belirlendi: ${_formatTurkishCity(cityName)} / ${_formatTurkishDistrict(districtName)}", success: true);
                _goToNextPage();
                return;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Auto location error: $e");
    }

    // Fallback if location not detected
    setState(() {
      _loadingLocation = false;
    });
    _goToNextPage();
  }

  // Requests notification permission
  Future<void> _requestNotificationPermission() async {
    await _notificationService.init();
    _showSnackBar("Bildirim izni başarıyla talep edildi.", success: true);
    _goToNextPage();
  }

  // Runs the beautiful 2-phase loading screen, then completed to Prayer Times Preview!
  Future<void> _runSetupAndComplete() async {
    if (_location['districtId'] == null) {
      _showSnackBar("Lütfen devam etmeden önce konumunuzu seçin.");
      _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    // Slide to Page 7 (the Setup screen)
    _pageController.animateToPage(7, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

    // 1st loading phase (1.5 seconds)
    setState(() {
      _setupStatusText = "Namaz vakitleri hesaplanıyor ...";
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    // 2nd loading phase (1.5 seconds)
    if (mounted) {
      setState(() {
        _setupStatusText = "Neredeyse hazır ...";
      });
    }

    // Complete saving preferences in background
    try {
      final String cityName = _location['cityName']!;
      final String cityId = _location['cityId']!;
      final String districtName = _location['districtName']!;
      final String districtId = _location['districtId']!;

      final times = await _repository.getPrayerTimes(
        districtId,
        forceRefresh: true,
      );

      await _repository.saveLocation(cityName, cityId, districtName, districtId);

      // Save onboarding preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', 'Müslüman');
      await prefs.setString('user_gender', 'erkek');
      await prefs.setString('calculation_method', _selectedMethod);
      await prefs.setString('notification_reminder', _selectedReminderTime);

      await _notificationService.schedulePrayerAlarms(times);
    } catch (e) {
      debugPrint("Setup background save error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    // Slide to final Prayer Times Preview Screen (Page 8)
    if (mounted) {
      _pageController.animateToPage(8, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  // Final onboarding exit logic (triggered by Premium Screen close/purchase)
  Future<void> _handleComplete() async {
    setState(() {
      _saving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

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
    } catch (e) {
      debugPrint("Exit save error: $e");
      setState(() => _saving = false);
    }
  }

  // Opens manual location selector modal
  void _showManualLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1B31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Konum Seç",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Listeden şehir ve ilçenizi seçin",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // City Dropdown
                  if (_loadingCities)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF90B49C)))
                  else
                    DropdownButtonFormField<Map<String, dynamic>>(
                      dropdownColor: const Color(0xFF0F1B31),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Şehir Seçin",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.location_city, color: Color(0xFF90B49C)),
                      ),
                      value: _selectedCity,
                      items: _cities.map((city) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: city,
                          child: Text(city['SehirAdi'] ?? '', style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        setModalState(() {
                          _selectedCity = val;
                          _selectedDistrict = null;
                        });
                        if (val != null) {
                          setModalState(() => _loadingDistricts = true);
                          final districts = await _repository.getDistricts(val['SehirID'].toString());
                          setModalState(() {
                            _districts = districts;
                            _loadingDistricts = false;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  if (_selectedCity != null) ...[
                    if (_loadingDistricts)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF90B49C)))
                    else
                      DropdownButtonFormField<Map<String, dynamic>>(
                        dropdownColor: const Color(0xFF0F1B31),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "İlçe Seçin",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                        ),
                          prefixIcon: const Icon(Icons.map, color: Color(0xFF90B49C)),
                        ),
                        value: _selectedDistrict,
                        items: _districts.map((dist) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: dist,
                            child: Text(dist['IlceAdi'] ?? '', style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            _selectedDistrict = val;
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF90B49C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: (_selectedCity == null || _selectedDistrict == null)
                          ? null
                          : () async {
                              final String cityName = _selectedCity!['SehirAdi'];
                              final String cityId = _selectedCity!['SehirID'].toString();
                              final String districtName = _selectedDistrict!['IlceAdi'];
                              final String districtId = _selectedDistrict!['IlceID'].toString();

                              setState(() => _loadingLocation = true);
                              final times = await _repository.getPrayerTimes(districtId);

                              setState(() {
                                _location = {
                                  'cityName': cityName,
                                  'cityId': cityId,
                                  'districtName': districtName,
                                  'districtId': districtId,
                                };
                                _prayerTimes = times;
                                _originalPrayerTimes = List<Map<String, dynamic>>.from(times.map((item) => Map<String, dynamic>.from(item)));
                                _loadingLocation = false;
                              });
                              Navigator.pop(context);
                              _showSnackBar("Konum başarıyla seçildi.", success: true);
                            },
                      child: const Text(
                        "Konumu Onayla",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1B31),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide dots and buttons when in loading/setup/checkout screens
    final bool isSetupPage = _activePage == 7;
    final bool isPremiumPage = _activePage == 9;
    final bool hideFooter = isSetupPage || isPremiumPage;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B31),
      body: Stack(
        children: [
          // Background subtle stars (Permanent with dynamic opacity to avoid Stack reconciliation disposal)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isPremiumPage ? 0.0 : 0.12,
              duration: const Duration(milliseconds: 300),
              child: CustomPaint(
                painter: TwinklingStarsPainter(),
              ),
            ),
          ),

          // Main PageView Contents (With ValueKey so its state is permanently preserved across dynamic Stack structural updates)
          PageView(
            key: const ValueKey('onboarding_page_view'),
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _activePage = index;
              });
            },
            physics: const NeverScrollableScrollPhysics(), // Control through buttons
            children: [
              _buildPageWelcome(),
              _buildPagePermissionRequest(),
              _buildPageLocationDisplay(),
              _buildPageCalculationMethod(),
              _buildPageJoinUs(),
              _buildPageNotificationRequest(),
              _buildPageNotificationCustomize(),
              _buildPageSetupLoading(), // Immersive setup/loading screen
              _buildPagePrayerTimesPreview(), // Shows after setup loading screen!
              PremiumScreen(isFromOnboarding: true, onComplete: _handleComplete), // Stunning Botanical Premium Screen!
            ],
          ),

          // Top Header Bar (Permanent with dynamic opacity and IgnorePointer)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: isPremiumPage ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: isPremiumPage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display time/status
                    const Text(
                      "16:04",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    // Minimalist pill matching screenshot
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.mosque, color: Color(0xFF8AA996), size: 14),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Icon(Icons.battery_full, color: Color(0xFF27A770), size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pagination Dots indicator (Permanent with dynamic opacity and IgnorePointer)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: hideFooter ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: hideFooter,
                child: _buildDotsIndicator(8, _getDotIndex(_activePage)),
              ),
            ),
          ),

          // Main Lower Green Button (Permanent with dynamic opacity and IgnorePointer)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: hideFooter ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: hideFooter,
                child: _buildPageActionButton(),
              ),
            ),
          ),

          // ----------------------------------------------------
          // STARS RATING DIALOG OVERLAY (Screen 6 & 7)
          // ----------------------------------------------------
          if (_showRatingDialog)
            Container(
              color: Colors.black.withOpacity(0.75),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142442),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1B31),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(Icons.mosque, color: Color(0xFF90B49C), size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        "Namaz Vakitleri hoşunuza gidiyor mu?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "App Store'da puanlamak için yıldızlara dokunun.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Interactive Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final bool isLit = index < _selectedStars;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStars = index + 1;
                              });
                              _showSnackBar("Değerlendirmeniz için çok teşekkür ederiz! Mağazaya yönlendiriliyorsunuz...", success: true);
                              // Quick dynamic rating feedback
                              Future.delayed(const Duration(milliseconds: 500), () {
                                setState(() {
                                  _showRatingDialog = false;
                                });
                                _launchStore(); // Launch App Store / Play Store!
                                _goToNextPage(); // Go to next onboarding step
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                isLit ? Icons.star : Icons.star_border,
                                color: isLit ? const Color(0xFFE5A93B) : const Color(0xFF327CF6),
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // "Şimdi Değil" Flat Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showRatingDialog = false;
                          });
                          _goToNextPage(); // Go to step 6 (Notification)
                        },
                        child: const Text(
                          "Şimdi Değil",
                          style: TextStyle(
                            color: Color(0xFF327CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Location detecting dialog overlay
          if (_loadingLocation || _saving)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1B31),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF90B49C)),
                      const SizedBox(height: 16),
                      Text(
                        _saving ? "Ayarlar Kaydediliyor..." : "Konum Yükleniyor...",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loadingLocation = false;
                            _saving = false;
                          });
                        },
                        child: const Text(
                          "İptal Et",
                          style: TextStyle(color: Color(0xFF90B49C), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dots indicator
  Widget _buildDotsIndicator(int count, int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == activeIndex ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? const Color(0xFF90B49C)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // Page Action Button Logic
  Widget _buildPageActionButton() {
    return Row(
      children: [
        if (_activePage > 0) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
            onPressed: _goToPrevPage,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90B49C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (_activePage == 1) {
                  _requestLocationAndDetect();
                } else if (_activePage == 2) {
                  // Direct to method selection screen
                  if (_location['districtId'] == null) {
                    _showManualLocationModal();
                  } else {
                    _goToNextPage();
                  }
                } else if (_activePage == 4) {
                  // Star Rating trigger before transitioning from Join Us to Notification Request
                  setState(() {
                    _showRatingDialog = true;
                  });
                } else if (_activePage == 5) {
                  _requestNotificationPermission();
                } else if (_activePage == 6) {
                  _runSetupAndComplete(); // Starts loading animation and transitions
                } else {
                  _goToNextPage();
                }
              },
              child: const Text(
                "Devam",
                style: TextStyle(
                  color: Color(0xFF0F1B31),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // INDIVIDUAL PAGES CONTENT
  // ----------------------------------------------------

  // SCREEN 1: Welcome (Hoş Geldiniz)
  Widget _buildPageWelcome() {
    return _buildPageLayout(
      painter: IntroIllustrationPainter(),
      category: "HOŞ GELDİNİZ",
      title: "Namazınıza\nodaklanma zamanı",
      desc: "Sizi namazlarınızı hatırlatarak ve rehberlik ederek destekliyoruz. Deneyiminizi kişiselleştirelim.",
      fullWidthPainter: true,
    );
  }

  // SCREEN 2: Location Request (Doğru konum)
  Widget _buildPagePermissionRequest() {
    return _buildPageLayout(
      painter: LocationPermissionIllustrationPainter(),
      category: "NAMAZ VAKİTLERİ",
      title: "Doğru konum",
      desc: "Namaz vakitlerini doğru hesaplayabilmemiz için lütfen konuma erişime izin verin. Alternatif olarak konumunuzu manuel olarak girebilir ve ayarlardan istediğiniz zaman değiştirebilirsiniz.",
      fullWidthPainter: true,
    );
  }

  // SCREEN 3: Detected Location (Konumunuz)
  Widget _buildPageLocationDisplay() {
    final String city = _location['cityName'] ?? '';
    final String district = _location['districtName'] ?? '';
    final bool hasLocation = _location['districtId'] != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Dynamic street map illustration
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF142442),
                    child: CustomPaint(
                      painter: DetectedLocationIllustrationPainter(),
                    ),
                  ),
                ),
                // Location badge card floating
                Positioned(
                  bottom: 16,
                  child: GestureDetector(
                    onTap: _showManualLocationModal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: hasLocation ? Colors.white : const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(24),
                        border: hasLocation
                            ? Border.all(color: Colors.white)
                            : Border.all(color: const Color(0xFFF3C06F).withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasLocation ? Icons.my_location : Icons.location_off_outlined,
                            color: hasLocation ? const Color(0xFF90B49C) : const Color(0xFFE5A93B),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasLocation
                                ? "${_formatTurkishCity(city)} / ${_formatTurkishDistrict(district)}"
                                : "Konum Seçilmedi (Seçmek için Dokunun)",
                            style: TextStyle(
                              color: hasLocation ? const Color(0xFF0F1B31) : const Color(0xFF8C6000),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Texts
          Expanded(
            flex: 4,
            child: Column(
              children: [
                const Text(
                  "NAMAZ VAKİTLERİ",
                  style: TextStyle(
                    color: Color(0xFF8AA996),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Konumunuz",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Namaz vakitlerini doğru hesaplamak için konumunuzu kullanıyoruz. Ayrıca uygulama ayarlarından konumunuzu manuel olarak değiştirebilirsiniz.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 3.5: Prayer Times Preview (Namaz Vakitleri Önizlemesi)
  Widget _buildPagePrayerTimesPreview() {
    final String city = _formatTurkishCity(_location['cityName'] ?? '');
    String district = _formatTurkishDistrict(_location['districtName'] ?? '');
    
    if ((_location['cityName'] ?? '').trim().toLowerCase() == (_location['districtName'] ?? '').trim().toLowerCase()) {
      district = 'Merkez';
    }

    final hasLocation = _location['districtId'] != null;

    // Use fetched times if loaded, or fallback to mock offline Istanbul times
    final Map<String, dynamic> today = (_prayerTimes.isNotEmpty) ? _prayerTimes.first : {
      'Imsak': '03:33',
      'Gunes': '05:27',
      'Ogle': '13:05',
      'Ikindi': '16:54',
      'Aksam': '20:34',
      'Yatsi': '22:20',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Subtitle and Title
          const Text(
            "Namaz vakitleri için",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            hasLocation ? "$city / $district" : "Konum Seçilmedi",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Diyanet İşleri Başkanlığı",
            style: TextStyle(color: Color(0xFF90B49C), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Text(
            "İmsak: 18° - Yatsı: 17°",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Times Table
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF142442),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPreviewTimeRow("İmsak", today['Imsak'] ?? '03:33', false),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPreviewTimeRow("Güneş", today['Gunes'] ?? '05:27', false),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPreviewTimeRow("Öğle", today['Ogle'] ?? '13:05', false),
                  const Divider(color: Colors.white10, height: 1),
                  // Highlight next prayer (İkindi) in green just like the screenshot!
                  _buildPreviewTimeRow("İkindi", today['Ikindi'] ?? '16:54', true),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPreviewTimeRow("Akşam", today['Aksam'] ?? '20:34', false),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPreviewTimeRow("Yatsı", today['Yatsi'] ?? '22:20', false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Her namazın başında hatırlatma alacaksınız. Bunu ayarlardan istediğiniz zaman değiştirebilirsiniz.",
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 140), // Spacer for dot indicators
        ],
      ),
    );
  }

  Widget _buildPreviewTimeRow(String label, String value, bool isHighlighted) {
    final String mode = _previewNotifications[label] ?? 'sesli';
    
    IconData iconData = Icons.notifications_active_outlined;
    Color iconColor = isHighlighted ? const Color(0xFF90B49C) : Colors.white54;
    
    if (mode == 'sessiz') {
      iconData = Icons.notifications_paused_outlined;
      iconColor = const Color(0xFFE5A93B); // Golden yellow for silent
    } else if (mode == 'kapali') {
      iconData = Icons.notifications_off_outlined;
      iconColor = Colors.white24; // Faded grey for disabled
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF90B49C) : Colors.white,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              Text(
                label == "İkindi" && isHighlighted ? "59 dk içinde" : value,
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFF90B49C) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (mode == 'sesli') {
                      _previewNotifications[label] = 'sessiz';
                      _showSnackBar("$label vakti bildirimi sessiz olarak ayarlandı.", success: true);
                    } else if (mode == 'sessiz') {
                      _previewNotifications[label] = 'kapali';
                      _showSnackBar("$label vakti bildirimi kapatıldı.");
                    } else {
                      _previewNotifications[label] = 'sesli';
                      _showSnackBar("$label vakti bildirimi sesli olarak ayarlandı.", success: true);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SCREEN 4: Calculation Method (Bir yöntem seçin)
  Widget _buildPageCalculationMethod() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Astrolabe/Compass custom painted
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF142442),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: CalculationMethodIllustrationPainter(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            "NAMAZ VAKTİ HESAPLAMASI",
            style: TextStyle(
              color: Color(0xFF8AA996),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Bir yöntem seçin",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable list of options
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ÖNERİLEN",
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  // Recommended Method: Diyanet
                  _buildMethodCard(
                    id: 'diyanet',
                    title: "Diyanet İşleri Başkanlığı",
                    subtitle: "İmsak: 18° - Yatsı: 17°",
                    isRecommended: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "DİĞER",
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildMethodCard(
                    id: 'bae',
                    title: "BAE İslami İşler ve Vakıflar Genel Kurumu",
                    subtitle: "İmsak: 19.5° - Yatsı: 90 dk",
                    isRecommended: false,
                  ),
                  const SizedBox(height: 8),
                  _buildMethodCard(
                    id: 'bask',
                    title: "Bask Ülkesi",
                    subtitle: "İmsak: 18° - Yatsı: 18°",
                    isRecommended: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 5: Join Us (Bize Katıl)
  Widget _buildPageJoinUs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Dynamic painted map + stars character rating
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF142442),
                    child: CustomPaint(
                      painter: JoinUsIllustrationPainter(),
                    ),
                  ),
                ),
                // Rating Overlay
                Positioned(
                  left: 24,
                  bottom: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "4.9",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 16),
                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 16),
                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 16),
                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 16),
                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "App Store",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Texts
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const Text(
                  "BİZE KATIL",
                  style: TextStyle(
                    color: Color(0xFF8AA996),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Dünya çapında birçok\nkişi tarafından kullanılıyor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Doğru namaz vakitlerine, kıble yönüne ve günlük hatırlatmalara güvenen; nerede olurlarsa olsunlar inançlarıyla bağlı kalmak isteyen büyüyen bir Müslüman topluluğuna katılın.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 6: Notification Permission (Bildirimlere izin ver)
  Widget _buildPageNotificationRequest() {
    return _buildPageLayout(
      painter: ReminderIllustrationPainter(),
      category: "HATIRLATICI",
      title: "Bildirimlere izin ver",
      desc: "Size zamanında hatırlatırız, böylece namazınızı asla kaçırmazsınız.",
      fullWidthPainter: true,
    );
  }

  // SCREEN 7: Customize Notifications (Bildirimleri özelleştir)
  Widget _buildPageNotificationCustomize() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 70),
          // Clock Image - set fixed height to prevent overlaps across screen sizes
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF142442),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: ReminderIllustrationPainter(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Category and texts
          const Text(
            "HATIRLATICI",
            style: TextStyle(
              color: Color(0xFF8AA996),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Bildirimleri özelleştir",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Ne zaman hatırlatalım?",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Custom selection buttons
          Row(
            children: [
              Expanded(
                child: _buildReminderTimeButton(
                  id: '30',
                  label: "30 dk.\nönce",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReminderTimeButton(
                  id: '15',
                  label: "15 dk.\nönce",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReminderTimeButton(
                  id: 'vaktinde',
                  label: "Vaktinde",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flat link button below
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedReminderTime = 'kapali';
              });
              _runSetupAndComplete();
            },
            child: Text(
              "Hatırlatmaları kapalı tut",
              style: TextStyle(
                color: _selectedReminderTime == 'kapali' ? const Color(0xFF90B49C) : Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 140), // Reserved space for bottom action buttons to prevent overlapping
        ],
      ),
    );
  }

  // Maps active page index to correct dot indicator index
  int _getDotIndex(int page) {
    if (page < 7) return page; // 0-6 maps exactly to dots 0-6
    if (page == 8) return 7;   // Prayer preview (page 8) is the 8th dot (index 7)
    return 0;
  }

  // SCREEN 8: Final Immersive Setup/Loading screen
  Widget _buildPageSetupLoading() {
    return Column(
      children: [
        const SizedBox(height: 80),
        // Setup Gears custom painter animated
        Expanded(
          flex: 5,
          child: AnimatedBuilder(
            animation: _gearAnimationController,
            builder: (context, child) {
              final scale = 1.0 + 0.03 * math.sin(_gearAnimationController.value * 2 * math.pi);
              return Transform.scale(
                scale: scale,
                child: CustomPaint(
                  painter: SetupIllustrationPainter(
                    rotationAngle: _gearAnimationController.value * 2 * math.pi,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Animated transition status text at bottom
        Expanded(
          flex: 3,
          child: Center(
            child: Text(
              _setupStatusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Customize reminder time choice card button
  Widget _buildReminderTimeButton({
    required String id,
    required String label,
  }) {
    final bool isSelected = _selectedReminderTime == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReminderTime = id;
        });
      },
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E533F) : const Color(0xFF182845),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF90B49C) : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Base layout template for illustration screens
  Widget _buildPageLayout({
    String? imagePath,
    CustomPainter? painter,
    required String category,
    required String title,
    required String desc,
    bool fullWidthPainter = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fullWidthPainter ? 0.0 : 24.0),
      child: Column(
        children: [
          if (!fullWidthPainter) const SizedBox(height: 70),
          // Illustration Box
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF142442),
                borderRadius: fullWidthPainter ? BorderRadius.zero : BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: fullWidthPainter ? BorderRadius.zero : BorderRadius.circular(20),
                child: painter != null
                    ? CustomPaint(
                        painter: painter,
                        child: const SizedBox.expand(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Texts Box with safe scroll and bottom spacing for notches/safearea/buttons (Feedback 5)
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: fullWidthPainter ? 24.0 : 0.0),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF8AA996),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 160), // Reservate space at bottom to prevent dynamic notches/safespace button overlays!
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method Selection Item Card
  Widget _buildMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required bool isRecommended,
  }) {
    final bool isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
        
        _showSnackBar("Hesaplama yöntemi $title olarak seçildi.", success: true);
        
        // Dynamic time adjustment based on method
        if (id == 'bae') {
          _varyPrayerTimes(offsetMinutes: -3);
        } else if (id == 'bask') {
          _varyPrayerTimes(offsetMinutes: 2);
        } else {
          _varyPrayerTimes(offsetMinutes: 0); // Reset to Diyanet
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isRecommended ? const Color(0xFF2E533F) : const Color(0xFF1E2E4E))
              : const Color(0xFF182845),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF90B49C)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? Colors.white60 : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF90B49C), size: 20)
            else
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// CUSTOM PAINTERS FOR ILLUSTRATIONS (Stunning Vectors)
// ----------------------------------------------------

// Painter for Background Twinkling Stars
class TwinklingStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 1: Welcome Illustration (Two Muslim characters praying - Professional Flat Vector)
class IntroIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // ─── SKY GRADIENT (deep navy, matching reference) ───
    final skyGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0C1929), Color(0xFF152238), Color(0xFF0E1A2E)],
      stops: [0.0, 0.5, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = skyGradient);

    // ─── DECORATIVE STARS ───
    final starPaint = Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.3);
    final starPositions = [
      [0.12, 0.08, 1.5], [0.35, 0.05, 1.2], [0.08, 0.22, 1.0],
      [0.92, 0.08, 1.3], [0.55, 0.12, 0.9], [0.45, 0.03, 1.1],
      [0.82, 0.30, 1.0], [0.18, 0.15, 0.8], [0.68, 0.06, 1.4],
    ];
    for (final star in starPositions) {
      canvas.drawCircle(
        Offset(w * star[0], h * star[1]),
        star[2],
        starPaint,
      );
    }

    final double yGround = h * 0.82;

    // ─── SUN / MOON (warm orange with soft glow) ───
    final Offset sunCenter = Offset(w * 0.78, h * 0.18);
    final double sunRadius = h * 0.085;

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFD824D).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(sunCenter, sunRadius * 2.0, glowPaint);

    // Mid glow
    final midGlowPaint = Paint()
      ..color = const Color(0xFFFD824D).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(sunCenter, sunRadius * 1.4, midGlowPaint);

    // Sun disc
    final sunPaint = Paint()
      ..color = const Color(0xFFEF7B45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Lighter highlight on sun
    final sunHighlight = Paint()
      ..color = const Color(0xFFFFA96B).withOpacity(0.5);
    canvas.drawCircle(Offset(sunCenter.dx - 3, sunCenter.dy - 3), sunRadius * 0.6, sunHighlight);

    // ─── CLOUDS (stylized flat green clouds, matching reference) ───
    final cloudColor = const Color(0xFF3B5E47);
    final cloudLightColor = const Color(0xFF4A7358);

    // Cloud group 1 (overlapping sun from below-left)
    _drawFlatCloud(canvas, Offset(w * 0.62, h * 0.24), w * 0.32, h * 0.055, cloudColor);
    _drawFlatCloud(canvas, Offset(w * 0.65, h * 0.235), w * 0.22, h * 0.04, cloudLightColor.withOpacity(0.7));

    // Cloud group 2 (overlapping sun from upper-right)
    _drawFlatCloud(canvas, Offset(w * 0.82, h * 0.14), w * 0.24, h * 0.045, cloudColor);
    _drawFlatCloud(canvas, Offset(w * 0.85, h * 0.135), w * 0.16, h * 0.032, cloudLightColor.withOpacity(0.6));

    // ─── CRESCENT SYMBOL on cloud (Islamic detail) ───
    final crescentPaint = Paint()..color = const Color(0xFF8BB89A).withOpacity(0.9);
    final double cX = w * 0.74;
    final double cY = h * 0.14;
    canvas.drawCircle(Offset(cX, cY), 6.0, crescentPaint);
    canvas.drawCircle(Offset(cX + 3, cY - 1), 5.0, Paint()..color = cloudColor); // cut crescent
    // Star next to crescent
    canvas.drawCircle(Offset(cX + 10, cY - 2), 1.8, crescentPaint);

    // ─── MOUNTAINS (4 layers, green-tinted like reference) ───

    // Layer 1: Far background (darkest, tallest)
    final m1Fill = Paint()..color = const Color(0xFF1A3042).withOpacity(0.5);
    final pathM1 = Path()
      ..moveTo(0, yGround)
      ..lineTo(0, h * 0.48)
      ..quadraticBezierTo(w * 0.08, h * 0.30, w * 0.22, h * 0.36)
      ..quadraticBezierTo(w * 0.35, h * 0.42, w * 0.45, h * 0.52)
      ..quadraticBezierTo(w * 0.55, h * 0.60, w * 0.65, yGround)
      ..close();
    canvas.drawPath(pathM1, m1Fill);

    // Ridge line 1
    final ridgeStroke = Paint()
      ..color = const Color(0xFF4A7A5E).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final ridgeM1 = Path()
      ..moveTo(0, h * 0.48)
      ..quadraticBezierTo(w * 0.08, h * 0.30, w * 0.22, h * 0.36)
      ..quadraticBezierTo(w * 0.35, h * 0.42, w * 0.45, h * 0.52)
      ..quadraticBezierTo(w * 0.55, h * 0.60, w * 0.65, yGround);
    canvas.drawPath(ridgeM1, ridgeStroke);

    // Layer 2: Mid-left mountain (tallest peak)
    final m2Fill = Paint()..color = const Color(0xFF1D3A4A).withOpacity(0.45);
    final pathM2 = Path()
      ..moveTo(w * 0.05, yGround)
      ..quadraticBezierTo(w * 0.25, h * 0.22, w * 0.40, h * 0.28)
      ..quadraticBezierTo(w * 0.55, h * 0.35, w * 0.70, h * 0.55)
      ..lineTo(w * 0.80, yGround)
      ..close();
    canvas.drawPath(pathM2, m2Fill);

    final ridgeM2 = Path()
      ..moveTo(w * 0.05, yGround)
      ..quadraticBezierTo(w * 0.25, h * 0.22, w * 0.40, h * 0.28)
      ..quadraticBezierTo(w * 0.55, h * 0.35, w * 0.70, h * 0.55)
      ..lineTo(w * 0.80, yGround);
    canvas.drawPath(ridgeM2, ridgeStroke..color = const Color(0xFF5B8D6E).withOpacity(0.4));

    // Layer 3: Right side mountain
    final m3Fill = Paint()..color = const Color(0xFF223D4D).withOpacity(0.4);
    final pathM3 = Path()
      ..moveTo(w * 0.50, yGround)
      ..quadraticBezierTo(w * 0.65, h * 0.38, w * 0.80, h * 0.32)
      ..quadraticBezierTo(w * 0.92, h * 0.42, w, h * 0.58)
      ..lineTo(w, yGround)
      ..close();
    canvas.drawPath(pathM3, m3Fill);

    final ridgeM3 = Path()
      ..moveTo(w * 0.50, yGround)
      ..quadraticBezierTo(w * 0.65, h * 0.38, w * 0.80, h * 0.32)
      ..quadraticBezierTo(w * 0.92, h * 0.42, w, h * 0.58);
    canvas.drawPath(ridgeM3, Paint()
      ..color = const Color(0xFF5B8D6E).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Layer 4: Foreground hills (closest, darker green)
    final m4Fill = Paint()..color = const Color(0xFF162C3D).withOpacity(0.6);
    final pathM4 = Path()
      ..moveTo(0, yGround)
      ..quadraticBezierTo(w * 0.10, h * 0.62, w * 0.25, h * 0.65)
      ..quadraticBezierTo(w * 0.40, h * 0.70, w * 0.50, yGround)
      ..close();
    canvas.drawPath(pathM4, m4Fill);

    final pathM4b = Path()
      ..moveTo(w * 0.60, yGround)
      ..quadraticBezierTo(w * 0.75, h * 0.68, w * 0.88, h * 0.70)
      ..quadraticBezierTo(w * 0.95, h * 0.74, w, h * 0.76)
      ..lineTo(w, yGround)
      ..close();
    canvas.drawPath(pathM4b, m4Fill);

    // ─── GROUND ───
    final groundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF0E1D30), const Color(0xFF0A1522)],
    ).createShader(Rect.fromLTRB(0, yGround, w, h));
    canvas.drawRect(
      Rect.fromLTRB(0, yGround, w, h),
      Paint()..shader = groundGradient,
    );

    // Subtle ground line
    canvas.drawLine(
      Offset(0, yGround),
      Offset(w, yGround),
      Paint()
        ..color = const Color(0xFF2A4A3A).withOpacity(0.3)
        ..strokeWidth = 1.0,
    );

    // Grass tufts along ground
    final grassPaint = Paint()
      ..color = const Color(0xFF2E4D3B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (double gx = 0; gx < w; gx += w * 0.04) {
      final gy = yGround;
      final grassHeight = 3.0 + (gx.hashCode % 5);
      canvas.drawLine(Offset(gx, gy), Offset(gx - 2, gy - grassHeight), grassPaint);
      canvas.drawLine(Offset(gx + 3, gy), Offset(gx + 5, gy - grassHeight * 0.8), grassPaint);
    }

    // ─── CHARACTER PALETTE ───
    final robePaint = Paint()..color = const Color(0xFF3D6B50)..style = PaintingStyle.fill;
    final robeDarkPaint = Paint()..color = const Color(0xFF2E5740)..style = PaintingStyle.fill;
    final skinPaint = Paint()..color = const Color(0xFFF0C8A0)..style = PaintingStyle.fill;
    final pantsPaint = Paint()..color = const Color(0xFF1A1A2E)..style = PaintingStyle.fill;
    final capPaint = Paint()..color = const Color(0xFF5A8D6A)..style = PaintingStyle.fill;
    final capDarkPaint = Paint()..color = const Color(0xFF4A7A5A)..style = PaintingStyle.fill;

    // Scale factor based on canvas size for responsive characters
    final double sf = h / 400.0;

    // ────────────────────────────────────────────
    // CHARACTER 1: SITTING (Oturarak namaz - Sol)
    // ────────────────────────────────────────────
    final double c1x = w * 0.30;
    final double c1y = yGround;

    // Shadow under character
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c1x, c1y + 2), width: 70 * sf, height: 8 * sf),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Feet (showing behind)
    final foot1 = Path()
      ..moveTo(c1x - 30 * sf, c1y)
      ..quadraticBezierTo(c1x - 35 * sf, c1y - 3 * sf, c1x - 33 * sf, c1y - 10 * sf)
      ..quadraticBezierTo(c1x - 26 * sf, c1y - 12 * sf, c1x - 24 * sf, c1y - 5 * sf)
      ..close();
    canvas.drawPath(foot1, skinPaint);

    // Legs / Pants (folded sitting)
    final legs1 = Path()
      ..moveTo(c1x - 26 * sf, c1y)
      ..lineTo(c1x - 30 * sf, c1y - 10 * sf)
      ..quadraticBezierTo(c1x - 33 * sf, c1y - 22 * sf, c1x - 24 * sf, c1y - 24 * sf)
      ..quadraticBezierTo(c1x - 8 * sf, c1y - 24 * sf, c1x + 18 * sf, c1y - 18 * sf)
      ..quadraticBezierTo(c1x + 30 * sf, c1y - 14 * sf, c1x + 32 * sf, c1y - 6 * sf)
      ..quadraticBezierTo(c1x + 32 * sf, c1y + 1, c1x + 24 * sf, c1y)
      ..close();
    canvas.drawPath(legs1, pantsPaint);

    // Robe / Torso (sitting upright)
    final robe1 = Path()
      ..moveTo(c1x - 24 * sf, c1y - 16 * sf)
      ..quadraticBezierTo(c1x - 28 * sf, c1y - 55 * sf, c1x - 16 * sf, c1y - 78 * sf)
      ..lineTo(c1x - 4 * sf, c1y - 78 * sf)
      ..quadraticBezierTo(c1x + 8 * sf, c1y - 62 * sf, c1x + 5 * sf, c1y - 52 * sf)
      ..lineTo(c1x + 22 * sf, c1y - 24 * sf)
      ..quadraticBezierTo(c1x + 26 * sf, c1y - 18 * sf, c1x + 18 * sf, c1y - 18 * sf)
      ..lineTo(c1x, c1y - 42 * sf)
      ..lineTo(c1x - 4 * sf, c1y - 16 * sf)
      ..close();
    canvas.drawPath(robe1, robePaint);

    // Robe fold shadow
    final robeShadow1 = Path()
      ..moveTo(c1x - 4 * sf, c1y - 16 * sf)
      ..lineTo(c1x, c1y - 42 * sf)
      ..lineTo(c1x + 5 * sf, c1y - 52 * sf)
      ..quadraticBezierTo(c1x + 2 * sf, c1y - 38 * sf, c1x + 8 * sf, c1y - 20 * sf)
      ..close();
    canvas.drawPath(robeShadow1, Paint()..color = const Color(0xFF2E5740).withOpacity(0.3));

    // Neck
    final neck1 = Path()
      ..moveTo(c1x - 14 * sf, c1y - 78 * sf)
      ..lineTo(c1x - 10 * sf, c1y - 86 * sf)
      ..lineTo(c1x - 5 * sf, c1y - 86 * sf)
      ..lineTo(c1x - 4 * sf, c1y - 78 * sf)
      ..close();
    canvas.drawPath(neck1, skinPaint);

    // Head
    final headC1 = Offset(c1x - 8 * sf, c1y - 96 * sf);
    canvas.drawCircle(headC1, 12.0 * sf, skinPaint);

    // Ear
    canvas.drawCircle(Offset(headC1.dx + 11 * sf, headC1.dy + 2 * sf), 3.0 * sf, skinPaint);

    // Cap (prayer cap / takke)
    final cap1 = Path()
      ..moveTo(c1x - 20 * sf, c1y - 100 * sf)
      ..quadraticBezierTo(c1x - 8 * sf, c1y - 116 * sf, c1x + 4 * sf, c1y - 100 * sf)
      ..quadraticBezierTo(c1x - 8 * sf, c1y - 96 * sf, c1x - 20 * sf, c1y - 100 * sf)
      ..close();
    canvas.drawPath(cap1, capPaint);

    // Cap band detail
    canvas.drawLine(
      Offset(c1x - 18 * sf, c1y - 100 * sf),
      Offset(c1x + 2 * sf, c1y - 100 * sf),
      Paint()..color = capDarkPaint.color..strokeWidth = 1.5 * sf,
    );

    // Hand resting on knee
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c1x + 16 * sf, c1y - 22 * sf, 9 * sf, 6 * sf),
        Radius.circular(3.0 * sf),
      ),
      skinPaint,
    );

    // ────────────────────────────────────────────
    // CHARACTER 2: IN SUJUD / SECDE (Sağ)
    // ────────────────────────────────────────────
    final double c2x = w * 0.66;
    final double c2y = yGround;

    // Shadow under character
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c2x + 5 * sf, c2y + 2), width: 80 * sf, height: 8 * sf),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Feet (heels up at back)
    final foot2a = Path()
      ..moveTo(c2x - 45 * sf, c2y)
      ..quadraticBezierTo(c2x - 50 * sf, c2y - 3 * sf, c2x - 48 * sf, c2y - 10 * sf)
      ..quadraticBezierTo(c2x - 42 * sf, c2y - 12 * sf, c2x - 40 * sf, c2y - 5 * sf)
      ..close();
    canvas.drawPath(foot2a, skinPaint);

    final foot2b = Path()
      ..moveTo(c2x - 38 * sf, c2y)
      ..quadraticBezierTo(c2x - 43 * sf, c2y - 3 * sf, c2x - 41 * sf, c2y - 9 * sf)
      ..quadraticBezierTo(c2x - 36 * sf, c2y - 11 * sf, c2x - 34 * sf, c2y - 4 * sf)
      ..close();
    canvas.drawPath(foot2b, skinPaint);

    // Legs / Pants (bent in sujud)
    final legs2 = Path()
      ..moveTo(c2x - 42 * sf, c2y)
      ..quadraticBezierTo(c2x - 50 * sf, c2y - 18 * sf, c2x - 36 * sf, c2y - 28 * sf)
      ..quadraticBezierTo(c2x - 22 * sf, c2y - 32 * sf, c2x - 10 * sf, c2y - 20 * sf)
      ..lineTo(c2x - 16 * sf, c2y)
      ..close();
    canvas.drawPath(legs2, pantsPaint);

    // Robe (curved back in prostration)
    final robe2 = Path()
      ..moveTo(c2x - 22 * sf, c2y - 18 * sf)
      ..quadraticBezierTo(c2x - 28 * sf, c2y - 34 * sf, c2x - 14 * sf, c2y - 42 * sf)
      ..quadraticBezierTo(c2x + 8 * sf, c2y - 46 * sf, c2x + 25 * sf, c2y - 24 * sf)
      ..lineTo(c2x + 40 * sf, c2y - 8 * sf) // sleeve
      ..quadraticBezierTo(c2x + 44 * sf, c2y - 3 * sf, c2x + 38 * sf, c2y)
      ..lineTo(c2x + 28 * sf, c2y - 16 * sf) // sleeve underside
      ..quadraticBezierTo(c2x + 14 * sf, c2y - 18 * sf, c2x - 10 * sf, c2y - 16 * sf)
      ..close();
    canvas.drawPath(robe2, robePaint);

    // Robe back highlight
    final robeHighlight2 = Path()
      ..moveTo(c2x - 14 * sf, c2y - 42 * sf)
      ..quadraticBezierTo(c2x, c2y - 44 * sf, c2x + 10 * sf, c2y - 38 * sf)
      ..quadraticBezierTo(c2x + 4 * sf, c2y - 36 * sf, c2x - 8 * sf, c2y - 36 * sf)
      ..close();
    canvas.drawPath(robeHighlight2, Paint()..color = const Color(0xFF4A8060).withOpacity(0.5));

    // Head (touching ground in sujud)
    final headC2 = Offset(c2x + 48 * sf, c2y - 9 * sf);
    canvas.drawCircle(headC2, 10.0 * sf, skinPaint);

    // Cap in sujud position
    final cap2 = Path()
      ..moveTo(c2x + 40 * sf, c2y - 14 * sf)
      ..quadraticBezierTo(c2x + 50 * sf, c2y - 24 * sf, c2x + 58 * sf, c2y - 12 * sf)
      ..quadraticBezierTo(c2x + 50 * sf, c2y - 9 * sf, c2x + 40 * sf, c2y - 14 * sf)
      ..close();
    canvas.drawPath(cap2, capPaint);

    // Hands on ground (sujud position)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c2x + 32 * sf, c2y - 5 * sf, 10 * sf, 5 * sf),
        Radius.circular(2.5 * sf),
      ),
      skinPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c2x + 44 * sf, c2y - 5 * sf, 10 * sf, 5 * sf),
        Radius.circular(2.5 * sf),
      ),
      skinPaint,
    );

    // ─── SMALL PRAYER RUG / SEJJADEH indicators ───
    final rugPaint = Paint()
      ..color = const Color(0xFF2E5740).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    // Rug under character 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c1x, c1y + 1), width: 65 * sf, height: 4 * sf),
        Radius.circular(2 * sf),
      ),
      rugPaint,
    );
    // Rug under character 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c2x + 5 * sf, c2y + 1), width: 90 * sf, height: 4 * sf),
        Radius.circular(2 * sf),
      ),
      rugPaint,
    );
  }

  /// Draws a flat, rounded, puffy cloud shape
  void _drawFlatCloud(Canvas canvas, Offset center, double width, double height, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    // Main body
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(height * 0.5),
    ));

    // Puffy bumps on top
    final bumpCount = 3;
    final bumpSpacing = width / (bumpCount + 1);
    for (int i = 1; i <= bumpCount; i++) {
      final bx = center.dx - width / 2 + bumpSpacing * i;
      final by = center.dy - height * 0.25;
      final bumpRadius = height * (0.35 + (i == 2 ? 0.15 : 0.0));
      path.addOval(Rect.fromCircle(center: Offset(bx, by), radius: bumpRadius));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 2: Location Permission Illustration
class LocationPermissionIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF142442));

    // World map trace behind
    final mapPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw some stylized contour grid lines to look like a map
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), i * 36, mapPaint);
    }

    // Floating location pins in background
    final pinPaint = Paint()..color = const Color(0xFF90B49C).withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.35), 12, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.25), 8, pinPaint);

    // Phone outline container
    final phonePaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final phoneBezelPaint = Paint()
      ..color = const Color(0xFF2C3E5B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.45),
        width: size.width * 0.42,
        height: size.height * 0.65,
      ),
      const Radius.circular(20),
    );

    canvas.drawRRect(phoneRect, phonePaint);
    canvas.drawRRect(phoneRect, phoneBezelPaint);

    // Concentric green location circles on phone
    final pulsePaint = Paint()
      ..color = const Color(0xFF90B49C).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.38), 32, pulsePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.38), 16, Paint()..color = const Color(0xFF90B49C).withOpacity(0.4));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.38), 4, Paint()..color = const Color(0xFF90B49C));

    // A walking character silhouette
    final robePaint = Paint()..color = const Color(0xFF2E5E43);
    final skinPaint = Paint()..color = const Color(0xFFF5D6B6);
    final double charX = size.width * 0.72;
    final double charY = size.height * 0.68;

    canvas.drawPath(
      Path()
        ..moveTo(charX - 8, charY)
        ..quadraticBezierTo(charX - 10, charY - 24, charX - 4, charY - 32)
        ..lineTo(charX + 4, charY - 32)
        ..quadraticBezierTo(charX + 10, charY - 24, charX + 8, charY)
        ..close(),
      robePaint,
    );
    canvas.drawCircle(Offset(charX, charY - 38), 5, skinPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(charX, charY - 38), radius: 5),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8AA996),
    );
    // Legs
    canvas.drawRect(Rect.fromLTWH(charX - 6, charY, 4, 12), Paint()..color = const Color(0xFF1C1C1C));
    canvas.drawRect(Rect.fromLTWH(charX + 2, charY, 4, 12), Paint()..color = const Color(0xFF1C1C1C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 3: Detected Location Map Illustration
class DetectedLocationIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF142442));

    // Draw stylized street map lines
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final parkPaint = Paint()
      ..color = const Color(0xFF1E3C2B).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw green parks
    canvas.drawRect(Rect.fromLTWH(16, 24, size.width * 0.25, 48), parkPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.68, 60, size.width * 0.2, 70), parkPaint);

    // Vertical streets
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.2, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.8, size.height), streetPaint);

    // Horizontal streets
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), streetPaint);

    // Diagonal streets
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), streetPaint);

    // Concentric dynamic pulse
    final pulsePaint = Paint()
      ..color = const Color(0xFF90B49C).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    final centerOffset = Offset(size.width * 0.5, size.height * 0.45);
    canvas.drawCircle(centerOffset, 48, pulsePaint);
    canvas.drawCircle(centerOffset, 24, Paint()..color = const Color(0xFF90B49C).withOpacity(0.25));
    canvas.drawCircle(centerOffset, 6, Paint()..color = const Color(0xFF90B49C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 4: Calculation Method (Astrolabe/Compass)
class CalculationMethodIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF142442));

    final center = Offset(size.width * 0.5, size.height * 0.45);

    // Night stars in sky
    final starPaint = Paint()..color = Colors.white.withOpacity(0.6);
    final random = math.Random(123);
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height * 0.8),
        random.nextDouble() * 1.2 + 0.5,
        starPaint,
      );
    }

    // Astrolabe/Compass golden drawings
    final compassPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Rings
    canvas.drawCircle(center, 64, compassPaint);
    canvas.drawCircle(center, 54, compassPaint);
    canvas.drawCircle(center, 40, compassPaint);
    canvas.drawCircle(center, 12, compassPaint);

    // Dial spokes
    for (int angle = 0; angle < 360; angle += 30) {
      final rad = angle * math.pi / 180;
      canvas.drawLine(
        Offset(center.dx + 12 * math.cos(rad), center.dy + 12 * math.sin(rad)),
        Offset(center.dx + 64 * math.cos(rad), center.dy + 64 * math.sin(rad)),
        compassPaint,
      );
    }

    // Pointer needle
    final needlePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + 48 * math.cos(-math.pi / 3), center.dy + 48 * math.sin(-math.pi / 3)),
      needlePaint,
    );

    // Silhouette character standing on right looking up
    final robePaint = Paint()..color = const Color(0xFF2E5E43);
    final skinPaint = Paint()..color = const Color(0xFFF5D6B6);
    final double charX = size.width * 0.72;
    final double charY = size.height * 0.8;

    canvas.drawPath(
      Path()
        ..moveTo(charX - 8, charY)
        ..quadraticBezierTo(charX - 10, charY - 24, charX - 4, charY - 32)
        ..lineTo(charX + 4, charY - 32)
        ..quadraticBezierTo(charX + 10, charY - 24, charX + 8, charY)
        ..close(),
      robePaint,
    );
    canvas.drawCircle(Offset(charX, charY - 38), 5, skinPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(charX, charY - 38), radius: 5),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8AA996),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 5: Join Us (World map outline)
class JoinUsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF142442));

    // World map wireframe outline simulation
    final mapPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Americas outline shape
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.35, size.width * 0.18, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.65, size.width * 0.22, size.height * 0.8);
    path.lineTo(size.width * 0.24, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.26, size.height * 0.5, size.width * 0.28, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.18, size.width * 0.15, size.height * 0.2);

    // Europe & Africa outline shape
    path.moveTo(size.width * 0.45, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width * 0.56, size.height * 0.28);
    path.quadraticBezierTo(size.width * 0.46, size.height * 0.38, size.width * 0.48, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.54, size.height * 0.72, size.width * 0.58, size.height * 0.78);
    path.lineTo(size.width * 0.56, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.42, size.height * 0.55, size.width * 0.45, size.height * 0.25);

    // Asia outline shape
    path.moveTo(size.width * 0.6, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.88, size.height * 0.4, size.width * 0.82, size.height * 0.52);
    path.quadraticBezierTo(size.width * 0.68, size.height * 0.6, size.width * 0.6, size.height * 0.25);

    canvas.drawPath(path, mapPaint);

    // Minimalist Character silhouette on the right
    final robePaint = Paint()..color = const Color(0xFF2E5E43);
    final skinPaint = Paint()..color = const Color(0xFFF5D6B6);
    final double charX = size.width * 0.76;
    final double charY = size.height * 0.65;

    canvas.drawPath(
      Path()
        ..moveTo(charX - 8, charY)
        ..quadraticBezierTo(charX - 10, charY - 24, charX - 4, charY - 32)
        ..lineTo(charX + 4, charY - 32)
        ..quadraticBezierTo(charX + 10, charY - 24, charX + 8, charY)
        ..close(),
      robePaint,
    );
    canvas.drawCircle(Offset(charX, charY - 38), 5, skinPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(charX, charY - 38), radius: 5),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8AA996),
    );
    // Legs
    canvas.drawRect(Rect.fromLTWH(charX - 6, charY, 4, 14), Paint()..color = const Color(0xFF1C1C1C));
    canvas.drawRect(Rect.fromLTWH(charX + 2, charY, 4, 14), Paint()..color = const Color(0xFF1C1C1C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 6 & 7: Reminder/Notification Customization
class ReminderIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF142442));

    final center = Offset(size.width * 0.52, size.height * 0.52);

    // 1. Floating Switch Panel inside phone frame in top-right
    final panelPaint = Paint()
      ..color = const Color(0xFF1C2E4F).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final panelBorder = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.12, size.width * 0.3, size.height * 0.35),
      const Radius.circular(12),
    );
    canvas.drawRRect(panelRect, panelPaint);
    canvas.drawRRect(panelRect, panelBorder);

    // Switches in the panel
    final switchOnPaint = Paint()..color = const Color(0xFFE5A93B);
    final switchOffPaint = Paint()..color = Colors.grey.withOpacity(0.3);

    // Switch 1 (On)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.66, size.height * 0.18, 32, 16), const Radius.circular(8)),
      switchOnPaint,
    );
    canvas.drawCircle(Offset(size.width * 0.66 + 24, size.height * 0.18 + 8), 6, Paint()..color = Colors.white);

    // Switch 2 (Off)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.66, size.height * 0.28, 32, 16), const Radius.circular(8)),
      switchOffPaint,
    );
    canvas.drawCircle(Offset(size.width * 0.66 + 8, size.height * 0.28 + 8), 6, Paint()..color = Colors.white54);

    // 2. Large Circular Alarm Clock in the Center
    final clockPaint = Paint()
      ..color = const Color(0xFF1E352B)
      ..style = PaintingStyle.fill;
    
    final clockBorder = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final clockBezel = Paint()
      ..color = const Color(0xFF90B49C).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Clock legs
    final legPaint = Paint()
      ..color = Colors.black.withOpacity(0.9)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx - 48, center.dy + 72), legPaint);
    canvas.drawLine(center, Offset(center.dx + 48, center.dy + 72), legPaint);

    // Clock bells
    final bellPaint = Paint()
      ..color = Colors.black.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 36, center.dy - 56), 20, bellPaint);
    canvas.drawCircle(Offset(center.dx + 36, center.dy - 56), 20, bellPaint);

    // Hammer
    canvas.drawRect(Rect.fromLTWH(center.dx - 4, center.dy - 74, 8, 16), bellPaint);

    // Main clock body
    canvas.drawCircle(center, 58, clockPaint);
    canvas.drawCircle(center, 58, clockBorder);
    canvas.drawCircle(center, 52, clockBezel);

    // Clock hands
    final handPaint = Paint()
      ..color = Colors.black.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Hour hand (pointing to ~2)
    canvas.drawLine(center, Offset(center.dx + 28, center.dy - 8), handPaint);
    // Minute hand (pointing to ~10)
    canvas.drawLine(center, Offset(center.dx - 36, center.dy - 12), handPaint);

    // Center pivot
    canvas.drawCircle(center, 4, Paint()..color = const Color(0xFFE5A93B));

    // 3. Floating Musical Notes on Top-Left
    final notePaint = Paint()
      ..color = const Color(0xFF2E5E43).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    // Draw a small 8th note
    final notePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.18)
      ..lineTo(size.width * 0.26, size.height * 0.14)
      ..lineTo(size.width * 0.26, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.28, size.width * 0.2, size.height * 0.25)
      ..lineTo(size.width * 0.18, size.height * 0.18)
      ..close();
    canvas.drawPath(notePath, notePaint);

    // 4. Character Silhouette on Left
    final robePaint = Paint()..color = const Color(0xFF2E5E43);
    final skinPaint = Paint()..color = const Color(0xFFF5D6B6);
    final double charX = size.width * 0.24;
    final double charY = size.height * 0.8;

    canvas.drawPath(
      Path()
        ..moveTo(charX - 10, charY)
        ..quadraticBezierTo(charX - 12, charY - 28, charX - 5, charY - 38)
        ..lineTo(charX + 5, charY - 38)
        ..quadraticBezierTo(charX + 12, charY - 28, charX + 10, charY)
        ..close(),
      robePaint,
    );
    canvas.drawCircle(Offset(charX, charY - 44), 6, skinPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(charX, charY - 44), radius: 6),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8AA996),
    );
    // Legs
    canvas.drawRect(Rect.fromLTWH(charX - 7, charY, 4, 16), Paint()..color = const Color(0xFF1C1C1C));
    canvas.drawRect(Rect.fromLTWH(charX + 3, charY, 4, 16), Paint()..color = const Color(0xFF1C1C1C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SCREEN 8: Full Setup/Loading Screen (Phone, gears, character holding gear)
class SetupIllustrationPainter extends CustomPainter {
  final double rotationAngle;

  SetupIllustrationPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Gradient sky
    final skyGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1B31), Color(0xFF142442)],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = skyGradient);

    final center = Offset(size.width * 0.52, size.height * 0.45);

    // 1. Large smartphone outline
    final phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final phoneBezelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final phoneWidth = size.width * 0.46;
    final phoneHeight = size.height * 0.58;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: phoneWidth, height: phoneHeight),
      const Radius.circular(24),
    );

    canvas.drawRRect(phoneRect, phonePaint);
    canvas.drawRRect(phoneRect, phoneBezelPaint);

    // Dynamic island/speaker slot at the top of the phone
    final speakerPaint = Paint()..color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - (phoneHeight / 2) + 16),
          width: 44,
          height: 12,
        ),
        const Radius.circular(6),
      ),
      speakerPaint,
    );

    // 2. Character silhouette in green robe standing WITH BACK to viewer
    final robePaint = Paint()..color = const Color(0xFF436B53);
    final hairPaint = Paint()..color = Colors.black;
    final skinPaint = Paint()..color = const Color(0xFFF5D6B6);
    final pantsPaint = Paint()..color = const Color(0xFF141414);

    final double charX = size.width * 0.33;
    final double charY = size.height * 0.68;

    // Robe Body
    final robePath = Path()
      ..moveTo(charX - 16, charY)
      ..quadraticBezierTo(charX - 22, charY - 32, charX - 10, charY - 48)
      ..lineTo(charX + 10, charY - 48)
      ..quadraticBezierTo(charX + 22, charY - 32, charX + 16, charY)
      ..close();
    canvas.drawPath(robePath, robePaint);

    // Head / Hair (standing from back - cap and back hair visible)
    canvas.drawCircle(Offset(charX, charY - 56), 8, skinPaint);
    canvas.drawCircle(Offset(charX, charY - 56), 8, hairPaint);
    // cap top
    canvas.drawArc(
      Rect.fromCircle(center: Offset(charX, charY - 56), radius: 8),
      math.pi * 1.25,
      math.pi * 0.5,
      true,
      Paint()..color = const Color(0xFF8AA996),
    );

    // Arms: left arm resting, right arm holding gear on screen
    // Left arm
    canvas.drawPath(
      Path()
        ..moveTo(charX - 16, charY - 44)
        ..quadraticBezierTo(charX - 24, charY - 32, charX - 16, charY - 24)
        ..lineTo(charX - 12, charY - 24)
        ..close(),
      robePaint,
    );
    // Right arm pointing/touching screen gear
    canvas.drawPath(
      Path()
        ..moveTo(charX + 12, charY - 44)
        ..quadraticBezierTo(charX + 28, charY - 40, charX + 32, charY - 36)
        ..lineTo(charX + 28, charY - 32)
        ..close(),
      robePaint,
    );
    // Right hand
    canvas.drawCircle(Offset(charX + 33, charY - 36), 4, skinPaint);

    // Legs / Pants
    canvas.drawRect(Rect.fromLTWH(charX - 12, charY, 7, 24), pantsPaint);
    canvas.drawRect(Rect.fromLTWH(charX + 3, charY, 7, 24), pantsPaint);
    // Feet
    canvas.drawOval(Rect.fromLTWH(charX - 14, charY + 24, 10, 6), skinPaint);
    canvas.drawOval(Rect.fromLTWH(charX + 3, charY + 24, 10, 6), skinPaint);

    // 3. Main Green Gear in the middle of phone screen
    _drawGear(canvas, center, 22, 6, const Color(0xFF436B53));

    // 4. Rotating gears on the left (animated!)
    canvas.save();
    canvas.translate(size.width * 0.22, size.height * 0.38);
    canvas.rotate(rotationAngle);
    _drawGear(canvas, Offset.zero, 28, 8, const Color(0xFFE5A93B));
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.26, size.height * 0.26);
    canvas.rotate(-rotationAngle * 1.5);
    _drawGear(canvas, Offset.zero, 16, 5, Colors.white70);
    canvas.restore();

    // 5. Rotating loading dots circle on the right side
    final double radius = 24;
    final int dotCount = 8;
    final loadingCenter = Offset(size.width * 0.75, size.height * 0.42);
    final double angleStep = 2 * math.pi / dotCount;

    for (int i = 0; i < dotCount; i++) {
      // Create trailing/loading opacity shift
      final double offsetAngle = rotationAngle * 0.5;
      final double angle = i * angleStep + offsetAngle;
      final double x = loadingCenter.dx + radius * math.cos(angle);
      final double y = loadingCenter.dy + radius * math.sin(angle);
      
      final double opacity = (i / dotCount).clamp(0.1, 1.0);
      final dotPaint = Paint()..color = const Color(0xFFE5A93B).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    // 6. Styled potted plant in bottom right
    final double plantX = size.width * 0.76;
    final double plantY = size.height * 0.78;

    // Pot
    final potPath = Path()
      ..moveTo(plantX - 16, plantY)
      ..lineTo(plantX + 16, plantY)
      ..lineTo(plantX + 12, plantY + 20)
      ..lineTo(plantX - 12, plantY + 20)
      ..close();
    canvas.drawPath(potPath, Paint()..color = const Color(0xFF1C2E4F));

    // Leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF8AA996).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    
    // Draw 3 beautiful leaves curving out
    canvas.drawOval(
      Rect.fromCenter(center: Offset(plantX - 18, plantY - 12), width: 22, height: 12),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(plantX + 18, plantY - 12), width: 22, height: 12),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(plantX, plantY - 24), width: 14, height: 20),
      leafPaint,
    );
  }

  // General helper to draw gears
  void _drawGear(Canvas canvas, Offset center, double outerRadius, int teethCount, Color color) {
    final gearPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Central circular body
    canvas.drawCircle(center, outerRadius * 0.75, gearPaint);

    // Inner hole cutout
    canvas.drawCircle(center, outerRadius * 0.25, Paint()..color = const Color(0xFF142442));

    // Draw gear teeth spokes
    for (int i = 0; i < teethCount; i++) {
      final angle = i * (2 * math.pi / teethCount);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final toothRect = Rect.fromCenter(
        center: Offset(0, -outerRadius * 0.8),
        width: outerRadius * 0.35,
        height: outerRadius * 0.4,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(toothRect, const Radius.circular(2)), gearPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SetupIllustrationPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle;
}
