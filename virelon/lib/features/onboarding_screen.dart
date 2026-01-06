import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/presentation/screens/game_screen.dart';
import '../core/enums/game_enums.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.style,
      title: "VIRELON'a",
      titleHighlight: "Hoş Geldin!",
      description: "Blöf, strateji ve entrika oyunu.\nHayatta kalan son oyuncu ol!",
      color: Colors.purple,
      tips: ["🎭 Her oyuncuya 2 gizli kart", "💰 2 altın ile başla", "🎯 Tüm kartları kaybet = Elen"],
    ),
    OnboardingPage(
      icon: Icons.monetization_on,
      title: "Temel",
      titleHighlight: "Hamleler",
      description: "Her tur bir hamle yapmalısın.\nKarakter iddiası gerektirmeyenler:",
      color: Colors.amber,
      tips: ["💵 Gelir: +1 altın (engellenemez)", "🤝 Dış Yardım: +2 altın", "⚔️ Darbe: 7 altın = kart kaybettir"],
    ),
    OnboardingPage(
      icon: Character.duke.icon,
      title: "DÜK",
      titleHighlight: "Kartı",
      description: "Para imparatoru!\nVergilerle zenginleş.",
      color: Character.duke.color,
      tips: ["💰 Vergi: +3 altın al", "🛡️ Dış Yardımı engelle", "⚠️ Herkes iddia edebilir!"],
    ),
    OnboardingPage(
      icon: Character.assassin.icon,
      title: "SUİKASTÇI",
      titleHighlight: "Kartı",
      description: "Gölgelerin efendisi.\n3 altınla öldür!",
      color: Character.assassin.color,
      tips: ["🗡️ Suikast: 3 altın öde", "⚡ Darbe'den ucuz", "🛡️ Kontes engelleyebilir"],
    ),
    OnboardingPage(
      icon: Character.captain.icon,
      title: "YÜZBAŞI",
      titleHighlight: "Kartı",
      description: "Deniz korsanı!\nRakiplerden çal!",
      color: Character.captain.color,
      tips: ["💰 Çalma: Rakipten 2 altın", "🛡️ Çalmayı engelle", "⚔️ Saldırı + Savunma"],
    ),
    OnboardingPage(
      icon: Icons.gavel,
      title: "Meydan",
      titleHighlight: "Okuma!",
      description: "Blöf yakaladın mı?\nMeydan oku ve kanıtla!",
      color: Colors.red,
      tips: ["❓ Her iddiaya meydan oku", "✅ Haklı = Blöf yapan kaybeder", "❌ Haksız = Sen kaybedersin"],
    ),
    OnboardingPage(
      icon: Icons.emoji_events,
      title: "Artık",
      titleHighlight: "Hazırsın!",
      description: "VIRELON ustası olmak için\noynarken öğren!",
      color: Colors.green,
      tips: ["🏆 Son kalan kazanır", "🧠 Strateji & Blöf dengesi", "🎮 Hadi başlayalım!"],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  page.color.withOpacity(0.8),
                  page.color.withOpacity(0.4),
                  const Color(0xFFF5F6F6),
                ],
                stops: const [0.0, 0.4, 0.5],
              ),
            ),
          ),

          // Geometric decorations
          ..._buildGeometricShapes(page.color),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Atla',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGeometricShapes(Color color) {
    return [
      // Top-left circle
      Positioned(
        left: -50,
        top: -50,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 3.seconds),
      ),
      // Top-right triangle
      Positioned(
        right: -30,
        top: 100,
        child: Transform.rotate(
          angle: math.pi / 6,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: 0, end: 0.1, duration: 4.seconds),
      ),
      // Floating squares
      Positioned(
        left: 30,
        top: 200,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -20, duration: 2.seconds),
      ),
      Positioned(
        right: 50,
        top: 250,
        child: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.25),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: 15, duration: 2.5.seconds),
      ),
      Positioned(
        left: 80,
        top: 320,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .moveX(begin: 0, end: 10, duration: 3.seconds),
      ),
    ];
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Column(
      children: [
        // Top section - Icon area
        Expanded(
          flex: 4,
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: page.color.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 70,
                color: page.color,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          ),
        ),

        // Bottom section - White card
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
              child: Column(
                children: [
                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: "${page.title} ",
                          style: const TextStyle(color: Color(0xFF1A1A1A)),
                        ),
                        TextSpan(
                          text: page.titleHighlight,
                          style: TextStyle(color: page.color),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    page.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Tips
                  ...page.tips.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: page.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 400 + entry.key * 100))
                          .slideX(begin: 0.1, end: 0),
                    );
                  }).toList(),

                  const Spacer(),

                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? page.color
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next button
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 250,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [page.color, page.color.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: page.color.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'BAŞLA!' : 'Devam Et',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ).animate().shimmer(delay: 1.seconds, duration: 1.seconds),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String titleHighlight;
  final String description;
  final Color color;
  final List<String> tips;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.color,
    required this.tips,
  });
}
