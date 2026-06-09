import os
import subprocess

file_path = r"lib/screens/tool_detail_screen.dart"

# 1. Reset file to git base to ensure a clean state
print("Resetting tool_detail_screen.dart to clean git base...")
subprocess.run(["git", "checkout", "lib/screens/tool_detail_screen.dart"], check=True)

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 2. Define State Variables & Getters to inject at the top of _ToolDetailScreenState
state_declarations = """class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final PrayerRepository _repository = PrayerRepository();

  // Color Utility Getters
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _greenColor => _isDark ? const Color(0xFF27A770) : const Color(0xFF1E5E43);
  Color get _textColor => _isDark ? Colors.white : const Color(0xDE000000);
  Color get _subtitleColor => _isDark ? Colors.white70 : const Color(0x8A000000);
  Color get _cardBgColor => _isDark ? const Color(0xFF131D31) : Colors.white;
  Color get _goldColor => const Color(0xFFD4AF37);

  // General state variables
  String _currentLocationName = "";

  Future<void> _loadLocationName() async {
    final savedLoc = await _repository.getSavedLocation();
    final savedCity = savedLoc['cityName'] ?? "İstanbul";
    if (mounted) {
      setState(() {
        _currentLocationName = savedCity;
      });
    }
  }

  // Monthly Times state
  int _monthlyViewMode = 0; // 0 for Liste, 1 for Takvim
  int _selectedCalendarDayIndex = 0;
  List<Map<String, dynamic>> _monthlyPrayerTimes = [];
  bool _loadingMonthlyTimes = true;

  Future<void> _loadMonthlyTimes() async {
    try {
      final savedLoc = await _repository.getSavedLocation();
      final districtId = savedLoc['districtId'] ?? "9541";
      final List<Map<String, dynamic>> times = await _repository.getPrayerTimes(districtId);
      if (mounted) {
        setState(() {
          _monthlyPrayerTimes = times;
          _loadingMonthlyTimes = false;
        });
      }
    } catch (e) {
      print('Error loading monthly prayer times: $e');
      if (mounted) {
        setState(() {
          _loadingMonthlyTimes = false;
        });
      }
    }
  }

  // Quran V2 State
  int _lastSuraNo = 1;
  String _lastSuraName = "Fatiha";
  int _lastAyahNo = 1;
  int _lastTotalAyahs = 7;
  double _lastPercent = 0.0;
  String _quranSearchQuery = "";
  int _quranTab = 0; // 0 for Sureler, 1 for Cüzler
  Set<String> _quranBookmarks = {};

  Future<void> _loadQuranLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList = prefs.getStringList('quran_bookmarks') ?? [];
    if (mounted) {
      setState(() {
        _lastSuraNo = prefs.getInt('quran_last_sura_no') ?? 1;
        _lastSuraName = prefs.getString('quran_last_sura_name') ?? "Fatiha";
        _lastAyahNo = prefs.getInt('quran_last_ayah_no') ?? 1;
        _lastTotalAyahs = prefs.getInt('quran_last_total_ayahs') ?? 7;
        _lastPercent = _lastTotalAyahs > 0 ? (_lastAyahNo / _lastTotalAyahs) : 0.0;
        _quranBookmarks = Set<String>.from(bookmarkedList);
      });
    }
  }

  Future<void> _toggleQuranBookmark(String surahNo) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_quranBookmarks.contains(surahNo)) {
        _quranBookmarks.remove(surahNo);
      } else {
        _quranBookmarks.add(surahNo);
      }
    });
    await prefs.setStringList('quran_bookmarks', _quranBookmarks.toList());
  }

  // Zikirmatik V2 State
  Set<String> _zikirCompletedDates = {};
  double _counterScale = 1.0;

  Future<void> _loadZikirCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('zikir_completed_dates') ?? [];
    if (mounted) {
      setState(() {
        _zikirCompletedDates = Set<String>.from(completed);
      });
    }
  }

  Future<void> _markZikirCompletedToday() async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    setState(() {
      _zikirCompletedDates.add(todayStr);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('zikir_completed_dates', _zikirCompletedDates.toList());
  }

  // Dualar V2 State
  int _dualarTab = 0; // 0 for Kur'an, 1 for Hadis
  bool _showOnlyFavorites = false;
  Set<String> _favoriteDualar = {};
  String _dualarSearchQuery = "";
  Set<String> _expandedDualar = {};

  Future<void> _loadDualarFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorite_dualar') ?? [];
    if (mounted) {
      setState(() {
        _favoriteDualar = Set<String>.from(list);
      });
    }
  }

  Future<void> _toggleDuaFavorite(String duaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteDualar.contains(duaId)) {
        _favoriteDualar.remove(duaId);
      } else {
        _favoriteDualar.add(duaId);
      }
    });
    await prefs.setStringList('favorite_dualar', _favoriteDualar.toList());
  }

  // Dini Hoca State
  List<Map<String, dynamic>> _diniHocaMessages = [];
  bool _diniHocaIsTyping = false;
  final ScrollController _diniHocaScrollController = ScrollController();
  final TextEditingController _diniHocaInputController = TextEditingController();

  void _initDiniHoca() {
    if (_diniHocaMessages.isEmpty) {
      _diniHocaMessages = [
        {
          'isMe': false,
          'text': "Selamün Aleyküm mümin kardeşim. Ben yapay zeka Dini Hoca asistanınızım. İslamiyet, ibadetler (namaz, abdest, gusül, oruç, zekat vb.), dualar ve sureler hakkında sormak istediğiniz soruları cevaplamaktan mutluluk duyarım. Nasıl yardımcı olabilirim?",
          'time': DateTime.now(),
        }
      ];
    }
  }
"""

original_class_start = """class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final PrayerRepository _repository = PrayerRepository();"""

if original_class_start in content:
    content = content.replace(original_class_start, state_declarations)
    print("Injected state variables and getters.")
else:
    print("ERROR: Class start declaration not found!")
    exit(1)

# 3. Update initState() to load the new states and location name
original_init = """  @override
  void initState() {
    super.initState();
    _initMosques();
    if (widget.toolId == 'yakindaki-camiler') {
      _getUserLocation();
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
  }"""

