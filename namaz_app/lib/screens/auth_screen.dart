import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  String _selectedGender = 'erkek';
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Trigger rebuild to update dynamic heights
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
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

  bool _isValidEmail(String email) {
    // 1. Check regex format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$');
    if (!emailRegex.hasMatch(email)) return false;

    final lower = email.toLowerCase().trim();
    final domain = lower.split('@').last;
    
    // 2. Blacklist of temporary/junk/obviously-fake email domains
    const blacklistedDomains = {
      'tempmail.com', 'yopmail.com', 'mailinator.com', '10minutemail.com',
      'guerrillamail.com', 'sharklasers.com', 'dispostable.com', 'getairmail.com',
      'maildrop.cc', 'temp-mail.org', 'throwawaymail.com', 'burnermail.io',
      'example.com', 'test.com', 'fake.com', 'random.com', 'sallama.com',
      'temp.com', 'deneme.com', 'mail.com', 'a.com', 'b.com', 'c.com',
      'xyz.com', 'qq.com', '123.com', 'abc.com', 'testmail.com', 'asd.com',
      'qwerty.com', '111.com', '222.com', '333.com', '444.com', '555.com'
    };

    if (blacklistedDomains.contains(domain)) {
      return false;
    }

    // 3. Ensure parts have reasonable sizes
    final parts = domain.split('.');
    if (parts.length < 2) return false;
    if (parts.last.length < 2) return false; // e.g. .c is invalid, needs .co, .com
    if (parts.first.length < 2) return false; // e.g. a.com is invalid

    return true;
  }

  Future<String> _getPublicIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (_) {}
    return '192.168.1.105'; // Fallback local mock IP if offline
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String email = _loginEmailController.text.trim();
    final String fallbackName = email.split('@')[0];
    final String formattedName = fallbackName[0].toUpperCase() + fallbackName.substring(1);

    String name = formattedName;
    String gender = 'erkek';
    bool isPremium = false;

    final String ipAddress = await _getPublicIp();
    final String platform = Platform.isIOS ? 'iOS' : 'Android';

    try {
      final prefs = await SharedPreferences.getInstance();

      // Connect to Firestore to sync user details
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(email);
        final docSnap = await docRef.get().timeout(const Duration(seconds: 3));
        if (docSnap.exists) {
          final data = docSnap.data();
          if (data != null) {
            name = data['name'] ?? name;
            gender = data['gender'] ?? gender;
            isPremium = data['isPremium'] ?? false;
          }
          // Update active status
          await docRef.update({
            'lastActive': DateTime.now().toIso8601String(),
            'ipAddress': ipAddress,
            'platform': platform,
          }).timeout(const Duration(seconds: 2));
        } else {
          // Register in Firestore if didn't exist
          await docRef.set({
            'name': name,
            'email': email,
            'gender': gender,
            'isPremium': false,
            'created': DateTime.now().toIso8601String(),
            'lastActive': DateTime.now().toIso8601String(),
            'ipAddress': ipAddress,
            'usageDuration': 5,
            'platform': platform,
          }).timeout(const Duration(seconds: 3));

          // Log registration to the admin panel logs
          await FirebaseFirestore.instance.collection('registrations_log').add({
            'name': name,
            'email': email,
            'gender': gender,
            'ipAddress': ipAddress,
            'platform': platform,
            'created': DateTime.now().toIso8601String(),
            'appVersion': '1.0.0',
            'action': 'login_register_auto',
          }).timeout(const Duration(seconds: 3));
        }
      } catch (firestoreErr) {
        print("Firestore login sync failed: $firestoreErr");
      }

      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', name);
      await prefs.setString('user_gender', gender);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_premium', isPremium);

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Giriş başarılı! Hoş geldiniz.", success: true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Giriş yaparken hata oluştu.");
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String name = _registerNameController.text.trim();
    final String email = _registerEmailController.text.trim();

    final String ipAddress = await _getPublicIp();
    final String platform = Platform.isIOS ? 'iOS' : 'Android';

    try {
      final prefs = await SharedPreferences.getInstance();

      // Register locally
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', name);
      await prefs.setString('user_gender', _selectedGender);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_premium', false);

      // Register in Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(email).set({
          'name': name,
          'email': email,
          'gender': _selectedGender,
          'isPremium': false,
          'created': DateTime.now().toIso8601String(),
          'lastActive': DateTime.now().toIso8601String(),
          'ipAddress': ipAddress,
          'usageDuration': 0,
          'platform': platform,
        }).timeout(const Duration(seconds: 3));

        // Log registration to the admin panel logs
        await FirebaseFirestore.instance.collection('registrations_log').add({
          'name': name,
          'email': email,
          'gender': _selectedGender,
          'ipAddress': ipAddress,
          'platform': platform,
          'created': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
          'action': 'register',
        }).timeout(const Duration(seconds: 3));
      } catch (firestoreErr) {
        print("Firestore registration sync failed: $firestoreErr");
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Hesabınız başarıyla oluşturuldu!", success: true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Kayıt olurken hata oluştu.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF090E17) : const Color(0xFFF0F5F2),
      body: Stack(
        children: [
          // Background Gradient Decorator
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF27A770).withOpacity(dark ? 0.08 : 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5A93B).withOpacity(dark ? 0.05 : 0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Navigation Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: dark ? Colors.white.withOpacity(0.04) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                            color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
                            width: 1,
                          ),
                        ),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: dark ? Colors.white70 : const Color(0xFF1E5E43), size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        _tabController.index == 0 ? "Giriş Yap" : "Yeni Üyelik",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : const Color(0xFF1E5E43),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing spacer
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // App Logo/Badge
                        Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.8), width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF27A770).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.mosque_rounded, color: Colors.white, size: 42),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Vakit Dua",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: dark ? Colors.white : const Color(0xFF1E5E43),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            "Hesabınızı oluşturun ve dualarınızı buluta eşitleyin.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: dark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tab selectors card
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF131D31) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE0EBE4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey[500],
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: "Giriş Yap"),
                              Tab(text: "Kayıt Ol"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Container with dynamic heights
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Container(
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
                                  color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _tabController.index == 0
                                ? _buildLoginForm(dark)
                                : _buildRegisterForm(dark),
                          ),
                        ),

                        // Social Logins (Visual embellishment to look professional)
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(child: Divider(color: dark ? Colors.white10 : Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "veya şununla devam et",
                                style: TextStyle(color: dark ? Colors.white38 : Colors.grey[500], fontSize: 12),
                              ),
                            ),
                            Expanded(child: Divider(color: dark ? Colors.white10 : Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: dark ? Colors.white.withOpacity(0.02) : Colors.white,
                                  foregroundColor: dark ? Colors.white70 : Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(
                                    color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 28),
                                label: const Text("Google", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                onPressed: () => _showSnackBar("Google ile Giriş yakında hizmetinizde!"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: dark ? Colors.white.withOpacity(0.02) : Colors.white,
                                  foregroundColor: dark ? Colors.white70 : Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(
                                    color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0EBE4),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: Icon(Icons.apple_rounded, color: dark ? Colors.white : Colors.black87, size: 20),
                                label: const Text("Apple", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                onPressed: () => _showSnackBar("Apple ile Giriş yakında hizmetinizde!"),
                              ),
                            ),
                          ],
                        ),
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
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF27A770)),
                        const SizedBox(height: 18),
                        Text(
                          "Güvenli Bağlantı Kuruluyor...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : const Color(0xFF1E5E43),
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

  Widget _buildLoginForm(bool dark) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: _buildInputDecoration(
              labelText: "E-posta Adresi",
              icon: Icons.email_outlined,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen e-posta adresinizi girin.";
              if (!_isValidEmail(value)) return "Lütfen gerçek ve geçerli bir e-posta adresi girin.";
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: _buildInputDecoration(
              labelText: "Şifre",
              icon: Icons.lock_outlined,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureLoginPassword = !_obscureLoginPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Lütfen şifrenizi girin.";
              if (value.length < 6) return "Şifre en az 6 karakter olmalıdır.";
              return null;
            },
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27A770).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _handleLogin,
              child: const Text("Giriş Yap", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(bool dark) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _registerNameController,
            style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: _buildInputDecoration(
              labelText: "Adınız Soyadınız",
              icon: Icons.person_outline_rounded,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen adınızı girin.";
              if (value.trim().length < 3) return "Adınız en az 3 karakter olmalıdır.";
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: _buildInputDecoration(
              labelText: "E-posta Adresi",
              icon: Icons.email_outlined,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen e-posta adresinizi girin.";
              if (!_isValidEmail(value)) return "Lütfen gerçek ve geçerli bir e-posta adresi girin.";
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: _obscureRegisterPassword,
            style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: _buildInputDecoration(
              labelText: "Şifre",
              icon: Icons.lock_outlined,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureRegisterPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureRegisterPassword = !_obscureRegisterPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Lütfen bir şifre girin.";
              if (value.length < 6) return "Şifre en az 6 karakter olmalıdır.";
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Gender Selection Label
          Text(
            "Cinsiyetiniz",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          // Gender Selector Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = 'erkek'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'erkek'
                          ? const Color(0xFF27A770).withOpacity(0.12)
                          : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedGender == 'erkek'
                            ? const Color(0xFF27A770)
                            : (dark ? Colors.white10 : Colors.grey[300]!),
                        width: 1.8,
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
                            color: _selectedGender == 'erkek'
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
                  onTap: () => setState(() => _selectedGender = 'kadin'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'kadin'
                          ? const Color(0xFFE5A93B).withOpacity(0.12)
                          : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedGender == 'kadin'
                            ? const Color(0xFFE5A93B)
                            : (dark ? Colors.white10 : Colors.grey[300]!),
                        width: 1.8,
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
                            color: _selectedGender == 'kadin'
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
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27A770).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _handleRegister,
              child: const Text("Kayıt Ol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
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
    Widget? suffix,
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
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
