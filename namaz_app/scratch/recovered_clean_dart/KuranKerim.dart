"  Widget _buildKuranKerim() {
    final filteredSuras = QURAN_SURAHS.where((s) {
      final name = _normalize(s.name);
      final query = _normalize(_quranSearchQuery);
      return name.contains(query) || s.number.toString() == query;
    }).toList();

    final filteredJuzs = QURAN_JUZS.where((j) {
      final title = _normalize(j.title);
      final range = _normalize(j.range);
      final query = _normalize(_quranSearchQuery);
      return title.contains(query) || range.contains(query) || j.number.toString() == query;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Kaldığın Yer Card
              GestureDetector(
                onTap: () {
                  final targetSurah = QURAN_SURAHS.firstWhere(
                    (s) => s.number == _lastSuraNo,
                    orElse: () => QURAN_SURAHS[0],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranDetailScreen(
                        surah: targetSurah,
                        targetAyah: _lastAyahNo,
                      ),
                    ),
                  ).then((_) => _loadQuranLastRead());
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF163124), Color(0xFF0F2018)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFC5A059).withOpacity(0.3)),
          
<truncated 16801 bytes>