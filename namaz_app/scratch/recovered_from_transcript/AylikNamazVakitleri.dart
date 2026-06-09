Widget _buildAylikNamazVakitleri() {
2578:     final bool dark = _isDark;
2579: 
2580:     if (_loadingMonthlyTimes) {
2581:       return Center(
2582:         child: Column(
2583:           mainAxisAlignment: MainAxisAlignment.center,
2584:           children: [
2585:             CircularProgressIndicator(
2586:               valueColor: AlwaysStoppedAnimation<Color>(_greenColor),
2587:             ),
2588:             const SizedBox(height: 16),
2589:             Text(
2590:               "Namaz Vakitleri Y\u00fckleniyor...",
2591:               style: TextStyle(
2592:                 fontSize: 14,
2593:                 color: _textColor,
2594:                 fontWeight: FontWeight.w500,
2595:               ),
2596:             ),
2597:           ],
2598:         ),
2599:       );
2600:     }
2601: 
2602:     if (_monthlyPrayerTimes.isEmpty) {
2603:       return Center(
2604:         child: Padding(
2605:           padding: const EdgeInsets.all(24.0),
2606:           child: Column(
2607:             mainAxisAlignment: MainAxisAlignment.center,
2608:             children: [
2609:               const Icon(
2610:                 Icons.cloud_off,
2611:                 color: Colors.grey,
2612:                 size: 64,
2613:               ),
2614:               const SizedBox(height: 16),
2615:               Text(
2616:                 "Namaz Vakitleri Al\u0131namad\u0131",
2617:                 style: TextStyle(
2618:                   fontSize: 16,
2619:                   fontWeight: FontWeight.bold,
2620:                   color: _textColor,
2621:                 ),
2622:               ),
2623:               const SizedBox(height: 8),
2624:               Text(
2625:                 "L\u00fctfen internet ba\u011flant\u0131n\u0131z\u0131 kontrol edip tekrar deneyin veya konum ayarlar\u0131n\u0131z\u0131 g\u00fcncelleyin.",
2626:                 textAlign: TextAlign.center,
2627:                 style: TextStyle(fontSize: 12.5, color: _subtitleColor, height: 1.4),
2628:               ),
2629:             ],
2630:           ),
2631:         ),
2632:       );
2633:     }
2634: 
2635:     // Get today's date formatted as dd.MM.yyyy
2636:     final now = DateTime.now();
2637:     final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
2638: 
2639:     return Column(
2640:       children: [
2641:         // Premium Header Card showing selected location
2642:         Container(
2643:           width: double.infinity,
2644:           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
2645:           margin: const EdgeInsets.only(bottom: 12),
2646:           decoration: BoxDecoration(
2647:             gradient: LinearGradient(
2648:               colors: dark
2649:                   ? [const Color(0xFF131D31), const Color(0xFF0F1B2A)]
2650:                   : [Colors.white, const Color(0xFFF0F4F8)],
The above content does NOT show the entire file contents. If you need to view any lines of the file which were not shown to complete your task, call this tool again to view those lines.
"}