"  Widget _buildWeekViewChart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: _isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: _greenColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Bu Haftanın Zikir Takibi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : const Color(0xFF1E5E43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayDate = monday.add(Duration(days: index));
              final dateStr = dayDate.toIso8601String().split('T')[0];
              final isCompleted = _zikirCompletedDates.contains(dateStr);
              final isToday = dayDate.day == now.day &&
                  dayDate.month == now.month &&
                  dayDate.year == now.year;

              return Column(
    
<truncated 12487 bytes>