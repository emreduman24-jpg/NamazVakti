import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: success ? const Color(0xFF27A770) : Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate secure network call

    try {
      final prefs = await SharedPreferences.getInstance();
      final String email = _loginEmailController.text.trim();
      final String fallbackName = email.split('@')[0];
      final String formattedName = fallbackName[0].toUpperCase() + fallbackName.substring(1);

      // Default fallback values
      String name = formattedName;
      String gender = 'erkek';
      bool isPremium = false;

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
            'ipAddress': '192.168.1.105', // Mock local IP
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
            'ipAddress': '192.168.1.105',
            'usageDuration': 5, // Simulated initial usage duration in minutes
            'platform': 'Android',
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
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate secure registration

    try {
      final prefs = await SharedPreferences.getInstance();
      final String name = _registerNameController.text.trim();
      final String email = _registerEmailController.text.trim();

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
          'ipAddress': '192.168.1.105', // Mock local IP
          'usageDuration': 0, // Minutes
          'platform': 'Android',
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
      backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: const Text(
          "Giriş & Üyelik",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Styled content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // App Emblem
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF27A770).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.mosque_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "İslami Rehber'e Katılın",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : const Color(0xFF1E5E43),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dualarınızı paylaşmak ve özelliklerinizi eşitlemek için oturum açın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: dark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tab Selectors Card
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dark ? Colors.white.withOpacity(0.05) : const Color(0xFFE0EBE4),
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF27A770),
                      labelColor: const Color(0xFF27A770),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: "Giriş Yap"),
                        Tab(text: "Kayıt Ol"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Forms Container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _tabController.index == 0 ? 300 : 480, // Dynamic height sizing
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLoginForm(dark),
                        _buildRegisterForm(dark),
                      ],
                    ),
                  ),
                ],
              ),
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
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: _buildInputDecoration(
              labelText: "E-posta Adresi",
              icon: Icons.email_outlined,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen e-posta adresinizi girin.";
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return "Geçersiz e-posta formatı.";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: _buildInputDecoration(
              labelText: "Şifre",
              icon: Icons.lock_outlined,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
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
          const SizedBox(height: 24),
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
              child: const Text("Giriş Yap", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: _buildInputDecoration(
              labelText: "Adınız Soyadınız",
              icon: Icons.person_outline,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen adınızı girin.";
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: _buildInputDecoration(
              labelText: "E-posta Adresi",
              icon: Icons.email_outlined,
              dark: dark,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Lütfen e-posta adresinizi girin.";
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return "Geçersiz e-posta formatı.";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: _obscureRegisterPassword,
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: _buildInputDecoration(
              labelText: "Şifre",
              icon: Icons.lock_outlined,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
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
          // Gender Selector Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = 'erkek'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'erkek'
                          ? const Color(0xFF27A770).withOpacity(0.12)
                          : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedGender == 'erkek'
                            ? const Color(0xFF27A770)
                            : (dark ? Colors.white10 : Colors.grey[300]!),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👨', style: TextStyle(fontSize: 18)),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'kadin'
                          ? const Color(0xFFE5A93B).withOpacity(0.12)
                          : (dark ? Colors.white.withOpacity(0.04) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedGender == 'kadin'
                            ? const Color(0xFFE5A93B)
                            : (dark ? Colors.white10 : Colors.grey[300]!),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👩', style: TextStyle(fontSize: 18)),
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
          const SizedBox(height: 24),
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
              child: const Text("Kayıt Ol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
      labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.grey[700], fontSize: 13),
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(0.04) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF27A770), width: 1.5),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF27A770), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
