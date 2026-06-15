import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'data/prayer_repository.dart';
import 'services/notification_service.dart';
import 'services/location_cache_service.dart';
import 'screens/main_screen.dart';
import 'screens/prayer_tracker_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tool_detail_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PrayerRepository _repository = PrayerRepository();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.light;
  bool _loading = true;
  bool _locationSelected = false;
  bool _isBlocked = false;
  Timer? _blockTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startBlockCheckTimer();
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    super.dispose();
  }

  void _startBlockCheckTimer() {
    _blockTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _checkBlockStatus();
      _checkPremiumStatus();
      _checkAnnouncements();
    });
  }

  Future<void> _checkAnnouncements() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('id', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 4));

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final idVal = data['id'];
        if (idVal == null) return;
        final String announcementId = idVal.toString();
        final String title = data['title'] ?? 'Yeni Bildirim';
        final String body = data['body'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        final String? lastId = prefs.getString('last_announcement_id');

        if (lastId != announcementId) {
          // Save the new ID immediately so we don't trigger it again
          await prefs.setString('last_announcement_id', announcementId);

          // Get integer ID from timestamp for Notification service
          final notificationId = int.tryParse(
                announcementId.substring(
                  announcementId.length > 6 ? announcementId.length - 6 : 0,
                ),
              ) ??
              999;

          await NotificationService().showNotification(
            id: notificationId,
            title: title,
            body: body,
          );
        }
      }
    } catch (e) {
      print("Announcement check error: $e");
    }
  }

  Future<void> _checkBlockStatus() async {
    try {
      final blocked = await _repository.getGlobalBlockStatus();
      if (blocked != _isBlocked) {
        setState(() {
          _isBlocked = blocked;
        });
      }
    } catch (e) {
      print("Block check error: $e");
    }
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        try {
          final userCredential = await FirebaseAuth.instance.signInAnonymously();
          currentUser = userCredential.user;
          print("Signed in anonymously as Guest: ${currentUser?.uid}");
        } catch (authErr) {
          print("Anonymous sign in failed: $authErr");
        }
      }
      
      if (currentUser != null) {
        final String docId = isLoggedIn ? (prefs.getString('user_email') ?? currentUser.uid) : currentUser.uid;
        
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .get()
            .timeout(const Duration(seconds: 2));
            
        if (doc.exists) {
          final isPremium = doc.data()?['isPremium'] ?? false;
          final localIsPremium = prefs.getBool('is_premium') ?? false;
          if (isPremium != localIsPremium) {
            await prefs.setBool('is_premium', isPremium);
            print("Premium status updated dynamically from Firestore: $isPremium");
          }
        } else {
          if (currentUser.isAnonymous) {
            String ipAddress = '192.168.1.105';
            try {
              final response = await http.get(Uri.parse('https://api.ipify.org')).timeout(const Duration(seconds: 3));
              if (response.statusCode == 200) {
                ipAddress = response.body.trim();
              }
            } catch (_) {}
            
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
              'name': 'Misafir Kullanıcı',
              'email': null,
              'isPremium': false,
              'isAnonymous': true,
              'created': DateTime.now().toIso8601String(),
              'lastActive': DateTime.now().toIso8601String(),
              'ipAddress': ipAddress,
              'platform': Platform.isIOS ? 'iOS' : 'Android',
              'uid': currentUser.uid,
            }).timeout(const Duration(seconds: 3));
            
            await prefs.setBool('is_premium', false);
            print("Created new guest user document in Firestore with Standard access.");
          }
        }
      }
    } catch (e) {
      print("Premium status check error: $e");
    }
  }

  Future<void> _initializeApp() async {
    final themeStr = await _repository.getThemeMode();
    final isLocSet = await _repository.isLocationSelected();
    await _checkBlockStatus();
    await _checkPremiumStatus();

    // Prefetch location and mosques in background on app startup
    LocationCacheService().prefetchLocationAndMosques();

    setState(() {
      _themeMode = _parseThemeMode(themeStr);
      _locationSelected = isLocSet;
      _loading = false;
    });
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  void _onThemeChanged() async {
    final themeStr = await _repository.getThemeMode();
    setState(() {
      _themeMode = _parseThemeMode(themeStr);
    });
  }

  void _onLocationReset() async {
    await _repository.clearLocation();
    setState(() {
      _locationSelected = false;
    });
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SplashScreen(
          onThemeChanged: _onThemeChanged,
          onLocationReset: _onLocationReset,
          onLocationChanged: _onLocationChanged,
          onOnboardingComplete: _onOnboardingComplete,
        ),
      ),
      (route) => false,
    );
  }

  void _onLocationChanged() {
    LocationCacheService().prefetchLocationAndMosques();
    setState(() {
      _locationSelected = true;
    });
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainAppContainerWrapper(
          onThemeChanged: _onThemeChanged,
          onLocationReset: _onLocationReset,
          onLocationChanged: _onLocationChanged,
        ),
      ),
      (route) => false,
    );
  }

  void _onOnboardingComplete() {
    LocationCacheService().prefetchLocationAndMosques();
    setState(() {
      _locationSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return _isBlocked 
              ? const BlockedScreen()
              : child ?? const SizedBox();
        },
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF27A770)),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Namaz Vakitleri',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        return _isBlocked 
            ? const BlockedScreen()
            : child ?? const SizedBox();
      },
      home: SplashScreen(
        onThemeChanged: _onThemeChanged,
        onLocationReset: _onLocationReset,
        onLocationChanged: _onLocationChanged,
        onOnboardingComplete: _onOnboardingComplete,
      ),
    );
  }

  // Light Theme Definition
  ThemeData get _lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF27A770),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF27A770),
        primary: const Color(0xFF27A770),
        secondary: const Color(0xFF1E5E43),
        background: const Color(0xFFF3F8F5),
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E5E43),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F8F5),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF27A770),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Dark Theme Definition
  ThemeData get _darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF27A770),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF27A770),
        primary: const Color(0xFF27A770),
        secondary: const Color(0xFF4CAF50),
        background: const Color(0xFF0A1220),
        surface: const Color(0xFF131D31),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF131D31),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A1220),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF27A770),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF131D31),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF131D31),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class MainAppContainer extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onLocationReset;
  final VoidCallback? onLocationChanged;

  const MainAppContainer({
    super.key,
    required this.onThemeChanged,
    required this.onLocationReset,
    this.onLocationChanged,
  });

  @override
  _MainAppContainerState createState() => _MainAppContainerState();
}

