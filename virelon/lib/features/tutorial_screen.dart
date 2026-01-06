import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../core/enums/game_enums.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedScenarioIndex = 0;
  bool _isPlaying = false;
  int _currentStep = 0;
  Timer? _animationTimer;

  // === DATA (SCENARIOS, CHARACTERS, SIMULATIONS) ===
  // (Data is same as before, preserving it)
  
  // === TAB 1: HAMLELER ===
  final List<TutorialScenario> _actionScenarios = [
    // TEMEL HAMLELER
    TutorialScenario(
      title: "Gelir",
      description: "En güvenli hamle! Engellenemez.",
      character: null,
      color: Colors.green,
      icon: Icons.attach_money,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "GELİR aldı", coins: "+1", narration: "Havuzdan 1 altın alır. Kimse bunu engelleyemez!", emoji: "💰"),
        ScenarioStep(playerName: "Sistem", action: "Tamamlandı", coins: "", narration: "En yavaş ama en güvenli para kazanma yolu.", emoji: "✅"),
      ],
    ),
    TutorialScenario(
      title: "Dış Yardım",
      description: "2 altın al - Dük engelleyebilir!",
      character: null,
      color: Colors.blue,
      icon: Icons.handshake,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "DIŞ YARDIM ister", coins: "+2", narration: "2 altın almak istiyor...", emoji: "🤝"),
        ScenarioStep(playerName: "Mehmet", action: "DÜK ile engeller!", coins: "0", narration: "'Dük'üm var!' diyerek engeller.", emoji: "🛡️"),
        ScenarioStep(playerName: "Ahmet", action: "Meydan okumadı", coins: "", narration: "Risk almadı, hamle iptal.", emoji: "❌"),
      ],
    ),
    TutorialScenario(
      title: "Darbe (Coup)",
      description: "7 altın - Kesin kart kaybettir!",
      character: null,
      color: Colors.red,
      icon: Icons.flash_on,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "DARBE yapar!", coins: "-7", narration: "7 altın ödeyerek Mehmet'e darbe yapar.", emoji: "⚔️"),
        ScenarioStep(playerName: "Mehmet", action: "Kart kaybetti", coins: "", narration: "Darbe ENGELLENEMEZ! Bir kart açığa çıkar.", emoji: "💀"),
        ScenarioStep(playerName: "Sistem", action: "Zorunlu darbe", coins: "", narration: "10+ altın = DARBE ZORUNLU!", emoji: "⚠️"),
      ],
    ),
    // DÜK HAMLELERİ
    TutorialScenario(
      title: "Vergi (Dük)",
      description: "Dük olarak 3 altın al!",
      character: Character.duke,
      color: Character.duke.color,
      icon: Character.duke.icon,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "VERGİ alır", coins: "+3", narration: "'Dük'üm var!' - 3 altın almak istiyor.", emoji: "👑"),
        ScenarioStep(playerName: "Diğerleri", action: "Bekliyor...", coins: "", narration: "Herkes meydan okuyabilir veya izin verebilir.", emoji: "🤔"),
        ScenarioStep(playerName: "Kimse", action: "İtiraz etmedi", coins: "", narration: "Blöf olsa bile, meydan okunmadı!", emoji: "✅"),
        ScenarioStep(playerName: "Ahmet", action: "3 altın aldı", coins: "+3", narration: "Gerçekten Dük'ü var mı? Bilinmez...", emoji: "💰"),
      ],
    ),
    TutorialScenario(
      title: "Dük ile Blok",
      description: "Dış yardımı engelle!",
      character: Character.duke,
      color: Character.duke.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: "Mehmet", action: "DIŞ YARDIM ister", coins: "+2", narration: "Mehmet 2 altın almak istiyor.", emoji: "🤝"),
        ScenarioStep(playerName: "Ahmet", action: "DÜK ile engeller!", coins: "", narration: "'Dük'üm var, dış yardımı engelliyorum!'", emoji: "🛡️"),
        ScenarioStep(playerName: "Mehmet", action: "Kabul etti", coins: "0", narration: "Meydan okumadı, hamle iptal.", emoji: "❌"),
      ],
    ),
    // SUİKASTÇI HAMLELERİ
    TutorialScenario(
      title: "Suikast",
      description: "3 altın öde, rakibi etkisizleştir!",
      character: Character.assassin,
      color: Character.assassin.color,
      icon: Character.assassin.icon,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "SUİKAST yapar", coins: "-3", narration: "3 altın ödeyerek Mehmet'e suikast!", emoji: "🗡️"),
        ScenarioStep(playerName: "Mehmet", action: "Engel yok", coins: "", narration: "Kontes'i yok, engelleyemiyor.", emoji: "😱"),
        ScenarioStep(playerName: "Mehmet", action: "Kart kaybetti", coins: "", narration: "Bir kartını açığa çıkarır.", emoji: "💀"),
      ],
    ),
    TutorialScenario(
      title: "Suikast Engeli",
      description: "Kontes ile suikastı blokla!",
      character: Character.countess,
      color: Character.countess.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "SUİKAST yapar", coins: "-3", narration: "3 altın ödeyerek Mehmet'e suikast.", emoji: "🗡️"),
        ScenarioStep(playerName: "Mehmet", action: "KONTES ile engeller!", coins: "", narration: "'Kontes'im var, suikastı engelledim!'", emoji: "❤️"),
        ScenarioStep(playerName: "Ahmet", action: "Kabul etti", coins: "", narration: "3 altını gitti ama suikast iptal!", emoji: "💸"),
      ],
    ),
    // YÜZBAŞI HAMLELERİ
    TutorialScenario(
      title: "Çalma (Yüzbaşı)",
      description: "Rakipten 2 altın çal!",
      character: Character.captain,
      color: Character.captain.color,
      icon: Character.captain.icon,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "ÇALIYOR", coins: "+2", narration: "Mehmet'ten 2 altın çalmak istiyor.", emoji: "🏴‍☠️"),
        ScenarioStep(playerName: "Mehmet", action: "Engelleyemez!", coins: "-2", narration: "Yüzbaşı/Elçi/Engizisyoncu yok!", emoji: "😢"),
        ScenarioStep(playerName: "Sistem", action: "Transfer", coins: "", narration: "Para doğrudan transfer edilir.", emoji: "💱"),
      ],
    ),
    TutorialScenario(
      title: "Çalmayı Engelle",
      description: "Yüzbaşı/Elçi ile çalmayı blokla!",
      character: Character.captain,
      color: Character.captain.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "ÇALIYOR", coins: "+2", narration: "Mehmet'ten 2 altın çalmak istiyor.", emoji: "🏴‍☠️"),
        ScenarioStep(playerName: "Mehmet", action: "YÜZBAŞI ile engeller!", coins: "", narration: "'Yüzbaşı'ım var, çalamazsın!'", emoji: "🛡️"),
        ScenarioStep(playerName: "Ahmet", action: "Kabul etti", coins: "0", narration: "Hırsızlık engellendi!", emoji: "❌"),
      ],
    ),
    // ELÇİ HAMLELERİ
    TutorialScenario(
      title: "Kart Değişimi (Elçi)",
      description: "Desteden 2 kart çek, 2 ver!",
      character: Character.ambassador,
      color: Character.ambassador.color,
      icon: Character.ambassador.icon,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "DEĞİŞİM yapar", coins: "", narration: "Elçi olarak kart değişimi istiyor.", emoji: "🔄"),
        ScenarioStep(playerName: "Ahmet", action: "2 kart çekti", coins: "", narration: "Desteden 2 kart alır, 4 kartı var.", emoji: "🃏"),
        ScenarioStep(playerName: "Ahmet", action: "2 kart seçti", coins: "", narration: "İstediği 2 kartı tutar, diğerlerini verir.", emoji: "✨"),
      ],
    ),
    // MEYDAN OKUMA
    TutorialScenario(
      title: "Meydan Okuma - Başarılı",
      description: "Blöf yapanı yakala!",
      character: null,
      color: Colors.orange,
      icon: Icons.gavel,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "VERGİ alır", coins: "+3", narration: "Ama Dük'ü YOK! Blöf yapıyor.", emoji: "🎭"),
        ScenarioStep(playerName: "Mehmet", action: "MEYDAN OKUYOR!", coins: "", narration: "'Dük'ün yok, blöf yapıyorsun!'", emoji: "⚡"),
        ScenarioStep(playerName: "Ahmet", action: "Kartları gösteriyor", coins: "", narration: "Kartlarını göstermek ZORUNDA.", emoji: "👀"),
        ScenarioStep(playerName: "Ahmet", action: "BLÖF YAKALANDI!", coins: "", narration: "Dük yok! Ahmet kart kaybeder.", emoji: "💀"),
      ],
    ),
    TutorialScenario(
      title: "Meydan Okuma - Başarısız",
      description: "Yanlış tahmin = Kart kaybı!",
      character: null,
      color: Colors.red.shade700,
      icon: Icons.gavel,
      steps: [
        ScenarioStep(playerName: "Ahmet", action: "VERGİ alır", coins: "+3", narration: "Dük ile vergi almak istiyor.", emoji: "👑"),
        ScenarioStep(playerName: "Mehmet", action: "MEYDAN OKUYOR!", coins: "", narration: "'Dük'ün yok!'", emoji: "⚡"),
        ScenarioStep(playerName: "Ahmet", action: "Dük'ü gösterdi!", coins: "", narration: "Gerçekten Dük'ü var!", emoji: "✅"),
        ScenarioStep(playerName: "Mehmet", action: "YANILDI!", coins: "", narration: "Mehmet kart kaybeder!", emoji: "💀"),
        ScenarioStep(playerName: "Ahmet", action: "Kartını değişti", coins: "", narration: "Dük desteye geri gider, yeni kart alır.", emoji: "🔄"),
      ],
    ),
  ];

  // === TAB 2: KARAKTERLER ===
  final List<CharacterInfo> _characters = [
    // NORMAL MOD
    CharacterInfo(
      character: Character.duke,
      name: "Dük",
      isPlusMod: false,
      description: "Para imparatoru! Vergi topla ve dış yardımı engelle.",
      abilities: ["💰 Vergi: Havuzdan 3 altın al", "🛡️ Dış Yardımı engelle"],
      tips: ["En güçlü para kazanma yolu", "Herkes Dük iddia eder - dikkatli ol!"],
    ),
    CharacterInfo(
      character: Character.assassin,
      name: "Suikastçı",
      isPlusMod: false,
      description: "Gölgelerin efendisi. 3 altınla rakibi etkisizleştir!",
      abilities: ["🗡️ Suikast: 3 altın öde, hedef kart kaybeder", "⚡ Darbe'den ucuz ama engellenebilir"],
      tips: ["Kontes suikastı engeller", "Para geri gelmez, engellense bile!"],
    ),
    CharacterInfo(
      character: Character.countess,
      name: "Kontes",
      isPlusMod: false,
      description: "Sarayın koruyucusu. Suikastlara kalkan!",
      abilities: ["🛡️ Suikastları engelle", "❌ Saldırı yeteneği yok"],
      tips: ["Savunma odaklı", "Suikastçıya karşı değerli"],
    ),
    CharacterInfo(
      character: Character.captain,
      name: "Yüzbaşı",
      isPlusMod: false,
      description: "Deniz korsanı! Rakiplerden çal!",
      abilities: ["💰 Çalma: Rakipten 2 altın çal", "🛡️ Çalmayı engelle"],
      tips: ["Hem saldırı hem savunma", "Fakir oyuncudan çalamazsın"],
    ),
    CharacterInfo(
      character: Character.ambassador,
      name: "Elçi",
      isPlusMod: false,
      description: "Diplomat! Kartlarını değiştir!",
      abilities: ["🔄 Değişim: Desteden 2 çek, 2 ver", "🛡️ Çalmayı engelle"],
      tips: ["Strateji değiştirmek için harika", "Kötü kartlardan kurtul"],
    ),
    // PLUS MOD KARAKTERLERİ
    CharacterInfo(
      character: Character.inquisitor,
      name: "Engizisyoncu",
      isPlusMod: true,
      description: "Sorgulayıcı! Rakibin kartını gör ve değiştirt!",
      abilities: ["🔍 Sorgu: Rakibin 1 kartını gör", "🔄 Zorunlu değişim yaptırabilirsin", "🛡️ Çalmayı engelle"],
      tips: ["Bilgi güçtür!", "Gördüğün kartı değiştirtebilirsin"],
    ),
    CharacterInfo(
      character: Character.avukat,
      name: "Avukat",
      isPlusMod: true,
      description: "Miras avcısı! Ölen oyuncunun parasını al!",
      abilities: ["⚖️ Kayyum: Ölen oyuncunun parasını al", "🛡️ Suikastı engelle"],
      tips: ["Oyuncu öldüğünde aktif ol", "Birden fazla avukat varsa paylaşım"],
    ),
    CharacterInfo(
      character: Character.gazeteci,
      name: "Gazeteci",
      isPlusMod: true,
      description: "Manipülatör! 3 kart dağıtarak rakibin elini değiştir!",
      abilities: ["📰 Manipülasyon: 1 deste + 2 hedef kartı", "🎲 1 kartı hedefe, 1 kartı destede, 1 sana"],
      tips: ["Rakibin iyi kartını al!", "Stratejik olarak kullan"],
    ),
  ];

  // === TAB 3: OYUN SİMÜLASYONLARI ===
  final List<GameSimulation> _simulations = [
    GameSimulation(
      title: "Hızlı Zafer",
      description: "3 oyunculu agresif oyun",
      players: ["Ahmet", "Mehmet", "Ayşe"],
      winner: "Ahmet",
      turns: [
        SimTurn(player: "Ahmet", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Mehmet", action: "Vergi (Dük)", result: "+3 altın", emoji: "👑"),
        SimTurn(player: "Ayşe", action: "Dış Yardım", result: "+2 altın", emoji: "🤝"),
        SimTurn(player: "Ahmet", action: "Vergi (Dük)", result: "+3 altın (4 total)", emoji: "👑"),
        SimTurn(player: "Mehmet", action: "Çalma (Yüzbaşı)", result: "Ayşe'den 2 altın", emoji: "🏴‍☠️"),
        SimTurn(player: "Ayşe", action: "Suikast → Mehmet", result: "Mehmet 1 kart kaybetti", emoji: "🗡️"),
        SimTurn(player: "Ahmet", action: "Darbe → Ayşe", result: "Ayşe 1 kart kaybetti", emoji: "⚔️"),
        SimTurn(player: "Mehmet", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Ayşe", action: "Çalma → Ahmet", result: "+2 altın", emoji: "🏴‍☠️"),
        SimTurn(player: "Ahmet", action: "Darbe → Mehmet", result: "MEHMET ELENDİ!", emoji: "💀"),
        SimTurn(player: "Ayşe", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Ahmet", action: "Darbe → Ayşe", result: "AYŞE ELENDİ!", emoji: "💀"),
        SimTurn(player: "🏆", action: "AHMET KAZANDI!", result: "", emoji: "🎉"),
      ],
    ),
    GameSimulation(
      title: "Blöf Savaşı",
      description: "Meydan okumalarla dolu oyun",
      players: ["Ali", "Veli", "Zeynep"],
      winner: "Zeynep",
      turns: [
        SimTurn(player: "Ali", action: "Vergi (Dük)", result: "+3 altın", emoji: "👑"),
        SimTurn(player: "Veli", action: "Meydan okudu!", result: "Ali Dük'ü gösterdi!", emoji: "⚡"),
        SimTurn(player: "Veli", action: "Kart kaybetti", result: "Yanlış tahmin!", emoji: "💀"),
        SimTurn(player: "Zeynep", action: "Dış Yardım", result: "+2 altın", emoji: "🤝"),
        SimTurn(player: "Ali", action: "Suikast → Zeynep", result: "-3 altın", emoji: "🗡️"),
        SimTurn(player: "Zeynep", action: "Kontes ile engelledi!", result: "Suikast iptal", emoji: "❤️"),
        SimTurn(player: "Veli", action: "Vergi (Dük)", result: "BLÖF!", emoji: "🎭"),
        SimTurn(player: "Ali", action: "Meydan okudu!", result: "Veli'de Dük yok!", emoji: "⚡"),
        SimTurn(player: "Veli", action: "ELENDİ!", result: "Son kartını kaybetti", emoji: "💀"),
        SimTurn(player: "Zeynep", action: "Darbe → Ali", result: "Ali 1 kart kaybetti", emoji: "⚔️"),
        SimTurn(player: "Ali", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Zeynep", action: "Darbe → Ali", result: "ALİ ELENDİ!", emoji: "💀"),
        SimTurn(player: "🏆", action: "ZEYNEP KAZANDI!", result: "", emoji: "🎉"),
      ],
    ),
    GameSimulation(
      title: "Uzun Savaş",
      description: "4 oyunculu stratejik oyun",
      players: ["Can", "Deniz", "Ece", "Fatma"],
      winner: "Deniz",
      turns: [
        SimTurn(player: "Can", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Deniz", action: "Dış Yardım", result: "+2 altın", emoji: "🤝"),
        SimTurn(player: "Ece", action: "Vergi (Dük)", result: "+3 altın", emoji: "👑"),
        SimTurn(player: "Fatma", action: "Çalma → Ece", result: "+2 altın", emoji: "🏴‍☠️"),
        SimTurn(player: "Ece", action: "Elçi ile engelledi!", result: "Çalma iptal", emoji: "🛡️"),
        SimTurn(player: "Can", action: "Elçi ile değişim", result: "2 yeni kart", emoji: "🔄"),
        SimTurn(player: "Deniz", action: "Vergi (Dük)", result: "+3 altın (5 total)", emoji: "👑"),
        SimTurn(player: "Ece", action: "Suikast → Can", result: "Can 1 kart kaybetti", emoji: "🗡️"),
        SimTurn(player: "Fatma", action: "Darbe → Ece", result: "Ece 1 kart kaybetti", emoji: "⚔️"),
        SimTurn(player: "Can", action: "Çalma → Deniz", result: "+2 altın", emoji: "🏴‍☠️"),
        SimTurn(player: "Deniz", action: "Darbe → Can", result: "CAN ELENDİ!", emoji: "💀"),
        SimTurn(player: "Ece", action: "Gelir", result: "+1 altın", emoji: "💰"),
        SimTurn(player: "Fatma", action: "Darbe → Ece", result: "ECE ELENDİ!", emoji: "💀"),
        SimTurn(player: "Deniz", action: "Darbe → Fatma", result: "Fatma 1 kart kaybetti", emoji: "⚔️"),
        SimTurn(player: "Fatma", action: "Suikast → Deniz", result: "Deniz 1 kart kaybetti", emoji: "🗡️"),
        SimTurn(player: "Deniz", action: "Darbe → Fatma", result: "FATMA ELENDİ!", emoji: "💀"),
        SimTurn(player: "🏆", action: "DENİZ KAZANDI!", result: "", emoji: "🎉"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _resetScenario();
        setState(() => _selectedScenarioIndex = 0);
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _playScenario() {
    if (_isPlaying) {
      _animationTimer?.cancel();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isPlaying = true;
      _currentStep = 0;
    });

    _animateNextStep();
  }

  void _animateNextStep() {
    final scenarios = _tabController.index == 0 ? _actionScenarios : [];
    if (_tabController.index != 0 || _currentStep >= scenarios.length) {
      setState(() => _isPlaying = false);
      return;
    }

    final scenario = scenarios[_selectedScenarioIndex];
    if (_currentStep >= scenario.steps.length) {
      setState(() => _isPlaying = false);
      return;
    }

    _animationTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _isPlaying) {
        setState(() => _currentStep++);
        _animateNextStep();
      }
    });
  }

  void _resetScenario() {
    _animationTimer?.cancel();
    setState(() {
      _currentStep = 0;
      _isPlaying = false;
    });
  }

  List<Widget> _buildGeometricShapes() {
    return [
      // Circles and shapes for background
      Positioned(
        left: -80,
        top: -80,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 5.seconds),
      ),
      Positioned(
        right: -30,
        top: 50,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6200EA), // Deep Purple
                  Color(0xFF0F0F1A), // Dark Background
                ],
                stops: [0.0, 0.5], // Gradient fades out by the middle
              ),
            ),
          ),
          
          // Decoration
          ..._buildGeometricShapes(),

          SafeArea(
            child: Column(
              children: [
                // Header (Transparent area)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "OYUN REHBERİ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF6200EA),
                    unselectedLabelColor: Colors.white.withOpacity(0.8),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "HAMLELER"),
                      Tab(text: "KARAKTER"),
                      Tab(text: "SİMÜLASYON"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // White Card Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F6F6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildActionsTab(),
                          _buildCharactersTab(),
                          _buildSimulationsTab(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === TAB 1: HAMLELER (White Design) ===
  Widget _buildActionsTab() {
    final scenario = _actionScenarios[_selectedScenarioIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scenario Selection (Horizontal)
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _actionScenarios.length,
            clipBehavior: Clip.none, // Allow shadows to be seen
            itemBuilder: (context, index) {
              final s = _actionScenarios[index];
              final isSelected = index == _selectedScenarioIndex;
              return GestureDetector(
                onTap: () {
                  _resetScenario();
                  setState(() => _selectedScenarioIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 75,
                  margin: const EdgeInsets.only(right: 12, bottom: 10, top: 5), // Spacing
                  decoration: BoxDecoration(
                    color: isSelected ? s.color : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? s.color.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.icon, color: isSelected ? Colors.white : s.color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        s.title.split(' ').first,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Title & Description
        Text(
          scenario.title,
          style: TextStyle(
            color: scenario.color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          scenario.description,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Animation Box (Dark Theme maintained inside for contrast or switch to Light?)
        // Switching to Light Clean Look for Animation Box too
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    color: Colors.grey.shade200,
                  ),
                  child: Row(
                    children: List.generate(scenario.steps.length, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: index <= _currentStep ? scenario.color : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Steps List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: (_currentStep + 1).clamp(0, scenario.steps.length),
                    itemBuilder: (context, index) {
                      final step = scenario.steps[index];
                      final isLatest = index == _currentStep;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLatest ? scenario.color.withOpacity(0.1) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLatest ? scenario.color.withOpacity(0.5) : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(step.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        step.playerName,
                                        style: TextStyle(
                                          color: isLatest ? scenario.color : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (step.coins.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: step.coins.contains('+') 
                                                ? Colors.green.shade100 
                                                : Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            step.coins,
                                            style: TextStyle(
                                              color: step.coins.contains('+') ? Colors.green.shade800 : Colors.red.shade800,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.action,
                                    style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.narration,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Controls
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              _buildControlButton(
                icon: Icons.replay,
                onTap: _resetScenario,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _playScenario,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? "DURAKLAT" : "OYNAT"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scenario.color,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: scenario.color.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildControlButton(
                icon: Icons.skip_next,
                onTap: () {
                  if (_currentStep < scenario.steps.length - 1) {
                    setState(() => _currentStep++);
                  }
                },
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: Colors.grey.shade700),
      ),
    );
  }

  // === TAB 2: KARAKTERLER (White Design) ===
  Widget _buildCharactersTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final char = _characters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: char.character.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: char.character.color.withOpacity(0.2)),
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(side: BorderSide.none), // Remove divider
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: char.character.color.withOpacity(0.2), blurRadius: 8),
                ],
              ),
              child: Icon(char.character.icon, color: char.character.color, size: 28),
            ),
            title: Row(
              children: [
                Text(
                  char.name,
                  style: TextStyle(
                    color: char.character.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (char.isPlusMod)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "PLUS",
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              char.description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            iconColor: char.character.color,
            collapsedIconColor: Colors.grey.shade400,
            children: [
               Divider(color: char.character.color.withOpacity(0.1)),
               const SizedBox(height: 8),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("YETENEKLERİ:", style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   ...char.abilities.map((ability) => Padding(
                     padding: const EdgeInsets.only(bottom: 8),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           width: 6, 
                           height: 6, 
                           margin: const EdgeInsets.only(top: 6, right: 8),
                           decoration: BoxDecoration(color: char.character.color, shape: BoxShape.circle),
                         ),
                         Expanded(child: Text(ability, style: TextStyle(color: Colors.grey.shade800, fontSize: 14))),
                       ],
                     ),
                   )),
                   const SizedBox(height: 12),
                   const Text("İPUÇLARI:", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   ...char.tips.map((tip) => Padding(
                     padding: const EdgeInsets.only(bottom: 6),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("💡 ", style: TextStyle(fontSize: 14)),
                         Expanded(
                           child: Text(tip, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                         ),
                       ],
                     ),
                   )),
                 ],
               ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: 0.05, end: 0);
      },
    );
  }

  // === TAB 3: SİMÜLASYONLAR (White Design) ===
  Widget _buildSimulationsTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _simulations.length,
      itemBuilder: (context, index) {
        final sim = _simulations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
             shape: const RoundedRectangleBorder(side: BorderSide.none),
             childrenPadding: const EdgeInsets.all(20),
             leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EA), Color(0xFFB388FF)], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.sports_esports, color: Colors.white, size: 24),
            ),
            title: Text(
              sim.title,
              style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${sim.players.length} oyuncu • Kazanan: ${sim.winner}",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Players Chips
                  Wrap(
                    spacing: 8,
                    children: sim.players.map((p) => Chip(
                      label: Text(p),
                      labelStyle: TextStyle(
                        color: p == sim.winner ? Colors.green.shade900 : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: p == sim.winner ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: p == sim.winner ? Colors.green.shade100 : Colors.grey.shade100,
                      side: BorderSide.none,
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("OYUN AKIŞI:", style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Turns
                  ...sim.turns.asMap().entries.map((entry) {
                    final turn = entry.value;
                    final isWinner = turn.player == "🏆";
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isWinner ? Colors.green.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isWinner ? Colors.green.shade200 : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(turn.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          if (!isWinner) ...[
                            SizedBox(
                              width: 50,
                              child: Text(
                                turn.player,
                                style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              turn.action,
                              style: TextStyle(
                                color: isWinner ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: isWinner ? 13 : 12,
                                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (turn.result.isNotEmpty)
                            Text(
                              turn.result,
                              style: TextStyle(
                                color: turn.result.contains("ELENDİ") ? Colors.red.shade700 : Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(begin: 0.05, end: 0);
      },
    );
  }
}

// === DATA CLASSES ===
// (Keeping classes as they were)
class TutorialScenario {
  final String title;
  final String description;
  final Character? character;
  final Color color;
  final IconData icon;
  final List<ScenarioStep> steps;

  const TutorialScenario({
    required this.title,
    required this.description,
    required this.character,
    required this.color,
    required this.icon,
    required this.steps,
  });
}

class ScenarioStep {
  final String playerName;
  final String action;
  final String coins;
  final String narration;
  final String emoji;

  const ScenarioStep({
    required this.playerName,
    required this.action,
    required this.coins,
    required this.narration,
    required this.emoji,
  });
}

class CharacterInfo {
  final Character character;
  final String name;
  final bool isPlusMod;
  final String description;
  final List<String> abilities;
  final List<String> tips;

  const CharacterInfo({
    required this.character,
    required this.name,
    required this.isPlusMod,
    required this.description,
    required this.abilities,
    required this.tips,
  });
}

class GameSimulation {
  final String title;
  final String description;
  final List<String> players;
  final String winner;
  final List<SimTurn> turns;

  const GameSimulation({
    required this.title,
    required this.description,
    required this.players,
    required this.winner,
    required this.turns,
  });
}

class SimTurn {
  final String player;
  final String action;
  final String result;
  final String emoji;

  const SimTurn({
    required this.player,
    required this.action,
    required this.result,
    required this.emoji,
  });
}
