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