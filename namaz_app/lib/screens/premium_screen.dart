import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  static const Color _primaryGreen = Color(0xFF27A770);
  static const Color _darkGreen = Color(0xFF1E5E43);
  static const Color _darkCharcoal = Color(0xFF2D2D2D);
  static const Color _orange = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCloseButton(),
              const SizedBox(height: 12),
              _buildHeaderSection(),
              const SizedBox(height: 28),
              _buildPaketlerSection(),
              const SizedBox(height: 28),
              _buildGelistiriciMesaji(),
              const SizedBox(height: 28),
              _buildYardimciOlma(),
              const SizedBox(height: 28),
              _buildSizdenGelenler(),
              const SizedBox(height: 28),
              _buildOzelliklerTable(),
              const SizedBox(height: 28),
              _buildPricingPlans(),
              const SizedBox(height: 20),
              _buildSatinAlButton(),
              const SizedBox(height: 12),
              _buildAboneligiGeriYukle(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Close Button ───────────────────────────────────────────────────
  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.close, size: 28, color: Colors.black54),
      ),
    );
  }

  // ─── Header Section ─────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Namaz Vakitleri',
                style: TextStyle(
                  color: _primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              TextSpan(
                text: ' eğlence harcamalarından çok daha uygun!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Rahatsız edici reklamlardan kurtulun ve tüm özelliklere sınırsız erişin',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // ─── Paketler Section ───────────────────────────────────────────────
  Widget _buildPaketlerSection() {
    return Column(
      children: [
        const Text(
          'Paketler',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Table header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  'Günlük Fiyat Karşılaştırması',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildComparisonRow('Video Platformu', '₺349/ay', false),
              _buildDivider(),
              _buildComparisonRow('Müzik Platformu', '₺259/ay', false),
              _buildDivider(),
              _buildComparisonRow('Bir Fincan Kahve', '₺100', false),
              _buildDivider(),
              _buildPremiumRow(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Günlük sadece birkaç lira ile tüm özelliklere erişin!',
          style: TextStyle(
            color: _primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String name, String price, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 14)),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumRow() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryGreen.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🏅 ', style: TextStyle(fontSize: 18)),
              const Text(
                'Namaz Vakitleri Premium',
                style: TextStyle(
                  color: _primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Text(
            '₺24/ay',
            style: TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300);
  }

  // ─── Geliştiricinin Mesajı ──────────────────────────────────────────
  Widget _buildGelistiriciMesaji() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Container(
                width: 50,
                height: 50,
                color: _primaryGreen,
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Geliştiricinin Mesajı',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Selamun aleykum.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Namaz vakitlerini takip etmeyi kolaylaştırmak için bu uygulamayı geliştirdim. İlginiz ve dualarınız için çok teşekkür ederim.',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Yardımcı Olma ─────────────────────────────────────────────────
  Widget _buildYardimciOlma() {
    const bullets = [
      'Premium üyelik ile uygulamayı reklamsız kullanabilirsiniz',
      'Hayır dualarınızla bizi destekleyebilirsiniz',
      'Play Store\'da değerlendirme yaparak görüşlerinizi paylaşabilirsiniz',
      'Geri bildirimleriniz ve önerileriniz bizim için çok değerli',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bize bu yolculukta ve gelişimlerimizde yardımcı olabilirsiniz:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(b, style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Destekleriniz için teşekkür ederiz.',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ─── Sizden Gelenler ───────────────────────────────────────────────
  Widget _buildSizdenGelenler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sizden gelenler',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          initial: 'E',
          name: 'Emine T.',
          review:
              'Çocuklarıma namaz vakitlerini öğretmek için kullanıyorum. Çok pratik ve anlaşılır. Ailece memnunuz.',
        ),
        const SizedBox(height: 10),
        _buildReviewCard(
          initial: 'O',
          name: 'Osman P.',
          review:
              'Yaşlı babam için kurdum, çok beğendi. Büyük yazılar ve net bildirimler sayesinde rahatça kullanıyor.',
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String initial,
    required String name,
    required String review,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _primaryGreen,
              radius: 22,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(Icons.star, color: Colors.orange, size: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Özellikler Table ──────────────────────────────────────────────
  Widget _buildOzelliklerTable() {
    final features = <_Feature>[
      _Feature('Ezan Hatırlatıcıları', true, true),
      _Feature('Namaz Takibi', true, true),
      _Feature('Kıble Bulucu', true, true),
      _Feature('Kur\'an & Tesbih & Dualar', true, true),
      _Feature('Geliştiriciye Destek', false, true),
      _Feature('Reklamsız Deneyim', false, true),
      _Feature('Kuran Arapçası', false, true),
      _Feature('Tebrik Kartları', false, true),
      _Feature('Dini Hikayeler', false, true),
      _Feature('Dini Radyolar', false, true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özellikler',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 4,
                      child: Text(
                        'Özellikler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Ücretsiz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Premium 👑',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ...List.generate(features.length, (i) {
                final f = features[i];
                return Container(
                  color: i.isOdd ? Colors.grey.shade50 : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          f.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: f.free
                              ? const Icon(
                                  Icons.check,
                                  color: _primaryGreen,
                                  size: 20,
                                )
                              : const Text(
                                  '—',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: f.premium
                              ? const Icon(
                                  Icons.check,
                                  color: _primaryGreen,
                                  size: 20,
                                )
                              : const Text(
                                  '—',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Pricing Plans ─────────────────────────────────────────────────
  Widget _buildPricingPlans() {
    return Row(
      children: [
        // Aylık
        Expanded(
          child: _buildPlanCard(
            gradient: const LinearGradient(
              colors: [_primaryGreen, _darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            badge: null,
            title: 'Aylık Plan',
            subtitle: 'Aylık ödeme',
            price: '₺24,99',
          ),
        ),
        const SizedBox(width: 8),
        // Önerilen
        Expanded(
          child: _buildPlanCard(
            gradient: const LinearGradient(
              colors: [_darkCharcoal, Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            badge: 'Tek seferlik',
            badgeColor: _primaryGreen,
            title: 'Önerilen Planı',
            subtitle: 'Tek seferlik ödeme',
            price: '₺249,99',
          ),
        ),
        const SizedBox(width: 8),
        // Yıllık
        Expanded(
          child: _buildPlanCard(
            gradient: const LinearGradient(
              colors: [_orange, Color(0xFFD35400)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            badge: '50% İndirim',
            badgeColor: Colors.red,
            title: 'Yıllık Plan',
            subtitle: 'Yıllık ödeme',
            price: '₺149,99',
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required LinearGradient gradient,
    required String? badge,
    Color? badgeColor,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor ?? _primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Satın Al Button ───────────────────────────────────────────────
  Widget _buildSatinAlButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Premium üyelik yakında aktif edilecektir. Teşekkür ederiz!',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkCharcoal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Satın Al',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // ─── Aboneliği Geri Yükle ──────────────────────────────────────────
  Widget _buildAboneligiGeriYukle() {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonelik geri yükleme işlemi başlatıldı.'),
            ),
          );
        },
        child: const Text(
          'Aboneliği Geri Yükle',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

// ─── Helper model ──────────────────────────────────────────────────────
class _Feature {
  final String name;
  final bool free;
  final bool premium;

  const _Feature(this.name, this.free, this.premium);
}
