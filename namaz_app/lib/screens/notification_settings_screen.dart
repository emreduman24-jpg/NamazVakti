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
  // Style constants
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
      _soundEnabled = prefs.getBool('notification_sound_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
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
        print("Error rescheduling alarms on save: $e");
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
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
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTimingSection(),
                      const SizedBox(height: 16),
                      _buildPrayerTimesSection(),
                      const SizedBox(height: 16),
                      _buildSoundSection(),
                      const SizedBox(height: 16),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 24),
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

  Widget _buildTopBar() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: dark ? Colors.white : Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Bildirim Ayarları',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildTimingSection() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: dark ? const Color(0xFF131D31) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bildirim Zamanı',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Namaz vakti bildirimlerinin ne zaman gönderileceğini seçin',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('15 dakika önce', 15),
            _buildRadioOption('10 dakika önce', 10),
            _buildRadioOption('5 dakika önce', 5),
            _buildRadioOption('Tam vaktinde', 0),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, int value) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return RadioListTile<int>(
      title: Text(label, style: TextStyle(fontSize: 14, color: dark ? Colors.white : Colors.black87)),
      value: value,
      groupValue: _timingOffset,
      activeColor: _primaryGreen,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() => _timingOffset = newValue);
        }
      },
    );
  }

  Widget _buildPrayerTimesSection() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: dark ? const Color(0xFF131D31) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Namaz Vakitleri',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hangi vakitler için bildirim almak istediğinizi seçin',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildCheckbox('İmsak', _imsak, (v) => setState(() => _imsak = v!)),
            _buildCheckbox('Sabah', _sabah, (v) => setState(() => _sabah = v!)),
            _buildCheckbox('Öğle', _ogle, (v) => setState(() => _ogle = v!)),
            _buildCheckbox(
              'İkindi',
              _ikindi,
              (v) => setState(() => _ikindi = v!),
            ),
            _buildCheckbox('Akşam', _aksam, (v) => setState(() => _aksam = v!)),
            _buildCheckbox('Yatsı', _yatsi, (v) => setState(() => _yatsi = v!)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return CheckboxListTile(
      title: Text(label, style: TextStyle(fontSize: 14, color: dark ? Colors.white : Colors.black87)),
      value: value,
      activeColor: _primaryGreen,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }

  Widget _buildSoundSection() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: dark ? const Color(0xFF16251C) : const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ezan Sesi',
                        style: TextStyle(
                          color: dark ? const Color(0xFF27A770) : _primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bildirimle birlikte ezan sesi çalınır',
                        style: TextStyle(color: dark ? Colors.white70 : Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _soundEnabled,
                  activeThumbColor: _primaryGreen,
                  onChanged: (bool value) {
                    setState(() => _soundEnabled = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  NotificationService().playTestNotification();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: dark ? const Color(0xFF27A770) : _primaryGreen,
                  side: BorderSide(color: dark ? const Color(0xFF27A770) : _primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Sesi Dinle',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    const infoItems = [
      'Bildirimlerin zamanında gelmesi için uygulamanın arka planda çalışmasına izin verilmelidir',
      'Pil tasarrufu modundan muaf tutulması, bildirimlerin kesintisiz çalışmasını sağlar',
      'Seçtiğiniz ayarlar anında aktif olur ve bir sonraki namaz vaktinde bildirim alırsınız',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bilgilendirme',
          style: TextStyle(
            color: _primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...infoItems.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Icon(Icons.circle, size: 8, color: _primaryGreen),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? _primaryGreen : _darkGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Kaydet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
