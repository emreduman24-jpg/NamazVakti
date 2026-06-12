import 'package:flutter/material.dart';
import '../data/prayer_repository.dart';

class ToolsScreen extends StatefulWidget {
  final Function(String, String) onOpenTool;
  final VoidCallback? onClose;

  const ToolsScreen({super.key, required this.onOpenTool, this.onClose});

  @override
  _ToolsScreenState createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with AutomaticKeepAliveClientMixin<ToolsScreen> {
  final PrayerRepository _repository = PrayerRepository();
  List<Map<String, dynamic>> _allTools = [];
  List<Map<String, dynamic>> _filteredTools = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTools();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadTools() async {
    try {
      final tools = await _repository.getDynamicTools();
      final activeSorted = tools
          .where((t) => t['aktif'] == true || t['aktif'] == null)
          .toList();
      activeSorted.sort((a, b) => (a['sira'] ?? 999).compareTo(b['sira'] ?? 999));
      if (mounted) {
        setState(() {
          _allTools = activeSorted;
          _filteredTools = _allTools;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tools: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  void _onSearchChanged() {
    final query = _normalize(_searchController.text);
    setState(() {
      _filteredTools = _allTools.where((tool) {
        final title = _normalize(tool['title'] ?? '');
        final desc = _normalize(tool['desc'] ?? '');
        return title.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: const Text(
          "Araçlar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: widget.onClose != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF131D31) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: dark ? Colors.white : Colors.black87),
                  decoration: const InputDecoration(
                    hintText: "Araç ara...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF27A770)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tools Grid View
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTools,
                color: const Color(0xFF27A770),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF27A770),
                        ),
                      )
                    : _filteredTools.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  "Eşleşen araç bulunamadı.",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _filteredTools.length,
                            itemBuilder: (context, index) {
                              final tool = _filteredTools[index];
                              final String id = tool['id'] ?? '';
                              final String title = tool['title'] ?? '';
                              final String desc = tool['desc'] ?? '';
                              final String icon = tool['icon'] ?? '✨';
                              
                              Color bgColor = const Color(0xFFEAF7F1);
                              final String? colorVal = tool['color'];
                              if (colorVal != null) {
                                try {
                                  if (colorVal.startsWith('0x')) {
                                    bgColor = Color(int.parse(colorVal));
                                  } else if (colorVal.startsWith('#')) {
                                    bgColor = Color(int.parse(colorVal.replaceFirst('#', '0xff')));
                                  } else {
                                    bgColor = Color(int.parse(colorVal));
                                  }
                                } catch (_) {}
                              }

                              Color cardBg = dark ? const Color(0xFF131D31) : bgColor;
                              BorderSide borderSide = dark 
                                  ? BorderSide(color: bgColor.withOpacity(0.35), width: 1.5)
                                  : BorderSide.none;

                              return Card(
                                elevation: dark ? 0 : 1,
                                shadowColor: Colors.black.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: borderSide,
                                ),
                                color: cardBg,
                                child: InkWell(
                                  onTap: () => widget.onOpenTool(id, title),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon circle
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: dark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            icon,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: dark ? Colors.white : const Color(0xFF1E5E43),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: dark ? Colors.white60 : Colors.grey[750],
                                            fontSize: 10,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
