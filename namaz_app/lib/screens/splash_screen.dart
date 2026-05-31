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
      backgroundColor: const Color(
        0xFFFDFBF7,
      ), // Warm beige background matching Image 1
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

          // 3. Center Content (Arabic & Turkish Greetings + Boy Image)
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
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                          fontFamily: 'Traditional Arabic',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Selamün Aleyküm",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4037),
                          fontFamily: 'Cursive',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Filigree line decoration under calligraphy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFD4AF37),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(
                              Icons.star,
                              size: 8,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFD4AF37),
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
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Thin Loading Line
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 3,
                            width: 140,
                            child: LinearProgressIndicator(
                              value: _loadingProgress,
                              backgroundColor: Colors.grey[200],
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Golden border prayer times panel
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // Premium metallic golden layout
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3E2723), // Dark brown/bronze ends
                                Color(0xFF795548),
                                Color(0xFFD4AF37), // Golden center glow
                                Color(0xFF795548),
                                Color(0xFF3E2723),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                _buildTimeColumn("İMSAK", imsak, isFirst: true),
                                _buildDivider(),
                                _buildTimeColumn("GÜNEŞ", gunes),
                                _buildDivider(),
                                _buildTimeColumn("ÖĞLE", ogle),
                                _buildDivider(),
                                _buildTimeColumn("İKİNDİ", ikindi),
                                _buildDivider(),
                                _buildTimeColumn("AKŞAM", aksam),
                                _buildDivider(),
                                _buildTimeColumn("YATSI", yatsi, isLast: true),
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
    return Container(width: 1, height: 30, color: Colors.white24);
  }

  Widget _buildTimeColumn(
    String title,
    String time, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "($time)",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    final paint = Paint()
      ..color = const Color(0xFFC8A261)
          .withOpacity(0.18) // Delicate golden-beige
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw concentric circles
    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 90, paint);
    canvas.drawCircle(center, 120, paint);

    // Draw an 8-pointed star (two overlapping squares rotated by 45 deg)
    _drawStar(canvas, center, 60, 8, paint);
    _drawStar(canvas, center, 85, 16, paint);
    _drawStar(canvas, center, 110, 8, paint);

    // Draw some flower petal curves / arcs around the outer border
    final outerPaint = Paint()
      ..color = const Color(0xFFC8A261).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final petalCount = 24;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      final petalCenter = Offset(
        center.dx + 125 * math.cos(angle),
        center.dy + 125 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, 14, paint);
      canvas.drawCircle(petalCenter, 8, outerPaint);
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    int points,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius = i % 2 == 0 ? radius : radius * 0.75;
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
    final goldPaint = Paint()
      ..color = const Color(0xFFC8A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final goldFill = Paint()
      ..color = const Color(0xFFC8A261)
      ..style = PaintingStyle.fill;

    // 1. Draw hanging chain
    canvas.drawLine(
      const Offset(50, 0),
      const Offset(50, 180),
      goldPaint..strokeWidth = 1.5,
    );

    // 2. Draw lantern attachment ring at chain end
    canvas.drawCircle(const Offset(50, 180), 6, goldPaint..strokeWidth = 2.0);

    // 3. Draw lantern top cap dome
    final domePath = Path();
    domePath.moveTo(35, 195);
    domePath.quadraticBezierTo(50, 182, 65, 195);
    domePath.lineTo(72, 205);
    domePath.lineTo(28, 205);
    domePath.close();
    canvas.drawPath(domePath, goldFill);

    // Draw little hanging ornament under cap
    canvas.drawRect(const Rect.fromLTWH(30, 205, 40, 4), goldFill);

    // 4. Draw lantern glass body (glow inside)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9C4).withOpacity(0.95), // Glowing yellow center
          const Color(0xFFFFD54F).withOpacity(0.6),
          const Color(0xFFC8A261).withOpacity(0.1),
        ],
      ).createShader(const Rect.fromLTRB(25, 209, 75, 269))
      ..style = PaintingStyle.fill;

    // Paint glow
    canvas.drawRect(const Rect.fromLTWH(26, 209, 48, 60), glowPaint);

    // Draw glass outer arches/lines
    final glassPath = Path();
    glassPath.moveTo(30, 209);
    glassPath.lineTo(24, 269);
    glassPath.lineTo(76, 269);
    glassPath.lineTo(70, 209);
    glassPath.close();
    canvas.drawPath(glassPath, goldPaint..strokeWidth = 2.0);

    // Draw vertical ornamental grilles inside glass
    canvas.drawCurve(const Offset(35, 209), const Offset(31, 269), goldPaint);
    canvas.drawCurve(const Offset(50, 209), const Offset(50, 269), goldPaint);
    canvas.drawCurve(const Offset(65, 209), const Offset(69, 269), goldPaint);

    // 5. Draw lantern bottom plate and tip ornament
    canvas.drawRect(const Rect.fromLTWH(20, 269, 60, 5), goldFill);

    final tipPath = Path();
    tipPath.moveTo(25, 274);
    tipPath.lineTo(50, 298); // pointy end
    tipPath.lineTo(75, 274);
    tipPath.close();
    canvas.drawPath(tipPath, goldFill);

    // Tiny gold ring at the very tip
    canvas.drawCircle(const Offset(50, 298), 3, goldFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension to easily draw curved lines in CustomPainter
extension CanvasCurve on Canvas {
  void drawCurve(Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + 3,
      (start.dy + end.dy) / 2,
    );
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.controlPointY(start, end),
      end.dx,
      end.dy,
    );
    drawPath(path, paint);
  }
}

extension ControlPointExtension on Offset {
  double controlPointY(Offset start, Offset end) {
    return (start.dy + end.dy) / 2;
  }
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
