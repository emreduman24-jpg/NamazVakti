import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../data/prayer_tracker_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final PrayerTrackerState _trackerState = PrayerTrackerState();

  String _email = '';
  String _gender = 'erkek';
  bool _isPremium = false;
  bool _isLoading = false;

  // Statistics
  int _currentStreak = 0;
  int _totalCompletedDays = 0;
  int _weeklyCompletedDays = 0;
  int _totalZikirs = 0;
  int _zikirDays = 0;
  int _quranBookmarkCount = 0;
  String _quranLastReadText = "Bulunmuyor";
  int _quranLastPercent = 0;
  int _quranLastSuraNo = 0;

  // Animations
  late AnimationController _headerAnimController;
  late AnimationController _cardsAnimController;
  late Animation<double> _headerFadeIn;
  late Animation<Offset> _headerSlideIn;
  late Animation<double> _cardsFadeIn;

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFadeIn = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerSlideIn = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    ));
    _cardsFadeIn = CurvedAnimation(
      parent: _cardsAnimController,
      curve: Curves.easeOut,
    );

    _nameController.addListener(_onNameTextChanged);
    _loadProfileData();
    _trackerState.addListener(_onTrackerChanged);
    _calculateTrackerMetrics();

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardsAnimController.dispose();
    _nameController.removeListener(_onNameTextChanged);
    _trackerState.removeListener(_onTrackerChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameTextChanged() {
    setState(() {});
  }

  void _onTrackerChanged() {
    if (!mounted) return;
    setState(() {
      _calculateTrackerMetrics();
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name') ?? '';
    final guestUuid = prefs.getString('guest_uuid') ?? '';
    
    // Find all keys starting with 'zikir_count_' and sum them up
    int sumZikirs = 0;
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('zikir_count_')) {
        sumZikirs += prefs.getInt(key) ?? 0;
      }
    }
    
    final zikirDaysList = prefs.getStringList('zikir_completed_dates') ?? [];
    final quranBookmarks = prefs.getStringList('quran_bookmarks') ?? [];
    
    final lastSuraName = prefs.getString('quran_last_sura_name');
    final lastAyahNo = prefs.getInt('quran_last_ayah_no');
    final lastPercent = prefs.getInt('quran_last_percent') ?? 0;
    final lastSuraNo = prefs.getInt('quran_last_sura_no') ?? 0;
    
    String lastReadText = "Bulunmuyor";
    if (lastSuraName != null && lastAyahNo != null) {
      lastReadText = "$lastSuraName Suresi, $lastAyahNo. Ayet";
    }

    setState(() {
      _email = guestUuid;
      _gender = prefs.getString('user_gender') ?? 'erkek';
      _isPremium = prefs.getBool('is_premium') ?? false;
      _nameController.text = savedName.isNotEmpty ? savedName : "Kullanıcı";
      
      _totalZikirs = sumZikirs;
      _zikirDays = zikirDaysList.length;
      _quranBookmarkCount = quranBookmarks.length;
      _quranLastReadText = lastReadText;
      _quranLastPercent = lastPercent;
      _quranLastSuraNo = lastSuraNo;
    });
  }

  String _formatDate(DateTime dt) {
    String y = dt.year.toString();
    String m = dt.month.toString().padLeft(2, '0');
    String d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  void _calculateTrackerMetrics() {
    final history = _trackerState.history;
    int curStreak = 0;
    int completedDays = 0;
    int weeklyDays = 0;

    final now = DateTime.now();

    // 1. Calculate Total Completed Days (at least 4 out of 5 prayers checked) ONLY FOR THE CURRENT MONTH
    history.forEach((key, list) {
      if (list.length == 5 && list.where((e) => e).length >= 4) {
        try {
          final parts = key.split('-');
          final int year = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          if (year == now.year && month == now.month) {
            completedDays++;
          }
        } catch (_) {}
      }
    });

    // 2. Calculate Current Streak (at least 4 out of 5 prayers checked)
    DateTime checkDate = DateTime.now();
    String todayStr = _formatDate(checkDate);
    final todayList = history[todayStr] ?? [false, false, false, false, false];
    bool todayAll = todayList.length == 5 && todayList.where((e) => e).length >= 4;

    if (!todayAll) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      String checkStr = _formatDate(checkDate);
      final list = history[checkStr] ?? [false, false, false, false, false];
      if (list.length == 5 && list.where((e) => e).length >= 4) {
        curStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // 3. Weekly completed days (past 7 days)
    for (int i = 0; i < 7; i++) {
      final dt = now.subtract(Duration(days: i));
      final key = _formatDate(dt);
      final list = history[key] ?? [false, false, false, false, false];
      if (list.length == 5 && list.where((e) => e).length >= 4) {
        weeklyDays++;
      }
    }

    setState(() {
      _currentStreak = curStreak;
      _totalCompletedDays = completedDays;
      _weeklyCompletedDays = weeklyDays;
    });
  }

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? const Color(0xFF27A770) : const Color(0xFFE53935),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        elevation: 8,
      ),
    );
  }

  Future<String> _getPublicIp() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (_) {}
    return '192.168.1.105';
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final String newName = _nameController.text.trim();
    final String ipAddress = await _getPublicIp();
    final String platform = Platform.isIOS ? 'iOS' : 'Android';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      await prefs.setString('user_gender', _gender);

      // Sync with Firestore using guest_uuid
      final guestUuid = prefs.getString('guest_uuid') ?? '';
      if (guestUuid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(guestUuid)
            .set({
          'name': newName,
          'gender': _gender,
          'lastActive': DateTime.now().toUtc().toIso8601String(),
          'ipAddress': ipAddress,
          'platform': platform,
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
      }

      _showSnackBar("Profil başarıyla güncellendi!", success: true);
    } catch (e) {
      _showSnackBar("Profil güncellenirken senkronizasyon hatası oluştu.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Color palette
    final Color bg = dark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA);
    final Color cardBg = dark ? const Color(0xFF141B2D) : Colors.white;
    final Color cardBorder = dark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFE8ECF0);
    final Color textPrimary = dark ? Colors.white : const Color(0xFF1A2332);
    final Color textSecondary = dark ? Colors.white60 : const Color(0xFF6B7B8D);
    const Color accent = Color(0xFF27A770);
    const Color accentDark = Color(0xFF1E5E43);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Gradient Header Background ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? [const Color(0xFF0F2D20), const Color(0xFF0A0E1A)]
                      : [const Color(0xFF27A770), const Color(0xFF1B8A5A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Decorative Pattern Overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.5),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(dark ? 0.03 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Curve ──
          Positioned(
            top: 280,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header Nav Bar ──
                SlideTransition(
                  position: _headerSlideIn,
                  child: FadeTransition(
                    opacity: _headerFadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        children: [
                          _buildHeaderButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          const Text(
                            "Profilim",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Body Content ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // ── Avatar Section ──
                        FadeTransition(
                          opacity: _headerFadeIn,
                          child: _buildAvatarSection(dark, textSecondary),
                        ),

                        const SizedBox(height: 28),

                        // ── Stats Section ──
                        FadeTransition(
                          opacity: _cardsFadeIn,
                          child: _buildStatsSection(dark, cardBg, cardBorder,
                              textPrimary, textSecondary),
                        ),

                        const SizedBox(height: 20),

                        // ── Profile Form Section ──
                        FadeTransition(
                          opacity: _cardsFadeIn,
                          child: _buildProfileForm(
                              dark, cardBg, cardBorder, textPrimary, textSecondary),
                        ),

                        const SizedBox(height: 20),

                        // ── Device ID Section ──
                        FadeTransition(
                          opacity: _cardsFadeIn,
                          child: _buildDeviceIdCard(
                              dark, cardBg, cardBorder, textSecondary),
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Loading Overlay ──
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF1A2332)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: accent,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Güncelleniyor...",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ── Widget Builders ──
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool dark, Color textSecondary) {
    return Column(
      children: [
        // Avatar with glow ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isPremium
                        ? const Color(0xFFD4AF37).withOpacity(0.3)
                        : const Color(0xFF27A770).withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Avatar border ring
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isPremium
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD4AF37),
                          Color(0xFFF5D76E),
                          Color(0xFFD4AF37),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF34D399),
                          Color(0xFF27A770),
                          Color(0xFF1E5E43),
                        ],
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? const Color(0xFF141B2D) : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _gender == 'kadin' ? '👩' : '👨',
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              ),
            ),
            // Pro badge overlay
            if (_isPremium)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFF996515)],
                    ),
                    border: Border.all(
                      color: dark ? const Color(0xFF141B2D) : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : "Kullanıcı",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: _isPremium
                ? const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFC49B28)],
                  )
                : null,
            color: _isPremium
                ? null
                : (dark ? Colors.white.withOpacity(0.15) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPremium
                  ? const Color(0xFFD4AF37).withOpacity(0.6)
                  : (dark ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.85)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPremium
                    ? Icons.diamond_rounded
                    : Icons.person_rounded,
                color: _isPremium
                    ? Colors.white
                    : (dark ? Colors.white : const Color(0xFF1E5E43)),
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                _isPremium ? "PRO ÜYE" : "STANDART HESAP",
                style: TextStyle(
                  color: _isPremium
                      ? Colors.white.withOpacity(1.0)
                      : (dark ? Colors.white.withOpacity(0.85) : const Color(0xFF1E5E43)),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    bool dark,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF27A770),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Namaz İstatistikleri",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCardNew(
                emoji: "🔥",
                title: "Günlük namaz seri",
                value: "$_currentStreak",
                unit: "gün",
                progress: _currentStreak / 30,
                color: const Color(0xFFEF5350),
                dark: dark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCardNew(
                emoji: "📅",
                title: "Aylık namaz takibi",
                value: "$_totalCompletedDays",
                unit: "gün",
                progress: _totalCompletedDays / 30,
                color: const Color(0xFF27A770),
                dark: dark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCardNew(
                emoji: "🕌",
                title: "Haftalık namaz takibi",
                value: "$_weeklyCompletedDays",
                unit: "gün",
                progress: _weeklyCompletedDays / 7,
                color: const Color(0xFFE5A93B),
                dark: dark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E44AD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "İbadet & Okuma İstatistikleri",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCardNew(
                emoji: "📿",
                title: "Toplam zikir sayısı",
                value: "$_totalZikirs",
                unit: "adet",
                progress: _totalZikirs / 1000,
                color: const Color(0xFF8E44AD),
                dark: dark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCardNew(
                emoji: "📖",
                title: "Hatim ilerlemesi",
                value: "${(_quranLastSuraNo / 114.0 * 100).toInt()}",
                unit: "%",
                progress: _quranLastSuraNo / 114.0,
                color: const Color(0xFF2D9CDB),
                dark: dark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
          ],
        ),
        if (_quranLastReadText != "Bulunmuyor") ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.15 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27A770).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFF27A770), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kur'an-ı Kerim Kaldığın Yer",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _quranLastReadText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_quranLastPercent > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27A770).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "%$_quranLastPercent",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF27A770),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCardNew({
    required String emoji,
    required String title,
    required String value,
    required String unit,
    required double progress,
    required Color color,
    required bool dark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(dark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mini circular progress
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: clampedProgress,
                      color: color,
                      bgColor: dark
                          ? Colors.white.withOpacity(0.06)
                          : color.withOpacity(0.1),
                      strokeWidth: 4,
                    ),
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                TextSpan(
                  text: " $unit",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(
    bool dark,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27A770).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF27A770),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Profil Bilgileri",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Name field
            _buildModernTextField(dark, textPrimary, textSecondary),
            const SizedBox(height: 18),

            // Gender selector label
            Text(
              "Cinsiyet",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Gender toggles
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    emoji: '👨',
                    label: 'Erkek',
                    value: 'erkek',
                    color: const Color(0xFF27A770),
                    dark: dark,
                    textPrimary: textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption(
                    emoji: '👩',
                    label: 'Kadın',
                    value: 'kadin',
                    color: const Color(0xFFE5A93B),
                    dark: dark,
                    textPrimary: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Save button
            _buildSaveButton(dark),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
      bool dark, Color textPrimary, Color textSecondary) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(
        color: textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: "Adınız Soyadınız",
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: dark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF8FAF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFE0EBE4),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF27A770),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 2,
          ),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF27A770).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF27A770),
            size: 17,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Ad alanı boş bırakılamaz.";
        }
        if (value.trim().length < 3) return "Ad en az 3 karakter olmalıdır.";
        return null;
      },
    );
  }

  Widget _buildGenderOption({
    required String emoji,
    required String label,
    required String value,
    required Color color,
    required bool dark,
    required Color textPrimary,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _gender = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(dark ? 0.15 : 0.08)
              : (dark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAF9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : (dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4)),
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
                color: isSelected ? color : (dark ? Colors.white60 : textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool dark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF27A770), Color(0xFF1E8F5E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27A770).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading ? null : _saveProfileChanges,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save_rounded, size: 18),
            const SizedBox(width: 8),
            const Text(
              "Bilgileri Güncelle",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIdCard(
    bool dark,
    Color cardBg,
    Color cardBorder,
    Color textSecondary,
  ) {
    // Show shortened device ID
    final shortId = _email.length > 12
        ? '${_email.substring(0, 6)}...${_email.substring(_email.length - 4)}'
        : _email;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: textSecondary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cihaz Kimliği",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shortId,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white70 : const Color(0xFF3D4F5F),
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _email));
                HapticFeedback.lightImpact();
                _showSnackBar("Cihaz kimliği kopyalandı!", success: true);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27A770).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: Color(0xFF27A770),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ── Custom Circular Progress Painter ──
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
