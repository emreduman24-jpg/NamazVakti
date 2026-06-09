
// ==========================================
// FILE: step_16734_0_replace_file_content.json
// INSTRUCTION: "Add Dini Hoca state variables."
// ==========================================
"    \"Ve aleyküm selam ve rahmetullah.\",\n  ];\n\n  // Dini Hoca AI State\n  final List<Map<String, String>> _diniHocaMessages = [\n    {\n      'sender': 'ai',\n      'text': 'Selamün Aleyküm mümin kardeşim. Ben Dini Hoca Yapay Zeka Danışmanıyım. İslam fıkhı, inanç, ibadetler (abdest, namaz, zekat vb.), hadis-i şerifler veya ahlak adabı hakkında aklına takılan her soruyu bana sorabilirsin. Sana hayırla rehberlik etmek için buradayım.',\n    }\n  ];\n  final TextEditingController _diniHocaInputController = TextEditingController();\n  final ScrollController _diniHocaScrollController = ScrollController();\n  bool _diniHocaIsTyping = false;"

// ==========================================
// FILE: step_16738_0_replace_file_content.json
// INSTRUCTION: "Dispose of Dini Hoca input and scroll controllers."
// ==========================================
"  @override\n  void dispose() {\n    _audioPlayer?.dispose();\n    _duaNameController.dispose();\n    _duaTextController.dispose();\n    _questionNameController.dispose();\n    _qaInputController.dispose();\n    _chatInputController.dispose();\n    _diniHocaInputController.dispose();\n    _diniHocaScrollController.dispose();\n    _hadisSearchController.dispose();\n    _dualarSearchController.dispose();\n    _goldController.dispose();\n    _cashController.dispose();\n    _businessController.dispose();\n    _debtsController.dispose();\n    super.dispose();\n  }"

// ==========================================
// FILE: step_16744_0_replace_file_content.json
// INSTRUCTION: "Add case 'dini-hoca' to the switch."
// ==========================================
"      case 'canli-sohbet':\n        return _buildCanliSohbet();\n      case 'dini-hoca':\n        return _buildDiniHoca();"

// ==========================================
// FILE: step_16762_0_replace_file_content.json
// INSTRUCTION: "Add Dini Hoca state variables: _diniHocaMessages and _diniHocaIsTyping."
// ==========================================
"  ];\n  final TextEditingController _chatInputController = TextEditingController();\n\n  // Dini Hoca State\n  List<Map<String, dynamic>> _diniHocaMessages = [];\n  bool _diniHocaIsTyping = false;"

// ==========================================
// FILE: step_16766_0_replace_file_content.json
// INSTRUCTION: "Add ScrollController and TextEditingController."
// ==========================================
"  // Dini Hoca State\n  List<Map<String, dynamic>> _diniHocaMessages = [];\n  bool _diniHocaIsTyping = false;\n  final ScrollController _diniHocaScrollController = ScrollController();\n  final TextEditingController _diniHocaInputController = TextEditingController();"

// ==========================================
// FILE: step_16780_0_replace_file_content.json
// INSTRUCTION: "Insert _buildDiniHoca and Dini Hoca helper methods."
// ==========================================
"  }\n\n  // Dini Hoca Asistanı (Yapay Zeka)\n  void _initDiniHoca() {\n    if (_diniHocaMessages.isEmpty) {\n      _diniHocaMessages = [\n        {\n          'isMe': false,\n          'text': \"Selamün Aleyküm mümin kardeşim. Ben yapay zeka Dini Hoca asistanınızım. İslamiyet, ibadetler (namaz, abdest, gusül, oruç, zekat vb.), dualar ve sureler hakkında sormak istediğiniz soruları cevaplamaktan mutluluk duyarım. Nasıl yardımcı olabilirim?\",\n          'time': DateTime.now(),\n        }\n      ];\n    }\n  }\n\n  Widget _buildDiniHoca() {\n    _initDiniHoca();\n    \n    final suggestions = [\n      \"Abdest nasıl alınır? 💧\",\n      \"Guslün farzları nelerdir? 🚿\",\n      \"Namazın farzları nelerdir? 🕋\",\n      \"Orucu bozan şeyler nelerdir? 🌙\",\n      \"Zekat kimlere verilir? 💰\",\n      \"Sehiv secdesi nedir? 🙇\",\n      \"Kaza namazı nasıl kılınır? 🕰️\",\n    ];\n\n    return Column(\n      children: [\n        // AI Advisor Header Card\n        Container(\n          margin: const EdgeInsets.all(12),\n          padding: const EdgeInsets.all(12),\n          decoration: BoxDecoration(\n            color: _isDark ? const Color(0xFF131D31) : const Color(0xFFEBF5F0),\n            borderRadius: BorderRadius.circular(16),\n            border: Border.all(\n              color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFC2E3D2),\n            ),\n          ),\n          child: Row(\n            children: [\n              Container(\n                padding: const EdgeInsets.all(10),\n                decoration: BoxDecoration(\n                  color: _isDark ? const Color(0xFF1E2D4A) : Colors.white,\n                  shape: BoxShape.circle,\n                ),\n                child: const Icon(\n                  Icons.psychology_rounded,\n                  color: Color(0xFFC5A059),\n                  size: 28,\n                ),\n              ),\n              const SizedBox(width: 12),\n              Expanded(\n                child: Column(\n    
<truncated 24225 bytes>

