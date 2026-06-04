import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumScreen extends StatefulWidget {
  final bool isFromOnboarding;
  final VoidCallback? onComplete;

  const PremiumScreen({
    super.key,
    this.isFromOnboarding = false,
    this.onComplete,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // Billing options
  String _selectedPackage = 'yearly'; // 'yearly', 'monthly', 'lifetime'
  bool _isLifetimeToggled = false;

  // Testimonials Carousel
  final PageController _reviewController = PageController();
  int _activeReview = 0;
  Timer? _reviewTimer;

  final List<Map<String, String>> _testimonials = [
    {
      'title': 'Doğru namaz vakitleri',
      'review': 'Bu uygulamayı seviyorum ve bir süredir kullanıyorum. Bu uygulama sayesinde namazlarımı zamanında kılabildiğim için mutluyum. 💖🤍',
      'user': 'Ayse991'
    },
    {
      'title': 'Harika alarmlar ve ezanlar',
      'review': 'Ezan sesleri çok huzurlu ve alarmlar asla şaşmıyor. Arayüzü çok sade ve premium hissettiriyor, kesinlikle tavsiye ederim.',
      'user': 'AhmetK'
    },
    {
      'title': 'Reklamsız olması mükemmel',
      'review': 'Reklamların olmaması uygulamayı o kadar akıcı hale getiriyor ki. Emeği geçenlerden Allah razı olsun.',
      'user': 'Zeynep_D'
    }
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll testimonials every 4 seconds
    _reviewTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_reviewController.hasClients) {
        int nextPage = (_activeReview + 1) % _testimonials.length;
        _reviewController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F3A20), // Rich botanical dark green
              Color(0xFF072111), // Near black forest green
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Bar with Close Button & App Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cami Logo + Pro Badge
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF144D2B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Center(
                            child: Icon(Icons.mosque, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5A93B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Pro",
                            style: TextStyle(
                              color: Color(0xFF0F3A20),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Close X button
                    GestureDetector(
                      onTap: _handleClose,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Premium Info Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // 1. Laurel Wreath #1 App Store Badge (Custom drawn)
                      CustomPaint(
                        size: const Size(120, 70),
                        painter: LaurelWreathPainter(),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "#1 Namaz Vakitleri Uygulaması",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Şimdi ödeme yok.\n7 gün ücretsiz",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // 2. Billing Selection Options
                      if (!_isLifetimeToggled) ...[
                        // Yearly Package (Best value)
                        _buildPackageOption(
                          id: 'yearly',
                          title: "Yıllık",
                          badge: "7-gün ücretsiz",
                          priceMonthly: "₺125,00 /ay",
                          priceTotal: "₺1.499,99 /yıl",
                          discountTag: "İNDİRİM",
                        ),
                        const SizedBox(height: 12),
                        // Monthly Package
                        _buildPackageOption(
                          id: 'monthly',
                          title: "Aylık",
                          badge: "Ücretsiz deneme dahil değil",
                          priceMonthly: "₺499,99 /ay",
                          priceTotal: "₺5.999,88 /yıl",
                        ),
                      ] else ...[
                        // Lifetime package
                        _buildPackageOption(
                          id: 'lifetime',
                          title: "Ömür Boyu",
                          badge: "Sonsuza dek sınırsız erişim",
                          priceMonthly: "₺2.499,99",
                          priceTotal: "Tek seferlik ödeme",
                          discountTag: "FIRSAT",
                        ),
                      ],
                      const SizedBox(height: 28),

                      // 3. Dynamic swipable reviews carousel
                      const Text(
                        "Binlerce yorumda en beğenilen\nEzan Vakti uygulaması",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (_) => const Icon(Icons.star, color: Color(0xFFE5A93B), size: 16)),
                          const SizedBox(width: 8),
                          const Text(
                            "4,9 puan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "102.000 yorum arasından",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(height: 16),

                      // Swipable review PageView
                      SizedBox(
                        height: 120,
                        child: PageView.builder(
                          controller: _reviewController,
                          onPageChanged: (int index) {
                            setState(() {
                              _activeReview = index;
                            });
                          },
                          itemCount: _testimonials.length,
                          itemBuilder: (context, index) {
                            final item = _testimonials[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const Row(
                                        children: [
                                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 12),
                                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 12),
                                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 12),
                                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 12),
                                          Icon(Icons.star, color: Color(0xFFE5A93B), size: 12),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      item['review']!,
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['user']!,
                                    style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Carousel slide dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_testimonials.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _activeReview == index
                                  ? const Color(0xFF90B49C)
                                  : Colors.white24,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // 4. Feature list description (Namaz Pro'da neler var?)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Namaz Pro'da neler var?",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildFeatureRow(Icons.alarm, "Gelişmiş Alarmlar", "Asla vakit kaçırmayın"),
                      _buildFeatureRow(Icons.widgets_outlined, "Widget & Kilit Ekran Bildirim", "Tüm cihazlarınızda vakitleri görmek kolay"),
                      _buildFeatureRow(Icons.block_outlined, "Reklamları Kaldır", "Sorunsuz uygulama deneyimi"),
                      _buildFeatureRow(Icons.volume_up_outlined, "Ezan Bildirimleri", "Güzel ezan sesleri ve günlük hatırlatmalar"),
                      _buildFeatureRow(Icons.headphones_outlined, "Pro Ses Oynatıcı", "Kur'an tilaveti ve dualar"),
                      _buildFeatureRow(Icons.calendar_month_outlined, "Hicri Takvim", "Dini gün ve gecelere özel içerikler"),

                      const SizedBox(height: 16),
                      Text(
                        "Katkılarınız için teşekkür ederiz. En iyi Namaz Vakitleri uygulamasını desteklemek için Pro üyelik başlatıp çalışmalarımıza katkıda bulunabilirsiniz.",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 5. Lifetime / Ömür Boyu Switch Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kararsız mısın?",
                                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Ömür Boyu üyelik",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isLifetimeToggled,
                              onChanged: (val) {
                                setState(() {
                                    _isLifetimeToggled = val;
                                    _selectedPackage = val ? 'lifetime' : 'yearly';
                                });
                              },
                              activeColor: const Color(0xFF27A770),
                              activeTrackColor: const Color(0xFF144D2B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                decoration: const BoxDecoration(
                  color: Color(0xFF072111),
                  border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27A770), // Radiant glow green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _handlePurchase,
                        child: const Text(
                          "Ücretsiz Başlat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _handleRestore,
                      child: const Text(
                        "Üyeliğini Geri Yükle",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _handleClose,
                      child: const Text(
                        "Ücretsiz Sürüm ile Devam Et",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row for features list
  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF27A770), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Package Option Card
  Widget _buildPackageOption({
    required String id,
    required String title,
    required String badge,
    required String priceMonthly,
    required String priceTotal,
    String? discountTag,
  }) {
    final bool isSelected = _selectedPackage == id;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPackage = id;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF144D2B).withOpacity(0.2) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF27A770) : Colors.white.withOpacity(0.08),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                // Radio button circle
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF27A770) : Colors.white30,
                  size: 22,
                ),
                const SizedBox(width: 16),
                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (id == 'yearly') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27A770).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "7-gün ücretsiz",
                                style: TextStyle(color: Color(0xFF27A770), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badge,
                        style: TextStyle(
                          color: isSelected ? Colors.white60 : Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Prices
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      priceMonthly,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      priceTotal,
                      style: TextStyle(
                        color: isSelected ? Colors.white54 : Colors.white30,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Discount tag on top
        if (discountTag != null)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF27A770),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                discountTag,
                style: const TextStyle(
                  color: Color(0xFF0F3A20),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Handle closing of premium screen
  Future<void> _handleClose() async {
    if (widget.isFromOnboarding) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // Handle purchase processing
  Future<void> _handlePurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Premium Namaz Pro üyeliğiniz başarıyla başlatıldı! Teşekkür ederiz.", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF27A770),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _handleClose();
  }

  // Handle Restore
  void _handleRestore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aboneliğiniz App Store üzerinden geri yükleniyor...", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF142442),
      ),
    );
  }
}

// Custom Painter to draw Laurels & the App Store Badge offline with high premium fidelity
class LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;

    // Draw Laurel branches (Left and Right arcs)
    final leftPath = Path();
    leftPath.addArc(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.3, size.height * 0.7),
      math.pi * 0.5,
      math.pi * 0.9,
    );
    canvas.drawPath(leftPath, paint);

    final rightPath = Path();
    rightPath.addArc(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.1, size.width * 0.3, size.height * 0.7),
      math.pi * 0.5,
      -math.pi * 0.9,
    );
    canvas.drawPath(rightPath, paint);

    // Draw leaf decoration along the wreaths
    for (int i = 0; i < 5; i++) {
      double t = i / 4.0;
      // Left side leaves
      double lx = size.width * (0.17 + 0.1 * t);
      double ly = size.height * (0.7 - 0.5 * t);
      canvas.drawOval(Rect.fromCenter(center: Offset(lx - 5, ly), width: 8, height: 4), leafPaint);

      // Right side leaves
      double rx = size.width * (0.83 - 0.1 * t);
      double ry = size.height * (0.7 - 0.5 * t);
      canvas.drawOval(Rect.fromCenter(center: Offset(rx + 5, ry), width: 8, height: 4), leafPaint);
    }

    // Text "1" in the center
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: "1",
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset((size.width - textPainter1.width) / 2, size.height * 0.12),
    );

    // Text "App Store" underneath the number 1
    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: "App Store",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset((size.width - textPainter2.width) / 2, size.height * 0.52),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
