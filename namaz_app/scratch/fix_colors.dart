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
  
  // Make line endings uniform
  content = content.replaceAll('\r\n', '\n');

  // 1. Insert the getters at the top of the state class
  const classDeclaration = 'class _ToolDetailScreenState extends State<ToolDetailScreen> {';
  const repoDeclaration = '  final PrayerRepository _repository = PrayerRepository();';
  
  final gettersString = '''

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _greenColor => _isDark ? const Color(0xFF27A770) : const Color(0xff1e5e43);
  Color get _textColor => _isDark ? Colors.white : const Color(0xDE000000); // Colors.black87 equivalent
  Color get _subtitleColor => _isDark ? Colors.white70 : const Color(0x8A000000); // Colors.black54 equivalent
  Color get _cardBgColor => _isDark ? const Color(0xFF131D31) : Colors.white;
''';

  final targetString = classDeclaration + '\n' + repoDeclaration;
  final replacementString = targetString + gettersString;

  if (content.contains(targetString)) {
    content = content.replaceFirst(targetString, replacementString);
  } else {
    print('Warning: Getter injection target not found.');
  }

  // 2. Perform color and background replacements
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

  file.writeAsStringSync(content);
  print('Color and const cleanup script finished successfully!');
}
