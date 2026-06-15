import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../data/prayer_tracker_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final PrayerTrackerState _trackerState = PrayerTrackerState();

  String _email = '';
  String _gender = 'erkek';
  bool _isPremium = false;
  bool _isLoading = false;
  String _lastSyncTime = 'Bilinmiyor';

  // Statistics
  int _currentStreak = 0;
  int _totalCompletedDays = 0;
  int _weeklyCompletedDays = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _trackerState.addListener(_onTrackerChanged);
    _calculateTrackerMetrics();
  }

  @override
  void dispose() {
    _trackerState.removeListener(_onTrackerChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onTrackerChanged() {
    if (!mounted) return;
    setState(() {
      _calculateTrackerMetrics();
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('user_email') ?? '';
      _gender = prefs.getString('user_gender') ?? 'erkek';
      _isPremium = prefs.getBool('is_premium') ?? false;
      _nameController.text = prefs.getString('user_name') ?? '';
      
      // Load last sync time (using current time as initial last sync)
      final now = DateTime.now();
      _lastSyncTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
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
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13.5),
        ),
        backgroundColor: success ? const Color(0xFF27A770) : Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<String> _getPublicIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (_) {}
    return '192.168.1.105';
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String newName = _nameController.text.trim();
    final String ipAddress = await _getPublicIp();
    final String platform = Platform.isIOS ? 'iOS' : 'Android';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      await prefs.setString('user_gender', _gender);

      // Sync with Firestore
      if (_email.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(_email).update({
          'name': newName,
          'gender': _gender,
          'lastActive': DateTime.now().toIso8601String(),
          'ipAddress': ipAddress,
          'platform': platform,
        }).timeout(const Duration(seconds: 3));
      }

      final now = DateTime.now();
      setState(() {
        _lastSyncTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      });

      _showSnackBar("Profil başarıyla güncellendi!", success: true);
    } catch (e) {
      _showSnackBar("Profil güncellenirken bulut senkronizasyon hatası oluştu.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
            width: 1.2,
          ),
        ),
        title: Text(
          'Oturumu Kapat',
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF1E5E43),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(
            color: dark ? Colors.white70 : Colors.black87,
            fontSize: 14.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: TextStyle(color: dark ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB5757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_name');
        await prefs.remove('user_gender');
        await prefs.remove('user_email');
        await prefs.setBool('is_premium', false);

        if (mounted) {
          _showSnackBar("Oturum kapatıldı.", success: true);
          Navigator.pop(context); // Pop back to settings
        }
      } catch (_) {
        _showSnackBar("Oturum kapatılırken bir hata oluştu.");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
            width: 1.2,
          ),
        ),
        title: const Text(
          'Hesabı Sil',
          style: TextStyle(
            color: Color(0xFFEB5757),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm bulut verileriniz silinecektir.',
          style: TextStyle(
            color: dark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Vazgeç', style: TextStyle(color: dark ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB5757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm1 == true) {
      // Secondary confirmation to prevent accidental deletion
      final bool? confirm2 = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: dark ? const Color(0xFF131D31) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
              width: 1.2,
            ),
          ),
          title: const Text(
            'Son Onay',
            style: TextStyle(
              color: Color(0xFFEB5757),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Hesabınız kalıcı olarak silinecektir. Lütfen işlemi onaylayın.',
            style: TextStyle(
              color: dark ? Colors.white70 : Colors.black87,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Vazgeç', style: TextStyle(color: dark ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB5757),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kalıcı Olarak Sil', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirm2 == true) {
        setState(() => _isLoading = true);
        final String ipAddress = await _getPublicIp();
        final String platform = Platform.isIOS ? 'iOS' : 'Android';

        try {
          // 1. Log account deletion to the admin logs
          await FirebaseFirestore.instance.collection('registrations_log').add({
            'name': _nameController.text.trim(),
            'email': _email,
            'gender': _gender,
            'ipAddress': ipAddress,
            'platform': platform,
            'created': DateTime.now().toIso8601String(),
            'appVersion': '1.0.0',
            'action': 'delete_account',
          }).timeout(const Duration(seconds: 3));

          // 2. Delete user document from Firestore users collection
          if (_email.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_email)
                .delete()
                .timeout(const Duration(seconds: 3));
          }

          // 3. Clear local preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', false);
          await prefs.remove('user_name');
          await prefs.remove('user_gender');
          await prefs.remove('user_email');
          await prefs.setBool('is_premium', false);

          if (mounted) {
            _showSnackBar("Hesabınız ve verileriniz başarıyla silindi.", success: true);
            Navigator.pop(context); // Pop back to settings screen
          }
        } catch (e) {
          _showSnackBar("Hesap silinirken sunucu hatası oluştu: $e");
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF090E17) : const Color(0xFFF0F5F2),
      body: Stack(
        children: [
          // Banner background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header navigation bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Profilim",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Avatar Card
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dark ? const Color(0xFF131D31) : Colors.white,
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _gender == 'kadin' ? '👩' : '👨',
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _nameController.text.isNotEmpty ? _nameController.text : "Değerli Kardeşimiz",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Premium state badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: _isPremium
                                      ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFF996515)])
                                      : null,
                                  color: _isPremium ? null : Colors.white24,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _isPremium ? const Color(0xFFD4AF37) : Colors.white30,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _isPremium ? "PRO ÜYE" : "STANDART HESAP",
                                  style: TextStyle(
                                    color: _isPremium ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats Grid (Professional Tracking stats)
                        _buildStatsGrid(dark),

                        const SizedBox(height: 24),

                        // Profile details editing Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF131D31) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.badge_outlined, color: const Color(0xFF27A770), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Profil Bilgileri",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: dark ? Colors.white : const Color(0xFF1E5E43),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
                                  decoration: _buildInputDecoration(
                                    labelText: "Adınız Soyadınız",
                                    icon: Icons.person_outline_rounded,
                                    dark: dark,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return "Ad alanı boş bırakılamaz.";
                                    if (value.trim().length < 3) return "Ad en az 3 karakter olmalıdır.";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Cinsiyet",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: dark ? Colors.white70 : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _gender = 'erkek'),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _gender == 'erkek'
                                                ? const Color(0xFF27A770).withOpacity(0.12)
                                                : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[50]),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _gender == 'erkek'
                                                  ? const Color(0xFF27A770)
                                                  : (dark ? Colors.white10 : Colors.grey[200]!),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('👨', style: TextStyle(fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Erkek',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: _gender == 'erkek'
                                                      ? const Color(0xFF27A770)
                                                      : (dark ? Colors.white70 : Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _gender = 'kadin'),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _gender == 'kadin'
                                                ? const Color(0xFFE5A93B).withOpacity(0.12)
                                                : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[50]),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _gender == 'kadin'
                                                  ? const Color(0xFFE5A93B)
                                                  : (dark ? Colors.white10 : Colors.grey[200]!),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('👩', style: TextStyle(fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Kadın',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: _gender == 'kadin'
                                                      ? const Color(0xFFE5A93B)
                                                      : (dark ? Colors.white70 : Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: _saveProfileChanges,
                                    child: const Text("Bilgileri Güncelle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Info & Sync Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF131D31).withOpacity(0.5) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_done_rounded, color: const Color(0xFF27A770), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Verileriniz Firestore ile senkronize.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: dark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Son Eşitleme: Bugün $_lastSyncTime",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: dark ? Colors.white38 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Danger zone options
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFFEB5757),
                            side: const BorderSide(color: Color(0xFFEB5757), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text("Oturumu Kapat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          onPressed: _logout,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[500],
                          ),
                          icon: const Icon(Icons.delete_forever_rounded, size: 16),
                          label: const Text("Hesabımı Kalıcı Olarak Sil", style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                          onPressed: _deleteAccount,
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF27A770)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool dark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard("Günlük Seri", "$_currentStreak Gün", "🔥", const Color(0xFFEB5757), dark),
        _buildStatCard("Bu Ay Takip", "$_totalCompletedDays Gün", "✅", const Color(0xFF27A770), dark),
        _buildStatCard("Haftalık İbadet", "$_weeklyCompletedDays/7 Gün", "🕋", const Color(0xFFE5A93B), dark),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color accentColor, bool dark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : const Color(0xFF1E5E43),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: dark ? Colors.white38 : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData icon,
    required bool dark,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: dark ? Colors.white60 : Colors.grey[600], fontSize: 13),
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(0.04) : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF27A770), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF27A770), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