new_init = """  @override
  void initState() {
    super.initState();
    _initMosques();
    _loadLocationName();
    _loadQuranLastRead();
    _loadZikirCompletedDates();
    _loadDualarFavorites();
    _initDiniHoca();
    if (widget.toolId == 'namaz-vakitleri-aylik') {
      _loadMonthlyTimes();
    }
    if (widget.toolId == 'yakindaki-camiler' || widget.toolId == 'kible-bulucu') {
      _getUserLocation();
    }
    _initAudio();
    _loadZikirState();
    _loadDuaList();
    _loadQuestionList();
    _loadKazaState();
  }"""

if original_init in content:
    content = content.replace(original_init, new_init)
    print("Updated initState method.")
else:
    # Try different whitespace matching
    print("Warning: original initState not found exactly, seeking fallback...")
    content = content.replace("super.initState();\n    _initMosques();", "super.initState();\n    _initMosques();\n    _loadLocationName();\n    _loadQuranLastRead();\n    _loadZikirCompletedDates();\n    _loadDualarFavorites();\n    _initDiniHoca();\n    if (widget.toolId == 'namaz-vakitleri-aylik') {\n      _loadMonthlyTimes();\n    }")

# 4. Update dispose()
original_dispose = """  @override
  void dispose() {
    _audioPlayer?.dispose();
    _duaNameController.dispose();
    _duaTextController.dispose();
    _questionNameController.dispose();
    _qaInputController.dispose();
    _chatInputController.dispose();
    _goldController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }"""

new_dispose = """  @override
  void dispose() {
    _audioPlayer?.dispose();
    _duaNameController.dispose();
    _duaTextController.dispose();
    _questionNameController.dispose();
    _qaInputController.dispose();
    _chatInputController.dispose();
    _diniHocaInputController.dispose();
    _diniHocaScrollController.dispose();
    _goldController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }"""

if original_dispose in content:
    content = content.replace(original_dispose, new_dispose)
    print("Updated dispose method.")
else:
    print("Warning: original dispose not found exactly.")

# 5. Inject switch-cases into _buildToolBody()
case_target = """      case 'kuran-kerim':
        return _buildKuranKerim();"""

case_replacement = """      case 'kuran-kerim':
        return _buildKuranKerim();
      case 'dini-hoca':
        return _buildDiniHoca();
      case 'namaz-vakitleri-aylik':
        return _buildAylikNamazVakitleri();"""

if case_target in content:
    content = content.replace(case_target, case_replacement)
    print("Injected switch cases for dini-hoca and namaz-vakitleri-aylik.")
else:
    print("ERROR: Case target inside _buildToolBody not found!")
    exit(1)

# 6. Load replacement views codes
print("Injecting new views and painters...")

# Define views as string blocks
kuran_kerim_view = """  // 6. Kuran-ı Kerim V2
  Widget _buildKuranKerim() {
    final bool dark = _isDark;

    // Filter surahs/juzs
    final queryNormalized = _normalize(_quranSearchQuery);
    final List<QuranSurah> filteredSuras = QURAN_SURAHS.where((s) {
      return _normalize(s.name).contains(queryNormalized) ||
          _normalize(s.arabicName).contains(queryNormalized) ||
          s.number.toString().contains(queryNormalized);
    }).toList();

    // Generate Juz list (30 juzs)
    final List<QuranJuz> filteredJuzs = List.generate(30, (i) => QuranJuz(number: i + 1)).where((j) {
      return j.number.toString().contains(queryNormalized) ||
          "${j.number}. cüz".contains(queryNormalized);
    }).toList();

    return Column(
      children: [
        // Kaldığın Yer bookmark progress card
        if (_lastSuraName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              color: dark ? const Color(0xFF131D31) : Colors.white,
              elevation: dark ? 0 : 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: dark
                    ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                    : BorderSide.none,
              ),
              child: InkWell(
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
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _greenColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_rounded, color: _goldColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "KALDIĞIN YER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: _goldColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_lastSuraName Suresi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                            Text(
                              "Ayet $_lastAyahNo / $_lastTotalAyahs",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _lastPercent,
                                backgroundColor: dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: _greenColor, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Tabs switcher & search row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _quranTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quranTab == 0
                                ? _greenColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Sureler",
                            style: TextStyle(
                              color: _quranTab == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _quranTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quranTab == 1
                                ? _greenColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Cüzler",
                            style: TextStyle(
                              color: _quranTab == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: _quranTab == 0 ? "Sure adı veya no ara..." : "Cüz no ara...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: _greenColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _quranSearchQuery = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // List builder
        Expanded(
          child: _quranTab == 0
              ? _buildSurelerList(filteredSuras)
              : _buildCuzlerList(filteredJuzs),
        ),
      ],
    );
  }

  Widget _buildSurelerList(List<QuranSurah> list) {
    final bool dark = _isDark;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Eşleşen sure bulunamadı.",
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final surah = list[index];
        final isBookmarked = _quranBookmarks.contains(surah.number.toString());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranDetailScreen(
                    surah: surah,
                    targetAyah: 1,
                  ),
                ),
              ).then((_) => _loadQuranLastRead());
            },
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: _goldColor, width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: _goldColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              surah.name,
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              "${surah.versesCount} Ayet • ${surah.revelationPlace}",
              style: TextStyle(
                color: _subtitleColor,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah.arabicName,
                  style: TextStyle(
                    color: _greenColor,
                    fontFamily: 'Traditional Arabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isBookmarked ? _goldColor : (dark ? Colors.white38 : Colors.black26),
                    size: 22,
                  ),
                  onPressed: () => _toggleQuranBookmark(surah.number.toString()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCuzlerList(List<QuranJuz> list) {
    final bool dark = _isDark;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "Eşleşen cüz bulunamadı.",
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final juz = list[index];
        return Card(
          elevation: dark ? 0 : 1,
          color: _cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            onTap: () {
              final startInfo = _getJuzStartInfo(juz.number);
              final targetSurah = QURAN_SURAHS.firstWhere(
                (s) => s.number == startInfo['sura'],
                orElse: () => QURAN_SURAHS[0],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranDetailScreen(
                    surah: targetSurah,
                    isJuz: true,
                    juz: juz,
                    targetAyah: startInfo['ayah']!,
                  ),
                ),
              ).then((_) => _loadQuranLastRead());
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🕋",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${juz.number}. Cüz",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _getJuzStartInfo(int juzNumber) {
    const juzStarts = {
      1: {'sura': 1, 'ayah': 1},
      2: {'sura': 2, 'ayah': 142},
      3: {'sura': 2, 'ayah': 253},
      4: {'sura': 3, 'ayah': 93},
      5: {'sura': 4, 'ayah': 24},
      6: {'sura': 4, 'ayah': 148},
      7: {'sura': 5, 'ayah': 82},
      8: {'sura': 6, 'ayah': 111},
      9: {'sura': 7, 'ayah': 88},
      10: {'sura': 8, 'ayah': 41},
      11: {'sura': 9, 'ayah': 93},
      12: {'sura': 11, 'ayah': 6},
      13: {'sura': 12, 'ayah': 53},
      14: {'sura': 15, 'ayah': 1},
      15: {'sura': 17, 'ayah': 1},
      16: {'sura': 18, 'ayah': 75},
      17: {'sura': 21, 'ayah': 1},
      18: {'sura': 23, 'ayah': 1},
      19: {'sura': 25, 'ayah': 21},
      20: {'sura': 27, 'ayah': 56},
      21: {'sura': 29, 'ayah': 46},
      22: {'sura': 33, 'ayah': 31},
      23: {'sura': 36, 'ayah': 28},
      24: {'sura': 39, 'ayah': 32},
      25: {'sura': 41, 'ayah': 47},
      26: {'sura': 46, 'ayah': 1},
      27: {'sura': 51, 'ayah': 31},
      28: {'sura': 58, 'ayah': 1},
      29: {'sura': 67, 'ayah': 1},
      30: {'sura': 78, 'ayah': 1},
    };
    return juzStarts[juzNumber] ?? {'sura': 1, 'ayah': 1};
  }
"""

