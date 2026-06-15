import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../data/prayer_repository.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Style colors
  static const Color _primaryGreen = Color(0xFF27A770);
  static const Color _darkGreen = Color(0xFF1E5E43);
  static const Color _background = Color(0xFFF3F8F5);

  // State
  int _timingOffset = 0;
  bool _imsak = true;
  bool _sabah = true;
  bool _ogle = true;
  bool _ikindi = true;
  bool _aksam = true;
  bool _yatsi = true;
  bool _soundEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermissions();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timingOffset = prefs.getInt('notification_timing_offset') ?? 0;
      _imsak = prefs.getBool('notification_prayer_imsak') ?? true;
      _sabah = prefs.getBool('notification_prayer_sabah') ?? true;
      _ogle = prefs.getBool('notification_prayer_ogle') ?? true;
      _ikindi = prefs.getBool('notification_prayer_ikindi') ?? true;
      _aksam = prefs.getBool('notification_prayer_aksam') ?? true;
      _yatsi = prefs.getBool('notification_prayer_yatsi') ?? true;
      _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettingsSilently() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_timing_offset', _timingOffset);
    await prefs.setBool('notification_prayer_imsak', _imsak);
    await prefs.setBool('notification_prayer_sabah', _sabah);
    await prefs.setBool('notification_prayer_ogle', _ogle);
    await prefs.setBool('notification_prayer_ikindi', _ikindi);
    await prefs.setBool('notification_prayer_aksam', _aksam);
    await prefs.setBool('notification_prayer_yatsi', _yatsi);
    await prefs.setBool('notification_sound_enabled', _soundEnabled);

    // Reschedule alarms immediately with the updated preferences
    final String? districtId = prefs.getString('selected_district_id');
    if (districtId != null) {
      try {
        final times = await PrayerRepository().getPrayerTimes(districtId);
        if (times.isNotEmpty) {
          await NotificationService().schedulePrayerAlarms(times);
        }
      } catch (e) {
        debugPrint("Error rescheduling alarms on save: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = dark ? const Color(0xFF0A1220) : _background;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator(color: _primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Bildirim Ayarları",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF0A1220) : _darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // 1. Timing Option Section
                      _buildTimingSection(dark),
                      const SizedBox(height: 16),
                      
                      // 2. Prayer Switches Card
                      _buildPrayerTimesSection(dark),
                      const SizedBox(height: 16),
                      
                      // 3. Ezan Sound Configuration
                      _buildSoundSection(dark),
                      const SizedBox(height: 16),
                      
                      // 4. Alert/Info Banner
                      _buildInfoSection(dark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'BİLDİRİM ZAMANI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white54 : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hatırlatma Zamanı',
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF1E5E43),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Namaz vakti bildirimlerinin ne kadar süre önce gönderileceğini seçin:',
                style: TextStyle(color: dark ? Colors.white60 : Colors.grey[600], fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              
              _buildTimingCard('15 dakika önce', 15, Icons.timer_outlined, _primaryGreen, dark),
              _buildTimingCard('10 dakika önce', 10, Icons.timer_outlined, _primaryGreen, dark),
              _buildTimingCard('5 dakika önce', 5, Icons.timer_outlined, _primaryGreen, dark),
              _buildTimingCard('Tam vaktinde', 0, Icons.timer_outlined, _primaryGreen, dark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard(String label, int value, IconData icon, Color color, bool dark) {
    final bool isSelected = _timingOffset == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _timingOffset = value);
          _saveSettingsSilently();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.12)
              : (dark ? Colors.white.withOpacity(0.03) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : (dark ? Colors.white10 : Colors.grey[300]!),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: isSelected ? color : (dark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20)
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: dark ? Colors.white30 : Colors.grey[400]!, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
          child: Text(
            'VAKİT LİSTESİ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white54 : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPrayerSwitchRow(
                title: 'İmsak',
                value: _imsak,
                onChanged: (v) {
                  setState(() => _imsak = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFF3F51B5), const Color(0xFF9C27B0)],
                icon: Icons.nights_stay_rounded,
              ),
              _buildPrayerSwitchRow(
                title: 'Sabah',
                value: _sabah,
                onChanged: (v) {
                  setState(() => _sabah = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFFEC407A), const Color(0xFFFF7043)],
                icon: Icons.wb_twilight_rounded,
              ),
              _buildPrayerSwitchRow(
                title: 'Öğle',
                value: _ogle,
                onChanged: (v) {
                  setState(() => _ogle = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFFFFB300), const Color(0xFFF57C00)],
                icon: Icons.wb_sunny_rounded,
              ),
              _buildPrayerSwitchRow(
                title: 'İkindi',
                value: _ikindi,
                onChanged: (v) {
                  setState(() => _ikindi = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFFE64A19), const Color(0xFF8D6E63)],
                icon: Icons.filter_drama_rounded,
              ),
              _buildPrayerSwitchRow(
                title: 'Akşam',
                value: _aksam,
                onChanged: (v) {
                  setState(() => _aksam = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFFD84315), const Color(0xFF37474F)],
                icon: Icons.brightness_medium_rounded,
              ),
              _buildPrayerSwitchRow(
                title: 'Yatsı',
                value: _yatsi,
                onChanged: (v) {
                  setState(() => _yatsi = v);
                  _saveSettingsSilently();
                },
                gradientColors: [const Color(0xFF1A237E), const Color(0xFF0D47A1)],
                icon: Icons.brightness_2_rounded,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required List<Color> gradientColors,
    required IconData icon,
    bool isLast = false,
  }) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Styled Gradient Icon Container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                activeColor: _primaryGreen,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            color: dark ? Colors.white.withOpacity(0.05) : const Color(0xFFE0EBE4),
          ),
      ],
    );
  }

  Widget _buildSoundSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
          child: Text(
            'SES AYARLARI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white54 : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2F1), Color(0xFF80CBC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.volume_up_rounded, color: Color(0xFF00796B), size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ezan Sesi',
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vakit geldiğinde ezan sesiyle uyarılın',
                      style: TextStyle(color: dark ? Colors.white60 : Colors.grey[600], fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _soundEnabled,
                activeColor: _primaryGreen,
                onChanged: (bool value) {
                  setState(() => _soundEnabled = value);
                  _saveSettingsSilently();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool dark) {
    const infoItems = [
      'Bildirimlerin tam vaktinde ulaşabilmesi için uygulamanın arka planda çalışmasına izin verilmelidir.',
      'Seçtiğiniz ayarlar anında kaydedilir ve bir sonraki namaz vaktinde geçerli olur.',
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFFD4AF37).withOpacity(0.06) : const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(dark ? 0.15 : 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFFB8860B), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Önemli Bilgilendirme',
                  style: TextStyle(
                    color: Color(0xFFB8860B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...infoItems.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0, right: 6.0),
                          child: Icon(Icons.circle, size: 5, color: Color(0xFFB8860B)),
                        ),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: dark ? Colors.white60 : Colors.grey[700],
                              fontSize: 11.5,
                              height: 1.3,
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
        ],
      ),
    );
  }
}
