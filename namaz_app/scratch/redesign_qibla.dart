import 'dart:io';

void main() {
  final file = File('lib/screens/tool_detail_screen.dart');
  if (!file.existsSync()) {
    print('Error: lib/screens/tool_detail_screen.dart not found.');
    exit(1);
  }

  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Find the boundaries of the original _buildKibleBulucu
  final startKey = '  Widget _buildKibleBulucu() {';
  final endKey = '  Widget _buildZikirmatik() {';

  final startIndex = content.indexOf(startKey);
  final endIndex = content.indexOf(endKey);

  if (startIndex == -1 || endIndex == -1) {
    print('Error: Could not locate Qibla Finder boundaries in file.');
    exit(1);
  }

  final newKibleBulucu = '''  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        bool hasSensor = heading != null && !_forceSimulation;

        // Use manual rotation if no sensor is available or simulation is forced
        double finalHeading = hasSensor ? heading : _manualCompassHeading;
        double needleRotation = qiblaAngle - finalHeading;
        double dialRotation = -finalHeading;

        // Calculate difference for direction instructions
        double diff = (qiblaAngle - finalHeading) % 360;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        
        bool isAligned = diff.abs() < 3;
        final bool dark = _isDark;

        Widget instructionWidget;
        if (isAligned) {
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF27A770).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF27A770), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27A770),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "KIBLEYE HİZALANDI 🕋",
                  style: TextStyle(
                    color: Color(0xFF27A770),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        } else {
          String dirText = diff > 0 
              ? "Sağa Dönün: \${diff.round()}° ↪️" 
              : "Sola Dönün: \${diff.abs().round()}° ↩️";
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Card(
                color: dark ? const Color(0xFF251A0A) : const Color(0xFFFFF7EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(
                    color: dark ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Cihazınızı düz zeminde yatay tutun.",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Pusulayı döndürerek Kabe sembolünü (🕋) en üstteki hedef çizgisi ile hizalayın.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: dark ? Colors.white60 : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Custom Visual Compass stack
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fixed outer glow ring that turns green when aligned
                    Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAligned 
                              ? const Color(0xFF27A770).withOpacity(0.8) 
                              : (dark ? const Color(0xFF1E2E4A) : const Color(0xFFE2E8F0)),
                          width: 2.5,
                        ),
                        boxShadow: [
                          if (isAligned)
                            BoxShadow(
                              color: const Color(0xFF27A770).withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                    // Compass Ring (Dial) rotated by DialRotation
                    Transform.rotate(
                      angle: (dialRotation * 3.141592653589793 / 180),
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: dark ? Colors.black45 : Colors.black12,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _KiblePusulaPainter(
                            qiblaAngle: qiblaAngle,
                            isDark: dark,
                          ),
                          child: Stack(
                            children: [
                              // K (Kuzey - North) at top (0°)
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 14.0),
                                  child: Text(
                                    "K",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // G (Güney - South) at bottom (180°)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: Text(
                                    "G",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: dark ? Colors.white70 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // B (Batı - West) at left (270°)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "B",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: dark ? Colors.white70 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // D (Doğu - East) at right (90°)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: Text(
                                    "D",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: dark ? Colors.white70 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Compass Needle (Qibla pointer) pointing to qiblaAngle
                    Transform.rotate(
                      angle: (needleRotation * 3.141592653589793 / 180),
                      child: SizedBox(
                        width: 70,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Main golden indicator line pointing UP
                            Positioned(
                              top: 25,
                              bottom: 100,
                              child: Container(
                                width: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      dark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFF27A770).withOpacity(0.3),
                                      dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Beautiful Kaaba card at the top
                            Positioned(
                              top: 15,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isAligned ? const Color(0xFF27A770) : (dark ? const Color(0xFF1A263F) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isAligned ? Colors.white : (dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770)),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isAligned 
                                          ? const Color(0xFF27A770).withOpacity(0.6) 
                                          : Colors.black12,
                                      blurRadius: isAligned ? 12 : 4,
                                      spreadRadius: isAligned ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "🕋",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            // Center golden ring/dot
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fixed Alignment Target at the top
                    Positioned(
                      top: 0,
                      child: Icon(
                        Icons.arrow_drop_down_sharp,
                        color: isAligned ? const Color(0xFF27A770) : Colors.red,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Intelligent alignment instruction widget
              instructionWidget,
              
              const SizedBox(height: 24),
              Text(
                "Kıble Açısı: \${qiblaAngle.toInt()}° (İstanbul)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _greenColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasSensor
                    ? "Pusula Yönü: \${finalHeading.round()}°"
                    : "Simüle Yönü: \${finalHeading.round()}°",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SwitchListTile(
                  title: const Text(
                    "Simülasyon Modu",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Pusulayı el ile döndürmek için aktifleştirin",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _forceSimulation,
                  activeColor: const Color(0xFF27A770),
                  onChanged: (val) {
                    setState(() {
                      _forceSimulation = val;
                    });
                  },
                ),
              ),
              if (!hasSensor) ...[
                const SizedBox(height: 8),
                const Text(
                  "Sürgü ile pusula açısını döndürün:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Slider(
                    value: _manualCompassHeading,
                    min: 0,
                    max: 360,
                    activeColor: const Color(0xFF27A770),
                    onChanged: (val) {
                      setState(() {
                        _manualCompassHeading = val;
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

''';

  // Perform replacement of the _buildKibleBulucu method
  content = content.replaceRange(startIndex, endIndex, newKibleBulucu);

  // Define CustomPainter class to append at the bottom of the file
  final customPainterCode = '''

class _KiblePusulaPainter extends CustomPainter {
  final double qiblaAngle;
  final bool isDark;

  _KiblePusulaPainter({required this.qiblaAngle, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Paint concentric circles
    final circlePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.02) : const Color(0xFF27A770).withOpacity(0.03)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFF1E5E43).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(center, radius - 8, borderPaint);

    // 2. Paint Islamic Star Pattern (8-pointed star) at the center
    final starPaint = Paint()
      ..color = isDark ? const Color(0xFFD4AF37).withOpacity(0.08) : const Color(0xFF27A770).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final double starRadius = radius * 0.45;
    
    // First square
    path.moveTo(center.dx + starRadius, center.dy);
    path.lineTo(center.dx, center.dy + starRadius);
    path.lineTo(center.dx - starRadius, center.dy);
    path.lineTo(center.dx, center.dy - starRadius);
    path.close();

    // Second square rotated by 45 degrees
    final double diagonalRadius = starRadius * 0.70710678118; // cos(45)
    path.moveTo(center.dx + diagonalRadius, center.dy + diagonalRadius);
    path.lineTo(center.dx - diagonalRadius, center.dy + diagonalRadius);
    path.lineTo(center.dx - diagonalRadius, center.dy - diagonalRadius);
    path.lineTo(center.dx + diagonalRadius, center.dy - diagonalRadius);
    path.close();

    canvas.drawPath(path, starPaint);

    // Draw small inner circle
    canvas.drawCircle(center, starRadius * 0.4, starPaint);

    // 3. Paint Ticks (360 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final double angle = i * 3.141592653589793 / 180;
      final bool isMajor = i % 30 == 0;
      final bool isCardinal = i % 90 == 0;

      final double tickLength = isCardinal ? 12 : (isMajor ? 8 : 4);
      final double startR = radius - 8;
      final double endR = startR - tickLength;

      tickPaint.color = isCardinal 
          ? (isDark ? const Color(0xFFD4AF37) : const Color(0xFF27A770))
          : (isDark ? Colors.white30 : Colors.black26);
      tickPaint.strokeWidth = isCardinal ? 2.0 : (isMajor ? 1.5 : 1.0);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
''';

  // Append painter at the end of the file
  content += customPainterCode;

  file.writeAsStringSync(content);
  print('Qibla Finder redesigned successfully!');
}
