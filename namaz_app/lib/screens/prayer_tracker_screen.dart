import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/prayer_tracker_state.dart';

class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  _PrayerTrackerScreenState createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> with AutomaticKeepAliveClientMixin<PrayerTrackerScreen> {
  // DB map of "YYYY-MM-DD" -> [Sabah, Öğle, İkindi, Akşam, Yatsı]
  Map<String, List<bool>> _history = {};
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  // Real-time calculated stats
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalCompletedDays = 0;
  int _weeklyCompletedPrayers = 0;

  // Calendar navigation state
  late DateTime _focusedMonth;
  final List<String> _weekdays = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
  final List<String> _monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  final PrayerTrackerState _trackerState = PrayerTrackerState();

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _trackerState.addListener(_onStateChanged);
    _onStateChanged();
  }

  @override
  void dispose() {
    _trackerState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {
      _history = _trackerState.history;
      _loading = _trackerState.loading;
      _calculateMetrics();
    });
  }

  String _formatDate(DateTime dt) {
    String y = dt.year.toString();
    String m = dt.month.toString().padLeft(2, '0');
    String d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  void _calculateMetrics() {
    int curStreak = 0;
    int maxStreak = 0;
    int completedDays = 0;
    int weeklyCompletedDays = 0;

    // 1. Calculate Total Completed Days (at least 4 out of 5 prayers checked) ONLY FOR THE CURRENT MONTH
    final now = DateTime.now();
    _history.forEach((key, list) {
      if (list.length == 5 && list.where((e) => e).length >= 4) {
        try {
          final parts = key.split('-');
          final int year = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          if (year == now.year && month == now.month) {
            completedDays++;
          }
        } catch (_) {}
      }
    });

    // 2. Calculate Current Streak (at least 4 out of 5 prayers checked)
    DateTime checkDate = DateTime.now();
    String todayStr = _formatDate(checkDate);
    final todayList = _history[todayStr] ?? [false, false, false, false, false];
    bool todayAll = todayList.length == 5 && todayList.where((e) => e).length >= 4;

    if (!todayAll) {
      // If today is not fully completed, check if yesterday was fully completed.
      // If yes, streak continues from yesterday. If no, streak is 0 or today's partial streak.
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      String dateStr = _formatDate(checkDate);
      final list = _history[dateStr];
      if (list != null && list.length == 5 && list.where((e) => e).length >= 4) {
        curStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // 3. Calculate Longest Streak
    int tempStreak = 0;
    DateTime? prevDate;
    final List<DateTime> completedDates = [];

    _history.forEach((dateStr, list) {
      if (list.length == 5 && list.where((e) => e).length >= 4) {
        try {
          final parts = dateStr.split('-');
          completedDates.add(DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])));
        } catch (_) {}
      }
    });

    completedDates.sort();

    for (var dateObj in completedDates) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = dateObj.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          if (tempStreak > maxStreak) maxStreak = tempStreak;
          tempStreak = 1;
        }
      }
      prevDate = dateObj;
    }
    if (tempStreak > maxStreak) maxStreak = tempStreak;

    // 4. Calculate Weekly Completed Days (Monday - Sunday of this week)
    final int weekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = now.subtract(Duration(days: weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dateStr = _formatDate(day);
      final list = _history[dateStr] ?? [false, false, false, false, false];
      if (list.where((e) => e).length >= 4) {
        weeklyCompletedDays++;
      }
    }

    _currentStreak = curStreak;
    _longestStreak = maxStreak;
    _totalCompletedDays = completedDays;
    _weeklyCompletedPrayers = weeklyCompletedDays;
  }

  int _getNextMilestone(int current) {
    if (current < 3) return 3;
    if (current < 7) return 7;
    if (current < 14) return 14;
    if (current < 30) return 30;
    if (current < 100) return 100;
    return 365;
  }

  void _togglePrayer(String dateStr, int prayerIndex) {
    _trackerState.togglePrayer(dateStr, prayerIndex);
  }

  void _showEditDaySheet(DateTime date) {
    final String dateStr = _formatDate(date);
    final String label = "${date.day} ${_monthNames[date.month - 1]} ${date.year}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1B31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final list = _history[dateStr] ?? [false, false, false, false, false];
            final int doneCount = list.where((e) => e).length;
            
            Widget buildCheckRow(String name, int index, IconData icon, Color color) {
              final isDone = list[index];
              return GestureDetector(
                onTap: () {
                  _togglePrayer(dateStr, index);
                  setSheetState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF162544) : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDone ? const Color(0xFFD4AF37).withOpacity(0.4) : Colors.white.withOpacity(0.05),
                      width: 1.5,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Left icon representation
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? const Color(0xFFD4AF37).withOpacity(0.12) : Colors.white.withOpacity(0.04),
                        ),
                        child: Icon(
                          icon,
                          color: isDone ? const Color(0xFFD4AF37) : Colors.white30,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Text detail
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDone ? "Kılındı" : "Kılınmadı",
                              style: TextStyle(
                                color: isDone ? const Color(0xFF90B49C) : Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right Custom Circle Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? const Color(0xFFD4AF37) : Colors.transparent,
                          border: Border.all(
                            color: isDone ? const Color(0xFFD4AF37) : Colors.white30,
                            width: 2.0,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.35),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Color(0xFF0F1B31),
                                size: 16,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pull Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Beautiful Spacious Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Geçmiş Namaz Vakitlerinizi Düzenleyin",
                                  style: TextStyle(fontSize: 12, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          
                          // Premium Golden Count Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
                            ),
                            child: Text(
                              "$doneCount / 5 Vakit",
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Premium Card List for Prayers
                      buildCheckRow("Sabah Namazı", 0, Icons.wb_twilight_outlined, const Color(0xFF90B49C)),
                      buildCheckRow("Öğle Namazı", 1, Icons.wb_sunny_outlined, const Color(0xFFE5A93B)),
                      buildCheckRow("İkindi Namazı", 2, Icons.wb_sunny, const Color(0xFFD4AF37)),
                      buildCheckRow("Akşam Namazı", 3, Icons.nights_stay_outlined, const Color(0xFF327CF6)),
                      buildCheckRow("Yatsı Namazı", 4, Icons.nightlight_round_outlined, const Color(0xFF8B63E6)),
                      
                      const SizedBox(height: 16),

                      // Spacious Floating Gold Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Değişiklikleri Kaydet",
                            style: TextStyle(
                              color: Color(0xFF0F1B31),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Re-trigger layout rebuild to update dots on calendar
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1B31),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF90B49C))),
      );
    }

    final theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    
    // Formatting today's date
    final DateTime today = DateTime.now();
    final String todayStr = _formatDate(today);
    final List<bool> todayList = _history[todayStr] ?? [false, false, false, false, false];
    final int todayCount = todayList.where((e) => e).length;

    // Milestones math
    final int nextGoal = _getNextMilestone(_currentStreak);
    
    double getMilestoneProgress(int streak) {
      if (streak <= 3) return 0.0;
      if (streak <= 7) {
        return 0.0 + 0.2 * ((streak - 3) / (7 - 3));
      }
      if (streak <= 14) {
        return 0.2 + 0.2 * ((streak - 7) / (14 - 7));
      }
      if (streak <= 30) {
        return 0.4 + 0.2 * ((streak - 14) / (30 - 14));
      }
      if (streak <= 100) {
        return 0.6 + 0.2 * ((streak - 30) / (100 - 30));
      }
      if (streak <= 365) {
        return 0.8 + 0.2 * ((streak - 100) / (365 - 100));
      }
      return 1.0;
    }
    
    final double milestoneProgress = getMilestoneProgress(_currentStreak);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFFF3F8F5),
      appBar: AppBar(
        title: const Text(
          "Namaz Takibi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF0A1220) : const Color(0xFF1E5E43),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PREMIUM STREAK CARD
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F1B31),
                    Color(0xFF19325C),
                    Color(0xFF22447A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Mosque & Sun rays ornament
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TopCardOrnamentPainter(),
                      ),
                    ),
                    // Information overlay
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      "🔥 ",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      _currentStreak >= 1 ? "NAMAZ SERİ" : "BAŞLANGIÇ",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "$_currentStreak",
                                      style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                    TextSpan(
                                      text: " gün",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD4AF37).withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                                style: const TextStyle(height: 1.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "En uzun: $_longestStreak gün",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. STATS TILES (TWIN CARDS) - Moved to Top
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    height: 110,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_totalCompletedDays gün",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87),
                            ),
                            Text(
                              "Tamamlanan",
                              style: TextStyle(fontSize: 11, color: dark ? Colors.white38 : Colors.black45, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    height: 110,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF131D31) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.bar_chart, color: Color(0xFFD4AF37), size: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_weeklyCompletedPrayers / 7",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87),
                            ),
                            Text(
                              "Bu hafta",
                              style: TextStyle(fontSize: 11, color: dark ? Colors.white38 : Colors.black45, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. TODAY'S DAILY TRACKER (Bugün)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bugün",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "$todayCount / 5",
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AnimatedPrayerButton(
                        label: "Sabah",
                        isChecked: todayList[0],
                        onTap: () => _togglePrayer(todayStr, 0),
                      ),
                      AnimatedPrayerButton(
                        label: "Öğle",
                        isChecked: todayList[1],
                        onTap: () => _togglePrayer(todayStr, 1),
                      ),
                      AnimatedPrayerButton(
                        label: "İkindi",
                        isChecked: todayList[2],
                        onTap: () => _togglePrayer(todayStr, 2),
                      ),
                      AnimatedPrayerButton(
                        label: "Akşam",
                        isChecked: todayList[3],
                        onTap: () => _togglePrayer(todayStr, 3),
                      ),
                      AnimatedPrayerButton(
                        label: "Yatsı",
                        isChecked: todayList[4],
                        onTap: () => _togglePrayer(todayStr, 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. GOAL STEPS CARD (Sıradaki Hedef) - Moved to Bottom, Seri Koruma removed
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.flag_outlined, color: Color(0xFFD4AF37), size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Sıradaki Hedef",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        "$_currentStreak / $nextGoal gün",
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Horizontal Stepper Bar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Loading Track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            value: milestoneProgress,
                            backgroundColor: dark ? Colors.white10 : Colors.black.withOpacity(0.05),
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      // Stepper Nodes (3, 7, 14, 30, 100, 365)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMilestoneNode(3, _currentStreak, dark),
                          _buildMilestoneNode(7, _currentStreak, dark),
                          _buildMilestoneNode(14, _currentStreak, dark),
                          _buildMilestoneNode(30, _currentStreak, dark),
                          _buildMilestoneNode(100, _currentStreak, dark),
                          _buildMilestoneNode(365, _currentStreak, dark),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Label row for nodes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMilestoneText(3, _currentStreak, dark),
                      _buildMilestoneText(7, _currentStreak, dark),
                      _buildMilestoneText(14, _currentStreak, dark),
                      _buildMilestoneText(30, _currentStreak, dark),
                      _buildMilestoneText(100, _currentStreak, dark),
                      _buildMilestoneText(365, _currentStreak, dark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. EDITABLE MONTHLY CALENDAR CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month navigation row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: dark ? Colors.white60 : Colors.black54),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                          });
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            "${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: dark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 10, color: dark ? Colors.white30 : Colors.black38),
                              const SizedBox(width: 4),
                              Text(
                                "Düzenlenebilir",
                                style: TextStyle(fontSize: 10, color: dark ? Colors.white30 : Colors.black38, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: dark ? Colors.white60 : Colors.black54),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calendar Grid Weekdays
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            _weekdays[index],
                            style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white38 : Colors.black45, fontSize: 11),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Calendar Grid Days
                  _buildCalendarDaysGrid(dark),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Tamamlandı",
                            style: TextStyle(color: dark ? Colors.white60 : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF68B291),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Kısmen",
                            style: TextStyle(color: dark ? Colors.white60 : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDaysGrid(bool dark) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    final int totalDays = lastDay.day;
    int startWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    
    // We want pt (Mon) to trigger start at index 0. If startWeekday is 1 (Mon), offset is 0. If Sun (7), offset is 6.
    final int prefixOffset = startWeekday - 1;

    final List<Widget> dayWidgets = [];

    // Add empty spacers for previous month offset
    for (int i = 0; i < prefixOffset; i++) {
      dayWidgets.add(const SizedBox());
    }

    final DateTime today = DateTime.now();

    // Add actual days
    for (int dayNum = 1; dayNum <= totalDays; dayNum++) {
      final dayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
      final String dayDateStr = _formatDate(dayDate);
      final dayPrayers = _history[dayDateStr] ?? [false, false, false, false, false];
      final bool isToday = today.year == dayDate.year && today.month == dayDate.month && today.day == dayDate.day;
      final bool isFuture = dayDate.isAfter(DateTime(today.year, today.month, today.day));

      final int checkedCount = dayPrayers.where((e) => e).length;
      final bool isFull = checkedCount >= 4;
      final bool isPartial = checkedCount >= 1 && checkedCount < 4;

      dayWidgets.add(
        GestureDetector(
          onTap: isFuture ? null : () => _showEditDaySheet(dayDate),
          child: Container(
            margin: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isFull
                  ? const Color(0xFFD4AF37).withOpacity(0.15)
                  : (isPartial ? const Color(0xFF68B291).withOpacity(0.12) : (dark ? Colors.white.withOpacity(0.015) : Colors.black.withOpacity(0.02))),
              border: isToday
                  ? Border.all(color: const Color(0xFFD4AF37), width: 1.8)
                  : (isFull
                      ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1.0)
                      : (isPartial
                          ? Border.all(color: const Color(0xFF68B291).withOpacity(0.4), width: 1.0)
                          : Border.all(color: Colors.transparent))),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  dayNum.toString(),
                  style: TextStyle(
                    color: isToday
                        ? const Color(0xFFD4AF37)
                        : (isFull
                            ? const Color(0xFFD4AF37)
                            : (isPartial ? const Color(0xFF68B291) : (dark ? Colors.white54 : Colors.black54))),
                    fontWeight: isToday || isFull || isPartial ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Render 5 small dots representing prayer completion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (pIndex) {
                    final isDone = dayPrayers[pIndex];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.6),
                      width: 3.0,
                      height: 3.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? const Color(0xFFD4AF37) : (dark ? Colors.white12 : Colors.black.withOpacity(0.08)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      );
    }

    // Gridview layout with 7 items per row
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) {
        return dayWidgets[index];
      },
    );
  }

  Widget _buildMilestoneNode(int nodeVal, int current, bool dark) {
    final bool isPassed = current >= nodeVal;
    final bool isActive = current < nodeVal && (current >= 3 && nodeVal == 7 || current < 3 && nodeVal == 3 || current >= 7 && current < 14 && nodeVal == 14 || current >= 14 && current < 30 && nodeVal == 30 || current >= 30 && current < 100 && nodeVal == 100 || current >= 100 && current < 365 && nodeVal == 365);
    
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPassed
            ? const Color(0xFFD4AF37)
            : (isActive ? const Color(0xFF19325C) : (dark ? Colors.grey[850] : Colors.grey[300])),
        border: Border.all(
          color: isActive ? const Color(0xFFD4AF37) : (isPassed ? const Color(0xFFD4AF37) : Colors.transparent),
          width: 2.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildMilestoneText(int nodeVal, int current, bool dark) {
    final bool isActiveOrPassed = current >= nodeVal;
    return SizedBox(
      width: 14, // Same width as the node container
      child: OverflowBox(
        minWidth: 0,
        maxWidth: 40,
        child: Center(
          child: Text(
            nodeVal.toString(),
            style: TextStyle(
              color: isActiveOrPassed ? const Color(0xFFD4AF37) : (dark ? Colors.white30 : Colors.black38),
              fontSize: 11,
              fontWeight: isActiveOrPassed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedPrayerButton extends StatefulWidget {
  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  const AnimatedPrayerButton({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onTap,
  });

  @override
  _AnimatedPrayerButtonState createState() => _AnimatedPrayerButtonState();
}

class _AnimatedPrayerButtonState extends State<AnimatedPrayerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onTap();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isChecked
                    ? const Color(0xFFD4AF37)
                    : (dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                border: Border.all(
                  color: widget.isChecked
                      ? const Color(0xFFD4AF37)
                      : (dark ? Colors.white12 : Colors.black12),
                  width: 1.5,
                ),
                boxShadow: widget.isChecked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.isChecked ? Icons.check : Icons.add,
                  color: widget.isChecked
                      ? const Color(0xFF0F1B31)
                      : (dark ? Colors.white38 : Colors.black38),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            color: dark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class TopCardOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Sun rays from top-left
    final path = Path();
    const numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final startAngle = (math.pi / 2) * (i / numRays);
      final endAngle = (math.pi / 2) * ((i + 0.5) / numRays);
      
      path.moveTo(0, 0);
      path.lineTo(size.width * math.cos(startAngle) * 1.5, size.height * math.sin(startAngle) * 1.5);
      path.lineTo(size.width * math.cos(endAngle) * 1.5, size.height * math.sin(endAngle) * 1.5);
      path.close();
    }
    canvas.drawPath(path, paint);

    // Mosque silhouette in bottom right corner
    final mosquePaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final mosquePath = Path();
    double w = size.width;
    double h = size.height;

    mosquePath.moveTo(w * 0.45, h);
    
    // Left minaret
    mosquePath.lineTo(w * 0.52, h);
    mosquePath.lineTo(w * 0.52, h * 0.55);
    mosquePath.lineTo(w * 0.535, h * 0.55);
    mosquePath.lineTo(w * 0.535, h * 0.35); // spire
    mosquePath.lineTo(w * 0.545, h * 0.35);
    mosquePath.lineTo(w * 0.545, h * 0.55);
    mosquePath.lineTo(w * 0.56, h * 0.55);
    mosquePath.lineTo(w * 0.56, h);

    // Center dome
    mosquePath.lineTo(w * 0.65, h);
    mosquePath.quadraticBezierTo(w * 0.65, h * 0.62, w * 0.73, h * 0.62); // dome left arc
    mosquePath.quadraticBezierTo(w * 0.73, h * 0.54, w * 0.75, h * 0.54); // dome tip
    mosquePath.quadraticBezierTo(w * 0.77, h * 0.54, w * 0.77, h * 0.62);
    mosquePath.quadraticBezierTo(w * 0.85, h * 0.62, w * 0.85, h);
    
    // Right minaret
    mosquePath.lineTo(w * 0.88, h);
    mosquePath.lineTo(w * 0.88, h * 0.55);
    mosquePath.lineTo(w * 0.895, h * 0.55);
    mosquePath.lineTo(w * 0.895, h * 0.35); // spire
    mosquePath.lineTo(w * 0.905, h * 0.35);
    mosquePath.lineTo(w * 0.905, h * 0.55);
    mosquePath.lineTo(w * 0.92, h * 0.55);
    mosquePath.lineTo(w * 0.92, h);

    mosquePath.lineTo(w, h);
    mosquePath.close();
    
    canvas.drawPath(mosquePath, mosquePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