// ==========================================
// FILE: step_16786_0_replace_file_content.json
// INSTRUCTION: "Append _MiniDotAnimator class definition."
// ==========================================
"  @override\n  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;\n}\n\nclass _MiniDotAnimator extends StatefulWidget {\n  final Color color;\n  const _MiniDotAnimator({Key? key, required this.color}) : super(key: key);\n\n  @override\n  __MiniDotAnimatorState createState() => __MiniDotAnimatorState();\n}\n\nclass __MiniDotAnimatorState extends State<_MiniDotAnimator> with SingleTickerProviderStateMixin {\n  late AnimationController _controller;\n  \n  @override\n  void initState() {\n    super.initState();\n    _controller = AnimationController(\n      vsync: this,\n      duration: const Duration(milliseconds: 1000),\n    )..repeat();\n  }\n  \n  @override\n  void dispose() {\n    _controller.dispose();\n    super.dispose();\n  }\n  \n  @override\n  Widget build(BuildContext context) {\n    return AnimatedBuilder(\n      animation: _controller,\n      builder: (context, child) {\n        String dots = \".\";\n        if (_controller.value > 0.33) dots = \"..\";\n        if (_controller.value > 0.66) dots = \"...\";\n        return Text(\n          dots,\n          style: TextStyle(\n            color: widget.color,\n            fontWeight: FontWeight.bold,\n            fontSize: 14,\n          ),\n        );\n      },\n    );\n  }\n}\n"

// ==========================================
// FILE: step_16792_0_replace_file_content.json
// INSTRUCTION: "Remove duplicate Dini Hoca state variables."
// ==========================================
"  // Dini Hoca State is defined above."

// ==========================================
// FILE: step_16796_0_replace_file_content.json
// INSTRUCTION: "Set initial welcome message for _diniHocaMessages."
// ==========================================
"  // Dini Hoca State\n  List<Map<String, dynamic>> _diniHocaMessages = [\n    {\n      'sender': 'ai',\n      'text': 'Selamün Aleyküm mümin kardeşim. Ben Dini Hoca Yapay Zeka Danışmanıyım. İslam fıkhı, inanç, ibadetler (abdest, namaz, zekat vb.), hadis-i şerifler veya ahlak adabı hakkında aklına takılan her soruyu bana sorabilirsin. Sana hayırla rehberlik etmek için buradayım.',\n    }\n  ];\n  bool _diniHocaIsTyping = false;\n  final ScrollController _diniHocaScrollController = ScrollController();\n  final TextEditingController _diniHocaInputController = TextEditingController();"

// ==========================================
// FILE: step_16829_0_replace_file_content.json
// INSTRUCTION: "Close _buildCanliSohbet and define _buildDiniHoca."
// ==========================================
"            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  Widget _buildDiniHoca() {\n    final List<String> suggestions = [\n      \"Abdest nasıl alınır? 💧\",\n      \"Namazın farzları nelerdir? 🕋\",\n      \"Gusül abdesti farzları 🚿\",\n      \"Sehiv secdesi nedir? 🙇\",\n      \"Zekat kimlere verilir? 💰\",\n      \"Orucu bozan şeyler 🍽️\",\n    ];\n\n    return Column(\n      children: [\n        // Message List\n        Expanded("

// ==========================================
// FILE: step_16831_0_replace_file_content.json
// INSTRUCTION: "Close _buildCanliSohbet and define _buildDiniHoca."
// ==========================================
"            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  Widget _buildDiniHoca() {\n    final List<String> suggestions = [\n      \"Abdest nasıl alınır? 💧\",\n      \"Namazın farzları nelerdir? 🕋\",\n      \"Gusül abdesti farzları 🚿\",\n      \"Sehiv secdesi nedir? 🙇\",\n      \"Zekat kimlere verilir? 💰\",\n      \"Orucu bozan şeyler 🍽️\",\n    ];\n\n    return Column(\n      children: [\n        // Message List\n        Expanded("

// ==========================================
// FILE: step_16840_0_replace_file_content.json
// INSTRUCTION: "Add closing parenthesis for ElevatedButton."
// ==========================================
"                child: Text(\n                  \"Geri Dön\",\n                  style: TextStyle(\n                    color: Colors.white,\n                    fontWeight: FontWeight.bold,\n                    fontSize: 13,\n                  ),\n                ),\n              ),\n            ],"

