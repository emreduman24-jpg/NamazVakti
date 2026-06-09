"  // Dynamic Prayer Times Metadata for Premium Icons and Colors
  static const List<Map<String, dynamic>> vakitMeta = [
    {'name': 'İmsak', 'key': 'Imsak', 'icon': Icons.nights_stay, 'color': Color(0xFF5C6BC0)},
    {'name': 'Güneş', 'key': 'Gunes', 'icon': Icons.wb_twilight, 'color': Color(0xFFFFB300)},
    {'name': 'Öğle', 'key': 'Ogle', 'icon': Icons.wb_sunny, 'color': Color(0xFFF57C00)},
    {'name': 'İkindi', 'key': 'Ikindi', 'icon': Icons.wb_sunny_outlined, 'color': Color(0xFF8D6E63)},
    {'name': 'Akşam', 'key': 'Aksam', 'icon': Icons.flare, 'color': Color(0xFFFF7043)},
    {'name': 'Yatsı', 'key': 'Yatsi', 'icon': Icons.brightness_3, 'color': Color(0xFF3F51B5)},
  ];

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
                  color: _tex
<truncated 35952 bytes>