class _MainAppContainerState extends State<MainAppContainer> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late PageController _pageController;
  final GlobalKey<MainScreenState> _mainScreenKey = GlobalKey<MainScreenState>();
  final GlobalKey<SettingsScreenState> _settingsScreenKey = GlobalKey<SettingsScreenState>();

  void _handleLocationChanged() {
    _mainScreenKey.currentState?.loadData();
    _settingsScreenKey.currentState?.loadSettings();
    // Re-prefetch location & mosques for the new location
    LocationCacheService().prefetchLocationAndMosques();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      MainScreen(
        key: _mainScreenKey,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        onOpenTool: _openToolDetail,
        onLocationReset: widget.onLocationReset,
        onLocationChanged: _handleLocationChanged,
      ),
      const PrayerTrackerScreen(),
      const ToolDetailScreen(
        toolId: 'kible-bulucu',
        toolTitle: 'Kıble Bulucu',
        isTab: true,
      ),
      ToolsScreen(
        onOpenTool: _openToolDetail,
        onClose: () {
          setState(() {
            _currentIndex = 0;
          });
          _pageController.jumpToPage(0);
        },
      ),
      SettingsScreen(
        key: _settingsScreenKey,
        onThemeChanged: widget.onThemeChanged,
        onLocationReset: widget.onLocationReset,
        onLocationChanged: _handleLocationChanged,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openToolDetail(String toolId, String toolTitle) {
    if (toolId == 'kible-bulucu') {
      setState(() {
        _currentIndex = 2; // Jump to Qibla Finder tab
      });
      _pageController.jumpToPage(2);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ToolDetailScreen(toolId: toolId, toolTitle: toolTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: CustomGlassNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}

class CustomGlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      bottom: true,
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Layer 1: Frosted Glass Background
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark 
                            ? const Color(0xFF0F172A).withOpacity(0.18)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: dark 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.white.withOpacity(0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.25 : 0.08),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Layer 2: Interactive Tabs Row (with overflowing Qibla Compass)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTab(0, Icons.home_outlined, Icons.home, 'Ana Sayfa', dark),
                      _buildTab(1, null, null, 'Namaz', dark, isSajdah: true),
                      _buildTab(2, null, null, 'Kıble', dark, isQibla: true),
                      _buildTab(3, Icons.grid_view_outlined, Icons.grid_view, 'Araçlar', dark),
                      _buildTab(4, Icons.settings_outlined, Icons.settings, 'Ayarlar', dark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData? inactiveIcon, IconData? activeIcon, String label, bool dark, {bool isSajdah = false, bool isQibla = false}) {
    final bool active = currentIndex == index;
    final activeColor = dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43);
    final inactiveColor = dark ? Colors.white38 : Colors.black45;

    Widget iconWidget;
    if (isQibla) {
      iconWidget = QiblaBottomTabIcon(active: active);
    } else if (isSajdah) {
      iconWidget = SajdahIcon(
        size: 22, 
        filled: active,
      );
      iconWidget = IconTheme(
        data: IconThemeData(color: active ? activeColor : inactiveColor),
        child: iconWidget,
      );
    } else {
      iconWidget = Icon(
        active ? activeIcon : inactiveIcon,
        color: active ? activeColor : inactiveColor,
        size: 22,
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: active && !isQibla
                  ? (dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 28,
                  child: OverflowBox(
                    maxHeight: 60,
                    maxWidth: 60,
                    child: isQibla
                        ? Transform.translate(
                            offset: const Offset(0, -16),
                            child: iconWidget,
                          )
                        : iconWidget,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.0,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active ? activeColor : inactiveColor,
                    letterSpacing: 0.2,
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

class QiblaBottomTabIcon extends StatelessWidget {
  final bool active;
  const QiblaBottomTabIcon({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: dark
                    ? [const Color(0xFF1C2C42), const Color(0xFF131D31)]
                    : [const Color(0xFFFFF9EE), const Color(0xFFFFF0D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: active
                ? const Color(0xFF27A770).withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: active ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.explore,
          size: 26,
          color: active ? Colors.white : const Color(0xFFD4AF37),
        ),
      ),
    );
  }
}

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🚫",
                style: TextStyle(fontSize: 80),
              ),
              SizedBox(height: 24),
              Text(
                "Erişiminiz Engellendi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Kullanım şartlarını ihlal ettiğiniz için İslami Rehber uygulamasına erişiminiz yönetici tarafından engellenmiştir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SajdahIcon extends StatelessWidget {
  final double size;
  final bool filled;

  const SajdahIcon({
    super.key,
    this.size = 24.0,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = IconTheme.of(context).color ?? const Color(0xFFD4AF37);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SajdahIconPainter(color: iconColor, filled: filled),
      ),
    );
  }
}

class _SajdahIconPainter extends CustomPainter {
  final Color color;
  final bool filled;

  _SajdahIconPainter({required this.color, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    // Standard icon grid: 24x24
    final double scaleX = size.width / 24.0;
    final double scaleY = size.height / 24.0;
    canvas.scale(scaleX, scaleY);

    // Fringe paint
    final fringePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Outer rug boundary: X = 5.0 to 19.0, Y = 3.5 to 20.5 (height 17)
    final rugRect = Rect.fromLTRB(5.0, 3.5, 19.0, 20.5);
    final rugRRect = RRect.fromRectAndRadius(rugRect, const Radius.circular(1.5));

    // Inner border boundary: X = 6.5 to 17.5, Y = 5.0 to 19.0
    final innerRect = Rect.fromLTRB(6.5, 5.0, 17.5, 19.0);
    final innerRRect = RRect.fromRectAndRadius(innerRect, const Radius.circular(1.0));

    // Mihrab arch path
    final mihrabPath = Path();
    mihrabPath.moveTo(8.5, 19.0);
    mihrabPath.lineTo(8.5, 12.0);
    mihrabPath.cubicTo(8.5, 9.5, 10.0, 8.5, 12.0, 8.5);
    mihrabPath.cubicTo(14.0, 8.5, 15.5, 9.5, 15.5, 12.0);
    mihrabPath.lineTo(15.5, 19.0);

    // Hanging lamp path
    final lampPath = Path();
    lampPath.moveTo(12.0, 11.5);
    lampPath.lineTo(13.0, 12.5);
    lampPath.lineTo(12.0, 13.5);
    lampPath.lineTo(11.0, 12.5);
    lampPath.close();

    // 1. Draw top & bottom fringes (in both modes)
    for (double x = 5.0; x <= 19.1; x += 2.33) {
      canvas.drawLine(Offset(x, 1.5), Offset(x, 3.5), fringePaint);
      canvas.drawLine(Offset(x, 20.5), Offset(x, 22.5), fringePaint);
    }

    if (filled) {
      // FILLED SECCADE DESIGN
      canvas.saveLayer(Rect.fromLTWH(0, 0, 24, 24), Paint());

      // Draw the solid rug base
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rugRRect, fillPaint);

      // Cut out the inner border, mihrab, and lamp using BlendMode.dstOut
      final cutPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.dstOut;

      canvas.drawRRect(innerRRect, cutPaint);
      canvas.drawPath(mihrabPath, cutPaint);

      final lampCutPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.dstOut;
      canvas.drawPath(lampPath, lampCutPaint);

      // Draw the hanging line as a stroke cutout
      final lampLinePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..blendMode = BlendMode.dstOut;
      canvas.drawLine(const Offset(12.0, 8.5), const Offset(12.0, 11.5), lampLinePaint);

      canvas.restore();
    } else {
      // OUTLINE SECCADE DESIGN
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      // Draw outer rug frame
      canvas.drawRRect(rugRRect, borderPaint);

      // Draw inner border frame (lighter/semi-transparent)
      final innerBorderPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawRRect(innerRRect, innerBorderPaint);

      // Draw mihrab arch
      final mihrabPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(mihrabPath, mihrabPaint);

      // Draw hanging lamp
      final lampPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(lampPath, lampPaint);

      final lampLinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(const Offset(12.0, 8.5), const Offset(12.0, 11.5), lampLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