kible_bulucu_view = """  // 10. Kıble Bulucu V2 (Qibla Radar)
  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        final bool dark = _isDark;

        // If no sensor detected, display a beautiful fallback message
        if (heading == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_off_outlined,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Pusula Sensörü Bulunamadı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cihazınızda manyetik pusula sensörü tespit edilemedi. Kıble Radar özelliğini kullanabilmek için lütfen pusula desteği olan bir mobil cihaz kullanın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        double needleRotation = qiblaAngle - heading;

        // Calculate difference for direction instructions
        double diff = (qiblaAngle - heading) % 360;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        
        bool isAligned = diff.abs() < 3;

        // Blip coordinates on the radar grid
        final double angleRad = (needleRotation - 90) * 3.141592653589793 / 180;
        final double radarRadius = 90.0; // Half of 180
        final double blipX = 120.0 + radarRadius * math.cos(angleRad) - 16;
        final double blipY = 120.0 + radarRadius * math.sin(angleRad) - 16;

        // Real distance to Kaaba from user's current GPS, fallback to Istanbul
        double meccaDistance = 2400.0;
        if (_currentPosition != null) {
          meccaDistance = _calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, 21.4225, 39.8262);
        }

        Widget instructionWidget;
        if (isAligned) {
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF27A770).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF27A770), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27A770).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27A770),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "KIBLE KİLİTLENDİ 🕋",
                  style: TextStyle(
                    color: Color(0xFF27A770),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          );
        } else {
          String dirText = diff > 0 
              ? "SAĞA DÖNÜN: ${diff.round()}° ↪️" 
              : "SOLA DÖNÜN: ${diff.abs().round()}° ↩️";
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
            ),
            child: Text(
              dirText,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Card(
                color: dark ? const Color(0xFF1E2E4A).withOpacity(0.2) : const Color(0xFFEAF7F1).withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(
                    color: dark ? const Color(0xFF27A770).withOpacity(0.15) : const Color(0xFF27A770).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar_rounded, color: _greenColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Kıble Radar Arayüzü",
                            style: TextStyle(
                              fontSize: 14.5, 
                              fontWeight: FontWeight.bold, 
                              color: _greenColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Telefonunuzu yatay tutup kendi etrafınızda dönün. Parıldayan Kabe hedefini (🕋) en üstteki kırmızı hedef çizgisine yerleştirin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: _subtitleColor, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Futuristic Qibla Radar Screen
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isAligned
                                ? const Color(0xFF27A770).withOpacity(0.1)
                                : (dark ? Colors.black45 : Colors.black12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _KibleRadarPainter(
                          needleRotation: needleRotation,
                          isAligned: isAligned,
                          isDark: dark,
                        ),
                      ),
                    ),
                    Positioned(
                      left: blipX,
                      top: blipY,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAligned ? const Color(0xFF27A770) : _cardBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAligned ? Colors.white : (dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAligned ? const Color(0xFF27A770).withOpacity(0.8) : Colors.black26,
                              blurRadius: isAligned ? 12 : 4,
                              spreadRadius: isAligned ? 2 : 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "🕋",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              instructionWidget,
              
              const SizedBox(height: 24),
              
              // HUD Information Panel
              Card(
                color: _cardBgColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KIBLE RADAR VERİLERİ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: _subtitleColor,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Hedef Açısı:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${qiblaAngle.toInt()}° (İstanbul)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _greenColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cihaz Yönü:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${heading.round()}°", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kabe'ye Uzaklık:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text("${meccaDistance.round()} km", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Konum:", style: TextStyle(fontSize: 13, color: _subtitleColor)),
                          Text(_currentLocationName.isNotEmpty ? _currentLocationName : "İstanbul", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
"""

# Zikirmatik view and chart are defined above in python, let's load them
# Also need to write daily prayers view, dini hoca, and monthly prayer times

# Let's read Kuran Kerim method and replace it
idx_kuran_start = content.find("  // 6. Kuran-ı Kerim Player")
idx_kuran_end = content.find("  // 7. Esmaül Hüsna")

if idx_kuran_start != -1 and idx_kuran_end != -1:
    content = content[:idx_kuran_start] + kuran_kerim_view + "\n" + content[idx_kuran_end:]
    print("Replaced _buildKuranKerim method.")
else:
    print("ERROR: Kuran-ı Kerim boundaries not found!")
    exit(1)

# Let's replace _buildKibleBulucu method
idx_kible_start = content.find("  Widget _buildKibleBulucu() {")
idx_kible_end = content.find("  // 11. Zikirmatik")

if idx_kible_start != -1 and idx_kible_end != -1:
    content = content[:idx_kible_start] + kible_bulucu_view + "\n" + content[idx_kible_end:]
    print("Replaced _buildKibleBulucu method.")
else:
    print("ERROR: Kıble Bulucu boundaries not found!")
    exit(1)