// ==========================================
// FILE: step_16925_0_replace_file_content.json
// INSTRUCTION: "Replace _buildCanliSohbet implementation with the newly designed radio screen."
// ==========================================
"  // 4. Canlı Sohbet (Canlı Kur'an Radyosu)\n  Widget _buildCanliSohbet() {\n    final List<Map<String, String>> radioStations = [\n      {\n        'name': \"Kur'an Radyo\",\n        'tagline': \"Sözün Başladığı Yer\",\n        'desc': \"7/24 Kesintisiz Kur'an-ı Kerim Meali ve Hatmi Şerif Yayını.\",\n        'url': \"https://eustr76.mediatriple.net/videoonlylive/mtikoimxnztxlive/broadcast_5e3c14192aa92.smil/playlist.m3u8\",\n        'icon': \"🕌\",\n        'freq': \"Ankara 88.2 • İstanbul 106.4 • İzmir 90.3\",\n        'color1': \"0xFF0A1220\",\n        'color2': \"0xFF1E5E43\",\n        'accent': \"0xFFFFC107\",\n      },\n      {\n        'name': \"Diyanet Radyo\",\n        'tagline': \"Güvenle Dinleyin\",\n        'desc': \"Dini, ahlaki ve sosyal konularda eğitici ve aydınlatıcı yayınlar.\",\n        'url': \"https://eustr76.mediatriple.net/videoonlylive/mtikoimxnztxlive/broadcast_5e3c1171d7d2a.smil/playlist.m3u8\",\n        'icon': \"📻\",\n        'freq': \"Ankara 105.6 • İstanbul 103.2 • İzmir 100.8\",\n        'color1': \"0xFF051D2D\",\n        'color2': \"0xFF104F55\",\n        'accent': \"0xFF48CAE4\",\n      },\n      {\n        'name': \"Risalet Radyo\",\n        'tagline': \"Kutlu Çağrı\",\n        'desc': \"Sünnet-i Seniyye ve Hz. Peygamber (s.a.v.) efendimizin ahlakı.\",\n        'url': \"https://eustr76.mediatriple.net/videoonlylive/mtikoimxnztxlive/broadcast_5e3c1520b2626.smil/playlist.m3u8\",\n        'icon': \"✨\",\n        'freq': \"Dijital / Uydu Yayını\",\n        'color1': \"0xFF1F0813\",\n        'color2': \"0xFF6B1D2F\",\n        'accent': \"0xFFFF758F\",\n      },\n    ];\n\n    final station = radioStations[_activeRadioIndex];\n    final isSelectedPlaying = _playerState == PlayerState.playing && _currentAudioUrl == station['url'];\n\n    final bgGradient1 = Color(int.parse(station['color1']!));\n    final bgGradient2 = Color(int.parse(station['color2']!));\n    final accentColor = Color(int.parse(station['accent']!));\n\n    return Column(\n 
<truncated 17924 bytes>

// ==========================================
// FILE: step_16933_0_replace_file_content.json
// INSTRUCTION: "Append the helper classes to the end of the file."
// ==========================================
"  @override\n  Widget build(BuildContext context) {\n    return AnimatedBuilder(\n      animation: _controller,\n      builder: (context, child) {\n        String dots = \".\";\n        if (_controller.value > 0.33) dots = \"..\";\n        if (_controller.value > 0.66) dots = \"...\";\n        return Text(\n          dots,\n          style: TextStyle(\n            color: widget.color,\n            fontWeight: FontWeight.bold,\n            fontSize: 14,\n          ),\n        );\n      },\n    );\n  }\n}\n\nclass RadioVisualizer extends StatefulWidget {\n  final bool isPlaying;\n  final Color color;\n  const RadioVisualizer({super.key, required this.isPlaying, required this.color});\n\n  @override\n  _RadioVisualizerState createState() => _RadioVisualizerState();\n}\n\nclass _RadioVisualizerState extends State<RadioVisualizer> {\n  late Timer _timer;\n  List<double> _heights = List.filled(7, 4.0);\n  final math.Random _random = math.Random();\n\n  @override\n  void initState() {\n    super.initState();\n    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {\n      if (widget.isPlaying && mounted) {\n        setState(() {\n          _heights = List.generate(7, (index) => 4.0 + _random.nextDouble() * 32.0);\n        });\n      } else if (!widget.isPlaying && _heights.any((h) => h != 4.0) && mounted) {\n        setState(() {\n          _heights = List.filled(7, 4.0);\n        });\n      }\n    });\n  }\n\n  @override\n  void dispose() {\n    _timer.cancel();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Row(\n      mainAxisSize: MainAxisSize.min,\n      mainAxisAlignment: MainAxisAlignment.center,\n      children: List.generate(7, (index) {\n        return AnimatedContainer(\n          duration: const Duration(milliseconds: 150),\n          margin: const EdgeInsets.symmetric(horizontal: 3),\n          width: 4,\n          height: _heights[index],\n          decoration: BoxDecoration(\n            color: widget.color,\n            borderRadius: BorderR
<truncated 2396 bytes>
