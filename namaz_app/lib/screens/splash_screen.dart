import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/prayer_repository.dart';
import '../data/prayer_data.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onLocationReset;
  final VoidCallback onLocationChanged;
  final VoidCallback onOnboardingComplete;

  const SplashScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocationReset,
    required this.onLocationChanged,
    required this.onOnboardingComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final PrayerRepository _repository = PrayerRepository();
  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  Map<String, dynamic>? _todayTimes;
  bool _isLocationSelected = false;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _startLoadingAnimation();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    final isSelected = await _repository.isLocationSelected();
    Map<String, dynamic>? times;

    if (isSelected) {
      final loc = await _repository.getSavedLocation();
      final districtId = loc['districtId'];
      if (districtId != null) {
        final list = await _repository.getPrayerTimes(districtId);
        final nowStr = _formatDate(DateTime.now());
        for (var item in list) {
          if (item['MiladiTarihKisa'] == nowStr) {
            times = item;
            break;
          }
        }
        if (times == null && list.isNotEmpty) {
          times = list.first;
        }
      }
    }

    // Default mock times from Image 1 if not configured/available
    times ??= {
      "Imsak": "05:41",
      "Gunes": "07:05",
      "Ogle": "13:18",
      "Ikindi": "16:39",
      "Aksam": "19:20",
      "Yatsi": "20:38",
    };

    if (mounted) {
      setState(() {
        _todayTimes = times;
        _isLocationSelected = isSelected;
      });
    }
  }

  String _formatDate(DateTime dt) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    return "$day.$month.${dt.year}";
  }

  void _startLoadingAnimation() {
    const totalSteps = 60;
    const duration = Duration(milliseconds: 3000);
    final stepDuration = duration ~/ totalSteps;
    int currentStep = 0;

    _progressTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _loadingProgress = currentStep / totalSteps;
        });
      }

      if (currentStep >= totalSteps) {
        timer.cancel();
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Pass root configuration to the next screen dynamically
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _isLocationSelected
            ? MainAppContainerWrapper(
                onThemeChanged: widget.onThemeChanged,
                onLocationReset: widget.onLocationReset,
                onLocationChanged: widget.onLocationChanged,
              )
            : OnboardingScreen(
                onComplete: widget.onOnboardingComplete,
                onThemeChanged: widget.onThemeChanged,
                onLocationReset: widget.onLocationReset,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // String representations for the times
    final imsak = _todayTimes?['Imsak'] ?? '05:41';
    final gunes = _todayTimes?['Gunes'] ?? '07:05';
    final ogle = _todayTimes?['Ogle'] ?? '13:18';
    final ikindi = _todayTimes?['Ikindi'] ?? '16:39';
    final aksam = _todayTimes?['Aksam'] ?? '19:20';
    final yatsi = _todayTimes?['Yatsi'] ?? '20:38';

    final percent = (_loadingProgress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm beige background
      body: Stack(
        children: [
          // 1. Top-Left Islamic Geometric Mandala Ornament
          Positioned(
            left: -80,
            top: -80,
            child: SizedBox(
              width: 320,
              height: 320,
              child: CustomPaint(painter: MandalaPainter()),
            ),
          ),

          // 2. Top-Right Elegant Hanging Golden Lantern
          Positioned(
            right: 40,
            top: 0,
            child: SizedBox(
              width: 100,
              height: 350,
              child: CustomPaint(painter: LanternPainter()),
            ),
          ),

          // 3. Center Content (Arabic & Turkish Greetings + Boy Image + Loading + Prayer Times)
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 140),

                  // Calligraphy block
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "سَلَامٌ عَلَيْكُمْ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E63), // Soft elegant brown/bronze
                          fontFamily: 'serif',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selamün Aleyküm",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4037),
                          fontStyle: FontStyle.italic,
                          fontFamily: 'serif',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Filigree line decoration under calligraphy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 1.2,
                            color: const Color(0xFFC8A261).withOpacity(0.5),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "•••• ⚜ ••••",
                              style: TextStyle(
                                color: Color(0xFFC8A261),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 1.2,
                            color: const Color(0xFFC8A261).withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 3D Cartoon character boy
                  Image.asset(
                    'assets/muslim_boy_heart.png',
                    height: 270,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  // 4. Loading indicator & golden panel at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Loading Progress Indicator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$percent%",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Thin Loading Line
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            height: 2.5,
                            width: 140,
                            child: LinearProgressIndicator(
                              value: _loadingProgress,
                              backgroundColor: Colors.black12,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Golden border mahogany prayer times panel
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF231513), // Deep chocolate
                                Color(0xFF3E2723), // Mahogany
                                Color(0xFF231513),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFC8A261),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 6.0,
                            ),
                            child: Row(
                              children: [
                                _buildTimeColumn("İMSAK", imsak, Icons.nights_stay_outlined, isFirst: true),
                                _buildDivider(),
                                _buildTimeColumn("GÜNEŞ", gunes, Icons.wb_sunny_outlined),
                                _buildDivider(),
                                _buildTimeColumn("ÖĞLE", ogle, Icons.wb_sunny),
                                _buildDivider(),
                                _buildTimeColumn("İKİNDİ", ikindi, Icons.wb_sunny_rounded),
                                _buildDivider(),
                                _buildTimeColumn("AKŞAM", aksam, Icons.wb_twilight_outlined),
                                _buildDivider(),
                                _buildTimeColumn("YATSI", yatsi, Icons.bedtime_outlined, isLast: true),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 35, color: Colors.white12);
  }

  Widget _buildTimeColumn(
    String title,
    String time,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFFC8A261),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "($time)",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFF8E1),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a beautiful, detailed Islamic Geometric Mandala Motif on the top-left
class MandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final goldPaint = Paint()
      ..color = const Color(0xFFC8A261).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles
    canvas.drawCircle(center, 25, goldPaint);
    canvas.drawCircle(center, 45, goldPaint);
    canvas.drawCircle(center, 65, goldPaint);
    canvas.drawCircle(center, 90, goldPaint);
    canvas.drawCircle(center, 115, goldPaint);
    canvas.drawCircle(center, 130, goldPaint);

    // Intricate nested star polygons (8-point, 12-point, 16-point, 24-point)
    _drawStar(canvas, center, 40, 8, goldPaint);
    _drawStar(canvas, center, 60, 12, goldPaint);
    _drawStar(canvas, center, 85, 16, goldPaint);
    _drawStar(canvas, center, 110, 24, goldPaint);

    // Draw detailed flower-like outer petals
    final petalCount = 32;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      
      // Small outer loops/arcs
      final x1 = center.dx + 130 * math.cos(angle);
      final y1 = center.dy + 130 * math.sin(angle);
      final x2 = center.dx + 130 * math.cos(angle + (2 * math.pi / petalCount));
      final y2 = center.dy + 130 * math.sin(angle + (2 * math.pi / petalCount));
      
      final controlAngle = angle + (math.pi / petalCount);
      final cx = center.dx + 148 * math.cos(controlAngle);
      final cy = center.dy + 148 * math.sin(controlAngle);
      
      final path = Path();
      path.moveTo(x1, y1);
      path.quadraticBezierTo(cx, cy, x2, y2);
      canvas.drawPath(path, goldPaint);
      
      // Draw small circle dots at the tip of each petal
      final tipX = center.dx + 143 * math.cos(controlAngle);
      final tipY = center.dy + 143 * math.sin(controlAngle);
      canvas.drawCircle(Offset(tipX, tipY), 2.5, goldPaint..style = PaintingStyle.fill);
      goldPaint.style = PaintingStyle.stroke; // restore
      
      // Secondary inner loops
      final ix1 = center.dx + 115 * math.cos(angle);
      final iy1 = center.dy + 115 * math.sin(angle);
      final ix2 = center.dx + 115 * math.cos(angle + (2 * math.pi / petalCount));
      final iy2 = center.dy + 115 * math.sin(angle + (2 * math.pi / petalCount));
      
      final icx = center.dx + 124 * math.cos(controlAngle);
      final icy = center.dy + 124 * math.sin(controlAngle);
      
      final ipath = Path();
      ipath.moveTo(ix1, iy1);
      ipath.quadraticBezierTo(icx, icy, ix2, iy2);
      canvas.drawPath(ipath, goldPaint);
    }
    
    // Draw center sunburst rays
    final rayCount = 16;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final start = Offset(
        center.dx + 10 * math.cos(angle),
        center.dy + 10 * math.sin(angle),
      );
      final end = Offset(
        center.dx + 25 * math.cos(angle),
        center.dy + 25 * math.sin(angle),
      );
      canvas.drawLine(start, end, goldPaint..strokeWidth = 1.2);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, int points, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius = i % 2 == 0 ? radius : radius * 0.82;
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw a beautiful, detailed golden hanging lantern on the top-right
class LanternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Elegant brass/gold paint
    final goldPaint = Paint()
      ..color = const Color(0xFFC8A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final goldFill = Paint()
      ..color = const Color(0xFFC8A261)
      ..style = PaintingStyle.fill;

    // Glowing shader for the lantern interior
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFF59D).withOpacity(0.95), // Glowing warm yellow center
          const Color(0xFFFFB300).withOpacity(0.7),
          const Color(0xFFC8A261).withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.55, 0.85, 1.0],
      ).createShader(const Rect.fromLTRB(15, 185, 85, 275))
      ..style = PaintingStyle.fill;

    // 1. Draw hanging chain (multiple linked oval shapes)
    final chainPaint = Paint()
      ..color = const Color(0xFFC8A261).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double y = 0; y < 155; y += 12) {
      canvas.drawOval(Rect.fromLTRB(48, y, 52, y + 14), chainPaint);
    }

    // 2. Draw ornate top attachment scrollwork
    final scrollPath = Path();
    scrollPath.moveTo(35, 160);
    scrollPath.quadraticBezierTo(50, 150, 65, 160);
    scrollPath.quadraticBezierTo(50, 172, 35, 160);
    canvas.drawPath(scrollPath, goldFill);
    canvas.drawCircle(const Offset(50, 153), 3, goldFill);

    // 3. Draw lantern dome/cap (mosque dome style with detailed steps)
    // Base of cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 175, 48, 6),
        const Radius.circular(2),
      ),
      goldFill,
    );
    // Dome shape
    final domePath = Path();
    domePath.moveTo(30, 175);
    domePath.cubicTo(30, 162, 50, 158, 50, 158);
    domePath.cubicTo(50, 158, 70, 162, 70, 175);
    domePath.close();
    canvas.drawPath(domePath, goldFill);

    // Little details on dome cap
    canvas.drawCircle(const Offset(50, 158), 2.5, goldFill);

    // 4. Lantern body - glass glow
    final glassPath = Path();
    glassPath.moveTo(32, 181);
    glassPath.lineTo(22, 250);
    glassPath.quadraticBezierTo(50, 260, 78, 250);
    glassPath.lineTo(68, 181);
    glassPath.close();
    canvas.drawPath(glassPath, glowPaint);

    // 5. Draw gold metal frame around glass
    canvas.drawPath(glassPath, goldPaint..strokeWidth = 2.0);

    // 6. Detailed filigree/cage overlay on glass
    canvas.drawLine(const Offset(29, 204), const Offset(71, 204), goldPaint..strokeWidth = 1.0);
    canvas.drawLine(const Offset(25, 228), const Offset(75, 228), goldPaint..strokeWidth = 1.0);

    // Arched vertical window-like division bars
    final archPath1 = Path();
    archPath1.moveTo(37, 181);
    archPath1.lineTo(31, 252);
    canvas.drawPath(archPath1, goldPaint..strokeWidth = 1.2);

    final archPath2 = Path();
    archPath2.moveTo(50, 181);
    archPath2.lineTo(50, 255);
    canvas.drawPath(archPath2, goldPaint..strokeWidth = 1.5);

    final archPath3 = Path();
    archPath3.moveTo(63, 181);
    archPath3.lineTo(69, 252);
    canvas.drawPath(archPath3, goldPaint..strokeWidth = 1.2);

    // Mini decorative diamonds/stars at cage intersections
    canvas.drawRect(const Rect.fromLTWH(48.5, 202.5, 3, 3), goldFill);
    canvas.drawRect(const Rect.fromLTWH(48.5, 226.5, 3, 3), goldFill);

    // 7. Ornate bottom structure
    final bottomPath = Path();
    bottomPath.moveTo(22, 250);
    bottomPath.lineTo(32, 266);
    bottomPath.lineTo(68, 266);
    bottomPath.lineTo(78, 250);
    bottomPath.quadraticBezierTo(50, 258, 22, 250);
    canvas.drawPath(bottomPath, goldFill);

    // Lower ornamental collar
    canvas.drawRect(const Rect.fromLTWH(36, 266, 28, 4), goldFill);

    // Bottom pointy tip pendant
    final tipPath = Path();
    tipPath.moveTo(40, 270);
    tipPath.lineTo(50, 285);
    tipPath.lineTo(60, 270);
    tipPath.close();
    canvas.drawPath(tipPath, goldFill);

    // Hanging little bead/droplet at the bottom tip
    canvas.drawCircle(const Offset(50, 290), 3.0, goldFill);
    canvas.drawLine(const Offset(50, 285), const Offset(50, 290), goldPaint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Temporary wrapper class to allow MainAppContainer mapping
class MainAppContainerWrapper extends StatelessWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onLocationReset;
  final VoidCallback? onLocationChanged;

  const MainAppContainerWrapper({
    super.key,
    required this.onThemeChanged,
    required this.onLocationReset,
    this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MainAppContainer(
      onThemeChanged: onThemeChanged,
      onLocationReset: onLocationReset,
      onLocationChanged: onLocationChanged,
    );
  }
}