# Zikirmatik view contains both _buildZikirmatik and _buildWeekViewChart
zikir_view_full = """  // 11. Zikirmatik V2
""" + kuran_kerim_view.split('// 6. Kuran-ı Kerim V2')[0] # just placeholder or loaded from our string
# Wait, let's just write the actual zikir_view_full string

zikir_view_full = """  // 11. Zikirmatik V2
  Widget _buildZikirmatik() {
    final zikir = _zikirData[_selectedZikirId] ?? _zikirData['subhanallah']!;
    final bool dark = _isDark;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _zikirData.length,
              itemBuilder: (context, index) {
                final key = _zikirData.keys.elementAt(index);
                final item = _zikirData[key]!;
                final isSelected = _selectedZikirId == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _onZikirSelected(key),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? _greenColor : _cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _greenColor
                              : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _greenColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['ad'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : _textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['hedef'] == 9999 ? "∞" : "Hedef: ${item['hedef']}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white75 : _subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: _cardBgColor,
            elevation: dark ? 0 : 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: dark
                  ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1)
                  : BorderSide.none,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    zikir['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFFFF9F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dark ? const Color(0xFF2E3D5A) : const Color(0xFFFFECE0),
                      ),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: dark ? const Color(0xFFE2B04E) : Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _counterScale = 0.92;
              });
            },
            onTapUp: (_) {
              setState(() {
                _counterScale = 1.0;
              });
            },
            onTapCancel: () {
              setState(() {
                _counterScale = 1.0;
              });
            },
            onTap: () async {
              HapticFeedback.lightImpact();
              if (_zikirSoundEnabled) {
                SystemSound.play(SystemSoundType.click);
              }
              setState(() {
                _zikirCount++;
              });
              await _repository.setZikirCount(_zikirCount);

              if (_zikirTarget != 9999 && _zikirCount >= _zikirTarget) {
                HapticFeedback.vibrate();
                await _markZikirCompletedToday();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Tebrikler! ${zikir['ad']} zikrini tamamladınız!",
                    ),
                    backgroundColor: const Color(0xFF27A770),
                  ),
                );
                setState(() {
                  _zikirCount = 0;
                });
                await _repository.setZikirCount(0);
              }
            },
            child: AnimatedScale(
              scale: _counterScale,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _cardBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _greenColor, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: _greenColor.withOpacity(dark ? 0.2 : 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$_zikirCount",
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: _greenColor,
                        ),
                      ),
                      Text(
                        _zikirTarget == 9999 ? "/ ∞" : "/ $_zikirTarget",
                        style: TextStyle(
                          fontSize: 13,
                          color: _subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sayaç Sıfırlansın mı?"),
                      content: const Text("Zikir sayacınızı sıfırlamak istediğinize emin misiniz?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetZikir();
                            Navigator.pop(context);
                          },
                          child: const Text("Sıfırla", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Sıfırla", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zikirSoundEnabled ? _greenColor : Colors.grey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _zikirSoundEnabled = !_zikirSoundEnabled;
                  });
                },
                icon: Icon(_zikirSoundEnabled ? Icons.volume_up : Icons.volume_off, size: 18),
                label: Text(
                  _zikirSoundEnabled ? "Ses: Açık" : "Ses: Kapalı",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildWeekViewChart(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeekViewChart() {
    final bool dark = _isDark;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = List.generate(7, (i) => monday.add(Duration(days: i)));
    final List<String> dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Card(
      color: _cardBgColor,
      elevation: dark ? 0 : 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: dark
            ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: _goldColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Bu Haftanın Zikir Takibi",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = daysOfWeek[index];
                final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                final bool isCompleted = _zikirCompletedDates.contains(dayStr);
                final bool isToday = day.year == now.year && day.month == now.month && day.day == now.day;

                return Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday ? _greenColor : _subtitleColor,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF27A770)
                            : (isToday
                                ? _greenColor.withOpacity(0.15)
                                : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9))),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: _greenColor, width: 2)
                            : Border.all(
                                color: isCompleted
                                    ? const Color(0xFF27A770)
                                    : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                                width: 1.5,
                              ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                "${day.day}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? _greenColor : _textColor,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
"""

idx_zikir_start = content.find("  Widget _buildZikirmatik() {")
idx_zikir_end = content.find("  // 12. Miladi - Hicri Çevirici")

if idx_zikir_start != -1 and idx_zikir_end != -1:
    content = content[:idx_zikir_start] + zikir_view_full + "\n" + content[idx_zikir_end:]
    print("Replaced _buildZikirmatik and WeekViewChart methods.")
else:
    print("ERROR: Zikirmatik boundaries not found!")
    exit(1)

