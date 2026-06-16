import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/billing_service.dart';


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
  String _selectedPackage = 'yearly'; // 'yearly', 'monthly'

  // Testimonials Carousel
  final PageController _reviewController = PageController();
  int _activeReview = 0;
  Timer? _reviewTimer;
  bool _isLoading = false;
  List<Package> _packages = [];

  Package? _getPackage(String id) {
    if (_packages.isEmpty) return null;
    if (id == 'yearly') {
      for (var p in _packages) {
        if (p.packageType == PackageType.annual) return p;
      }
    } else if (id == 'monthly') {
      for (var p in _packages) {
        if (p.packageType == PackageType.monthly) return p;
      }
    }
    return null;
  }


  final List<Map<String, String>> _testimonials = [
    {
      'title': 'Doğru namaz vakitleri',
      'review': 'Bu uygulamayı seviyorum ve bir süredir kullanıyorum. Bu uygulama sayesinde namazlarımı zamanında kılabildiğim için mutluyum. 💖',
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

    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final packages = await BillingService.fetchOfferings();
      if (packages.isNotEmpty) {
        setState(() {
          _packages = packages;
        });
      }
    } catch (e) {
      print("Error loading RevenueCat offerings: $e");
    }
  }


  @override
  void dispose() {
    _reviewTimer?.cancel();
    _reviewController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: success ? const Color(0xFF27A770) : const Color(0xFF142442),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F3A20), // Rich dark green
                  Color(0xFF05170B), // Deep forest black
                ],
              ),
            ),
          ),
          
          // Outer UI layout
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar
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
                              child: Icon(Icons.mosque_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
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
                      // Close button
                      GestureDetector(
                        onTap: _handleClose,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Info Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // 1. Laurel Wreath Gold App Store Badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radial Glow Effect
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD4AF37).withOpacity(0.08),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(120, 70),
                              painter: LaurelWreathPainter(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "#1 Namaz Vakitleri & Rehber Uygulaması",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "7 Gün Ücretsiz Deneyin",
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "İstediğiniz zaman iptal edin. Şimdi ödeme yok.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 28),

                        // 2. Billing Selection Options Stacked (Monthly, Yearly)
                        () {
                          final yearlyPkg = _getPackage('yearly');
                          final monthlyPkg = _getPackage('monthly');

                          final yearlyPrice = yearlyPkg?.storeProduct.priceString ?? "₺894,00";
                          final monthlyPrice = monthlyPkg?.storeProduct.priceString ?? "₺149,00";
                          
                          String yearlyMonthlyPrice = "₺74,50 /ay";
                          if (yearlyPkg != null) {
                            final monthlyVal = (yearlyPkg.storeProduct.price / 12).toStringAsFixed(2);
                            final symbol = yearlyPkg.storeProduct.priceString.replaceAll(RegExp(r'[0-9.,\s]'), '');
                            yearlyMonthlyPrice = symbol.isNotEmpty ? "$symbol$monthlyVal /ay" : "${yearlyPkg.storeProduct.currencyCode} $monthlyVal /ay";
                          }

                          return Column(
                            children: [
                              _buildPackageOption(
                                id: 'yearly',
                                title: "Yıllık Plan",
                                badge: "7 Gün Ücretsiz Deneme Dahil",
                                priceMonthly: yearlyMonthlyPrice,
                                priceTotal: "$yearlyPrice/yıl faturalandırılır",
                                discountTag: "%50 İNDİRİM",
                                isPopular: true,
                              ),
                              const SizedBox(height: 12),
                              _buildPackageOption(
                                id: 'monthly',
                                title: "Aylık Plan",
                                badge: "7 Gün Ücretsiz Deneme Dahil",
                                priceMonthly: monthlyPrice,
                                priceTotal: "₺1.788,00 /yıl değerinde",
                              ),
                            ],
                          );
                        }(),


                        const SizedBox(height: 32),

                        // 3. Features description built as a 2-Column Grid
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pro Özellikleri Nelerdir?",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildFeatureCard(
                              Icons.notifications_active_rounded, 
                              "Gelişmiş Alarmlar", 
                              "Asla vakit kaçırmayın",
                              [const Color(0xFFF2994A), const Color(0xFFF2C94C)],
                            ),
                            _buildFeatureCard(
                              Icons.block_rounded, 
                              "Reklamları Kaldır", 
                              "Sorunsuz deneyim",
                              [const Color(0xFFEB5757), const Color(0xFFFF8A8A)],
                            ),
                            _buildFeatureCard(
                              Icons.volume_up_rounded, 
                              "Ezan Bildirimleri", 
                              "Huzur veren sesler",
                              [const Color(0xFF6F52ED), const Color(0xFF8B73FF)],
                            ),
                            _buildFeatureCard(
                              Icons.headphones_rounded, 
                              "Pro Oynatıcı", 
                              "Sesli cüzler ve dualar",
                              [const Color(0xFF2F80ED), const Color(0xFF00C9FF)],
                            ),
                            _buildFeatureCard(
                              Icons.widgets_rounded, 
                              "Widget Desteği", 
                              "Ana ekranda hızlı takip",
                              [const Color(0xFF27A770), const Color(0xFF1E5E43)],
                            ),
                            _buildFeatureCard(
                              Icons.calendar_month_rounded, 
                              "Hicri Takvim", 
                              "Önemli dini geceler",
                              [const Color(0xFF80CBC4), const Color(0xFF00796B)],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // 4. Testimonials carousel
                        const Text(
                          "Müslüman Kardeşlerimizin Yorumları",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (_) => const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 16)),
                            const SizedBox(width: 8),
                            const Text(
                              "4.9 Puan",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 180,
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
                                  border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                                        Row(
                                          children: List.generate(
                                            5, 
                                            (_) => const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                                    ? const Color(0xFF27A770)
                                    : Colors.white24,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05170B),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.08), 
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF27A770), Color(0xFF1E5E43)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF27A770).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _handlePurchase,
                          child: Text(
                            "7 Gün Ücretsiz Deneme Başlat",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _handleRestore,
                            child: const Text(
                              "Aboneliği Geri Yükle",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Container(width: 1.2, height: 12, color: Colors.white12),
                          GestureDetector(
                            onTap: _handleClose,
                            child: const Text(
                              "Ücretsiz Sürüm ile Devam Et",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
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

          // Secure Purchase Loader Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF27A770)),
                        SizedBox(height: 20),
                        Text(
                          "İşlem Güvenli Şekilde Tamamlanıyor...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption({
    required String id,
    required String title,
    required String badge,
    required String priceMonthly,
    required String priceTotal,
    String? discountTag,
    bool isPopular = false,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF27A770).withOpacity(0.12) 
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFFD4AF37) 
                    : (isPopular ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.white.withOpacity(0.08)),
                width: isSelected ? 2.2 : (isPopular ? 1.5 : 1.0),
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Selection check indicator
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white30,
                  size: 22,
                ),
                const SizedBox(width: 14),
                
                // Details
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "7 Gün Bedava",
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
                          color: isSelected ? Colors.white70 : Colors.white38,
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
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF27A770),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                discountTag,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0F3A20) : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
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

  Future<void> _handlePurchase() async {
    final selectedPkg = _getPackage(_selectedPackage);
    
    if (selectedPkg != null) {
      setState(() => _isLoading = true);
      try {
        final success = await BillingService.purchase(selectedPkg);
        if (success) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showSnackBar("Namaz Pro üyeliğiniz başarıyla başlatıldı! Teşekkür ederiz.", success: true);
            _handleClose();
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            _showSnackBar("Ödeme işlemi iptal edildi veya tamamlanamadı.");
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar("Ödeme işlemi tamamlanırken hata oluştu.");
        }
      }
    } else {
      // Fallback: If RevenueCat package is not loaded, do the previous simulated purchase
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium', true);
        
        // Update Firestore if user is logged in or local guest session exists
        final String? email = prefs.getString('user_email');
        final String? guestUuid = prefs.getString('guest_uuid');
        final String? docId = (email != null && email.isNotEmpty) ? email : guestUuid;
        
        if (docId != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(docId).update({
              'isPremium': true,
              'premiumType': _selectedPackage,
              'premiumDate': DateTime.now().toIso8601String(),
            }).timeout(const Duration(seconds: 3));
          } catch (firestoreErr) {
            print("Firestore premium purchase sync failed: $firestoreErr");
          }
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar("Namaz Pro üyeliğiniz başarıyla başlatıldı! (Simüle)", success: true);
          _handleClose();
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        _showSnackBar("Ödeme işlemi tamamlanırken hata oluştu.");
      }
    }
  }

  // Handle Restore
  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    try {
      final success = await BillingService.restorePurchases();
      setState(() => _isLoading = false);
      if (success) {
        _showSnackBar("Premium üyeliğiniz başarıyla geri yüklendi!", success: true);
        _handleClose();
      } else {
        _showSnackBar("Geri yüklenecek aktif bir abonelik bulunamadı.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Abonelik geri yüklenirken hata oluştu.");
    }
  }
}

// Custom Painter to draw Laurel branch Offline Badge with high premium gold fidelity
class LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37) // Golden Metallic
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = const Color(0xFFD4AF37)
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

    // Text "1" in the center (Gold)
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: "1",
        style: TextStyle(
          color: Color(0xFFD4AF37),
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
