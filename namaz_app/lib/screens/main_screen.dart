import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../data/prayer_repository.dart';
import '../data/prayer_data.dart';
import '../data/prayer_tracker_state.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';
import 'premium_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';

class MainScreen extends StatefulWidget {
  final Function(int) onTabChange;
  final Function(String, String) onOpenTool;
  final VoidCallback onLocationReset;
  final VoidCallback? onLocationChanged;

  const MainScreen({
    super.key,
    required this.onTabChange,
    required this.onOpenTool,
    required this.onLocationReset,
    this.onLocationChanged,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin<MainScreen> {
  final PrayerRepository _repository = PrayerRepository();
  final NotificationService _notificationService = NotificationService();
  final PrayerTrackerState _trackerState = PrayerTrackerState();
  bool _isPremium = false;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  String? _adLoadError;

  @override
  bool get wantKeepAlive => true;

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

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF27A770)),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E5E43),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _autoDetectAndSaveLocation() async {
    _showLoadingDialog("Konumunuz GPS ile tespit ediliyor...");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Navigator.pop(context); // Dismiss loading dialog
        _showSnackBar("Lütfen telefonunuzun konum servisini (GPS) açın.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Navigator.pop(context); // Dismiss loading dialog
          _showSnackBar("Konum izni verilmedi.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Navigator.pop(context); // Dismiss loading dialog
        _showSnackBar("Konum izni reddedildi. Lütfen ayarlardan izin verin.");
        return;
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

            final times = await _repository.getPrayerTimes(
              districtId,
              forceRefresh: true,
            );

            await _repository.saveLocation(cityName, cityId, districtName, districtId);
            await _notificationService.schedulePrayerAlarms(times);

            Navigator.pop(context); // Dismiss loading dialog
            _showSnackBar("Konum GPS ile güncellendi: ${_formatTurkishCity(cityName)} / ${_formatTurkishDistrict(districtName)}", success: true);
            
            // Reload home screen in-place immediately
            widget.onLocationChanged?.call();
            return;
          }
        }
      }
      