# Let's replace _buildGunlukDualar method
dualar_view = """  // 17. Günlük Dualar (Dualar V2)
  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'sabah_aksam':
        return "☀️ Sabah & Akşam Ezkarı";
      case 'namaz':
        return "🕋 Namaz Duaları";
      case 'uyku':
        return "🛌 Uyku Duaları";
      case 'yolculuk':
        return "🚗 Yolculuk Duaları";
      case 'yemek':
        return "🍽️ Yemek Duaları";
      case 'genel':
      default:
        return "🤲 Genel Dualar";
    }
  }

  Widget _buildGunlukDualar() {
    final bool dark = _isDark;
    final List<Map<String, String>> sourceList = _dualarTab == 0 ? KURAN_DUALARI : HADIS_DUALARI;

    final queryNormalized = _normalize(_dualarSearchQuery);
    final List<Map<String, String>> filteredDualar = sourceList.where((d) {
      final matchesSearch = _normalize(d['ad'] ?? '').contains(queryNormalized) ||
          _normalize(d['anlam'] ?? '').contains(queryNormalized) ||
          _normalize(d['okunus'] ?? '').contains(queryNormalized);
      final isFav = _favoriteDualar.contains(d['id'] ?? '');
      if (_showOnlyFavorites) {
        return matchesSearch && isFav;
      }
      return matchesSearch;
    }).toList();

    final Map<String, List<Map<String, String>>> groupedDualar = {};
    for (final dua in filteredDualar) {
      final cat = dua['kategori'] ?? 'genel';
      groupedDualar.putIfAbsent(cat, () => []).add(dua);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _dualarTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _dualarTab == 0 ? _greenColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Kur'an Duaları",
                            style: TextStyle(
                              color: _dualarTab == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _dualarTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _dualarTab == 1 ? _greenColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Hadis Duaları",
                            style: TextStyle(
                              color: _dualarTab == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF131D31) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: _textColor),
                        decoration: InputDecoration(
                          hintText: "Dua ara...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: _greenColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _dualarSearchQuery = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites ? Colors.red : (dark ? const Color(0xFF131D31) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showOnlyFavorites ? Colors.red : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.05 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                        color: _showOnlyFavorites ? Colors.white : Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredDualar.isEmpty
              ? Center(
                  child: Text(
                    _showOnlyFavorites ? "Favorilere eklenmiş dua bulunamadı." : "Eşleşen dua bulunamadı.",
                    style: TextStyle(color: _subtitleColor, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 36.0),
                  itemCount: groupedDualar.keys.length,
                  itemBuilder: (context, catIndex) {
                    final cat = groupedDualar.keys.elementAt(catIndex);
                    final prayers = groupedDualar[cat]!;
                    final catTitle = _getCategoryTitle(cat);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                          child: Text(
                            "$catTitle (${prayers.length})",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _goldColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...List.generate(prayers.length, (duaIndex) {
                          final dua = prayers[duaIndex];
                          final id = dua['id'] ?? '';
                          final title = dua['ad'] ?? '';
                          final source = dua['sure'] ?? dua['kaynak'] ?? '';
                          final arabic = dua['arapca'] ?? '';
                          final mean = dua['anlam'] ?? '';
                          final reading = dua['okunus'] ?? '';
                          final audio = dua['ses'] ?? '';
                          
                          final isExpanded = _expandedDualar.contains(id);
                          final isFav = _favoriteDualar.contains(id);
                          final isPlaying = _currentAudioUrl == audio && _playerState == PlayerState.playing;

                          return Card(
                            color: _cardBgColor,
                            elevation: dark ? 0 : 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedDualar.remove(id);
                                  } else {
                                    _expandedDualar.add(id);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (audio.isNotEmpty)
                                          GestureDetector(
                                            onTap: () => _playAudio(audio, title),
                                            child: Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: isPlaying ? _greenColor : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1)),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isPlaying ? Icons.pause : Icons.play_arrow,
                                                color: isPlaying ? Colors.white : _greenColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        if (audio.isNotEmpty) const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: _textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                source,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: _subtitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          onPressed: () => _toggleDuaFavorite(id),
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(height: 20),
                                      if (arabic.isNotEmpty) ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            arabic,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _greenColor,
                                              fontFamily: 'Traditional Arabic',
                                              height: 1.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (reading.isNotEmpty) ...[
                                        Text(
                                          "Okunuşu:",
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldColor),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          reading,
                                          style: TextStyle(fontSize: 13, color: _textColor, height: 1.35),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        "Anlamı:",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _goldColor),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        mean,
                                        style: TextStyle(fontSize: 13, color: _textColor, height: 1.4),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
"""

idx_dua_start = content.find("  Widget _buildGunlukDualar() {")
idx_dua_end = content.find("  // 18. Zekat Hesaplayıcı")

if idx_dua_start != -1 and idx_dua_end != -1:
    content = content[:idx_dua_start] + dualar_view + "\n" + content[idx_dua_end:]
    print("Replaced _buildGunlukDualar method.")
else:
    print("ERROR: Dualar boundaries not found!")
    exit(1)

# Define the new Dini Hoca and Aylık Vakitler methods to append below _buildGunlukDualar
new_methods = """
  // 21. Dini Hoca AI Chat
""" + kuran_kerim_view.split('// 6. Kuran-ı Kerim V2')[0] # just placeholder

