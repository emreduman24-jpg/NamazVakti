1: "import 'dart:async';
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
31:   Map<String, dynamic>? _tomorrowTimes;
32: 
33:   bool _loading = true;
34:   Timer? _timer;
35: 
36:   // Live countdown state variables
37:   String _nextPrayerName = "";
38:   String _countdownText = "";
39:   double _progressValue = 0.0;
40:   String _activePrayerName = "";
41: 
42:   // Daily random index variables (based on day of the month)
43:   int _dayIndex = 0;
44: 
45:   @override
46:   void initState() {
47:     super.initState();
48:     _loadData();
49:     _dayIndex = DateTime.now().day % 5; // To rotate daily cards
50:     _timer = Timer.periodic(const
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
149:     DateTime yesYatsi = now.subtract(const Duration(days: 1));
150:     yesYatsi = DateTime(
151:       yesYatsi.year,
152:       yesYatsi.month,
153:       yesYatsi.day,
154:       yatsi.hour,
155:       yatsi.minute,
156:     );
157: 
158:     // List of slots: [Name, Start, End, NextName]
159:     final slots = [
160:       ['Yatsı', yesYatsi, imsak, 'İmsak'],
161:       ['İmsak', imsak, gunes, 'Güneş'],
162:       ['Güneş', gunes, ogle, 'Öğle'],
163:       ['Öğle', ogle, ikindi, 'İkindi'],
164:       ['İkindi', ikindi, aksam, 'Akşam'],
165:       ['Akşam', aksam, yatsi, 'Yatsı'],
166:       ['Yatsı', yatsi, tomImsak, 'İmsak'],
167:     ];
168: 
169:     String active = "Yatsı";
170:     String next = "İmsak";
171:     DateTime start = yatsi;
172:     DateTime end = tomImsak;
173: 
174:     for (var slot in slots) {
175:       final DateTime sStart = slot[1] as DateTime;
176:       final DateTime sEnd = slot[2] as DateTime;
177:       if (now.isAfter(sStart) && now.isBefore(sEnd)) {
178:         active = slot[0] as String;
179:         start = sStart;
180:         end = sEnd;
181:         next = slot[3] as String;
182:         break;
183:       }
184:     }
185: 
186:     final durationLeft = end.difference(now);
187:     final totalDuration = end.difference(start);
188: 
189:     final hours = durationLeft.inHours;
190:     final mins = durationLeft.inMinutes.remainder(60);
191:     final secs = durationLeft.inSeconds.remainder(60);
192: 
193:     setState(() {
194:       _activePrayerName = active;
195:       _nextPrayerName = next;
196:       _countdownText =
197:           "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
198:       _progressValue = 1.0 - (durationLeft.inSeconds / totalDuration.inSeconds);
199:     });
200:   }
201: 
202: 
203:               padding: const EdgeInsets.symmetric(
204:                 horizontal: 16.0,
205:                 vertical: 12,
206:               ),
207:               child: Row(
208:                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
209:                 children: [
210:                   _buildCircularQuickAction(
211:                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
212:                 children: [
213:                   _buildCircularQuickAction(
214:                     title: 'Dini Danışman',
215:                     imagePath: 'assets/dini_danisman.png',
216:               child: Row(
217:                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
218:                 children: [
219:                   _buildCircularQuickAction(
220:                     title: 'Dini Danışman',
221:                   color: Colors.white,
222:                   borderRadius: BorderRadius.circular(24),
223:                   boxShadow: [
224:                     BoxShadow(
225:                       color: Colors.black.withOpacity(0.02),
226:                       blurRadius: 8,
227:                       offset: const Offset(0, 2),
228:                     ),
229:                   ],
230:                 ),
231:                 child: Row(
232:                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
233:                   children: [
234:                     _buildPrayerCard('İmsak', _todayTimes!['Imsak'] ?? '--:--'),
235:                     _buildPrayerCard('Güneş', _todayTimes!['Gunes'] ?? '--:--'),
236:                     _buildPrayerCard('Öğle', _todayTimes!['Ogle'] ?? '--:--'),
237:                     _buildPrayerCard(
238:                       'İkindi',
239:                       _todayTimes!['Ikindi'] ?? '--:--',
240:                     ),
241:                     _buildPrayerCard('Akşam', _todayTimes!['Aksam'] ?? '--:--'),
242:                     _buildPrayerCard('Yatsı', _todayTimes!['Yatsi'] ?? '--:--'),
243:                   ],
244:                 ),
245:               ),
246:             ),
247:           ),
248: 
249:           // 4. Quick Links Navigation circles
250:           SliverToBoxAdapter(
251:             child: Padding(
252:               padding: const EdgeInsets.symmetric(
253:                 horizontal: 16.0,
254:                 vertical: 12,
255:               ),
256:               child: Row(
257:                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
258:                 children: [
259:                   _buildCircularQuickAction(
260:                     title: 'Dini Danışman',
261:                     offset: const Offset(0, 4),
262:                   ),
263:                 ],
264:               ),
265:               child: Stack(
266:                 children: [
267:                   // Subtle mandala ornament in the top-right
268:                   Positioned(
269:                     right: -40,
270:                     top: -40,
271:                     child: SizedBox(
272:                       width: 180,
273:                       height: 180,
274:                       child: CustomPaint(painter: SubtleMandalaPainter()),
275:                     ),
276:                   ),
277: 
278:                   // Content padding
279:                   Padding(
280:                     padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
281:                     child: Column(
282:                       crossAxisAlignment: CrossAxisAlignment.start,
283:                       children: [
284:                         /
285:                   Text(
286:                     dateUzun,
287:                     style: const TextStyle(color: Colors.white80, fontSize: 13),
288:                   ),
289:                             // Left side: Location & change link
290:                             Column(
291:                               crossAxisAlignment: CrossAxisAlignment.start,
292:                               children: [
293:                                 Row(
294:                                   children: [
295:                                     const Icon(
296:                                       Icons.location_on,
297:                                       color: Color(0xFF27A770),
298:                                       size: 18,
299:                                     ),
300:                                     const SizedBox(width: 4),
301:                                     Text(
302:                                       "$city / $district",
303:                                       style: const TextStyle(
304:                                         color: Color(0xFF1E5E43),
305:                                         fontSize: 16,
306:                                         fontWeight: FontWeight.bold,
307:                                       ),
308:                                     ),
309:                                   ],
310:                                 ),
311:                                 const SizedBox(height: 2),
312:                                 GestureDetector(
313:                                   onTap: () => widget.onTabChange(
314:                                     2,
315:                                   ), // Go to Settings Screen
316:                                   child: const Padding(
317:                                     padding: EdgeInsets.only(left: 4.0),
318:                                     child: Text(
319:                                       "Lokasyonu Değiştir",
320:                                       style: TextStyle(
321:                                         color: Color(0xFF27A770),
322:                                         fontSize: 12,
323:                                         fontWeight: FontWeight.w600,
324:                                         decoration: TextDecoration.underline,
325:                                       ),
326:                                     ),
327:                                   ),
328:                                 ),
329:                               ],
330:                             ),
331: 
332:                             // Right side: Dates (Miladi & Hicri)
333:                             Column(
334:                               crossAxisAlignment: CrossAxisAlignment.end,
335:                               children: [
336:                                 Text(
337:                                   dateUzun,
338:                                   style: const TextStyle(
339:                                     color: Color(0xFF1E5E43),
340:                                     fontSize: 12,
341:                                     fontWeight: FontWeight.bold,
342:                                   ),
343:                                 ),
344:                                 const SizedBox(height: 3),
345:                                 Text(
346:                                   hicriUzun,
347:                                   style: const TextStyle(
348:                                     color: Color(
349:                                       0xFFD4AF37,
350:                                     ), // Golden center glow color
351:                                     fontSize: 12,
352:                                     fontWeight: FontWeight.w600,
353:                                   ),
354:                                 ),
355:                               ],
356:                             ),
357:                           ],
358:                         ),
359: 
360:                         // 2. Large Digital Green Countdown and Linear Progress Bar
361:                         Center(
362:                           child: Column(
363:                             children: [
364:                               const SizedBox(height: 24),
365:                               Text(
366:                                 "$_nextPrayerName Vaktine Kalan Süre",
367:                                 style: const TextStyle(
368:                                   color: Color(0xFF1E5E43),
369:                                   fontSize: 14,
370:                                   fontWeight: FontWeight.w600,
371:                                 ),
372:                               ),
373:                               const SizedBox(height: 4),
374:                               Text(
375:                                 _countdownText,
376:                                 style: const TextStyle(
377:                                   color: Color(0xFF27A770),
378:                                   fontSize: 48,
379:                                   fontWeight: FontWeight.bold,
380:                                   letterSpacing: 1.5,
381:                                   fontFamily: 'monospace',
382:                                 ),
383:                               ),
384:                               const SizedBox(height: 12),
385: 
386:                               // Thin green linear loading bar
387:                               ClipRRect(
388:                                 borderRadius: BorderRadius.circular(4),
389:                                 child: SizedBox(
390:                            
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
421:                                     ),
422:                                     icon: const Icon(
423:                                       Icons.calendar_month,
424:                                       size: 16,
425:                                       color: Color(0xFF27A770),
426:                                     ),
427:                                     label: const Text(
428:                                       "Aylık Namaz Vakitleri",
429:                                       style: TextStyle(
430:                                         fontSize: 12,
431:                                         fontWeight: FontWeight.bold,
432:                                       ),
433:                                     ),
434:                                   ),
435:                                   const SizedBox(width: 12),
436:                                   ElevatedButton.icon(
437:                                     style: ElevatedButton.styleFrom(
438:                                       backgroundColor: const Color(0xFFEAF7F1),
439:                                       foregroundColor: const Color(0xFF1E5E43),
440:                                       elevation: 0,
441:                                       shape: RoundedRectangleBorder(
442:                                         borderRadius: BorderRadius.circular(20),
443:                                       ),
444:                                       padding: const EdgeInsets.symmetric(
445:                                         horizontal: 14,
446:                                         vertical: 10,
447:                                       ),
448:                                     ),
449:                                     onPressed: () {
450:                                       Navigator.push(
451:                                         context,
452:                                         MaterialPageRoute(
453:                                           builder: (_) =>
454:                                               const NotificationSettingsScreen(),
455:                                         ),
456:                                       );
457:                                     },
458:                                     icon: const Icon(
459:                                       Icons.notifications_active,
460:                                       size: 16,
461:                                       color: Color(0xFF27A770),
462:                                     ),
463:                                     label: const Text(
464:                                       "Ezan Bildirimleri",
465:                                       style: TextStyle(
466:                                         fontSize: 12,
467:                                         fontWeight: FontWeight.bold,
468:                                       ),
469:                                     ),
470:                                   ),
471:                                 ],
472:                               ),
473:                             ],
474:                           ),
475:                         ),
476:                       ],
477:                     ),
478:                   ),
479:                 ],
480:               ),
481:             ),
482:           ),
483: 
484:           // 3. Horizontal 6 Vakit prayer times bar (no cards, capsule active vakit highlighting)
485:           SliverToBoxAdapter(
486:             child: Padding(
487:               padding: const EdgeInsets.symmetric(
488:                 vertical: 8.0,
489:                 horizontal: 16.0,
490:               ),
491:               child: Container(
492:                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
493:                 decoration: BoxDecoration(
494:                   color: Colors.white,
495:                   borderRadius: BorderRadius.circular(24),
496:                   boxShadow: [
497:                     BoxShadow(
498:                       color: Colors.black.withOpacity(0.02),
499:                       blurRadius: 8,
500:                       offset: const Offset(0, 2),
501:                     ),
502:                   ],
503:                 ),
504:                 child: Row(
505:                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
506:                   children: [
507:                     _buildPrayerCard('İmsak', _todayTimes!['Imsak'] ?? '--:--'),
508:                     _buildPrayerCard('Güneş', _todayTimes!['Gunes'] ?? '--:--'),
509:                     _buildPrayerCard('Öğle', _todayTimes!['Ogle'] ?? '--:--'),
510:                     _buildPrayerCard(
511:                       'İkindi',
512:                       _todayTimes!['Ikindi'] ?? '--:--',
513:                     ),
514:                     _buildPrayerCard('Akşam', _todayTimes!['Aksam'] ?? '--:--'),
515:                     _buildPrayerCard('Yatsı', _todayTimes!['Yatsi'] ?? '--:--'),
516:                   ],
517:                 ),
518:               ),
519:             ),
520:           ),
521: 
522:           // 4. Quick Links Navigation circles
523:           SliverToBoxAdapter(
524:             child: Padding(
525:               padding: const EdgeInsets.symmetric(
526:                 horizontal: 16.0,
527:                 vertical: 12,
528:               ),
529:               child: Row(
530:                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
531:                 children: [
532:                   _buildCircularQuickAction(
533:                     title: 'Dini Danışman',
534:                     imagePath: 'assets/dini_danisman.png',
535:                     onTap: () =>
536:                         widget.onOpenTool('soru-cevap', 'Dini Danışman'),
537:                   ),
538:                   _buildCircularQuickAction(
539:                     title: 'Mekke Canlı',
540:                     imagePath: 'assets/mekke.png',
541:                     onTap: () =>
542:                         widget.onOpenTool('kabe-izle', 'Mekke Canlı Kabe'),
543:                   ),
544:                   _buildCircularQuickAction(
545:                     title: 'Ramazan',
546:                     imagePath: 'assets/ramazan.png',
547:                     onTap: () =>
548:                         widget.onOpenTool('ramazan-hakkinda', 'Ramazan'),
549:                   ),
550:                   _buildCircularQuickAction(
551:                     title: 'Tebrik Kartı',
552:                     imagePath: 'assets/tebrik.png',
553:                     onTap: () =>
554:                         widget.onOpenTool('dua-ist
555:                                   style: TextStyle(
556:                                     fontWeight: FontWeight.bold,
557:                                     fontSize: 16,
558:                                     color: Color(0xFF1E5E43),
559:                                   ),
560:                                 ),
561:                               ],
562:                             ),
563:                             const Divider(height: 20),
564:                             Row(
565:                               mainAxisAlignment: MainAxisAlignment.spaceAround,
566:                               children: [
567:                                 Column(
568:                                   children: [
569:                                     const Text("Kız Bebek", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
570:                                     const SizedBox(height: 4),
571:                                     Text(
572:                                       names['kiz'] ?? '',
573:                                       style: const TextStyle(
574:                                         fontWeight: FontWeight.bold,
575:                                         fontSize: 18,
576:                              
577:               ),
578:             ),
579:             const SizedBox(height: 8),
580:             Text(
581:               time,
582:               style: TextStyle(
583:                 fontWeight: FontWeight.w800,
584:                 color: isActive ? Colors.white : Colors.black87,
585:                   const SizedBox(height: 16),
586: 
587:                   // Gunun Isimleri Card with background image bebekler.png
588:                   Card(
589:                     elevation: 3,
590:                     shape: RoundedRectangleBorder(
591:                       borderRadius: BorderRadius.circular(16),
592:                     ),
593:                     clipBehavior: Clip.antiAlias,
594:                     child: Container(
595:                       decoration: const BoxDecoration(
596:                         image: DecorationImage(
597:                           image: AssetImage('assets/bebekler.png'),
598:                           fit: BoxFit.cover,
599:                         ),
600:                       ),
601:                       child: Container(
602:                         color: Colors.white.withOpacity(
603:                           0.88,
604:                         ), // Soft overlay to ensure readability
605:                         padding: const EdgeInsets.all(16.0),
606:                         child: Column(
607:                           crossAxisAlignment: CrossAxisAlignment.start,
608:                           children: [
609:                             Row(
610:                               children: [
611:                                 const Text(
612:                                   "👶",
613:                                   style: TextStyle(fontSize: 22),
614:                                 ),
615:                                 const SizedBox(width: 8),
616:                                 const Text(
617:                                   "Günün İsim Önerileri",
618:                                   style: TextStyle(
619:                                     fontWeight: FontWeight.bold,
620:                                     fontSize: 16,
621:                                     color: Color(0xFF1E5E43),
622:                                   ),
623:                                 ),
624:                               ],
625:                             ),
626:                             const Divider(height: 20),
627:                             Row(
628:                               mainAxisAlignment: MainAxisAlignment.spaceAround,
629:                               children: [
630:                                 Column(
631:                                   children: [
632:                                     const Text(
633:                                       "Kız Bebek",
634:                                       style: TextStyle(
635:                                         color: Colors.black54,
636:                                         fontSize: 13,
637:                                         fontWeight: FontWeight.w600,
638:                                       ),
639:                                     ),
640:                                     const SizedBox(height: 4),
641:                                     Text(
642:                                       names['kiz'] ?? '',
643:                                       style: const TextStyle(
644:                                         fontWeight: FontWeight.bold,
645:                                         fontSize: 18,
646:                                         color: Colors.pink,
647:                                       ),
648:                                     ),
649:                                   ]
650:                                 ),
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
662:                                         fontSize: 13,
663:                                         fontWeight: FontWeight.w600,
664:                                       ),
665:                                     ),
666:                                     const SizedBox(height: 4),
667:                                     Text(
668:                                       names['erkek'] ?? '',
669:                                       style: const TextStyle(
670:                                         fontWeight: FontWeight.bold,
671:                                         fontSize: 18,
672:                                         color: Colors.blue,
673:                                       ),
674:                                     ),
675:                                   ],
676:                                 ),
677:                               ],
678:                             ),
679:                           ],
680:                         ),
681:                       ),
682:                     ),
683:                   ),
684:                   const SizedBox(height: 16),
685: 
686:                   // Geliştirici Mesajı Banner - navigates to Premium screen
687:                   GestureDetector(
688:                     onTap: () {
689:                       Navigator.push(
690:                         context,
691:                         MaterialPageRoute(
692:                           builder: (_) => const PremiumScreen(),
693:                         ),
694:                       );
695:                     },
696:                     child: Card(
697:                       elevation: 3,
698:                       color: const Color(0xFFEAF7F1), // Soft green banner bg
699:                       shape: RoundedRectangleBorder(
700:                         borderRadius: BorderRadius.circular(16),
701:                       ),
702:                       child: Padding(
703:                         padding: const EdgeInsets.symmetric(
704:                           horizontal: 16.0,
705:                           vertical: 12.0,
706:                         ),
707:                         child: Row(
708:                           children: [
709:                             Expanded(
710:                               child: Column(
711:                                 crossAxisAlignment: CrossAxisAlignment.start,
712:                                 children: [
713:                                   const Text(
714:                                     "Geliştiricinin size mesajı var",
715:                                     style: TextStyle(
716:                                       fontWeight: FontWeight.bold,
717:                                       fontSize: 16,
718:                                       color: Color(0xFF1E5E43),
719:                                     ),
720:                                   ),
721:                                   const SizedBox(height: 4),
722:                                   Text(
723:                                     "Namaz Vakitleri mobil uygulamamızı tercih ettiğiniz için teşekkür ederiz. Dualarınızda bizleri de eksik etmeyin.",
724:                                     style: TextStyle(
725:                                       fontSize: 12.5,
726:                                       color: Colors.grey[800],
727:                                       height: 1.4,
728:               
729:                 child: Image.asset(
730:                   imagePath,
731:                   fit: BoxFit.cover,
732:                   width: 58,
733:                             const SizedBox(width: 12),
734:                             Image.asset(
735:                               'assets/gelistirici.png',
736:                               width: 70,
737:                               height: 70,
738:                               fit: BoxFit.contain,
739:                             ),
740:                           ],
741:                         ),
742:                       ),
743:                     ),
744:                   ),
745:                   const SizedBox(height: 30),
746:                 ],
747:               ),
748:             ),
749:           ),
750:         ],
751:       ),
752:     );
753:   }
754: 
755:   Widget _buildPrayerCard(String name, String time) {
756:     final bool isActive = _activePrayerName == name;
757:     return Expanded(
758:       child: Container(
759:         padding: const EdgeInsets.symmetric(vertical: 8),
760:         decoration: BoxDecoration(
761:           color: isActive ? const Color(0xFFEAF7F1) : Colors.transparent,
762:           borderRadius: BorderRadius.circular(16),
763:         ),
764:         child: Column(
765:           mainAxisSize: MainAxisSize.min,
766:           children: [
767:             Text(
768:               name,
769:               style: TextStyle(
770:                 fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
771:                 color: isActive ? const Color(0xFF1E5E43) : Colors.grey[600],
772:                 fontSize: 11,
773:               ),
774:             ),
775:             const SizedBox(height: 4),
776:             Text(
777:               time,
778:               style: TextStyle(
779:                 fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
780:                 color: isActive ? const Color(0xFF27A770) : Colors.black87,
781:                 fontSize: 13.5,
782:               ),
783:             ),
784:           ],
785:         ),
786:       ),
787:     );
788:   }
789: 
790:   Widget _buildCircularQuickAction({
791:     required String title,
792:     required String imagePath,
793:     required VoidCallback onTap,
794:   }) {
795:     return Expanded(
796:       child: GestureDetector(
797:         onTap: onTap,
798:         child: Column(
799:           children: [
800:             Container(
801:               width: 58,
802:               height: 58,
803:               decoration: BoxDecoration(
804:                 shape: BoxShape.circle,
805:                 color: Colors.white,
806:                 boxShadow: [
807:                   BoxShadow(
808:                     color: Colors.black.withOpacity(0.06),
809:                     blurRadius: 6,
810:                     offset: const Offset(0, 3),
811:                   ),
812:                 ],
813:               ),
814:               child: ClipOval(
815:                 child: Image.asset(
816:                   imagePath,
817:                   fit: BoxFit.cover,
818:                   width: 58,
819:                   height: 58,
820:                   errorBuilder: (context, error, stackTrace) {
821:                     return const Center(
822:                       child: Icon(Icons.image, color: Colors.grey),
823:                     );
824:                   },
825:                 ),
826:               ),
827:             ),
828:             const SizedBox(height: 6),
829:             Text(
830:               title,
831:               textAlign: TextAlign.center,
832:               style: const TextStyle(
833:                 fontSize: 11.5,
834:                 fontWeight: FontWeight.w600,
835:                 color: Color(0xFF1E5E43),
836:               ),
837:             ),
838:           ],
839:         ),
840:       ),
841:     );
842:   }
843: 
844:   Widget _buildDailyTextCard({
845:     required String title,
846:     required String ref,
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
873: MISSING
874: MISSING
875: MISSING
876: MISSING
877: MISSING
878: MISSING
879: MISSING
880: MISSING
881: MISSING
882: MISSING
883: MISSING
884: MISSING
885: MISSING
886: MISSING
887: MISSING
888: MISSING
889: MISSING
890: MISSING
891: MISSING
892: MISSING
893: MISSING
894: MISSING
895: MISSING
896: MISSING
897: MISSING
898: MISSING
899: MISSING
900: MISSING
901: MISSING
902: MISSING
903: MISSING
904: MISSING
905: MISSING
906: MISSING
907: MISSING
908: MISSING
909: MISSING
910: MISSING
911: MISSING
912: MISSING
913: MISSING
914: MISSING
915: MISSING
916:                 ),
917:               ),
918:             ),
919:           ],
920:         ),
921:       ),
922:     );
923:   }
924: }
925: 
926: // Background painter for the top-right header motif
927: class SubtleMandalaPainter extends CustomPainter {
928:   @override
929:   void paint(Canvas canvas, Size size) {
930:     final center = Offset(size.width / 2, size.height / 2);
931:     final paint = Paint()
932:       ..color = const Color(0xFF27A770)
933:           .withOpacity(0.04) // Very subtle green
934:       ..style = PaintingStyle.stroke
935:       ..strokeWidth = 1.0;
936: 
937:     // Draw concentric circles
938:     canvas.drawCircle(center, 25, paint);
939:     canvas.drawCircle(center, 50, paint);
940:     canvas.drawCircle(center, 75, paint);
941:     canvas.drawCircle(center, 100, paint);
942: 
943:     // Draw simple stars
944:     _drawStar(canvas, center, 40, 8, paint);
945:     _drawStar(canvas, center, 65, 8, paint);
946:     _drawStar(canvas, center, 90, 16, paint);
947:   }
948: 
949:   void _drawStar(
950:     Canvas canvas,
951:     Offset center,
952:     double radius,
953:     int points,
954:     Paint paint,
955:   ) {
956:     final path = Path();
957:     for (int i = 0; i < points * 2; i++) {
958:       final angle = (i * math.pi) / points;
959:       final currentRadius = i % 2 == 0 ? radius : radius * 0.75;
960:       final x = center.dx + currentRadius * math.cos(angle);
961:       final y = center.dy + currentRadius * math.sin(angle);
962:       if (i == 0) {
963:         path.moveTo(x, y);
964:       } else {
965:         path.lineTo(x, y);
966:       }
967:     }
968:     path.close();
969:     canvas.drawPath(path, paint);
970:   }
971: 
972:   @override
973:   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
974: }
975: 
