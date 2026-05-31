1: import 'dart:async';
2: import 'package:flutter/material.dart';
3: import '../data/prayer_repository.dart';
4: import '../data/prayer_data.dart';
5: import '../services/notification_service.dart';
6: 
7: class MainScreen extends StatefulWidget {
8:   final Function(int) onTabChange;
9:   final Function(String, String) onOpenTool;
10: 
11:   const MainScreen({Key? key, required this.onTabChange, required this.onOpenTool}) : super(key: key);
12: 
13:   @override
14:   _MainScreenState createState() => _MainScreenState();
15: }
16: 
17: class _MainScreenState extends State<MainScreen> {
18:   final PrayerRepository _repository = PrayerRepository();
19:   final NotificationService _notificationService = NotificationService();
20: 
21:   Map<String, String?> _location = {};
22:   List<Map<String, dynamic>> _prayerTimes = [];
23:   Map<String, dynamic>? _todayTimes;
24:   Map<String, dynamic>? _tomorrowTimes;
25: 
26:   bool _loading = true;
27:   Timer? _timer;
28: 
29:   // Live countdown state variables
30:   String _nextPrayerName = "";
31:   String _countdownText = "";
32:   double _progressValue = 0.0;
33:   String _activePrayerName = "";
34: 
35:   // Daily random index variables (based on day of the month)
36:   int _dayIndex = 0;
37: 
38:   @override
39:   void initState() {
40:     super.initState();
41:     _loadData();
42:     _dayIndex = DateTime.now().day % 5; // To rotate daily cards
43:     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
44:       if (mounted && _todayTimes != null) {
45:         _updateCountdown();
46:       }
47:  
48:     });
49:   }
50: 
51:   @override
52:   void dispose() {
53:     _timer?.cancel();
54:     super.dispose();
55:   }
56: 
57:   Future<void> _loadData() async {
58:     setState(() {
59:       _loading = true;
60:     });
61: 
62:     final loc = await _repository.getSavedLocation();
63:     final districtId = loc['districtId'];
64:     if (districtId != null) {
65:       final times = await _repository.getPrayerTimes(districtId);
66:       setState(() {
67:         _location = loc;
68:         _prayerTimes = times;
69:         
70:         // Find today's and tomorrow's times
71:         final nowStr = _formatDate(DateTime.now());
72:         final tomStr = _formatDate(DateTime.now().add(const Duration(days: 1)));
73: 
74:         _todayTimes = _findTimesForDate(nowStr);
75:         _tomorrowTimes = _findTimesForDate(tomStr);
76: 
77:         // If today's times not found in list, default to first item
78:         if (_todayTimes == null && _prayerTimes.isNotEmpty) {
79:           _todayTimes = _prayerTimes.first;
80:         }
81:         if (_tomorrowTimes == null && _prayerTimes.length > 1) {
82:           _tomorrowTimes = _prayerTimes[1];
83:         }
84: 
85:         _loading = false;
86:       });
87:       _updateCountdown();
88:     } else {
89:       setState(() {
90:         _loading = false;
91:       });
92:     }
93:   }
94: 
95:   String _formatDate(DateTime dt) {
96:     String day = dt.day.toString().padLeft(2, '0');
97:     String month = dt.month.toString().padLeft(2, '0');
98:     return "$day.$month.${dt.year}";
99:   }
100: 
101: MISSING
102: MISSING
103: MISSING
104: MISSING
105: MISSING
106: MISSING
107: MISSING
108: MISSING
109: MISSING
110: MISSING
111: MISSING
112: MISSING
113: MISSING
114: MISSING
115: MISSING
116: MISSING
117: MISSING
118: MISSING
119: MISSING
120: MISSING
121: MISSING
122: MISSING
123: MISSING
124: MISSING
125: MISSING
126: MISSING
127: MISSING
128: MISSING
129: MISSING
130: MISSING
131: MISSING
132: MISSING
133: MISSING
134: MISSING
135: MISSING
136: MISSING
137: MISSING
138: MISSING
139: MISSING
140: MISSING
141: MISSING
142: MISSING
143: MISSING
144: MISSING
145: MISSING
146: MISSING
147: MISSING
148: MISSING
149: MISSING
150: MISSING
151: MISSING
152: MISSING
153: MISSING
154: MISSING
155: MISSING
156: MISSING
157: MISSING
158: MISSING
159: MISSING
160: MISSING
161: MISSING
162: MISSING
163: MISSING
164: MISSING
165: MISSING
166: MISSING
167: MISSING
168: MISSING
169: MISSING
170: MISSING
171: MISSING
172: MISSING
173: MISSING
174: MISSING
175: MISSING
176: MISSING
177: MISSING
178: MISSING
179: MISSING
180: MISSING
181: MISSING
182: MISSING
183: MISSING
184: MISSING
185: MISSING
186: MISSING
187: MISSING
188: MISSING
189: MISSING
190: MISSING
191: MISSING
192: MISSING
193: MISSING
194: MISSING
195: MISSING
196: MISSING
197: MISSING
198: MISSING
199: MISSING
200: MISSING
201: MISSING
202: MISSING
203: MISSING
204: MISSING
205: MISSING
206:               ElevatedButton(
207:                 onPressed: () => widget.onTabChange(2), // Redirect to settings
208:                 child: const Text("Konum Seç"),
209:               )
210:             ],
211:           ),
212:         ),
213:       );
214:     }
215: 
216:     final theme = Theme.of(context);
217:     final String city = _location['cityName'] ?? '';
218:     final String district = _location['districtName'] ?? '';
219:     final String dateUzun = _todayTimes!['MiladiTarihUzun'] ?? '';
220:     final String hicriUzun = _todayTimes!['HicriTarihUzun'] ?? '';
221: 
222:     // Daily contents
223:     final verse = VAKTIN_AYETLERI[_dayIndex];
224:     final hadith = VAKTIN_HADISLERI[_dayIndex];
225:     final names = GUNUN_ISIMLERI[_dayIndex];
226: 
227:     return Scaffold(
228:       backgroundColor: const Color(0xFFF8FBF9), // Extremely clean, premium light grey-green background
229:       body: CustomScrollView(
230:         slivers: [
231:           // 1. Sleek Light Header with Subtle Motif Background
232:           SliverToBoxAdapter(
233:             child: Container(
234:               margin: const EdgeInsets.only(bottom: 8),
235:               decoration: BoxDecoration(
236:                 color: const Color(0xFFFDFBF7), // Warm light background
237:                 borderRadius: const BorderRadius.only(
238:                   bottomLeft: Radius.circular(28),
239:                   bottomRight: Radius.circular(28),
240:                 ),
241:                 boxShadow: [
242:                   BoxShadow(
243:                     color: Colors.black.withOpacity(0.04),
244:                     blurRadius: 12,
245:                     offset: const Offset(0, 4),
246:                   )
247:                 ],
248:               ),
249:               child: Stack(
250:                 children: [
251:                   // Subtle mandala ornament in the top-right
252:                   Positioned(
253:                     right: -40,
254:                     top: -40,
255:                     child: SizedBox(
256:                       width: 180,
257:                       height: 180,
258:                       child: CustomPaint(
259:                         painter: SubtleMandalaPainter(),
260:                       ),
261:                     ),
262:                   ),
263:                   
264:                   // Content padding
265:                   Padding(
266:                     padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
267:                     child: Column(
268:                       crossAxisAlignment: CrossAxisAlignment.start,
269:                       children: [
270:                         // Location and Dates Row
271:                         Row(
272:                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
273:                           crossAxisAlignment: CrossAxisAlignment.start,
274:                           children: [
275:                           IconButton(
276:                             icon: const Icon(Icons.calendar_month, color: Colors.white),
277:                             onPressed: () => widget.onOpenTool('dini-gunler', 'Dini Günler'),
278:                           ),
279:                         ],
280:                       )
281:                     ],
282:                   ),
283:                   const SizedBox(height: 12),
284:                   // Dates
285:                   Text(
286:                     dateUzun,
287:                     style: const TextStyle(color: Colors.white80, fontSize: 13),
288:                   ),
289:                   const SizedBox(height: 4),
290:                   Text(
291:                     hicriUzun,
292:                     style: const TextStyle(
293:                       color: Color(0xFFFFD700), // Golden color
294:                       fontSize: 14,
295:                       fontWeight: FontWeight.w500,
296: MISSING
297: MISSING
298: MISSING
299: MISSING
300: MISSING
301: MISSING
302: MISSING
303: MISSING
304: MISSING
305: MISSING
306: MISSING
307: MISSING
308: MISSING
309: MISSING
310: MISSING
311: MISSING
312: MISSING
313: MISSING
314: MISSING
315: MISSING
316: MISSING
317: MISSING
318: MISSING
319: MISSING
320: MISSING
321: MISSING
322: MISSING
323: MISSING
324: MISSING
325: MISSING
326: MISSING
327: MISSING
328: MISSING
329: MISSING
330: MISSING
331: MISSING
332: MISSING
333: MISSING
334: MISSING
335: MISSING
336: MISSING
337: MISSING
338: MISSING
339: MISSING
340: MISSING
341: MISSING
342: MISSING
343: MISSING
344: MISSING
345: MISSING
346: MISSING
347: MISSING
348: MISSING
349: MISSING
350: MISSING
351: MISSING
352: MISSING
353: MISSING
354: MISSING
355: MISSING
356: MISSING
357: MISSING
358: MISSING
359: MISSING
360: MISSING
361: MISSING
362: MISSING
363: MISSING
364: MISSING
365: MISSING
366: MISSING
367: MISSING
368: MISSING
369: MISSING
370: MISSING
371: MISSING
372: MISSING
373: MISSING
374: MISSING
375: MISSING
376: MISSING
377: MISSING
378: MISSING
379: MISSING
380: MISSING
381: MISSING
382: MISSING
383: MISSING
384: MISSING
385: MISSING
386: MISSING
387: MISSING
388: MISSING
389: MISSING
390: MISSING
391: MISSING
392: MISSING
393: MISSING
394: MISSING
395:                                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
396:                                     ),
397:                                   ),
398:                                   const SizedBox(width: 12),
399:                                   ElevatedButton.icon(
400:                                     style: ElevatedButton.styleFrom(
401:                                       backgroundColor: const Color(0xFFEAF7F1),
402:                                       foregroundColor: const Color(0xFF1E5E43),
403:                                       elevation: 0,
404:                                       shape: RoundedRectangleBorder(
405:                                         borderRadius: BorderRadius.circular(20),
406:                                       ),
407:                                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
408:                                     ),
409:                                     onPressed: () {
410:                                       _notificationService.playTestNotification();
411:                                       ScaffoldMessenger.of(context).showSnackBar(
412:                                         const SnackBar(content: Text('Ezan Bildirim Testi Tetiklendi!')),
413:                                       );
414:                                     },
415:                                     icon: const Icon(Icons.notifications_active, size: 16, color: Color(0xFF27A770)),
416:                                     label: const Text(
417:                                       "Ezan Bildirimleri",
418:                                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
419:                                     ),
420:                                   ),
421:                                 ],
422:                               ),
423:                             ],
424:                           ),
425:                         ),
426:                       ],
427:                     ),
428:                   ),
429:                 ],
430:               ),
431:             ),
432:           ),
433:           
434:           // 3. Horizontal 6 Vakit prayer times bar (no cards, capsule active vakit highlighting)
435:           SliverToBoxAdapter(
436:             child: Padding(
437:               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
438:               child: Container(
439:                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
440:                 decoration: BoxDecoration(
441: MISSING
442: MISSING
443: MISSING
444: MISSING
445: MISSING
446: MISSING
447: MISSING
448: MISSING
449: MISSING
450: MISSING
451: MISSING
452: MISSING
453: MISSING
454: MISSING
455: MISSING
456: MISSING
457: MISSING
458: MISSING
459: MISSING
460: MISSING
461: MISSING
462: MISSING
463: MISSING
464: MISSING
465: MISSING
466: MISSING
467: MISSING
468: MISSING
469: MISSING
470: MISSING
471: MISSING
472: MISSING
473: MISSING
474: MISSING
475: MISSING
476: MISSING
477: MISSING
478: MISSING
479: MISSING
480: MISSING
481: MISSING
482: MISSING
483: MISSING
484: MISSING
485: MISSING
486: MISSING
487: MISSING
488: MISSING
489: MISSING
490: MISSING
491: MISSING
492: MISSING
493: MISSING
494: MISSING
495: MISSING
496: MISSING
497: MISSING
498: MISSING
499: MISSING
500: MISSING
501: MISSING
502: MISSING
503: MISSING
504: MISSING
505: MISSING
506: MISSING
507: MISSING
508: MISSING
509: MISSING
510: MISSING
511: MISSING
512: MISSING
513:                   ),
514:                   const SizedBox(height: 16),
515:                   
516:                   // Hadis Card
517:                   _buildDailyTextCard(
518:                     title: "Günün Hadis-i Şerifi",
519:                     ref: hadith['ref'] ?? '',
520:                     text: hadith['text'] ?? '',
521:                     bannerText: hadith['title'] ?? '',
522:                     icon: "📜",
523:                   ),
524:                   const SizedBox(height: 16),
525: 
526:                   // Gunun Isimleri Card with background image bebekler.png
527:                   Card(
528:                     elevation: 3,
529:                     shape: RoundedRectangleBorder(
530:                       borderRadius: BorderRadius.circular(16),
531:                     ),
532:                     clipBehavior: Clip.antiAlias,
533:                     child: Container(
534:                       decoration: const BoxDecoration(
535:                         image: DecorationImage(
536:                           image: AssetImage('assets/bebekler.png'),
537:                           fit: BoxFit.cover,
538:                         ),
539:                       ),
540:                       child: Container(
541:                         color: Colors.white.withOpacity(0.88), // Soft overlay to ensure readability
542:                         padding: const EdgeInsets.all(16.0),
543:                         child: Column(
544:                           crossAxisAlignment: CrossAxisAlignment.start,
545:                           children: [
546:                             Row(
547:                               children: [
548:                                 const Text(
549:                                   "👶",
550:       ),
551:     );
552:   }
553: 
554:   Widget _buildPrayerCard(String name, String time) {
555:     final bool isActive = _activePrayerName == name;
556:     return Card(
557:       elevation: isActive ? 6 : 2,
558:       shape: RoundedRectangleBorder(
559:         borderRadius: BorderRadius.circular(16),
560:         side: isActive 
561:             ? const BorderSide(color: Color(0xFF27A770), width: 2)
562:             : BorderSide.none,
563:       ),
564:       color: isActive ? const Color(0xFF27A770) : Colors.white,
565:       child: Container(
566:         width: 84,
567:         padding: const EdgeInsets.symmetric(vertical: 12),
568:         child: Column(
569:           mainAxisAlignment: MainAxisAlignment.center,
570:           children: [
571:             Text(
572:               name,
573:               style: TextStyle(
574:                 fontWeight: FontWeight.bold,
575:                 color: isActive ? Colors.white : const Color(0xFF1E5E43),
576:                 fontSize: 13,
577:               ),
578:             ),
579:             const SizedBox(height: 8),
580:             Text(
581:               time,
582:               style: TextStyle(
583:                 fontWeight: FontWeight.w800,
584:                 color: isActive ? Colors.white : Colors.black87,
585:                 fontSize: 16,
586:               ),
587:             ),
588:           ],
589:         ),
590:       ),
591:     );
592:   }
593: 
594:   Widget _buildQuickLinkCard(
595:     BuildContext context, {
596:     required String title,
597:     required String
598: MISSING
599: MISSING
600:                   ),
601:                   const SizedBox(height: 16),
602:                   
603:                   // Geliştirici Mesajı Banner
604:                   Card(
605:                     elevation: 3,
606:                     color: const Color(0xFFEAF7F1), // Soft green banner bg
607:                     shape: RoundedRectangleBorder(
608:                       borderRadius: BorderRadius.circular(16),
609:                     ),
610:                     child: Padding(
611:                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
612:                       child: Row(
613:                         children: [
614:                           Expanded(
615:                             child: Column(
616:                               crossAxisAlignment: CrossAxisAlignment.start,
617:                               children: [
618:                                 const Text(
619:                                   "Geliştirici Mesajı",
620:                                   style: TextStyle(
621:                                     fontWeight: FontWeight.bold,
622:                                     fontSize: 16,
623:                                     color: Color(0xFF1E5E43),
624:                                   ),
625:                                 ),
626:                                 const SizedBox(height: 4),
627:                                 Text(
628:                                   "Namaz Vakitleri mobil uygulamamızı tercih ettiğiniz için teşekkür ederiz. Dualarınızda bizleri de eksik etmeyin.",
629:                                   style: TextStyle(
630:                                     fontSize: 12.5,
631:                                     color: Colors.grey[800],
632:                                     height: 1.4,
633:                                   ),
634:                                 ),
635:                               ],
636:                             ),
637:                           ),
638:                           const SizedBox(width: 12),
639:                           Image.asset(
640:                             'assets/gelistirici.png',
641:                             width: 70,
642:                             height: 70,
643:                             fit: BoxFit.contain,
644:                           ),
645:                         ],
646:                       ),
647:                     ),
648:                   ),
649:                   const SizedBox(height: 30),
650:                 ],
651:               ),
652:             ),
653:           )
654:         ],
655:       ),
656:     );
657:   }
658: 
659:   Widget _buildPrayerCard(String name, String time) {
660:     final bool isActive = _activePrayerName == name;
661: MISSING
662: MISSING
663: MISSING
664: MISSING
665: MISSING
666: MISSING
667: MISSING
668: MISSING
669: MISSING
670: MISSING
671: MISSING
672: MISSING
673: MISSING
674: MISSING
675: MISSING
676: MISSING
677: MISSING
678: MISSING
679: MISSING
680:                       title,
681:                       style: const TextStyle(
682:                         fontWeight: FontWeight.bold,
683:                         fontSize: 16,
684:                         color: Color(0xFF1E5E43),
685:                       ),
686:                     ),
687:                   ],
688:                 ),
689:                 Container(
690:                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
691:                   decoration: BoxDecoration(
692:                     color: const Color(0xFF27A770).withOpacity(0.15),
693:                     borderRadius: BorderRadius.circular(12),
694:                   ),
695:                   child: Text(
696:                     bannerText,
697:                     style: const TextStyle(
698:                       fontSize: 10,
699:                       fontWeight: FontWeight.bold,
700:                       color: Color(0xFF1E5E43),
701:                     ),
702:                   ),
703:                 )
704:               ],
705:             ),
706:             const Divider(height: 20),
707:             Text(
708:               "“$text”",
709:               style: const TextStyle(
710:                 fontStyle: FontStyle.italic,
711:                 fontSize: 13.5,
712:                 height: 1.4,
713:                 color: Colors.black87,
714:               ),
715:             ),
716:             const SizedBox(height: 8),
717:             Align(
718:               alignment: Alignment.bottomRight,
719:               child: Text(
720:                 "- $ref",
721:                 style: const TextStyle(
722:                   fontWeight: FontWeight.bold,
723:                   fontSize: 12,
724:                   color: Color(0xFF27A770),
725:                 ),
726:               ),
727:             )
728:           ],
729:         ),
730:       ),
731:     );
732:   }
733: }
734: 
735:                     return const Center(child: Icon(Icons.image, color: Colors.grey));
736:                   },
737:                 ),
738:               ),
739:             ),
740:             const SizedBox(height: 6),
741:             Text(
742:               title,
743:               textAlign: TextAlign.center,
744:               style: const TextStyle(
745:                 fontSize: 11.5,
746:                 fontWeight: FontWeight.w600,
747:                 color: Color(0xFF1E5E43),
748:               ),
749:             ),
750:           ],
751:         ),
752:       ),
753:     );
754:       elevation: 3,
755:       shape: RoundedRectangleBorder(
756:         borderRadius: BorderRadius.circular(16),
757:       ),
758:       color: Colors.white,
759:       child: Padding(
760:         padding: const EdgeInsets.all(16.0),
761:         child: Column(
762:           crossAxisAlignment: CrossAxisAlignment.start,
763:           children: [
764:             Row(
765:               mainAxisAlignment: MainAxisAlignment.spaceBetween,
766:               children: [
767:                 Row(
768:                   children: [
769:                     Text(
770:                       icon,
771:                       style: const TextStyle(fontSize: 22),
772:                     ),
773:                     const SizedBox(width: 8),
774:                     Text(
775:                       title,
776:                       style: const TextStyle(
777:                         fontWeight: FontWeight.bold,
778:                         fontSize: 16,
779:                         color: Color(0xFF1E5E43),
780:                       ),
781:                     ),
782:                   ],
783:                 ),
784:                 Container(
785:                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
786:                   decoration: BoxDecoration(
787:                     color: const Color(0xFF27A770).withOpacity(0.15),
788:                     borderRadius: BorderRadius.circular(12),
789:                   ),
790:                   child: Text(
791:                     bannerText,
792:                     style: const TextStyle(
793:                       fontSize: 10,
794:                       fontWeight: FontWeight.bold,
795:                       color: Color(0xFF1E5E43),
796:                     ),
797:                   ),
798:                 )
799:               ],
800:             ),
801:             const Divider(height: 20),
802:             Text(
803:               "“$text”",
804:               style: const TextStyle(
805:                 fontStyle: FontStyle.italic,
806:                 fontSize: 13.5,
807:                 height: 1.4,
808:                 color: Colors.black87,
809:               ),
810:             ),
811:             const SizedBox(height: 8),
812:             Align(
813:               alignment: Alignment.bottomRight,
814:               child: Text(
815:                 "- $ref",
816:                 style: const TextStyle(
817:                   fontWeight: FontWeight.bold,
818:                   fontSize: 12,
819:                   color: Color(0xFF27A770),
820:                 ),
821:               ),
822:             )
823:           ],
824:         ),
825:       ),
826:     );
827:   }
828: }
829: 
830: // Background painter for the top-right header motif
831: class SubtleMandalaPainter extends CustomPainter {
832:   @override
833:   void paint(Canvas canvas, Size size) {
834:     final center = Offset(size.width / 2, size.height / 2);
835:     final paint = Paint()
836:       ..color = const Color(0xFF27A770).withOpacity(0.04) // Very subtle green
837:       ..style = PaintingStyle.stroke
838:       ..strokeWidth = 1.0;
839: 
840:     // Draw concentric circles
841:     canvas.drawCircle(center, 25, paint);
842:     canvas.drawCircle(center, 50, paint);
843:     canvas.drawCircle(center, 75, paint);
844:     canvas.drawCircle(center, 100, paint);
845: 
846:     // Draw simple stars
847:     _drawStar(canvas, center, 40, 8, paint);
848:     _drawStar(canvas, center, 65, 8, paint);
849:     _drawStar(canvas, center, 90, 16, paint);
850:   }
851: 
852:   void _drawStar(Canvas canvas, Offset center, double radius, int points, Paint paint) {
853:     final path = Path();
854:     for (int i = 0; i < points * 2; i++) {
855:       final angle = (i * math.pi) / points;
856:       final currentRadius = i % 2 == 0 ? radius : radius * 0.75;
857:       final x = center.dx + currentRadius * math.cos(angle);
858:       final y = center.dy + currentRadius * math.sin(angle);
859:       if (i == 0) {
860:         path.moveTo(x, y);
861:       } else {
862:         path.lineTo(x, y);
863:       }
864:     }
865:     path.close();
866:     canvas.drawPath(path, paint);
867:   }
868: 
869:   @override
870:   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
871: }
872: 