# We will read them directly from the python code block as a complete string
hoca_and_vakitler = """
  // 21. Dini Hoca AI Chat
  Widget _buildDiniHoca() {
    _initDiniHoca();
    final bool dark = _isDark;

    final List<String> suggestions = [
      "Abdest nasıl alınır? 💧",
      "Namazın farzları nelerdir? 🕋",
      "Gusül abdesti farzları 🚿",
      "Sehiv secdesi nedir? 🙇",
      "Zekat kimlere verilir? 💰",
      "Orucu bozan şeyler 🍽️",
      "Kaza namazı nasıl kılınır? 🕰️",
    ];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF131D31) : const Color(0xFFEBF5F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFC2E3D2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1E2D4A) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_rounded, color: _goldColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dini Hoca AI Danışmanı",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Sorularınıza fıkıh kaynaklı yapay zeka yanıtları alın.",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _diniHocaScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _diniHocaMessages.length + (_diniHocaIsTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _diniHocaMessages.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _greenColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1A263B) : const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Dini Hoca yazıyor ",
                              style: TextStyle(
                                fontSize: 13,
                                color: _subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildMiniTypingIndicator(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final msg = _diniHocaMessages[index];
              final bool isMe = msg['isMe'] ?? false;
              final String text = msg['text'] ?? "";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _greenColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? _greenColor
                              : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: _buildMessageText(text, isMe),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: dark ? Colors.white70 : Colors.black54,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
                  side: BorderSide(
                    color: dark ? const Color(0xFF2E3D5A) : const Color(0xFFCBD5E1),
                  ),
                  label: Text(
                    suggestions[index],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: dark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    _handleDiniHocaSend(suggestions[index].replaceAll(RegExp(r'\\s\\S+$'), ''));
                  },
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0C1524) : Colors.grey[50],
            border: Border(
              top: BorderSide(color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _diniHocaInputController,
                      style: TextStyle(color: _textColor),
                      decoration: const InputDecoration(
                        hintText: "Dini Hoca'ya sor...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleDiniHocaSend,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleDiniHocaSend(_diniHocaInputController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _greenColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _greenColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText(String text, bool isMe) {
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\\*\\*(.*?)\\*\\*');
    int lastIndex = 0;

    for (final Match match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: isMe ? Colors.white : _textColor,
        ),
      ),
    );
  }

  void _handleDiniHocaSend(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _diniHocaInputController.clear();

    setState(() {
      _diniHocaMessages.add({
        'isMe': true,
        'text': userMsg,
        'time': DateTime.now(),
      });
      _diniHocaIsTyping = true;
    });

    _scrollToBottomDiniHoca();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      final reply = _getDiniHocaResponse(userMsg);
      setState(() {
        _diniHocaIsTyping = false;
        _diniHocaMessages.add({
          'isMe': false,
          'text': reply,
          'time': DateTime.now(),
        });
      });
      _scrollToBottomDiniHoca();
    });
  }

  void _scrollToBottomDiniHoca() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_diniHocaScrollController.hasClients) {
        _diniHocaScrollController.animateTo(
          _diniHocaScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMiniTypingIndicator() {
    return _MiniDotAnimator(color: _subtitleColor);
  }

  String _getDiniHocaResponse(String query) {
    final q = _normalize(query);

    if (q.contains("abdest")) {
      return \"\"\"**Abdest Nasıl Alınır?** 💧

Abdest, belirli uzuvları usulüne uygun yıkamak ve mesh etmekten ibaret ibadet temizliğidir. Sırasıyla şu şekildedir:

1. **Niyet ve Besmele**: "Niyet ettim Allah rızası için abdest almaya" denir ve Eûzü-Besmele çekilir.
2. **Elleri Yıkamak**: Eller bileklere kadar üç defa yıkanır. Parmak araları hilallenir.
3. **Ağza Su Vermek**: Sağ el ile ağıza üç kere su verilip çalkalanır.
4. **Buruna Su Vermek**: Sağ el ile buruna üç kere su çekilip sol el ile temizlenir.
5. **Yüzü Yıkamak**: Alından çene altına, kulak yumuşaklarına kadar yüzün tamamı üç kere yıkanır.
6. **Kolları Yıkamak**: Önce sağ, sonra sol kol dirseklerle beraber üç kere yıkanır.
7. **Başı Mesh Etmek**: Sağ elin içi ıslatılarak başın dörtte biri mesh edilir.
8. **Kulak ve Boynu Mesh Etmek**: Parmaklar ıslatılarak kulakların içi ve arkası mesh edilir, elin dışı ile boyun mesh edilir.
9. **Ayakları Yıkamak**: Önce sağ, sonra sol ayak topuklarla birlikte, parmak aralarından başlanarak üç kere yıkanır.

**Abdestin Farzları (4'tür):**
1. Yüzü bir kere yıkamak.
2. Kolları dirseklerle beraber bir kere yıkamak.
3. Başın dörtte birini mesh etmek.
4. Ayakları topuklarla beraber bir kere yıkamak.\"\"\";
    }

    if (q.contains("gusul") || q.contains("gusül") || q.contains("boy abdesti")) {
      return \"\"\"**Gusül Abdesti (Boy Abdesti) Nasıl Alınır?** 🚿

Gusül, bütün vücudun temiz suyla iğne ucu kadar kuru yer kalmayacak şekilde yıkanmasıdır.

**Guslün Farzları (3'tür):**
1. **Ağıza Bolca Su Vermek (Mazmaza)**: Boğaza kadar su götürüp çalkalamak (3 defa).
2. **Buruna Bolca Su Vermek (İstinşak)**: Burun kemiği sızlayacak kadar derine su çekmek (3 defa).
3. **Bütün Vücudu Yıkamak**: Tepeden tırnağa kuru yer kalmayacak şekilde yıkanmak.

**Sünnete Uygun Gusül Alınışı:**
- Niyet edilir: *"Niyet ettim Allah rızası için boy abdesti almaya."* Besmele çekilir.
- Önce eller ve avret yerleri yıkanır, varsa vücuttaki kirler temizlenir.
- Namaz abdesti gibi tam bir abdest alınır (ağız ve buruna su bolca verilir).
- Önce başa, sonra sağ omuza, sonra sol omuza üçer defa su dökülür. Her su döküşte vücut ovulur.
- Vücutta iğne ucu kadar kuru yer kalmamasına dikkat edilir (göbek çukuru, küpe delikleri vb. ıslatılmalıdır).\"\"\";
    }

    if (q.contains("namaz")) {
      return \"\"\"**Namazın Farzları Nelerdir?** 🕋

Namazın dışındaki (şartları) ve içindeki (rüknü) olmak üzere toplam **12 farzı** vardır.

**A) Dışındaki Farzlar (Şartlar):**
1. **Hadesten Taharet**: Abdest veya gusül almak.
2. **Necasetten Taharet**: Vücut, elbise ve namaz kılınacak yerin temiz olması.
3. **Setr-i Avret**: Vücudun örtülmesi gereken yerlerini örtmek.
4. **İstikbal-i Kıble**: Namaz kılarken Kıble'ye (Kabe'ye) dönmek.
5. **Vakit**: Namazı kendi vakti içinde kılmak.
6. **Niyet**: Kılınacak namaza niyet etmek.

**B) İçindeki Farzlar (Rükünler):**
1. **İftitah Tekbiri**: Namaza "Allahu Ekber" diyerek başlamak.
2. **Kıyam**: Ayakta durmak (ayakta duramayanlar oturarak kılabilir).
3. **Kıraat**: Namazda ayaktayken Kur'an okumak (Fatiha ve sure).
4. **Rükû**: Elleri dizlere koyup eğilmek ve üç defa *"Sübhane Rabbiye'l-Azîm"* demek.
5. **Secde**: Alnı ve burnu yere koyup iki kez secde etmek ve *"Sübhane Rabbiye'l-A'lâ"* demek.
6. **Ka'de-i Âhire**: Son rekatta Ettehiyyatü duasını okuyacak kadar oturmak.\"\"\";
    }

    if (q.contains("oruc") || q.contains("oruç")) {
      return \"\"\"**Orucu Bozan ve Bozmayan Şeyler** 🌙

**A) Orucu Bozan Şeyler (Hem Kaza Hem Keffaret Gerektirenler):**
- Bilerek bir şey yemek, içmek.
- İlaç yutmak veya sigara içmek.

**B) Orucu Bozan Ama Sadece Kaza Gerektirenler (1 Gün Kaza):**
- Unutarak yiyip içtikten sonra orucun bozulduğunu sanarak bilerek yemeye devam etmek.
- Buruna ilaç damlatmak veya kulağa ağrı kesici damla damlatmak.
- İmsak vaktinin girmediğini veya iftar vaktinin geldiğini sanarak hataen yiyip içmek.

**C) Orucu Bozmayan Şeyler:**
- Unutarak yemek, içmek (hatırlayınca hemen ağız çalkalanıp oruca devam edilir).
- Ağza giren yağmur damlasını istem dışı yutmak.
- Diş fırçalamak (macun yutulmamak kaydıyla).
- Kan vermek, banyo yapmak, göze damla damlatmak.
- Parfüm veya kolonya koklamak.\"\"\";
    }

    if (q.contains("zekat") || q.contains("zekât")) {
      return \"\"\"**Zekat Kimlere Verilir ve Miktarı Nedir?** 💰

Zekat, dinen zengin sayılan Müslümanların, yılda bir kez mallarının belirli bir kısmını fakirlere vermesidir.

**Zekat Kimlere Verilir? (Tevbe Suresi 60. Ayet):**
1. Fakirler ve miskinler (hiçbir şeyi olmayanlar).
2. Borçlular (borcunu ödeyemeyecek durumda olanlar).
3. Yolda kalmış yolcular.
4. Allah yolunda olanlar (ilim talebeleri, cihat edenler).

**Zekat Kimlere Verilmez?**
- Anneye, babaya, büyükanne ve büyükbabalara.
- Çocuklara ve torunlara.
- Gayrimüslimlere.
- Zengin kişilere.
- Eşlerin birbirine zekat vermesi caiz değildir.

**Zekat Miktarı ve Şartları:**
- Kişinin temel ihtiyaçları ve borçları dışında **80.18 gram altın** veya muadili para/ticaret malına (Nisap miktarı) sahip olması gerekir.
- Bu malın üzerinden **1 tam kameri yıl** geçmiş olmalıdır.
- Zekat oranı genelde **1/40 yani %2.5**'tir.\"\"\";
    }

    if (q.contains("sehiv")) {
      return \"\"\"**Sehiv Secdesi Nedir ve Nasıl Yapılır?** 🙇

Sehiv secdesi (yanılma secdesi), namaz kılarken farzların geciktirilmesi veya vaciplerin unutularak terk edilmesi veya geciktirilmesi durumunda namazın sonunda yapılan secdedir. Namazdaki eksikliği tamamlar.

**Nasıl Yapılır?**
1. Son rekatta oturup sadece **Ettehiyyatü** duası okunur.
2. Sağ tarafa selam verilir. (Bazı görüşlere göre iki tarafa da selam verilebilir.)
3. Selamdan hemen sonra *"Allahu Ekber"* denilerek secdeye gidilir.
4. Secdede üç defa *"Sübhane Rabbiye'l-A'lâ"* denir, doğrulunur ve tekrar secdeye gidilir.
5. İkinci secdeden sonra oturulur ve **Ettehiyyatü, Salli, Barik ve Rabbena** duaları okunarak her iki tarafa da selam verilerek namaz tamamlanır.\"\"\";
    }

    if (q.contains("kaza")) {
      return \"\"\"**Kaza Namazı Nasıl Kılınır?** 🕰️

Kaza namazı, vaktinde kılınamamış olan farz namazların sonradan kılınmasıdır.

**Kaza Namazının Şartları ve Kılınışı:**
- Sadece **farz namazlar ve vitir namazı** kaza edilir (Sünnetlerin kazası olmaz, sadece sabah namazı o günün öğle vaktine kadar kaza edilirse sünneti de kılınabilir).
- Niyet edilirken hangi vaktin kazası olduğu belirtilir: *"Niyet ettim Allah rızası için en son kazaya kalan Sabah namazının farzını kılmaya."*
- Sırasıyla kılınır. Kaza namazları kılınırken kerahat vakitleri (güneş doğarken, tam tepedeyken ve batarken) dışında her vakit kılınabilir.
- Günlük kaçırılan namaz miktarı:
  - Sabah: 2 rekat farz.
  - Öğle: 4 rekat farz.
  - İkindi: 4 rekat farz.
  - Akşam: 3 rekat farz.
  - Yatsı: 4 rekat farz + 3 rekat Vitir vacip.\"\"\";
    }

    if (q.contains("dua") || q.contains("zikir")) {
      return \"\"\"**Dua ve Zikir Kavramları** 🤲

**Dua**: Kulun halini Yaradan'a arz etmesi, isteklerini O'ndan dilemesidir. Kur'an-ı Kerim'de *"Bana dua edin, size cevap vereyim"* (Mü'min, 60) buyurulmuştur. Dua, ibadetin özüdür.

**Zikir**: Allah'ı anmak, hatırlamak ve kalpte canlı tutmaktır. Kalpler ancak Allah'ı anmakla huzur bulur.

**Önemli Zikirlerin Faziletleri:**
- **Sübhanallah**: Allah'ı tüm noksanlıklardan tenzih etmektir.
- **Elhamdülillah**: Nimete karşı hamd etmektir, mizanı doldurur.
- **Allahu Ekber**: Allah'ın her şeyden büyük ve yüce olduğunu ikrar etmektir.
- **La ilahe illallah**: Zikrin en faziletlisidir, tevhid beyanıdır.\"\"\";
    }

    return \"\"\"Değerli mümin kardeşim, sorduğunuz konuyu tam olarak anlayamadım veya kelime haznemde yer almıyor olabilir. 

Lütfen sorunuzu daha açık kelimelerle sorunuz. Örneğin; **abdest alışı, guslün farzları, namazın farzları, sehiv secdesi, zekat verilecek kişiler, orucu bozan şeyler veya kaza namazları** gibi konularda doğrudan anahtar kelimeler kullanarak sorarsanız size çok daha detaylı bilgi aktarabilirim. 

Fıkhi konulardaki en doğru ve kesin hükümler için Diyanet İşleri Başkanlığı'nın resmi fetvalarına veya muteber fıkıh kitaplarına başvurmanızı tavsiye ederim.\"\"\";
  }

  // 22. Aylık Namaz Vakitleri V2
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

    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: _greenColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentLocationName.isNotEmpty ? _currentLocationName : "İstanbul",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "30 Günlük Aylık Namaz Vakitleri Tablosu",
                      style: TextStyle(
                        fontSize: 12,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Container(
            height: 46,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF131D31) : const Color(0xFFEAF7F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _monthlyViewMode = 0),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _monthlyViewMode == 0 ? _greenColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Liste Görünümü",
                        style: TextStyle(
                          color: _monthlyViewMode == 0 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _monthlyViewMode = 1;
                        final idx = _monthlyPrayerTimes.indexWhere((t) => (t['MiladiTarihKisa'] ?? '') == todayStr);
                        _selectedCalendarDayIndex = idx != -1 ? idx : 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _monthlyViewMode == 1 ? _greenColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Takvim Görünümü",
                        style: TextStyle(
                          color: _monthlyViewMode == 1 ? Colors.white : (dark ? Colors.white60 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _monthlyViewMode == 0
              ? _buildMonthlyListView(dark, todayStr)
              : _buildMonthlyCalendarView(dark, todayStr),
        ),
      ],
    );
  }

  Widget _buildMonthlyListView(bool dark, String todayStr) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Tarih",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.white70 : const Color(0xFF1E5E43),
                  ),
                ),
              ),
              ...vakitMeta.map(
                (meta) => Expanded(
                  flex: 1,
                  child: Text(
                    meta['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white70 : const Color(0xFF1E5E43),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _cardBgColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(
                color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: ListView.builder(
                itemCount: _monthlyPrayerTimes.length,
                itemBuilder: (context, index) {
                  final day = _monthlyPrayerTimes[index];
                  final String dateStr = day['MiladiTarihKisa'] ?? '';
                  final isToday = dateStr == todayStr;

                  final String dateUzun = day['MiladiTarihUzun'] ?? '';
                  final List<String> dateParts = dateUzun.split(' ');
                  String shortDate = dateStr;
                  if (dateParts.length >= 4) {
                    final String d = dateParts[0];
                    final String m = dateParts[1].substring(0, math.min(3, dateParts[1].length));
                    final String dayName = dateParts[3].substring(0, math.min(3, dateParts[3].length));
                    shortDate = "$d $m $dayName";
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF27A770).withOpacity(dark ? 0.18 : 0.08)
                          : (index % 2 == 0
                              ? (dark ? const Color(0xFF182438) : const Color(0xFFFAFCFA))
                              : Colors.transparent),
                      border: Border(
                        bottom: BorderSide(
                          color: dark ? const Color(0xFF1F2D44) : const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Text(
                                shortDate,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday
                                      ? const Color(0xFF27A770)
                                      : (dark ? Colors.white : Colors.black87),
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: _goldColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Bugün",
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ...vakitMeta.map(
                          (meta) => Expanded(
                            flex: 1,
                            child: Text(
                              day[meta['key']] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? const Color(0xFF27A770) : _textColor,
                              ),
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
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMonthlyCalendarView(bool dark, String todayStr) {
    final day = _monthlyPrayerTimes[_selectedCalendarDayIndex];
    final String dateStr = day['MiladiTarihKisa'] ?? '';
    final String dateUzun = day['MiladiTarihUzun'] ?? '';
    final String hicriStr = day['HicriTarihUzun'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Card(
            color: _cardBgColor,
            elevation: dark ? 0 : 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: dark
                  ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AYIN GÜNLERİ",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _goldColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Divider(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _monthlyPrayerTimes.length,
                    itemBuilder: (context, index) {
                      final item = _monthlyPrayerTimes[index];
                      final itemDate = item['MiladiTarihKisa'] ?? '';
                      final bool isSelected = _selectedCalendarDayIndex == index;
                      final bool isToday = itemDate == todayStr;

                      String dayNum = itemDate.split('.')[0];
                      if (dayNum.startsWith('0')) dayNum = dayNum.substring(1);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCalendarDayIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _greenColor
                                : (isToday
                                    ? _greenColor.withOpacity(0.15)
                                    : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9))),
                            borderRadius: BorderRadius.circular(12),
                            border: isToday
                                ? Border.all(color: _greenColor, width: 2)
                                : Border.all(
                                    color: isSelected
                                        ? _greenColor
                                        : (dark ? const Color(0xFF2E3D5A) : const Color(0xFFE2E8F0)),
                                    width: 1.5,
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              dayNum,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isToday ? _greenColor : _textColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: _cardBgColor,
            elevation: dark ? 0 : 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: dark
                  ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateUzun,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hicriStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: _goldColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dateStr == todayStr)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _goldColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Bugün",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...vakitMeta.map((meta) {
                    final String value = day[meta['key']] ?? '';
                    final IconData icon = meta['icon'];
                    final Color color = meta['color'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            meta['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _textColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _greenColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
"""

content = content.rstrip()
if content.endswith('}'):
    content = content[:-1]
content += hoca_and_vakitler + "\n}\n"

# 7. Append Custom Painter and Dot Animator helper classes at the end of the file
radar_and_dot_classes = """

class _MiniDotAnimator extends StatefulWidget {
  final Color color;

  const _MiniDotAnimator({required this.color});

  @override
  State<_MiniDotAnimator> createState() => _MiniDotAnimatorState();
}

class _MiniDotAnimatorState extends State<_MiniDotAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double animVal = math.sin((_controller.value * math.pi * 2) - (index * math.pi / 2));
            final double scale = 0.5 + 0.5 * (animVal + 1.0) / 2.0;
            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
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
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.3) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.45, ringPaint);

    // 3. Paint crosshairs
    final linePaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.4)
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.25) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // 4. Draw radar angle scale ticks (every 10 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * math.pi / 180;
      final bool isMajor = i % 30 == 0;

      final double tickLength = isMajor ? 8 : 4;
      final double startR = radius;
      final double endR = radius - tickLength;

      tickPaint.color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.5)
          : (isDark ? Colors.white24 : Colors.black12);
      tickPaint.strokeWidth = isMajor ? 1.5 : 1.0;

      final Offset startPoint = Offset(
        center.dx + startR * math.cos(angle),
        center.dy + startR * math.sin(angle),
      );
      final Offset endPoint = Offset(
        center.dx + endR * math.cos(angle),
        center.dy + endR * math.sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // 5. Draw active radar scanning beam
    final double radAngle = (needleRotation - 90) * math.pi / 180;

    final sweepPaint = Paint()
      ..color = isAligned
          ? const Color(0xFF27A770).withOpacity(0.15)
          : (isDark ? const Color(0xFFD4AF37).withOpacity(0.08) : const Color(0xFF27A770).withOpacity(0.08))
      ..style = PaintingStyle.fill;

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        radAngle - 0.2,
        0.4,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    // 6. Draw outer target marker (red bracket at the top)
    final targetPaint = Paint()
      ..color = isAligned ? const Color(0xFF27A770) : Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double bracketW = 16;
    final double bracketH = 8;
    final bracketPath = Path()
      ..moveTo(center.dx - bracketW, bracketH)
      ..lineTo(center.dx - bracketW, 0)
      ..lineTo(center.dx + bracketW, 0)
      ..lineTo(center.dx + bracketW, bracketH);
    canvas.drawPath(bracketPath, targetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
"""

content += radar_and_dot_classes

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Modification complete! Run flutter analyze to verify.")
