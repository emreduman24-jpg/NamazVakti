import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../data/prayer_repository.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';
import 'premium_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onLocationReset;
  final VoidCallback? onLocationChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocationReset,
    this.onLocationChanged,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final PrayerRepository _repository = PrayerRepository();
  final NotificationService _notificationService = NotificationService();

  String _themeMode = 'light';
  Map<String, String?> _location = {};
  bool _loading = true;
  String _userName = '';
  String _userGender = 'erkek';
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _loading = true);
    }
    final theme = await _repository.getThemeMode();
    final loc = await _repository.getSavedLocation();
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final gender = prefs.getString('user_gender') ?? 'erkek';
    final isPremium = prefs.getBool('is_premium') ?? false;
    setState(() {
      _themeMode = theme;
      _location = loc;
      _userName = name;
      _userGender = gender;
      _isPremium = isPremium;
      _loading = false;
    });
  }

  String _themeDisplayText() {
    switch (_themeMode) {
      case 'dark':
        return 'Karanlık';
      case 'system':
        return 'Sistem';
      case 'light':
      default:
        return 'Aydınlık';
    }
  }

  Future<void> _showThemeDialog() async {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Widget buildThemeOption(String value, String title, IconData icon, Color color) {
            final isSelected = _themeMode == value;
            return GestureDetector(
              onTap: () => Navigator.pop(context, value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withOpacity(0.12)
                      : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : (dark ? Colors.white10 : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : (dark ? Colors.white10 : Colors.grey[200]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : (dark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: color, size: 22),
                  ],
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
                width: 1.2,
              ),
            ),
            title: Text(
              'Tema Ayarları',
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF1E5E43),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                buildThemeOption('light', 'Aydınlık Tema', Icons.wb_sunny_rounded, const Color(0xFF27A770)),
                buildThemeOption('dark', 'Karanlık Tema', Icons.nights_stay_rounded, const Color(0xFF2D9CDB)),
                buildThemeOption('system', 'Sistem Varsayılanı', Icons.settings_suggest_rounded, Colors.grey),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kapat', style: TextStyle(color: dark ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      await _repository.setThemeMode(result);
      setState(() => _themeMode = result);
      widget.onThemeChanged();
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: success ? const Color(0xFF27A770) : Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
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
              color: dark ? const Color(0xFF131D31).withOpacity(0.95) : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
                width: 1.2,
              ),
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
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF1E5E43),
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

  Future<void> _autoDetectAndSaveLocation() async {
    _showLoadingDialog("Konumunuz GPS ile tespit ediliyor...");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) Navigator.pop(context);
        _showSnackBar("Lütfen telefonunuzun konum servisini (GPS) açın.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) Navigator.pop(context);
          _showSnackBar("Konum izni verilmedi.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.pop(context);
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
          
          Map<String, dynamic> matchedDistrict = <String, dynamic>{};
          final String normalizedCityName = normalizeString(cityName);
          
          final String? locality = geoData['locality'] != null ? normalizeString(geoData['locality']) : null;
          if (locality != null && locality != normalizedCityName) {
            matchedDistrict = districts.firstWhere(
              (dist) => normalizeString(dist['IlceAdi'] ?? '') == locality,
              orElse: () => <String, dynamic>{},
            );
          }
          
          if (matchedDistrict.isEmpty) {
            matchedDistrict = districts.firstWhere(
              (dist) => geoNames.contains(normalizeString(dist['IlceAdi'] ?? '')) &&
                        normalizeString(dist['IlceAdi'] ?? '') != normalizedCityName,
              orElse: () => <String, dynamic>{},
            );
          }
          
          if (matchedDistrict.isEmpty) {
            matchedDistrict = districts.firstWhere(
              (dist) => geoNames.contains(normalizeString(dist['IlceAdi'] ?? '')),
              orElse: () => <String, dynamic>{},
            );
          }

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

            if (mounted) Navigator.pop(context);
            _showSnackBar("Konum GPS ile güncellendi: $cityName/$districtName", success: true);
            await loadSettings(showLoading: false);
            widget.onLocationChanged?.call();
            return;
          }
        }
      }
      
      if (mounted) Navigator.pop(context);
      _showSnackBar("Konum otomatik eşleşmedi. Lütfen listeden manuel seçin.");
    } catch (e) {
      debugPrint("GPS auto-detect error: $e");
      if (mounted) Navigator.pop(context);
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

  Future<void> _showLocationDialog() async {
    final loc = await _repository.getSavedLocation();
    setState(() {
      _location = loc;
    });
    final String rawCity = loc['cityName'] ?? 'Bilinmiyor';
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

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (citiesList.isEmpty && loadingCities) {
            _repository.getCities().then((cities) {
              if (context.mounted) {
                setDialogState(() {
                  citiesList = cities;
                  loadingCities = false;
                });
              }
            }).catchError((e) {
              if (context.mounted) {
                setDialogState(() {
                  loadingCities = false;
                });
              }
            });
          }

          return AlertDialog(
            backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
                width: 1.2,
              ),
            ),
            title: Text(
              'Konum Ayarları',
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF1E5E43),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Active Location Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27A770).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF27A770).withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27A770).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: Color(0xFF27A770), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mevcut Konum',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: dark ? Colors.white60 : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$city / $district',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: dark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Konumunuzu değiştirmek için GPS ile otomatik algılayabilir veya listeden manuel olarak seçebilirsiniz.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: dark ? Colors.white60 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (savingLocation)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: Color(0xFF27A770)),
                      ),
                    )
                  else ...[
                    // GPS Button with gradient background
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF27A770).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.gps_fixed_rounded, size: 18, color: Color(0xFFD4AF37)),
                        label: const Text(
                          'Cihaz Konumunu Kullan (GPS)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await _autoDetectAndSaveLocation();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'VEYA MANUEL SEÇİN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: dark ? Colors.white38 : Colors.grey[500],
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // City Dropdown
                    if (loadingCities)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(color: Color(0xFF27A770)),
                        ),
                      )
                    else
                      DropdownButtonFormField<Map<String, dynamic>>(
                        dropdownColor: dark ? const Color(0xFF131D31) : Colors.white,
                        style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
                        icon: Icon(Icons.arrow_drop_down_circle_outlined, color: dark ? Colors.white60 : Colors.grey),
                        decoration: InputDecoration(
                          labelText: "Şehir Seçin",
                          labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.grey[700]),
                          filled: true,
                          fillColor: dark ? Colors.white.withOpacity(0.04) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF27A770), width: 1.5),
                          ),
                          prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF27A770), size: 20),
                        ),
                        value: selectedCity,
                        items: citiesList.map((c) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: c,
                            child: Text(c['SehirAdi'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          setDialogState(() {
                            selectedCity = val;
                            selectedDistrict = null;
                            loadingDistricts = true;
                          });
                          if (val != null) {
                            final dists = await _repository.getDistricts(val['SehirID'].toString());
                            setDialogState(() {
                              districtsList = dists;
                              loadingDistricts = false;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 12),

                    // District Dropdown
                    if (selectedCity != null) ...[
                      if (loadingDistricts)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(color: Color(0xFF27A770)),
                          ),
                        )
                      else
                        DropdownButtonFormField<Map<String, dynamic>>(
                          dropdownColor: dark ? const Color(0xFF131D31) : Colors.white,
                          style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
                          icon: Icon(Icons.arrow_drop_down_circle_outlined, color: dark ? Colors.white60 : Colors.grey),
                          decoration: InputDecoration(
                            labelText: "İlçe Seçin",
                            labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.grey[700]),
                            filled: true,
                            fillColor: dark ? Colors.white.withOpacity(0.04) : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF27A770), width: 1.5),
                            ),
                            prefixIcon: const Icon(Icons.map_rounded, color: Color(0xFF27A770), size: 20),
                          ),
                          value: selectedDistrict,
                          items: districtsList.map((d) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: d,
                              child: Text(d['IlceAdi'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedDistrict = val;
                            });
                          },
                        ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal', style: TextStyle(color: dark ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A770),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: (selectedCity == null || selectedDistrict == null || savingLocation)
                        ? null
                        : () async {
                            setDialogState(() => savingLocation = true);
                            try {
                              final String cityName = selectedCity!['SehirAdi'];
                              final String cityId = selectedCity!['SehirID'].toString();
                              final String districtName = selectedDistrict!['IlceAdi'];
                              final String districtId = selectedDistrict!['IlceID'].toString();

                              final times = await _repository.getPrayerTimes(districtId, forceRefresh: true);
                              await _repository.saveLocation(cityName, cityId, districtName, districtId);
                              await _notificationService.schedulePrayerAlarms(times);

                              await loadSettings(showLoading: false);

                              if (context.mounted) {
                                Navigator.pop(context);
                                _showSnackBar("Konum başarıyla güncellendi: $cityName / $districtName", success: true);
                              }
                              widget.onLocationChanged?.call();
                            } catch (e) {
                              setDialogState(() => savingLocation = false);
                              _showSnackBar("Konum güncellenirken hata oluştu.");
                            }
                          },
                    child: const Text('Konumu Güncelle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }





  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Direct launch is more robust in modern Flutter/Android versions and avoids query blockages
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar("Bağlantı açılamadı: $urlString");
        }
      }
    } catch (e) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar("Bağlantı açılamadı: $urlString");
        }
      } catch (_) {
        _showSnackBar("Hata oluştu: $e");
      }
    }
  }

  Future<void> _shareApp() async {
    await Clipboard.setData(const ClipboardData(
      text: "Vakit Dua: Namaz & Kıble uygulamasını indir: https://www.vakitdua.com.tr",
    ));
    _showSnackBar("Uygulama indirme bağlantısı kopyalandı! Dilediğiniz yerde paylaşabilirsiniz.", success: true);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    
    if (_loading) {
      return Scaffold(
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF27A770)),
        ),
      );
    }

    final String displayCity = _formatTurkishCity(_location['cityName'] ?? 'Konum Seçilmedi');
    final String rawDistrict = _location['districtName'] ?? '';
    final String displayDistrict = rawDistrict.toLowerCase() == _location['cityName']?.toLowerCase()
        ? 'Merkez'
        : _formatTurkishDistrict(rawDistrict);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: const Text(
          "Ayarlar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 1. Redesigned User Profile Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                    await loadSettings(showLoading: false);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF27A770).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _userGender == 'kadin' ? '👩' : '👨',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hayırlı Günler,",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? Colors.white60 : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _userName.isNotEmpty ? _userName : "Kullanıcı",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                                      ),
                                    ),
                                  ),
                                  if (_isPremium) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFD4AF37), Color(0xFF996515)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white24, width: 0.8),
                                      ),
                                      child: const Text(
                                        "PRO",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 12,
                                    color: dark ? Colors.white38 : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "Profili Düzenlemek İçin Dokunun",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: dark ? Colors.white38 : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: dark ? Colors.white38 : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Premium Promo Card
              _isPremium
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF131D31), Color(0xFF1E3A34)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFD4AF37).withOpacity(0.05),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                                      ),
                                      child: const Icon(
                                        Icons.verified_user_rounded,
                                        color: Color(0xFFD4AF37),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Namaz Vakti Pro Aktif",
                                            style: TextStyle(
                                              color: Color(0xFFD4AF37),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Reklamsız kullanım ve tüm özelliklere sınırsız erişiminiz aktif. Destekleriniz için teşekkür ederiz.",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.85),
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
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
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFF996515)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF996515).withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Subtle golden dust visual decoration
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    // Crown Icon inside bubble
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Premium Üye Olun",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Reklamsız kullanım ve tüm içeriklere sınırsız erişim elde edin.",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF996515),
                                              elevation: 2,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const PremiumScreen(),
                                                ),
                                              );
                                              loadSettings(showLoading: false);
                                            },
                                            child: const Text(
                                              "Şimdi Keşfet",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                            ),
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
                    ),

              // 3. Grouped Settings Categories
              _buildCardGroup(
                title: "VAKİT & KONUM AYARLARI",
                children: [
                  _buildSettingRow(
                    icon: Icons.location_on_rounded,
                    title: "Lokasyonlarım",
                    subtitle: displayDistrict.isNotEmpty ? "$displayCity / $displayDistrict" : displayCity,
                    gradientColors: [const Color(0xFF27A770), const Color(0xFF1E5E43)],
                    onTap: _showLocationDialog,
                  ),
                  _buildSettingRow(
                    icon: Icons.notifications_active_rounded,
                    title: "Bildirim Ayarları",
                    subtitle: "Ezan vakti alarmları ve bildirimleri",
                    gradientColors: [const Color(0xFF6F52ED), const Color(0xFF8B73FF)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingRow(
                    icon: Icons.access_time_filled_rounded,
                    title: "Kerahat Vakti Hatırlatıcısı",
                    subtitle: "Kerahat vakti kuralları hakkında bilgi",
                    gradientColors: [const Color(0xFFF2994A), const Color(0xFFF2C94C)],
                    onTap: () {
                      _showSnackBar(
                        'Kerahat vakti: Güneş doğduktan sonraki 45 dakika ve öğle vaktinden önceki 45 dakikalık süredir.',
                      );
                    },
                    isLast: true,
                  ),
                ],
              ),

              _buildCardGroup(
                title: "UYGULAMA ÖZELLEŞTİRME",
                children: [
                  _buildSettingRow(
                    icon: Icons.palette_rounded,
                    title: "Tema Ayarları",
                    subtitle: "Görünüm modu: ${_themeDisplayText()}",
                    gradientColors: [const Color(0xFF2D9CDB), const Color(0xFF56CCF2)],
                    onTap: _showThemeDialog,
                  ),
                  _buildSettingRow(
                    icon: Icons.language_rounded,
                    title: "Uygulama Dili",
                    subtitle: "Aktif dil: Türkçe",
                    gradientColors: [const Color(0xFF2F80ED), const Color(0xFF00C9FF)],
                    trailing: const Text(
                      'Türkçe',
                      style: TextStyle(
                        color: Color(0xFF27A770),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      _showSnackBar('Dil değişikliği seçeneği yakında eklenecektir.');
                    },
                    isLast: true,
                  ),
                ],
              ),

              if (!_isPremium)
                _buildCardGroup(
                  title: "DESTEK & HESAP",
                  children: [
                    _buildSettingRow(
                      icon: Icons.workspace_premium_rounded,
                      title: "Reklamlardan Kurtul",
                      subtitle: "Sadece 30 saniyenizi ayırarak destek olun",
                      gradientColors: [const Color(0xFFE2B93C), const Color(0xFFD4AF37)],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumScreen(),
                          ),
                        );
                        loadSettings(showLoading: false);
                      },
                      isLast: true,
                    ),
                  ],
                ),

              // 4. About Section Card Group
              _buildCardGroup(
                title: "HAKKINDA",
                children: [
                  _buildSettingRow(
                    icon: Icons.star_rounded,
                    title: "Değerlendir",
                    subtitle: "Uygulamamıza puan verin",
                    gradientColors: [const Color(0xFFFFB300), const Color(0xFFF57C00)],
                    onTap: () {
                      final String storeUrl = Platform.isIOS
                          ? "https://apps.apple.com/app/id6670732890"
                          : "https://play.google.com/store/apps/details?id=com.emreduman.namazvakitleri";
                      _launchURL(storeUrl);
                    },
                  ),
                  _buildSettingRow(
                    icon: Icons.share_rounded,
                    title: "Uygulamayı Paylaş",
                    subtitle: "Sevdiklerinizle paylaşın",
                    gradientColors: [const Color(0xFF2D9CDB), const Color(0xFF2F80ED)],
                    onTap: _shareApp,
                  ),
                  _buildSettingRow(
                    icon: Icons.mail_rounded,
                    title: "Bize Ulaş",
                    subtitle: "Görüş ve önerilerinizi iletin",
                    gradientColors: [const Color(0xFF00C9FF), const Color(0xFF00796B)],
                    onTap: () => _launchURL("mailto:destek@vakitdua.com.tr?subject=Vakit%20Dua%20Geri%20Bildirim"),
                  ),
                  _buildSettingRow(
                    icon: Icons.language_rounded,
                    title: "Web Sitesi",
                    subtitle: "Resmi internet sitemizi ziyaret edin",
                    gradientColors: [const Color(0xFF27A770), const Color(0xFF1E5E43)],
                    onTap: () => _launchURL("https://www.vakitdua.com.tr"),
                  ),
                  _buildSettingRow(
                    icon: Icons.security_rounded,
                    title: "Gizlilik Politikası",
                    subtitle: "Veri politikası ve koşullar",
                    gradientColors: [const Color(0xFF80CBC4), const Color(0xFF00796B)],
                    onTap: () => _launchURL("https://www.vakitdua.com.tr/gizlilik-politikasi"),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Version Info
              const Text(
                'Sürüm v4.7.4',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps children setting elements into a rounded, themed card container
  Widget _buildCardGroup({required List<Widget> children, required String title}) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 8.0, top: 20.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white54 : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark ? Colors.white.withOpacity(0.05) : const Color(0xFFE0EBE4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.15 : 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a single stylized setting row with rounded icon container, gradient, text elements and chevron indicator
  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Styled Gradient Icon Container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                // Text details block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: dark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trailing indicator or widget
                if (trailing != null) 
                  trailing
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: dark ? Colors.white24 : Colors.grey[400],
                    size: 14,
                  ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              indent: 70, // Align with text start, skipping the icon
              color: dark ? Colors.white.withOpacity(0.05) : const Color(0xFFE0EBE4),
            ),
        ],
      ),
    );
  }
}
