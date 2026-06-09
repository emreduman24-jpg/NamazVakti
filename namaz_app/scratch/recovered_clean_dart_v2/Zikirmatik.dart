import 'dart:io';

void main() {
  final file = File('lib/screens/tool_detail_screen.dart');
  if (!file.existsSync()) {
    print('Error: lib/screens/tool_detail_screen.dart not found.');
    exit(1);
  }

  // Restore the original file using Git first to start from a clean state
  Process.runSync('git', ['checkout', 'lib/screens/tool_detail_screen.dart']);

  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. Insert the getters and currentLocationName state variable at the top of the state class
  const classDeclaration = 'class _ToolDetailScreenState extends State<ToolDetailScreen> {';
  const repoDeclaration = '  final PrayerRepository _repository = PrayerRepository();';
  
  final gettersString = '''

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _greenColor => _isDark ? const Color(0xFF27A770) : const Color(0xff1e5e43);
  Color get _textColor => _isDark ? Colors.white : const Color(0xDE000000); // Colors.black87 equivalent
  Color get _subtitleColor => _isDark ? Colors.white70 : const Color(0x8A000000); // Colors.black54 equivalent
  Color get _cardBgColor => _isDark ? const Color(0xFF131D31) : Colors.white;
  String _currentLocationName = "";

  Future<void> _loadLocationName() async {
    final savedLoc = await _repository.getSavedLocation();
    final savedCity = savedLoc['cityName'] ?? "İstanbul";
    if (mounted) {
      setState(() {
        _currentLocationName = savedCity;
      });
    }
  }
''';

  final targetString = classDeclaration + '\n' + repoDeclaration;
  final replacementString = targetString + gettersString;

  if (content.contains(targetString)) {
    content = content.replaceFirst(targetString, replacementString);
  } else {
    print('Warning: Getter injection target not found.');
  }

  // 2. Perform color and background replacements on other sections
  content = content.replaceAll('const Color(0xFF1E5E43)', '_greenColor');
  content = content.replaceAll('Color(0xFF1E5E43)', '_greenColor');
  content = content.replaceAll('Colors.black87', '_textColor');
  content = content.replaceAll('Colors.black54', '_subtitleColor');
  content = content.replaceAll('backgroundColor: Colors.white', 'backgroundColor: _cardBgColor');
  content = content.replaceAll('Colors.grey[600]', '_isDark ? Colors.white60 : Colors.grey[600]');
  content = content.replaceAll('Colors.grey[700]', '_isDark ? Colors.white60 : Colors.grey[700]');
  content = content.replaceAll('Colors.grey[750]', '_isDark ? Colors.white60 : Colors.grey[750]');
  content = content.replaceAll('Colors.grey[800]', '_isDark ? Colors.white70 : Colors.grey[800]');

  // 3. Remove 'const' from widgets, lists, and styles to prevent compilation errors
  content = content.replaceAll('const TextStyle(', 'TextStyle(');
  content = content.replaceAll('children: const [', 'children: [');
  content = content.replaceAll('children: const <Widget>[', 'children: <Widget>[');
  content = content.replaceAll('const Border(', 'Border(');
  content = content.replaceAll('const BorderSide(', 'BorderSide(');
  content = content.replaceAll('const IconThemeData(', 'IconThemeData(');
  content = content.replaceAll('const RoundedRectangleBorder(', 'RoundedRectangleBorder(');
  content = content.replaceAll('const ChoiceChip(', 'ChoiceChip(');
  content = content.replaceAll('const Card(', 'Card(');
  content = content.replaceAll('const Divider(', 'Divider(');
  content = content.replaceAll('const Align(', 'Align(');
  content = content.replaceAll('const Text(', 'Text(');
  content = content.replaceAll('const SizedBox(', 'SizedBox(');
  content = content.replaceAll('const Padding(', 'Padding(');
  content = content.replaceAll('const Center(', 'Center(');
  content = content.replaceAll('const Row(', 'Row(');
  content = content.replaceAll('const Column(', 'Column(');
  content = content.replaceAll('const Expanded(', 'Expanded(');
  content = content.replaceAll('const SingleChildScrollView(', 'SingleChildScrollView(');
  content = content.replaceAll('const Icon(', 'Icon(');
  content = content.replaceAll('const CircleAvatar(', 'CircleAvatar(');
  content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
  content = content.replaceAll('const EdgeInsets.all(', 'EdgeInsets.all(');
  content = content.replaceAll('const EdgeInsets.symmetric(', 'EdgeInsets.symmetric(');
  content = content.replaceAll('const EdgeInsets.only(', 'EdgeInsets.only(');
  content = content.replaceAll('const Stack(', 'Stack(');

  // 4. Update the initState method to load location details for compass
  const initStart = '  void initState() {\n    super.initState();\n    _initMosques();';
  final initReplacement = '  void initState() {\n    super.initState();\n    _initMosques();\n    _loadLocationName();\n    if (widget.toolId == \'yakindaki-camiler\' || widget.toolId == \'kible-bulucu\') {\n      _getUserLocation();\n    }';

  if (content.contains(initStart)) {
    content = content.replaceFirst(initStart, initReplacement);
  }

  // Remove the old tool specific GPS call to avoid duplicate GPS calls
  content = content.replaceFirst("    if (widget.toolId == 'yakindaki-camiler') {\n      _getUserLocation();\n    }", "");

  // 5. Find the boundaries of the original _buildKibleBulucu to replace it with the Qibla Radar UI
  final startKey = '  Widget _buildKibleBulucu() {';
  final endKey = '  Widget _buildZikirmatik() {';

  final startIndex = content.indexOf(startKey);
  final endIndex = content.indexOf(endKey);

  if (startIndex == -1 || endIndex == -1) {
    print('Error: Could not locate Qibla Finder boundaries in file.');
    exit(1);
  }

  final newKibleRadar = '''  Widget _buildKibleBulucu() {
    const double qiblaAngle = 137.0; // Angle for Istanbul/Turkey approx.

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double? heading = snapshot.data?.heading;
        
        final bool dark = _isDark;

        // If no sensor detected, display a beautiful fallback message (No Simulation slider/switch)
        if (heading == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_off_outlined,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Pusula Sensörü Bulunamadı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cihazınızda manyetik pusula sensörü tespit edilemedi. Kıble Radar özelliğini kullanabilmek için lütfen pusula desteği olan bir mobil cihaz kullanın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        double needleRotation = qiblaAngle - heading;

        // Calculate difference for direction instructions
        double diff = (qiblaAngle - heading) % 360;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        
        bool isAligned = diff.abs() < 3;

        // Blip coordinates on the radar grid
        final double angleRad = (needleRotation - 90) * 3.141592653589793 / 180;
        final double radarRadius = 90.0; // Half of 180 (concentric ring)
        final double blipX = 120.0 + radarRadius * math.cos(angleRad) - 16;
        final double blipY = 120.0 + radarRadius * math.sin(angleRad) - 16;

        // Real distance to Kaaba from user's current GPS, fallback to Istanbul
        double meccaDistance = 2400.0;
        if (_currentPosition != null) {
          meccaDistance = _calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, 21.4225, 39.8262);
        }

        Widget instructionWidget;
        if (isAligned) {
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF27A770).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF27A770), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27A770).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27A770),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "KIBLE KİLİTLENDİ 🕋",
                  style: TextStyle(
                    color: Color(0xFF27A770),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          );
        } else {
          String dirText = diff > 0 
              ? "SAĞA DÖNÜN: \${diff.round()}° ↪️" 
              : "SOLA DÖNÜN: \${diff.abs().round()}° ↩️";
          instructionWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
            children: [
              const SizedBox(height: 8),
              Card(
                color: dark ? const Color(0xFF1E2E4A).withOpacity(0.2) : const Color(0xFFEAF7F1).withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(
                    color: dark ? const Color(0xFF27A770).withOpacity(0.15) : const Color(0xFF27A770).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar_rounded, color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Kıble Radar Arayüzü",
                            style: TextStyle(
                              fontSize: 14.5, 
                              fontWeight: FontWeight.bold, 
                              color: dark ? const Color(0xFF27A770) : const Color(0xFF1E5E43),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Telefonunuzu yatay tutup kendi etrafınızda dönün. Parıldayan Kabe hedefini (🕋) en üstteki kırmızı hedef çizgisine yerleştirin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: dark ? Colors.white60 : Colors.grey, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Futuristic Qibla Radar Screen
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer radar scanning container
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isAligned
                                ? const Color(0xFF27A770).withOpacity(0.1)
                                : (dark ? Colors.black45 : Colors.black12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _KibleRadarPainter(
                          needleRotation: needleRotation,
                          isAligned: isAligned,
                          isDark: dark,
                        ),
                      ),
                    ),
                    // Pulsing Kaaba Blip moving around the radar circles
                    Positioned(
                      left: blipX,
                      top: blipY,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAligned ? const Color(0xFF27A770) : (dark ? const Color(0xFF131D31) : Colors.white),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAligned ? Colors.white : (dark ? const Color(0xFFD4AF37) : const Color(0xFF27A770)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAligned ? const Color(0xFF27A770).withOpacity(0.8) : Colors.black26,
                              blurRadius: isAligned ? 12 : 4,
                              spreadRadius: isAligned ? 2 : 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "🕋",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Dynamic Target-Lock guidance banner
              instructionWidget,
              
              const SizedBox(height: 24),
              
              // HUD Information Panel
              Card(
                color: dark ? const Color(0xFF131D31) : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KIBLE RADAR VERİLERİ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: dark ? Colors.white60 : Colors.grey,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Hedef Açısı:", style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.grey)),
                          Text("\${qiblaAngle.toInt()}° (İstanbul)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _greenColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cihaz Yönü:", style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.grey)),
                          Text("\${heading.round()}°", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kabe'ye Uzaklık:", style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.grey)),
                          Text("\${meccaDistance.round()} km", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Konum:", style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.grey)),
                          Text(_currentLocationName.isNotEmpty ? _currentLocationName : "İstanbul", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

''';

  // Perform replacement of the _buildKibleBulucu method
  content = content.replaceRange(startIndex, endIndex, newKibleRadar);

  // Define CustomPainter class to append at the bottom of the file
  final radarPainterCode = '''

class _KibleRadarPainter extends CustomPainter {
  final double needleRotation;
  final bool isAligned;
  final bool isDark;

  _KibleRadarPainter({
    required this.needleRotation,
    required this.isAligned,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Paint radar background
    final bgPaint = Paint()
      ..color = isDark 
          ? const Color(0xFF0F1B2A).withOpacity(0.4) 
          : const Color(0xFFEAF7F1).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Paint concentric radar rings
    final ringPaint = Paint()
      ..color = isAligned 
          ? const Color(0xFF27A770).withOpacity(0.3) 
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.3) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.45, ringPaint);

    // 3. Paint crosshairs
    final linePaint = Paint()
      ..color = isAligned 
          ? const Color(0xFF27A770).withOpacity(0.4) 
          : (isDark ? const Color(0xFF3E5C76).withOpacity(0.25) : const Color(0xFF27A770).withOpacity(0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // 4. Draw radar angle scale ticks (every 10 degrees)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * 3.141592653589793 / 180;
      final bool isMajor = i % 30 == 0;
      
      final double tickLength = isMajor ? 8 : 4;
      final double startR = radius;
      final double endR = radius - tickLength;

      tickPaint.color = isAligned 
          ? const Color(0xFF27A770).withOpacity(0.5) 
          : (isDark ? Colors.white24 : Colors.black12);
      tickPaint.strokeWidth = isMajor ? 1.5 : 1.0;

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

    // 5. Draw active radar scanning beam
    final double radAngle = (needleRotation - 90) * 3.141592653589793 / 180;
    
    final sweepPaint = Paint()
      ..color = isAligned 
          ? const Color(0xFF27A770).withOpacity(0.15) 
          : (isDark ? const Color(0xFFD4AF37).withOpacity(0.08) : const Color(0xFF27A770).withOpacity(0.08))
      ..style = PaintingStyle.fill;
    
    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        radAngle - 0.2, 
        0.4,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    // 6. Draw outer target marker (red bracket at the top)
    final targetPaint = Paint()
      ..color = isAligned ? const Color(0xFF27A770) : Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double bracketW = 16;
    final double bracketH = 8;
    final bracketPath = Path()
      ..moveTo(center.dx - bracketW, bracketH)
      ..lineTo(center.dx - bracketW, 0)
      ..lineTo(center.dx + bracketW, 0)
      ..lineTo(center.dx + bracketW, bracketH);
    canvas.drawPath(bracketPath, targetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
''';

  content += radarPainterCode;

  file.writeAsStringSync(content);
  print('Qibla Radar Redesign applied successfully!');
}
