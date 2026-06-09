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