      Navigator.pop(context); // Dismiss loading dialog
      _showSnackBar("Konum otomatik eşleşmedi. Lütfen listeden manuel seçin.");
    } catch (e) {
      debugPrint("GPS auto-detect error: $e");
      Navigator.pop(context); // Dismiss loading dialog
      _showSnackBar("Konum alınırken hata oluştu. Lütfen listeden manuel seçin.");
    }
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

  void _showLocationChangeSheet(BuildContext context) {
    final String rawCity = _location['cityName'] ?? 'Bilinmiyor';
    final String rawDistrict = _location['districtName'] ?? 'Bilinmiyor';

    final String city = _formatTurkishCity(rawCity);
    String district = _formatTurkishDistrict(rawDistrict);

    if (rawCity.trim().toLowerCase() == rawDistrict.trim().toLowerCase()) {
      district = 'Merkez';
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    List<Map<String, dynamic>> citiesList = [];
    List<Map<String, dynamic>> districtsList = [];
    Map<String, dynamic>? selectedCity;
    Map<String, dynamic>? selectedDistrict;
    bool loadingCities = true;
    bool loadingDistricts = false;
    bool savingLocation = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            if (citiesList.isEmpty && loadingCities) {
              _repository.getCities().then((cities) {
                if (context.mounted) {
                  setSheetState(() {
                    citiesList = cities;
                    loadingCities = false;
                  });
                }
              }).catchError((e) {
                if (context.mounted) {
                  setSheetState(() {
                    loadingCities = false;
                  });
                }
              });
            }

            print("Builder State - selectedCity: $selectedCity, selectedDistrict: $selectedDistrict, savingLocation: $savingLocation");
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pull handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: dark ? Colors.white24 : Colors.grey[350],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title and Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27A770).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF27A770),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lokasyon Değiştir",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: dark ? Colors.white : const Color(0xFF1E5E43),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Namaz vakitleri için yeni konum seçin",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? Colors.white60 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Current Location Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF3F8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF27A770).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "📍",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mevcut Konumunuz",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: dark ? Colors.white60 : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$city / $district",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: dark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (savingLocation)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(color: Color(0xFF27A770)),
                        ),
                      )
                    else ...[
                      // Auto GPS Option
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5E43),
                            foregroundColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.gps_fixed, size: 20, color: Color(0xFFD4AF37)),
                          label: const Text(
                            "Cihaz Konumunu Kullan (Otomatik)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context); // Close bottom sheet
                            await _autoDetectAndSaveLocation();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(height: 20, color: Colors.white12),
                      const SizedBox(height: 8),

                      // City Dropdown
                      if (loadingCities)
                        const Center(child: CircularProgressIndicator(color: Color(0xFF27A770)))
                      else
                        DropdownButtonFormField<Map<String, dynamic>>(
                          dropdownColor: dark ? const Color(0xFF131D31) : Colors.white,
                          style: TextStyle(color: dark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Şehir Seçin",
                            labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.grey[700]),
                            filled: true,
                            fillColor: dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.location_city, color: Color(0xFF27A770)),
                          ),
                          value: selectedCity,
                          items: citiesList.map((c) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: c,
                              child: Text(c['SehirAdi'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            print("Dropdown City changed: $val");
                            setSheetState(() {
                              selectedCity = val;
                              selectedDistrict = null;
                              loadingDistricts = true;
                            });
                            if (val != null) {
                              final dists = await _repository.getDistricts(val['SehirID'].toString());
                              print("Fetched districts for city ${val['SehirID']}: $dists");
                              setSheetState(() {
                                districtsList = dists;
                                loadingDistricts = false;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 16),

                      // District Dropdown
                      if (selectedCity != null) ...[
                        if (loadingDistricts)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF27A770)))
                        else
                          DropdownButtonFormField<Map<String, dynamic>>(
                            dropdownColor: dark ? const Color(0xFF131D31) : Colors.white,
                            style: TextStyle(color: dark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: "İlçe Seçin",
                              labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.grey[700]),
                              filled: true,
                              fillColor: dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.map, color: Color(0xFF27A770)),
                            ),
                            value: selectedDistrict,
                            items: districtsList.map((d) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: d,
                                child: Text(d['IlceAdi'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print("Dropdown District changed: $val");
                              setSheetState(() {
                                selectedDistrict = val;
                              });
                            },
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "İptal",
                              style: TextStyle(
                                color: dark ? Colors.white70 : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27A770),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: (selectedCity == null || selectedDistrict == null)
                                ? null
                                : () async {
                                    setSheetState(() => savingLocation = true);
                                    try {
                                      final String cityName = selectedCity!['SehirAdi'];
                                      final String cityId = selectedCity!['SehirID'].toString();
                                      final String districtName = selectedDistrict!['IlceAdi'];
                                      final String districtId = selectedDistrict!['IlceID'].toString();

                                      final times = await _repository.getPrayerTimes(districtId, forceRefresh: true);
                                      await _repository.saveLocation(cityName, cityId, districtName, districtId);
                                      await _notificationService.schedulePrayerAlarms(times);

                                      // Refresh state of main screen in-place
                                      await loadData();

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _showSnackBar("Konum başarıyla güncellendi: $cityName / $districtName", success: true);
                                      }
                                      widget.onLocationChanged?.call();
                                    } catch (e) {
                                      setSheetState(() => savingLocation = false);
                                      _showSnackBar("Konum güncellenirken hata oluştu.");
                                    }
                                  },
                            child: const Text(
                              "Konumu Güncelle",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Map<String, String?> _location = {};
  List<Map<String, dynamic>> _prayerTimes = [];
  Map<String, dynamic>? _todayTimes;
  Map<String, dynamic>? _tomorrowTimes;

  bool _loading = true;
  Timer? _timer;

  // Live countdown state variables
  String _nextPrayerName = "";
  String _countdownText = "";
  double _progressValue = 0.0;
  String _activePrayerName = "";

  // Daily random index variables (based on day of the month)
  int _dayIndex = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    _dayIndex = (DateTime.now().day + DateTime.now().month * 30) % VAKTIN_AYETLERI.length; // To rotate daily cards across 60 items
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted && _todayTimes != null) {
        _updateCountdown();
      }
      
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final localIsPremium = prefs.getBool('is_premium') ?? false;
        if (localIsPremium != _isPremium) {
          setState(() {
            _isPremium = localIsPremium;
          });
          if (localIsPremium) {
            _bannerAd?.dispose();
            _bannerAd = null;
            _isBannerAdLoaded = false;
          } else {
            _loadBannerAd();
          }
        }
      }
    });
    _trackerState.addListener(_onTrackerStateChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _trackerState.removeListener(_onTrackerStateChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    final showAds = await AdService.shouldShowAds();
    if (!showAds) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        setState(() {
          _isBannerAdLoaded = false;
        });
      }
      return;
    }

    if (_bannerAd != null) return; // Already loading/loaded

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
            _adLoadError = null;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print("AdMob Banner load failed in main_screen: ${err.code} - ${err.message}");
          ad.dispose();
          _bannerAd = null;
          setState(() {
            _isBannerAdLoaded = false;
            _adLoadError = "${err.code}: ${err.message}";
          });
        },
      ),
    )..load();
  }

  void _onTrackerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadData() async {
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;

    // Load or dispose of the banner ad based on premium status
    if (!isPremium) {
      _loadBannerAd();
    } else {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
      }
    }

    final loc = await _repository.getSavedLocation();
    final districtId = loc['districtId'];
    if (districtId != null) {
      final times = await _repository.getPrayerTimes(districtId);
      
      // Auto-schedule alarms on startup so alarms are always fresh
      await _notificationService.schedulePrayerAlarms(times);

      setState(() {
        _isPremium = isPremium;
        _location = loc;
        _prayerTimes = times;

        // Find today's and tomorrow's times
        final nowStr = _formatDate(DateTime.now());
        final tomStr = _formatDate(DateTime.now().add(const Duration(days: 1)));

        _todayTimes = _findTimesForDate(nowStr);
        _tomorrowTimes = _findTimesForDate(tomStr);

        // If today's times not found in list, default to first item
        if (_todayTimes == null && _prayerTimes.isNotEmpty) {
          _todayTimes = _prayerTimes.first;
        }
        if (_tomorrowTimes == null && _prayerTimes.length > 1) {
          _tomorrowTimes = _prayerTimes[1];
        }

        _loading = false;
      });
      _updateCountdown();
    } else {
      setState(() {
        _isPremium = isPremium;
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    return "$day.$month.${dt.year}";
  }

  Map<String, dynamic>? _findTimesForDate(String dateStr) {
    for (var item in _prayerTimes) {
      if (item['MiladiTarihKisa'] == dateStr) {
        return item;
      }
    }
    return null;
  }

  // Parse time string e.g. "03:34" to DateTime on a specific base Date
  DateTime _parseTime(String timeStr, DateTime baseDate) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  void _updateCountdown() {
    if (_todayTimes == null) return;

    final now = DateTime.now();

    // Parse all today times
    final DateTime imsak = _parseTime(_todayTimes!['Imsak'] ?? '03:30', now);
    final DateTime gunes = _parseTime(_todayTimes!['Gunes'] ?? '05:30', now);
    final DateTime ogle = _parseTime(_todayTimes!['Ogle'] ?? '13:00', now);
    final DateTime ikindi = _parseTime(_todayTimes!['Ikindi'] ?? '17:00', now);
    final DateTime aksam = _parseTime(_todayTimes!['Aksam'] ?? '20:30', now);
    final DateTime yatsi = _parseTime(_todayTimes!['Yatsi'] ?? '22:00', now);

    // Tomorrow's imsak
    DateTime tomImsak = now.add(const Duration(days: 1));
    if (_tomorrowTimes != null) {
      tomImsak = _parseTime(
        _tomorrowTimes!['Imsak'] ?? '03:30',
        now.add(const Duration(days: 1)),
      );
    } else {
      tomImsak = imsak.add(const Duration(days: 1));
    }

    // Yesterday's yatsi
    DateTime yesYatsi = now.subtract(const Duration(days: 1));
    yesYatsi = DateTime(
      yesYatsi.year,
      yesYatsi.month,
      yesYatsi.day,
      yatsi.hour,
      yatsi.minute,
    );

    // List of slots: [Name, Start, End, NextName]
    final slots = [
      ['Yatsı', yesYatsi, imsak, 'İmsak'],
      ['İmsak', imsak, gunes, 'Güneş'],
      ['Güneş', gunes, ogle, 'Öğle'],
      ['Öğle', ogle, ikindi, 'İkindi'],
      ['İkindi', ikindi, aksam, 'Akşam'],
      ['Akşam', aksam, yatsi, 'Yatsı'],
      ['Yatsı', yatsi, tomImsak, 'İmsak'],
    ];

    String active = "Yatsı";
    String next = "İmsak";
    DateTime start = yatsi;
    DateTime end = tomImsak;

    for (var slot in slots) {
      final DateTime sStart = slot[1] as DateTime;
      final DateTime sEnd = slot[2] as DateTime;
      if (now.isAfter(sStart) && now.isBefore(sEnd)) {
        active = slot[0] as String;
        start = sStart;
        end = sEnd;
        next = slot[3] as String;
        break;
      }
    }

    final durationLeft = end.difference(now);
    final totalDuration = end.difference(start);

    final hours = durationLeft.inHours;
    final mins = durationLeft.inMinutes.remainder(60);
    final secs = durationLeft.inSeconds.remainder(60);

    setState(() {
      _activePrayerName = active;
      _nextPrayerName = next;
      _countdownText =
          "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
      _progressValue = 1.0 - (durationLeft.inSeconds / totalDuration.inSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF27A770)),
        ),
      );
    }

    if (_todayTimes == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Seçili konum bulunamadı."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => widget.onTabChange(4), // Redirect to settings
                child: const Text("Konum Seç"),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final String rawCity = _location['cityName'] ?? '';
    final String rawDistrict = _location['districtName'] ?? '';

    final String city = _formatTurkishCity(rawCity);
    String district = _formatTurkishDistrict(rawDistrict);

    if (rawCity.trim().toLowerCase() == rawDistrict.trim().toLowerCase()) {
      district = 'Merkez';
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String dateUzun = _todayTimes!['MiladiTarihUzun'] ?? '';
    final String hicriUzun = _todayTimes!['HicriTarihUzun'] ?? '';

    // Daily contents
    final verse = VAKTIN_AYETLERI[_dayIndex];
    final hadith = VAKTIN_HADISLERI[_dayIndex];
    final names = GUNUN_ISIMLERI[_dayIndex];

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF8FBF9),
      body: CustomScrollView(
        slivers: [
          // 1. Sleek Light Header with Subtle Motif Background
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          const Color(0xFF16251C), // Koyu yeşil (geliştirici mesaj kutusu rengi)
                          const Color(0xFF0E1A13), // Daha derin orman yeşili
                        ]
                      : [
                          const Color(0xFF1E5E43),
                          const Color(0xFF27A770),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle mandala ornament in the top-right
                  Positioned(
                    right: -40,
                    top: -40,
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(painter: SubtleMandalaPainter()),
                    ),
                  ),

                  // Content padding
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 12,
                      20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location and Dates Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Location & change link
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFD4AF37),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$city / $district",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                GestureDetector(
                                  onTap: () => _showLocationChangeSheet(context),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      "Lokasyonu Değiştir",
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Right side: Dates (Miladi & Hicri)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  dateUzun,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  hicriUzun,
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37), // Golden center glow color
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 2. Large Digital Green Countdown and Linear Progress Bar
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                "$_nextPrayerName Vaktine Kalan Süre",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _countdownText,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Thin green linear loading bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 4.0,
                                  width: 200,
                                  child: LinearProgressIndicator(
                                    value: _progressValue.clamp(0.0, 1.0),
                                    backgroundColor: Colors.white.withOpacity(0.15),
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Main screen mini action buttons (Glassmorphic)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.12),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: () => widget.onOpenTool(
                                      'namaz-vakitleri-aylik',
                                      'Aylık Namaz Vakitleri',
                                    ),
                                    icon: const Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: Color(0xFFD4AF37),
                                    ),
                                    label: const Text(
                                      "Aylık Namaz Vakitleri",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.12),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationSettingsScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.notifications_active,
                                      size: 16,
                                      color: Color(0xFFD4AF37),
                                    ),
                                    label: const Text(
                                      "Ezan Bildirimleri",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Horizontal 6 Vakit prayer times bar (no cards, capsule active vakit highlighting)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPrayerCard('İmsak', _todayTimes!['Imsak'] ?? '--:--'),
                    _buildPrayerCard('Güneş', _todayTimes!['Gunes'] ?? '--:--'),
                    _buildPrayerCard('Öğle', _todayTimes!['Ogle'] ?? '--:--'),
                    _buildPrayerCard(
                      'İkindi',
                      _todayTimes!['Ikindi'] ?? '--:--',
                    ),
                    _buildPrayerCard('Akşam', _todayTimes!['Aksam'] ?? '--:--'),
                    _buildPrayerCard('Yatsı', _todayTimes!['Yatsi'] ?? '--:--'),
                  ],
                ),
              ),
            ),
          ),

          // 4. Quick Links Navigation circles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularQuickAction(
                    title: 'Dini Danışman',
                    imagePath: 'assets/dini_danisman.png',
                    onTap: () =>
                        widget.onOpenTool('dini-hoca', 'Dini Danışman'),
                  ),
                  _buildCircularQuickAction(
                    title: 'Kuran-ı Kerim',
                    imagePath: 'assets/dini_bilgiler.png',
                    onTap: () =>
                        widget.onOpenTool('kuran-kerim', 'Kuran-ı Kerim'),
                  ),
                  _buildCircularQuickAction(
                    title: 'Zikir',
                    imagePath: 'assets/zikir.png',
                    onTap: () =>
                        widget.onOpenTool('zikirmatik', 'Zikirmatik'),
                  ),
                  _buildCircularQuickAction(
                    title: 'Dualar',
                    imagePath: 'assets/dualar.png',
                    onTap: () =>
                        widget.onOpenTool('gunluk-dualar', 'Dualar'),
                  ),
                  _buildCircularQuickAction(
                    title: 'Dini Bilgiler',
                    imagePath: 'assets/kuran_kerim.png',
                    onTap: () => widget.onTabChange(3),
                  ),
                ],
              ),
            ),
          ),

          // 5. Daily Inspirations Cards (Ayet, Hadis, İsimler ve Geliştirici Mesajı)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Namaz Takibi Card (formerly 2nd)
                  _buildHomePrayerTrackerCard(),
                  const SizedBox(height: 16),

                  if (!_isPremium && (_isBannerAdLoaded || _adLoadError != null)) ...[
                    _buildAdMobBannerCard(),
                    const SizedBox(height: 16),
                  ],

                  // 2. Geliştirici Mesajı Banner (formerly 5th, now in the middle of Namaz Takibi and Günün Ayeti)
                  GestureDetector(
                    onTap: _isPremium
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PremiumScreen(),
                              ),
                            );
                          },
                    child: Card(
                      elevation: 3,
                      color: dark ? const Color(0xFF16251C) : const Color(0xFFEAF7F1), // Soft green banner bg
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Geliştiricinin size mesajı var",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Namaz Vakitleri mobil uygulamamızı tercih ettiğiniz için teşekkür ederiz. Dualarınızda bizleri de eksik etmeyin.",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: dark ? Colors.white70 : Colors.grey[800],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Image.asset(
                              'assets/muslim_boy_heart.png',
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Ayet Card (formerly 1st)
                  _buildDailyTextCard(
                    title: "Günün Ayeti",
                    ref: verse['ref'] ?? '',
                    text: verse['text'] ?? '',
                    bannerText: verse['title'] ?? '',
                    icon: "📖",
                  ),
                  const SizedBox(height: 16),

                  // 4. Hadis Card
                  _buildDailyTextCard(
                    title: "Günün Hadis-i Şerifi",
                    ref: hadith['ref'] ?? '',
                    text: hadith['text'] ?? '',
                    bannerText: hadith['title'] ?? '',
                    icon: "📜",
                  ),
                  const SizedBox(height: 16),

                  // 5. Gunun Isimleri Card with background image bebekler.png
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/bebekler.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: dark
                            ? const Color(0xFF131D31).withOpacity(0.88)
                            : Colors.white.withOpacity(0.88), // Soft overlay to ensure readability
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "👶",
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Günün İsim Önerileri",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 20, color: dark ? Colors.white24 : Colors.grey[300]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Kız Bebek",
                                      style: TextStyle(
                                        color: dark ? Colors.white70 : Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      names['kiz'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: dark ? Colors.pinkAccent : Colors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: dark ? Colors.white24 : Colors.grey[300],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Erkek Bebek",
                                      style: TextStyle(
                                        color: dark ? Colors.white70 : Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      names['erkek'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: dark ? Colors.blueAccent : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(String name, String time) {
    final bool isActive = _activePrayerName == name;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEAF7F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF1E5E43) : Colors.grey[600],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? const Color(0xFF27A770) : Colors.black87,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularQuickAction({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : const Color(0xFF1E5E43),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTextCard({
    required String title,
    required String ref,
    required String text,
    required String bannerText,
    required String icon,
  }) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? const Color(0xFF131D31) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27A770).withOpacity(dark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bannerText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              "“$text”",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
                height: 1.4,
                color: dark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- $ref",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF27A770),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTrackerDate(DateTime dt) {
    String y = dt.year.toString();
    String m = dt.month.toString().padLeft(2, '0');
    String d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  int _calculateCurrentStreak() {
    int curStreak = 0;
    DateTime checkDate = DateTime.now();
    
    String todayStr = _formatTrackerDate(checkDate);
    final todayList = _trackerState.history[todayStr] ?? [false, false, false, false, false];
    bool todayAll = todayList.length == 5 && todayList.where((e) => e).length >= 4;

    if (!todayAll) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      String dateStr = _formatTrackerDate(checkDate);
      final list = _trackerState.history[dateStr];
      if (list != null && list.length == 5 && list.where((e) => e).length >= 4) {
        curStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return curStreak;
  }

  Widget _buildHomePrayerButton(
    String label,
    bool isChecked,
    int index,
    String dateStr,
    bool dark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _trackerState.togglePrayer(dateStr, index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isChecked
                  ? const Color(0xFFD4AF37).withOpacity(0.15)
                  : (dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)),
              border: Border.all(
                color: isChecked
                    ? const Color(0xFFD4AF37)
                    : (dark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08)),
                width: isChecked ? 2.0 : 1.2,
              ),
              boxShadow: isChecked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isChecked ? 1.0 : 0.0,
                child: const Icon(
                  Icons.check,
                  color: Color(0xFFD4AF37),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
            color: isChecked
                ? (dark ? Colors.white : Colors.black87)
                : (dark ? Colors.white38 : Colors.black45),
          ),
        ),
      ],
    );
  }

  Widget _buildHomePrayerTrackerCard() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String todayStr = _formatTrackerDate(DateTime.now());
    final todayList = _trackerState.history[todayStr] ?? [false, false, false, false, false];
    final int currentStreak = _calculateCurrentStreak();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? const Color(0xFF131D31) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Row and Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => widget.onTabChange(1),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Text("🕌", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        "Namaz Takibi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: dark ? Colors.white : const Color(0xFF1E5E43),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: dark ? Colors.white54 : const Color(0xFF1E5E43).withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                // Dynamic Streak Badge (NAMAZ SERİSİ veya BAŞLANGIÇ)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentStreak >= 1 
                        ? const Color(0xFFD4AF37).withOpacity(0.12)
                        : (dark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentStreak >= 1 
                          ? const Color(0xFFD4AF37).withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStreak >= 1 ? "🔥 " : "🌱 ",
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        currentStreak >= 1 ? "SERİ: $currentStreak GÜN" : "BAŞLANGIÇ",
                        style: TextStyle(
                          color: currentStreak >= 1 
                              ? const Color(0xFFD4AF37)
                              : (dark ? Colors.white60 : Colors.black54),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Checkboxes Row (animated buttons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHomePrayerButton("Sabah", todayList[0], 0, todayStr, dark),
                _buildHomePrayerButton("Öğle", todayList[1], 1, todayStr, dark),
                _buildHomePrayerButton("İkindi", todayList[2], 2, todayStr, dark),
                _buildHomePrayerButton("Akşam", todayList[3], 3, todayStr, dark),
                _buildHomePrayerButton("Yatsı", todayList[4], 4, todayStr, dark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdMobBannerCard() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    if (_adLoadError != null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFFEE2E2),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Reklam Yüklenemedi (Test Bilgisi)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: dark ? Colors.white : Colors.red[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Hata Detayı: $_adLoadError\n\nBu bilgi sadece geliştirme/test aşamasında gösterilmektedir.",
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? Colors.white70 : Colors.red[800],
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isBannerAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? const Color(0xFF131D31) : Colors.white,
      child: Container(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble() + 16,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}

// Background painter for the top-right header motif
class SubtleMandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
          .withOpacity(0.12) // Soft gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles
    canvas.drawCircle(center, 25, paint);
    canvas.drawCircle(center, 50, paint);
    canvas.drawCircle(center, 75, paint);
    canvas.drawCircle(center, 100, paint);

    // Draw simple stars
    _drawStar(canvas, center, 40, 8, paint);
    _drawStar(canvas, center, 65, 8, paint);
    _drawStar(canvas, center, 90, 16, paint);
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    int points,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius = i % 2 == 0 ? radius : radius * 0.75;
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}