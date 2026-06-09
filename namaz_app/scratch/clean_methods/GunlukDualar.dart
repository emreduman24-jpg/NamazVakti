Widget _buildGunlukDualar() {
    final totalKuran = KURAN_DUALARI.length;
    final totalHadis = HADIS_DUALARI.length;
        final dua = DUALAR[index];
    final rawList = _dualarTab == 0 ? KURAN_DUALARI : HADIS_DUALARI;
    final filteredList = rawList.where((dua) {
      final matchesSearch = _dualarSearchQuery.isEmpty ||
          _normalize(dua['ad'] ?? '').contains(_normalize(_dualarSearchQuery)) ||
          _normalize(dua['sure'] ?? '').contains(_normalize(_dualarSearchQuery)) ||
          _normalize(dua['anlam'] ?? '').contains(_normalize(_dualarSearchQuery));
          child: Padding(
      final matchesFavorite = !_showOnlyFavorites || _favoriteDualar.contains(dua['id']);
            child: Column(
      return matchesSearch && matchesFavorite;
    }).toList();
                Text(
    final Map<String, List<Map<String, String>>> grouped = {
      'sabah_aksam': [],
      'namaz': [],
      'yemek': [],
      'uyku': [],
      'yolculuk': [],
      'genel': [],
    };
    for (var dua in filteredList) {
    for (var dua in filteredList) {
      final cat = dua['kategori'] ?? 'genel';
      grouped[cat]?.add(dua);
    }
    final categories = [
    final categories = [
      {'key': 'sabah_aksam', 'title': 'Sabah & Akşam Ezkarı', 'emoji': '☀️'},
      {'key': 'namaz', 'title': 'Namaz Duaları', 'emoji': '🕌'},
      {'key': 'yemek', 'title': 'Yemek Duaları', 'emoji': '🍴'},
      {'key': 'uyku', 'title': 'Uyku Duaları', 'emoji': '🌙'},
      {'key': 'yolculuk', 'title': 'Yolculuk Duaları', 'emoji': '🚗'},
      {'key': 'genel', 'title': 'Genel Dualar', 'emoji': '✨'},
    ];
                SizedBox(height: 8),
    bool isPlaying(String url) => _currentAudioUrl == url && _playerState == PlayerState.playing;
      final isSelected = _dualarTab == index;
    Widget buildSegmentButton(int index, String label, int count) {
      final isSelected = _dualarTab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _dualarTab = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDeco
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,


              border: isSelected
                  ? Border.all(color: const Color(0xFFC19E67), width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFC19E67)
                        : (_isDark ? Colors.grey : Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC19E67).withOpacity(0.15)
                        : (_isDark ? Colors.grey[850] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFC19E67)
                          : (_isDark ? Colors.grey : Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    ]);
    final tabRow = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1E1613) : const Color(0xFFEDF2F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          buildSegmentButton(0, "Kur'an Duaları", totalKuran),
          buildSegmentButton(1, "Hadis Duaları", totalHadis),
        ],
      ),
    );

    List<Widget> items = [];
    bool hasAnyItems = false;
    for (var cat in categories) {
      final key = cat['key']!;
      final list = grouped[key] ?? [];
      if (list.isEmpty) continue;

      hasAnyItems = true;

      // Section Header
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Row(
            children: [
              Text(
                "${cat['emoji']} ${cat['title']}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC19E67),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.
      "Med Harfleri (Uzatma): Elif (ا), Vav (و), Ya (ي) harfleridir. Önündeki harfi uzatarak okuturlar.",
      "Tenvin ve Sakin Nun Kuralları: Sakin nun (نْ) veya tenvin (ً ٍ ٌ) işaretlerinden sonra gelen harflere göre şekillenir.",
      "İzhar: Sakin nun veya tenvinden sonra boğaz harfler
      "İdgam-ı Mealgunne: Sakin nun veya tenvinden sonra (ي, م, ن, و) harfleri gelirse, ses burundan (genizden) verilerek şeddeli gibi okunur.",
      "İhfa: Sakin nun veya tenvinden sonra izhar ve idgam harfleri dışındaki 15 harf gelirse, nun sesi genizden gizlenerek okunur.",
      "Kalkale (Yankılama): (ق, ط, b, ج, د) harfleri sakin (cezimli) geldiğinde kuvvetli bir ses vurgusuyla yankılatılarak okunur.",
    ]);
  }
}

class _KibleRadarPainter extends CustomPainter {
  final double needleRotation;
  final bool isAligned;
  final bool isDark;

  _KibleRadarPainter({
    required this.needleRotation,
    required this.isAligned,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Paint radar background
    final bgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0F1B2A).withOpacity(0.4)
          : const Color(0xFFEAF7F1).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Paint concentric radar rings
    final ringPaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.3)
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.3) : const Color(0xFF27A770).w
























                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Play Button
                    GestureDetector(
                      onTap: () {
                        if (url.isNotEmpty) {
                          _playAudio(url, title);
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDark ? const Color(0xFF302820) : const Color(0xFFEAF7F1),
                        ),
                        child: Icon(
                          isPlaying(url)
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: const Color(0xFFC19E67),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorite Heart Button
                    GestureDetector(
                      onTap: () => _toggleFavoriteDua(id),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : (_isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    final double bracketW = 16;
    return Column(
      children: [
        tabRow,
        Expanded(
          child: hasAnyItems
              ? ListView(
                  physics: const BouncingScrollPhysics(),
                  children: items,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showOnlyFavorites ? Icons.favorite_border : Icons.search_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showOnlyFavorites
                            ? "Favori duanız bulunmuyor."
                            : "Aramanızla eşleşen dua bulunamadı.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }