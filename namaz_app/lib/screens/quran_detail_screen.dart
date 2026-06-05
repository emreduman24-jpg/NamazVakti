import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_data.dart';

class QuranDetailScreen extends StatefulWidget {
  final QuranSurah surah;
  final bool isJuz;
  final QuranJuz? juz;
  final int targetAyah;

  const QuranDetailScreen({
    Key? key,
    required this.surah,
    this.isJuz = false,
    this.juz,
    this.targetAyah = 1,
  }) : super(key: key);

  @override
  State<QuranDetailScreen> createState() => _QuranDetailScreenState();
}

class _QuranDetailScreenState extends State<QuranDetailScreen> {
  bool _loading = true;
  String _errorMessage = "";
  List<OfflineVerse> _verses = [];
  final List<GlobalKey> _verseKeys = [];

  // Reading settings
  double _fontSize = 22.0;
  bool _showTranslation = true;
  bool _showTranscription = true;

  // Scroll tracking
  late ScrollController _scrollController;
  int _activeVerseIndex = 0;

  // Audio Player State
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _audioUrl = "";
  bool _isTransitioning = false;

  // Offline Download State
  bool _isDownloaded = false;
  List<String> _downloadedSuras = [];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  String _getVerseAudioUrl(int sura, int ayah) {
    final suraStr = sura.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');
    return "https://everyayah.com/data/Alafasy_128kbps/$suraStr$ayahStr.mp3";
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _activeVerseIndex = 0;
    _audioUrl = widget.isJuz ? widget.juz!.audioUrl : widget.surah.audioUrl;
    _initAudio();
    _loadVerses();
    _checkDownloadState();
  }

  void _onScroll() {
    if (_verses.isEmpty) return;
    if (_scrollController.hasClients) {
      // Do not allow scroll updates to override the active verse bookmark 
      // if audio is currently active (playing, paused, or transitioning).
      if (_playerState != PlayerState.stopped || _isTransitioning) return;

      double offset = _scrollController.offset;
      // Estimate which index is currently visible at the top (using average height of ~200)
      int index = (offset / 200.0).floor();
      index = index.clamp(0, _verses.length - 1);
      if (index != _activeVerseIndex) {
        setState(() {
          _activeVerseIndex = index;
        });
        _updateLastReadForActiveVerse();
      }
    }
  }

  Future<void> _checkDownloadState() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('quran_downloaded_surahs') ?? [];
    if (mounted) {
      setState(() {
        _downloadedSuras = downloaded;
        _isDownloaded = downloaded.contains(widget.surah.number.toString());
      });
    }
  }

  Future<bool> _loadSavedBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    if (widget.isJuz) {
      final lastJuzNo = prefs.getInt('quran_last_juz_no');
      final lastJuzSuraNo = prefs.getInt('quran_last_juz_sura_no') ?? 1;
      final lastJuzAyahNo = prefs.getInt('quran_last_juz_ayah_no') ?? 1;
      if (lastJuzNo == widget.juz!.number) {
        if (mounted && _verses.isNotEmpty) {
          final targetIndex = _verses.indexWhere(
            (v) => v.surahNumber == lastJuzSuraNo && v.number == lastJuzAyahNo,
          );
          if (targetIndex != -1) {
            setState(() {
              _activeVerseIndex = targetIndex;
            });
            _scrollToVerse(targetIndex);
            return true;
          }
        }
      }
    } else {
      final lastSura = prefs.getInt('quran_last_sura_no');
      final lastAyah = prefs.getInt('quran_last_ayah_no') ?? 1;
      if (lastSura == widget.surah.number) {
        if (mounted && _verses.isNotEmpty) {
          final targetIndex = _verses.indexWhere((v) => v.number == lastAyah);
          if (targetIndex != -1) {
            setState(() {
              _activeVerseIndex = targetIndex;
            });
            _scrollToVerse(targetIndex);
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> _updateLastReadQuietly(int suraNo, String suraName, int ayahNo, int totalAyahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (widget.isJuz) {
        await prefs.setInt('quran_last_juz_no', widget.juz!.number);
        await prefs.setString('quran_last_juz_title', widget.juz!.title);
        await prefs.setString('quran_last_juz_range', widget.juz!.range);
        await prefs.setInt('quran_last_juz_sura_no', suraNo);
        await prefs.setInt('quran_last_juz_ayah_no', ayahNo);
        final percent = _verses.isEmpty ? 0 : (((_activeVerseIndex + 1) / _verses.length) * 100).round().clamp(0, 100);
        await prefs.setInt('quran_last_juz_percent', percent);
      } else {
        await prefs.setInt('quran_last_sura_no', suraNo);
        await prefs.setString('quran_last_sura_name', suraName);
        await prefs.setInt('quran_last_ayah_no', ayahNo);
        await prefs.setInt('quran_last_total_ayahs', totalAyahs);
        final percent = ((ayahNo / totalAyahs) * 100).round();
        await prefs.setInt('quran_last_percent', percent);
      }
    } catch (e) {
      debugPrint("Error saving last read state: $e");
    }
  }

  Future<void> _updateLastReadForActiveVerse() async {
    if (_verses.isEmpty) return;
    final verse = _verses[_activeVerseIndex];
    final suraNo = verse.surahNumber ?? widget.surah.number;
    final suraName = verse.surahName ?? widget.surah.name;
    final surahInfo = QURAN_SURAHS.firstWhere((s) => s.number == suraNo, orElse: () => widget.surah);
    await _updateLastReadQuietly(suraNo, suraName, verse.number, surahInfo.versesCount);
  }

  void _scrollToTarget() {
    if (_verses.isEmpty) return;
    int targetIndex = 0;
    if (widget.isJuz) {
      final startInfo = _getJuzStartInfo(widget.juz!.number);
      targetIndex = _verses.indexWhere(
        (v) => v.surahNumber == startInfo['sura'] && v.number == widget.targetAyah,
      );
    } else {
      targetIndex = _verses.indexWhere((v) => v.number == widget.targetAyah);
    }
    if (targetIndex == -1) targetIndex = 0;

    setState(() {
      _activeVerseIndex = targetIndex;
    });

    if (targetIndex > 0) {
      _scrollToVerse(targetIndex);
    }
  }

  void _scrollToVerse(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index >= 0 && index < _verseKeys.length) {
        final keyContext = _verseKeys[index].currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.35, // Position the active verse card at 35% of screen height from top
          );
        }
      }
    });
  }

  Map<String, int> _getJuzStartInfo(int juzNumber) {
    final list = [
      {'sura': 1, 'ayah': 1},
      {'sura': 2, 'ayah': 142},
      {'sura': 2, 'ayah': 253},
      {'sura': 3, 'ayah': 93},
      {'sura': 4, 'ayah': 24},
      {'sura': 4, 'ayah': 148},
      {'sura': 5, 'ayah': 82},
      {'sura': 6, 'ayah': 111},
      {'sura': 7, 'ayah': 88},
      {'sura': 8, 'ayah': 41},
      {'sura': 9, 'ayah': 93},
      {'sura': 11, 'ayah': 6},
      {'sura': 12, 'ayah': 53},
      {'sura': 15, 'ayah': 1},
      {'sura': 17, 'ayah': 1},
      {'sura': 18, 'ayah': 75},
      {'sura': 21, 'ayah': 1},
      {'sura': 23, 'ayah': 1},
      {'sura': 25, 'ayah': 21},
      {'sura': 27, 'ayah': 56},
      {'sura': 29, 'ayah': 46},
      {'sura': 33, 'ayah': 31},
      {'sura': 36, 'ayah': 28},
      {'sura': 39, 'ayah': 32},
      {'sura': 41, 'ayah': 47},
      {'sura': 46, 'ayah': 1},
      {'sura': 51, 'ayah': 31},
      {'sura': 57, 'ayah': 1},
      {'sura': 67, 'ayah': 1},
      {'sura': 78, 'ayah': 1},
    ];
    if (juzNumber >= 1 && juzNumber <= 30) {
      return list[juzNumber - 1];
    }
    return {'sura': 1, 'ayah': 1};
  }

  void _initAudio() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      _playNextVerse();
    });
  }

  Future<void> _playNextVerse() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      if (_activeVerseIndex < _verses.length - 1) {
        final nextIndex = _activeVerseIndex + 1;
        setState(() {
          _activeVerseIndex = nextIndex;
        });
        await _updateLastReadForActiveVerse();
        _scrollToVerse(nextIndex);
        final verse = _verses[nextIndex];
        final suraNo = verse.surahNumber ?? widget.surah.number;
        final url = _getVerseAudioUrl(suraNo, verse.number);
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
      } else {
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
            _position = Duration.zero;
          });
        }
      }
    } catch (e) {
      debugPrint("Error playing next verse: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isTransitioning = false;
    }
  }

  Future<void> _selectAndPlayVerse(int index, {bool playImmediately = false}) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      setState(() {
        _activeVerseIndex = index;
      });
      await _updateLastReadForActiveVerse();
      if (playImmediately || _playerState == PlayerState.playing) {
        await _audioPlayer.stop();
        final verse = _verses[index];
        final suraNo = verse.surahNumber ?? widget.surah.number;
        final url = _getVerseAudioUrl(suraNo, verse.number);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      debugPrint("Error playing verse: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isTransitioning = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadVerses() async {
    setState(() {
      _loading = true;
      _errorMessage = "";
    });

    // Check if we have offline data
    if (!widget.isJuz && OFFLINE_SURAHS.containsKey(widget.surah.number)) {
      setState(() {
        _verses = OFFLINE_SURAHS[widget.surah.number]!;
        _verseKeys.clear();
        _verseKeys.addAll(List.generate(_verses.length, (_) => GlobalKey()));
        _loading = false;
      });
      final int startingAyah = widget.isJuz ? _getJuzStartInfo(widget.juz!.number)['ayah']! : 1;
      if (widget.targetAyah == startingAyah) {
        final bookmarked = await _loadSavedBookmark();
        if (!bookmarked) {
          _scrollToTarget();
        }
      } else {
        _scrollToTarget();
      }
      _updateLastReadForActiveVerse();
      return;
    }

    // Otherwise, fetch from public API
    try {
      if (widget.isJuz) {
        // Fetch the 3 editions of the Juz in parallel
        final responses = await Future.wait([
          http.get(Uri.parse("https://api.alquran.cloud/v1/juz/${widget.juz!.number}/quran-uthmani")),
          http.get(Uri.parse("https://api.alquran.cloud/v1/juz/${widget.juz!.number}/tr.diyanet")),
          http.get(Uri.parse("https://api.alquran.cloud/v1/juz/${widget.juz!.number}/en.transliteration")),
        ]).timeout(const Duration(seconds: 25));

        if (responses[0].statusCode == 200 && responses[1].statusCode == 200 && responses[2].statusCode == 200) {
          final decodedArabic = json.decode(responses[0].body);
          final decodedTurkish = json.decode(responses[1].body);
          final decodedTrans = json.decode(responses[2].body);

          final arabicList = decodedArabic['data']['ayahs'] as List;
          final turkishList = decodedTurkish['data']['ayahs'] as List;
          final transList = decodedTrans['data']['ayahs'] as List;

          final List<OfflineVerse> fetchedVerses = [];
          for (int i = 0; i < arabicList.length; i++) {
            final int surahNo = arabicList[i]['surah']['number'];
            final surahName = QURAN_SURAHS.firstWhere((s) => s.number == surahNo, orElse: () => QURAN_SURAHS[0]).name;
            fetchedVerses.add(
              OfflineVerse(
                number: arabicList[i]['numberInSurah'] ?? (i + 1),
                arabic: arabicList[i]['text'] ?? "",
                transliteration: transList[i]['text'] ?? "",
                translation: turkishList[i]['text'] ?? "",
                surahName: surahName,
                surahNumber: surahNo,
              ),
            );
          }

          if (mounted) {
            setState(() {
              _verses = fetchedVerses;
              _verseKeys.clear();
              _verseKeys.addAll(List.generate(fetchedVerses.length, (_) => GlobalKey()));
              _loading = false;
            });
            final int startingAyah = widget.isJuz ? _getJuzStartInfo(widget.juz!.number)['ayah']! : 1;
            if (widget.targetAyah == startingAyah) {
              final bookmarked = await _loadSavedBookmark();
              if (!bookmarked) {
                _scrollToTarget();
              }
            } else {
              _scrollToTarget();
            }
            _updateLastReadForActiveVerse();
          }
        } else {
          throw Exception("API returned non-200 status for some editions");
        }
      } else {
        // Fetch Surah
        final url = "https://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/quran-uthmani,tr.diyanet,en.transliteration";
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded['code'] == 200 && decoded['data'] != null) {
            final editions = decoded['data'] as List;
            final arabicList = editions[0]['ayahs'] as List;
            final turkishList = editions[1]['ayahs'] as List;
            final transList = editions[2]['ayahs'] as List;

            final List<OfflineVerse> fetchedVerses = [];
            for (int i = 0; i < arabicList.length; i++) {
              fetchedVerses.add(
                OfflineVerse(
                  number: arabicList[i]['numberInSurah'] ?? (i + 1),
                  arabic: arabicList[i]['text'] ?? "",
                  transliteration: transList[i]['text'] ?? "",
                  translation: turkishList[i]['text'] ?? "",
                ),
              );
            }

            if (mounted) {
              setState(() {
                _verses = fetchedVerses;
                _verseKeys.clear();
                _verseKeys.addAll(List.generate(fetchedVerses.length, (_) => GlobalKey()));
                _loading = false;
              });
              final int startingAyah = widget.isJuz ? _getJuzStartInfo(widget.juz!.number)['ayah']! : 1;
              if (widget.targetAyah == startingAyah) {
                final bookmarked = await _loadSavedBookmark();
                if (!bookmarked) {
                  _scrollToTarget();
                }
              } else {
                _scrollToTarget();
              }
              _updateLastReadForActiveVerse();
            }
          } else {
            throw Exception("API response error");
          }
        } else {
          throw Exception("Server returned ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "Ayetler yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.\n\nHata: $e";
        });
      }
    }
  }

  Future<void> _toggleAudio() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        String url;
        if (_verses.isNotEmpty) {
          final verse = _verses[_activeVerseIndex];
          final suraNo = verse.surahNumber ?? widget.surah.number;
          url = _getVerseAudioUrl(suraNo, verse.number);
        } else {
          url = widget.isJuz ? widget.juz!.audioUrl : _getVerseAudioUrl(widget.surah.number, 1);
        }
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ses çalma hatası: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showDownloadPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? const Color(0xFF131F35) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.surah.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : const Color(0xFF1E5E43),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "çevrimdışı dinleme için indir",
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isDark ? Colors.white70 : Colors.black54,
                          side: BorderSide(color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27A770),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final prefs = await SharedPreferences.getInstance();
                          if (!_downloadedSuras.contains(widget.surah.number.toString())) {
                            _downloadedSuras.add(widget.surah.number.toString());
                          }
                          await prefs.setStringList('quran_downloaded_surahs', _downloadedSuras);
                          setState(() {
                            _isDownloaded = true;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${widget.surah.name} çevrimdışı dinleme için indirildi."),
                                backgroundColor: const Color(0xFF27A770),
                              ),
                            );
                          }
                        },
                        child: const Text("İndir", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeletePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? const Color(0xFF131F35) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${widget.surah.name} Sil ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "İndirilen ses dosyası silinecek.",
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isDark ? Colors.white70 : Colors.black54,
                          side: BorderSide(color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Vazgeç", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final prefs = await SharedPreferences.getInstance();
                          _downloadedSuras.remove(widget.surah.number.toString());
                          await prefs.setStringList('quran_downloaded_surahs', _downloadedSuras);
                          setState(() {
                            _isDownloaded = false;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${widget.surah.name} ses dosyası silindi."),
                                backgroundColor: Colors.red[600],
                              ),
                            );
                          }
                        },
                        child: const Text("Sil", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isJuz ? widget.juz!.title : widget.surah.name;
    final arabicTitle = widget.isJuz ? widget.juz!.arabicLabel : widget.surah.arabicName;
    final subtitle = widget.isJuz ? widget.juz!.range : "${widget.surah.revelationPlace} • ${widget.surah.versesCount} Ayet";

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF0C1524) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isDark ? Colors.white : const Color(0xFF1E5E43),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: _isDark ? const Color(0xFF131F35) : Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _isDark ? Colors.white : const Color(0xFF1E5E43)),
        actions: [
          IconButton(
            icon: Icon(
              _isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
              color: _isDownloaded ? const Color(0xFF27A770) : (_isDark ? Colors.white : const Color(0xFF1E5E43)),
            ),
            onPressed: () {
              if (_isDownloaded) {
                _showDeletePopup();
              } else {
                _showDownloadPopup();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Gorgeous Pattern Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: _isDark
                      ? [const Color(0xFF163124), const Color(0xFF0F2018)]
                      : [const Color(0xFF1B4D3E), const Color(0xFF27A770)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFC5A059).withOpacity(_isDark ? 0.3 : 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: _isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF27A770).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Circular Pattern overlays
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -30,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.isJuz ? arabicTitle : "سُورَةُ $arabicTitle",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Traditional Arabic',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Control Bar (A A size selectors, Meal, Okunuş Toggles)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF131F35) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE8ECE9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // A (Smaller)
                    GestureDetector(
                      onTap: () {
                        if (_fontSize > 16.0) {
                          setState(() {
                            _fontSize -= 2.0;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Text(
                          "A",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.white70 : const Color(0xFF1E5E43),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // A (Larger)
                    GestureDetector(
                      onTap: () {
                        if (_fontSize < 36.0) {
                          setState(() {
                            _fontSize += 2.0;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Text(
                          "A",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.white : const Color(0xFF1E5E43),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(color: Color(0xFFE8ECE9), thickness: 1.5),
                    ),
                    // Meal Switch
                    Row(
                      children: [
                        Text(
                          "Meal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _isDark ? Colors.white70 : const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _showTranslation,
                          activeColor: const Color(0xFF27A770),
                          onChanged: (val) {
                            setState(() {
                              _showTranslation = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(color: Color(0xFFE8ECE9), thickness: 1.5),
                    ),
                    // Okunuş Switch
                    Row(
                      children: [
                        Text(
                          "Okunuş",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _isDark ? Colors.white70 : const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _showTranscription,
                          activeColor: const Color(0xFF27A770),
                          onChanged: (val) {
                            setState(() {
                              _showTranscription = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Quran Text Scroll View
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF27A770)),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, height: 1.4),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadVerses,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF27A770),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Tekrar Dene", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: _verses.length,
                        itemBuilder: (context, index) {
                          final verse = _verses[index];
                          final isCurrentlyLastRead = _activeVerseIndex == index;
                           return GestureDetector(
                             key: _verseKeys[index],
                             onTap: () => _selectAndPlayVerse(index),
                             child: Card(
                              elevation: 0.5,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isCurrentlyLastRead
                                      ? const Color(0xFFC5A059)
                                      : (_isDark ? const Color(0xFF1E2D4A) : const Color(0xFFECEFF0)),
                                  width: isCurrentlyLastRead ? 1.8 : 1.0,
                                ),
                              ),
                              color: _isDark ? const Color(0xFF131F35) : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Verse top bar with Ayet marker only (Clean layout as requested)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCurrentlyLastRead
                                                ? const Color(0xFFC5A059).withOpacity(0.15)
                                                : (_isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEAF7F1)),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            verse.surahName != null
                                                ? "${verse.surahName} - Ayet ${verse.number}"
                                                : "Ayet ${verse.number}",
                                            style: TextStyle(
                                              color: isCurrentlyLastRead
                                                  ? const Color(0xFFC5A059)
                                                  : (_isDark ? Colors.white : const Color(0xFF1E5E43)),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Arabic Text
                                    Text(
                                      verse.arabic,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Traditional Arabic',
                                        fontSize: _fontSize,
                                        height: 2.2,
                                        fontWeight: FontWeight.bold,
                                        color: _isDark ? Colors.white : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (_showTranscription) ...[
                                      Divider(height: 20, color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFF3F4F6)),
                                      Text(
                                        verse.transliteration,
                                        style: TextStyle(
                                          fontSize: _fontSize - 7,
                                          fontStyle: FontStyle.italic,
                                          color: _isDark ? const Color(0xFFC5A059) : const Color(0xFFB3893E),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    if (_showTranslation) ...[
                                      Divider(height: 20, color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFF3F4F6)),
                                      Text(
                                        verse.translation,
                                        style: TextStyle(
                                          fontSize: _fontSize - 8,
                                          color: _isDark ? Colors.white70 : const Color(0xFF4B5563),
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // 4. Elegant Dynamic Audio Player Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF163124) : const Color(0xFF1E5E43),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_isDark ? const Color(0xFF163124) : const Color(0xFF1E5E43)).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Play Button
                      GestureDetector(
                        onTap: _toggleAudio,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _playerState == PlayerState.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: _isDark ? const Color(0xFF163124) : const Color(0xFF1E5E43),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Text Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _verses.isNotEmpty
                                  ? "Dinle — ${_verses[_activeVerseIndex].surahName ?? widget.surah.name} (Ayet ${_verses[_activeVerseIndex].number})"
                                  : (widget.isJuz ? "Dinle — ${widget.juz!.title}" : "Dinle — ${widget.surah.name}"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isJuz ? "Mişari Raşid el-Afasi" : "Mişari Raşid el-Afasi",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Timer text
                      Text(
                        _duration == Duration.zero
                            ? "00:00"
                            : "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress Slider Bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      trackHeight: 3.0,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayColor: Colors.white.withOpacity(0.1),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble() > 0
                          ? _duration.inMilliseconds.toDouble()
                          : 1.0,
                      value: _position.inMilliseconds.toDouble().clamp(
                            0.0,
                            _duration.inMilliseconds.toDouble() > 0
                                ? _duration.inMilliseconds.toDouble()
                                : 1.0,
                          ),
                      onChanged: (val) async {
                        await _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
