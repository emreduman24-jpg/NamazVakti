import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../data/prayer_repository.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';
import 'premium_screen.dart';

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
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PrayerRepository _repository = PrayerRepository();
  final NotificationService _notificationService = NotificationService();

  String _themeMode = 'light';
  Map<String, String?> _location = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final theme = await _repository.getThemeMode();
    final loc = await _repository.getSavedLocation();
    setState(() {
      _themeMode = theme;
      _location = loc;
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
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Aydınlık Tema'),
              value: 'light',
              groupValue: _themeMode,
              activeColor: const Color(0xFF27A770),
              onChanged: (val) => Navigator.pop(context, val),
            ),
            RadioListTile<String>(
              title: const Text('Karanlık Tema'),
              value: 'dark',
              groupValue: _themeMode,
              activeColor: const Color(0xFF27A770),
              onChanged: (val) => Navigator.pop(context, val),
            ),
            RadioListTile<String>(
              title: const Text('Sistem Varsayılanı'),
              value: 'system',
              groupValue: _themeMode,
              activeColor: const Color(0xFF27A770),
              onChanged: (val) => Navigator.pop(context, val),
            ),
          ],
        ),
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
        content: Text(message),
        backgroundColor: success ? const Color(0xFF27A770) : Colors.redAccent,
        duration: const Duration(seconds: 3),
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
    setState(() {
      _loading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        _showSnackBar("Lütfen telefonunuzun konum servisini (GPS) açın.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loading = false);
          _showSnackBar("Konum izni verilmedi.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
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
            await _notificationService.schedulePrayerAlarms(times);

            _showSnackBar("Konum GPS ile güncellendi: $cityName/$districtName", success: true);
            await _loadSettings();
            widget.onLocationChanged?.call();
            return;
          }
        }
      }
      
      setState(() => _loading = false);
      _showSnackBar("Konum otomatik eşleşmedi. Lütfen listeden manuel seçin.");
    } catch (e) {
      debugPrint("GPS auto-detect error: $e");
      setState(() => _loading = false);
      _showSnackBar("Konum alınırken hata oluştu. Lütfen listeden manuel seçin.");
    }
  }

  Future<void> _showLocationDialog() async {
    final city = _location['cityName'] ?? 'Bilinmiyor';
    final district = _location['districtName'] ?? 'Bilinmiyor';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lokasyonlarım'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF27A770)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$city / $district',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Konumunuzu otomatik olarak güncelleyebilir veya manuel olarak değiştirebilirsiniz.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat', style: TextStyle(color: Colors.grey)),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5E43),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.gps_fixed, size: 14),
                    label: const Text('Otomatik Bul', style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _autoDetectAndSaveLocation();
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A770),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _repository.clearLocation();
                      await _notificationService.cancelAllAlarms();
                      widget.onLocationReset();
                    },
                    child: const Text('Manuel Seç', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF27A770)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header - "Ayarlar" title + close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 26,
                      ),
                      onPressed: () {
                        // Navigate back to home tab
                        Navigator.of(context).maybePop();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable menu items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profilim
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.person,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Profilim',
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final String currentName = prefs.getString('user_name') ?? '';
                        final String currentGender = prefs.getString('user_gender') ?? 'erkek';
                        
                        final TextEditingController nameController = TextEditingController(text: currentName);
                        String selectedGender = currentGender;

                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: const Text('Profilimi Düzenle'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Adınız Soyadınız',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Cinsiyetiniz:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: selectedGender == 'erkek' ? const Color(0xFF27A770) : Colors.grey[200],
                                              foregroundColor: selectedGender == 'erkek' ? Colors.white : Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              setDialogState(() {
                                                selectedGender = 'erkek';
                                              });
                                            },
                                            child: const Text('👨 Erkek'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: selectedGender == 'kadin' ? const Color(0xFFE5A93B) : Colors.grey[200],
                                              foregroundColor: selectedGender == 'kadin' ? Colors.white : Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              setDialogState(() {
                                                selectedGender = 'kadin';
                                              });
                                            },
                                            child: const Text('👩 Kadın'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Kapat', style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF27A770),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final String name = nameController.text.trim();
                                      if (name.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Lütfen adınızı giriniz.')),
                                        );
                                        return;
                                      }
                                      await prefs.setString('user_name', name);
                                      await prefs.setString('user_gender', selectedGender);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Profil bilgileri başarıyla güncellendi.')),
                                        );
                                      }
                                    },
                                    child: const Text('Kaydet'),
                                  ),
                                ],
                              );
                            }
                          ),
                        );
                      },
                    ),

                    // Çıkış Yap
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Oturum yönetimi yakında eklenecektir.',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 8.0,
                          ),
                          child: Row(
                            children: [
                              _buildCircleIcon(
                                Icons.logout,
                                const Color(0xFFCDDC39),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Çıkış Yap',
                                style: TextStyle(
                                  color: Color(0xFF27A770),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _buildSectionDivider(),

                    // Premium Ol
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.workspace_premium,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Premium Ol',
                      subtitle:
                          'Tüm özelliklere erişin, daha fazla müslümana ulaşmamıza yardım et!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumScreen(),
                          ),
                        );
                      },
                    ),

                    // Reklamlardan ücretsiz kurtul!
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.star,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Reklamlardan ücretsiz kurtul!',
                      subtitle: 'Sadece 30 saniyenizi ayırın.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumScreen(),
                          ),
                        );
                      },
                    ),

                    _buildSectionDivider(),

                    // Uygulama Dili
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.language,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Uygulama Dili',
                      trailing: const Text(
                        'Türkçe',
                        style: TextStyle(
                          color: Color(0xFF27A770),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Dil değişikliği yakında eklenecektir.',
                            ),
                          ),
                        );
                      },
                    ),

                    // Bildirim Ayarları
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.notifications_outlined,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Bildirim Ayarları',
                      subtitle: 'Ezan vakti bildirimlerini yönet',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),

                    // Lokasyonlarım
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.location_on_outlined,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Lokasyonlarım',
                      onTap: _showLocationDialog,
                    ),

                    // Tema Ayarları
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.palette_outlined,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Tema Ayarları',
                      trailing: Text(
                        _themeDisplayText(),
                        style: const TextStyle(
                          color: Color(0xFF27A770),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: _showThemeDialog,
                    ),

                    // Kerahat Vakti
                    _buildMenuItem(
                      icon: _buildCircleIcon(
                        Icons.timer_outlined,
                        const Color(0xFFCDDC39),
                      ),
                      title: 'Kerahat Vakti',
                      trailing: const Text(
                        '45 dk',
                        style: TextStyle(
                          color: Color(0xFF27A770),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Kerahat vakti: Güneş doğduktan sonraki 45 dakika ve öğle vaktinden önceki 45 dakika.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Gizlilik Politikası
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gizlilik Politikası sayfası yakında eklenecektir.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Gizlilik Politikası',
                        style: TextStyle(
                          color: Color(0xFF27A770),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF27A770),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Version
                    const Text(
                      'v4.7.4',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a circular icon widget matching the screenshot style (yellow-green circle with icon)
  Widget _buildCircleIcon(IconData icon, Color bgColor) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor.withOpacity(0.5), width: 2),
      ),
      child: Icon(icon, color: const Color(0xFF689F38), size: 22),
    );
  }

  /// Builds a single menu item row
  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  /// Builds a horizontal section divider
  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }
}
