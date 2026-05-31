import 'dart:async';
import 'package:flutter/material.dart';
import 'data/prayer_repository.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tool_detail_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    });
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

  Future<void> _initializeApp() async {
    final themeStr = await _repository.getThemeMode();
    final isLocSet = await _repository.isLocationSelected();
    await _checkBlockStatus();

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

  void _onLocationReset() {
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
    setState(() {
      _locationSelected = true;
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

  void _onOnboardingComplete() {
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
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF27A770),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
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

  @override
  void initState() {
    super.initState();
    _screens = [
      MainScreen(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onOpenTool: _openToolDetail,
        onLocationReset: widget.onLocationReset,
        onLocationChanged: widget.onLocationChanged,
      ),
      ToolsScreen(
        onOpenTool: _openToolDetail,
        onClose: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        onLocationReset: widget.onLocationReset,
        onLocationChanged: widget.onLocationChanged,
      ),
    ];
  }

  void _openToolDetail(String toolId, String toolTitle) {
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Araçlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
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
