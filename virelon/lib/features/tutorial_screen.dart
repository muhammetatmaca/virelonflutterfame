import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../core/enums/game_enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<TutorialScenario> get _actionScenarios => _getActionScenarios(context);
  List<CharacterInfo> get _characters => _getCharacters(context);
  List<GameSimulation> get _simulations => _getSimulations(context);
  
  // === TAB 1: HAMLELER ===
  List<TutorialScenario> _getActionScenarios(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
    // TEMEL HAMLELER
    TutorialScenario(
      title: l10n.tutorialIncomeTitle,
      description: l10n.tutorialIncomeDesc,
      character: null,
      color: Colors.green,
      icon: Icons.attach_money,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialIncomeStep1Action, coins: "+1", narration: l10n.tutorialIncomeStep1Narration, emoji: "💰"),
        ScenarioStep(playerName: l10n.system, action: l10n.tutorialIncomeStep2Action, coins: "", narration: l10n.tutorialIncomeStep2Narration, emoji: "✅"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialForeignAidTitle,
      description: l10n.tutorialForeignAidDesc,
      character: null,
      color: Colors.blue,
      icon: Icons.handshake,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialForeignAidStep1Action, coins: "+2", narration: l10n.tutorialForeignAidStep1Narration, emoji: "🤝"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialForeignAidStep2Action, coins: "0", narration: l10n.tutorialForeignAidStep2Narration, emoji: "🛡️"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialForeignAidStep3Action, coins: "", narration: l10n.tutorialForeignAidStep3Narration, emoji: "❌"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialCoupTitle,
      description: l10n.tutorialCoupDesc,
      character: null,
      color: Colors.red,
      icon: Icons.flash_on,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialCoupStep1Action, coins: "-7", narration: l10n.tutorialCoupStep1Narration, emoji: "⚔️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialCoupStep2Action, coins: "", narration: l10n.tutorialCoupStep2Narration, emoji: "💀"),
        ScenarioStep(playerName: l10n.system, action: l10n.tutorialCoupStep3Action, coins: "", narration: l10n.tutorialCoupStep3Narration, emoji: "⚠️"),
      ],
    ),
    // DÜK HAMLELERİ
    TutorialScenario(
      title: l10n.tutorialTaxTitle,
      description: l10n.tutorialTaxDesc,
      character: Character.duke,
      color: Character.duke.color,
      icon: Character.duke.icon,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialTaxStep1Action, coins: "+3", narration: l10n.tutorialTaxStep1Narration, emoji: "👑"),
        ScenarioStep(playerName: l10n.otherPlayers, action: l10n.tutorialTaxStep2Action, coins: "", narration: l10n.tutorialTaxStep2Narration, emoji: "🤔"),
        ScenarioStep(playerName: l10n.noOne, action: l10n.tutorialTaxStep3Action, coins: "", narration: l10n.tutorialTaxStep3Narration, emoji: "✅"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialTaxStep4Action, coins: "+3", narration: l10n.tutorialTaxStep4Narration, emoji: "💰"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialDukeBlockTitle,
      description: l10n.tutorialDukeBlockDesc,
      character: Character.duke,
      color: Character.duke.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialDukeBlockStep1Action, coins: "+2", narration: l10n.tutorialDukeBlockStep1Narration, emoji: "🤝"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialDukeBlockStep2Action, coins: "", narration: l10n.tutorialDukeBlockStep2Narration, emoji: "🛡️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialDukeBlockStep3Action, coins: "0", narration: l10n.tutorialDukeBlockStep3Narration, emoji: "❌"),
      ],
    ),
    // SUİKASTÇI HAMLELERİ
    TutorialScenario(
      title: l10n.tutorialAssassinateTitle,
      description: l10n.tutorialAssassinateDesc,
      character: Character.assassin,
      color: Character.assassin.color,
      icon: Character.assassin.icon,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialAssassinateStep1Action, coins: "-3", narration: l10n.tutorialAssassinateStep1Narration, emoji: "🗡️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialAssassinateStep2Action, coins: "", narration: l10n.tutorialAssassinateStep2Narration, emoji: "😱"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialAssassinateStep3Action, coins: "", narration: l10n.tutorialAssassinateStep3Narration, emoji: "💀"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialContessaBlockTitle,
      description: l10n.tutorialContessaBlockDesc,
      character: Character.countess,
      color: Character.countess.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialContessaBlockStep1Action, coins: "-3", narration: l10n.tutorialContessaBlockStep1Narration, emoji: "🗡️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialContessaBlockStep2Action, coins: "", narration: l10n.tutorialContessaBlockStep2Narration, emoji: "❤️"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialContessaBlockStep3Action, coins: "", narration: l10n.tutorialContessaBlockStep3Narration, emoji: "💸"),
      ],
    ),
    // YÜZBAŞI HAMLELERİ
    TutorialScenario(
      title: l10n.tutorialStealTitle,
      description: l10n.tutorialStealDesc,
      character: Character.captain,
      color: Character.captain.color,
      icon: Character.captain.icon,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialStealStep1Action, coins: "+2", narration: l10n.tutorialStealStep1Narration, emoji: "🏴‍☠️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialStealStep2Action, coins: "-2", narration: l10n.tutorialStealStep2Narration, emoji: "😢"),
        ScenarioStep(playerName: l10n.system, action: l10n.tutorialStealStep3Action, coins: "", narration: l10n.tutorialStealStep3Narration, emoji: "💱"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialStealBlockTitle,
      description: l10n.tutorialStealBlockDesc,
      character: Character.captain,
      color: Character.captain.color,
      icon: Icons.shield,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialStealBlockStep1Action, coins: "+2", narration: l10n.tutorialStealBlockStep1Narration, emoji: "🏴‍☠️"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialStealBlockStep2Action, coins: "", narration: l10n.tutorialStealBlockStep2Narration, emoji: "🛡️"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialStealBlockStep3Action, coins: "0", narration: l10n.tutorialStealBlockStep3Narration, emoji: "❌"),
      ],
    ),
    // ELÇİ HAMLELERİ
    TutorialScenario(
      title: l10n.tutorialExchangeTitle,
      description: l10n.tutorialExchangeDesc,
      character: Character.ambassador,
      color: Character.ambassador.color,
      icon: Character.ambassador.icon,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialExchangeStep1Action, coins: "", narration: l10n.tutorialExchangeStep1Narration, emoji: "🔄"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialExchangeStep2Action, coins: "", narration: l10n.tutorialExchangeStep2Narration, emoji: "🃏"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialExchangeStep3Action, coins: "", narration: l10n.tutorialExchangeStep3Narration, emoji: "✨"),
      ],
    ),
    // MEYDAN OKUMA
    TutorialScenario(
      title: l10n.tutorialChallengeSuccessTitle,
      description: l10n.tutorialChallengeSuccessDesc,
      character: null,
      color: Colors.orange,
      icon: Icons.gavel,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeSuccessStep1Action, coins: "+3", narration: l10n.tutorialChallengeSuccessStep1Narration, emoji: "🎭"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialChallengeSuccessStep2Action, coins: "", narration: l10n.tutorialChallengeSuccessStep2Narration, emoji: "⚡"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeSuccessStep3Action, coins: "", narration: l10n.tutorialChallengeSuccessStep3Narration, emoji: "👀"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeSuccessStep4Action, coins: "", narration: l10n.tutorialChallengeSuccessStep4Narration, emoji: "💀"),
      ],
    ),
    TutorialScenario(
      title: l10n.tutorialChallengeFailTitle,
      description: l10n.tutorialChallengeFailDesc,
      character: null,
      color: Colors.red.shade700,
      icon: Icons.gavel,
      steps: [
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeFailStep1Action, coins: "+3", narration: l10n.tutorialChallengeFailStep1Narration, emoji: "👑"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialChallengeFailStep2Action, coins: "", narration: l10n.tutorialChallengeFailStep2Narration, emoji: "⚡"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeFailStep3Action, coins: "", narration: l10n.tutorialChallengeFailStep3Narration, emoji: "✅"),
        ScenarioStep(playerName: l10n.player2, action: l10n.tutorialChallengeFailStep4Action, coins: "", narration: l10n.tutorialChallengeFailStep4Narration, emoji: "💀"),
        ScenarioStep(playerName: l10n.player1, action: l10n.tutorialChallengeFailStep5Action, coins: "", narration: l10n.tutorialChallengeFailStep5Narration, emoji: "🔄"),
      ],
    ),
    ];
  }

  // === TAB 2: KARAKTERLER ===
  List<CharacterInfo> _getCharacters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
    // NORMAL MOD
    CharacterInfo(
      character: Character.duke,
      name: l10n.duke,
      isPlusMod: false,
      description: l10n.dukeCharDesc,
      abilities: [l10n.dukeAbility1, l10n.dukeAbility2],
      tips: [l10n.dukeTip1, l10n.dukeTip2],
    ),
    CharacterInfo(
      character: Character.assassin,
      name: l10n.assassin,
      isPlusMod: false,
      description: l10n.assassinCharDesc,
      abilities: [l10n.assassinAbility1, l10n.assassinAbility2],
      tips: [l10n.assassinTip1, l10n.assassinTip2],
    ),
    CharacterInfo(
      character: Character.countess,
      name: l10n.contessa,
      isPlusMod: false,
      description: l10n.contessaCharDesc,
      abilities: [l10n.contessaAbility1, l10n.contessaAbility2],
      tips: [l10n.contessaTip1, l10n.contessaTip2],
    ),
    CharacterInfo(
      character: Character.captain,
      name: l10n.captain,
      isPlusMod: false,
      description: l10n.captainCharDesc,
      abilities: [l10n.captainAbility1, l10n.captainAbility2],
      tips: [l10n.captainTip1, l10n.captainTip2],
    ),
    CharacterInfo(
      character: Character.ambassador,
      name: l10n.ambassador,
      isPlusMod: false,
      description: l10n.ambassadorCharDesc,
      abilities: [l10n.ambassadorAbility1, l10n.ambassadorAbility2],
      tips: [l10n.ambassadorTip1, l10n.ambassadorTip2],
    ),
    // PLUS MOD KARAKTERLERİ
    CharacterInfo(
      character: Character.inquisitor,
      name: l10n.inquisitor,
      isPlusMod: true,
      description: l10n.inquisitorCharDesc,
      abilities: [l10n.inquisitorAbility1, l10n.inquisitorAbility2, l10n.inquisitorAbility3],
      tips: [l10n.inquisitorTip1, l10n.inquisitorTip2],
    ),
    CharacterInfo(
      character: Character.avukat,
      name: l10n.lawyer,
      isPlusMod: true,
      description: l10n.lawyerCharDesc,
      abilities: [l10n.lawyerAbility1, l10n.lawyerAbility2],
      tips: [l10n.lawyerTip1, l10n.lawyerTip2],
    ),
    CharacterInfo(
      character: Character.gazeteci,
      name: l10n.journalist,
      isPlusMod: true,
      description: l10n.journalistCharDesc,
      abilities: [l10n.journalistAbility1, l10n.journalistAbility2],
      tips: [l10n.journalistTip1, l10n.journalistTip2],
    ),
  ];
  }

  // === TAB 3: OYUN SİMÜLASYONLARI ===
  List<GameSimulation> _getSimulations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
    GameSimulation(
      title: l10n.simQuickVictory,
      description: l10n.simQuickVictoryDesc,
      players: ["Ahmet", "Mehmet", "Ayşe"],
      winner: "Ahmet",
      turns: [
        SimTurn(player: "Ahmet", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Mehmet", action: "${l10n.tax} (${l10n.duke})", result: "+3", emoji: "👑"),
        SimTurn(player: "Ayşe", action: l10n.foreignAid, result: "+2", emoji: "🤝"),
        SimTurn(player: "Ahmet", action: "${l10n.tax} (${l10n.duke})", result: "+3", emoji: "👑"),
        SimTurn(player: "Mehmet", action: "${l10n.steal} (${l10n.captain})", result: "Ayşe -2", emoji: "🏴‍☠️"),
        SimTurn(player: "Ayşe", action: "${l10n.assassinate} → Mehmet", result: "-1 card", emoji: "🗡️"),
        SimTurn(player: "Ahmet", action: "${l10n.coup} → Ayşe", result: "-1 card", emoji: "⚔️"),
        SimTurn(player: "Mehmet", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Ayşe", action: "${l10n.steal} → Ahmet", result: "+2", emoji: "🏴‍☠️"),
        SimTurn(player: "Ahmet", action: "${l10n.coup} → Mehmet", result: l10n.playerEliminated("MEHMET"), emoji: "💀"),
        SimTurn(player: "Ayşe", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Ahmet", action: "${l10n.coup} → Ayşe", result: l10n.playerEliminated("AYŞE"), emoji: "💀"),
        SimTurn(player: "🏆", action: l10n.playerWon("AHMET"), result: "", emoji: "🎉"),
      ],
    ),
    GameSimulation(
      title: l10n.simBluffWar,
      description: l10n.simBluffWarDesc,
      players: ["Ali", "Veli", "Zeynep"],
      winner: "Zeynep",
      turns: [
        SimTurn(player: "Ali", action: "${l10n.tax} (${l10n.duke})", result: "+3", emoji: "👑"),
        SimTurn(player: "Veli", action: l10n.challenge, result: "Ali ${l10n.duke}!", emoji: "⚡"),
        SimTurn(player: "Veli", action: "-1 card", result: "Wrong!", emoji: "💀"),
        SimTurn(player: "Zeynep", action: l10n.foreignAid, result: "+2", emoji: "🤝"),
        SimTurn(player: "Ali", action: "${l10n.assassinate} → Zeynep", result: "-3", emoji: "🗡️"),
        SimTurn(player: "Zeynep", action: "${l10n.contessa} ${l10n.block}!", result: "Blocked", emoji: "❤️"),
        SimTurn(player: "Veli", action: "${l10n.tax} (${l10n.duke})", result: "BLUFF!", emoji: "🎭"),
        SimTurn(player: "Ali", action: l10n.challenge, result: "No ${l10n.duke}!", emoji: "⚡"),
        SimTurn(player: "Veli", action: l10n.playerEliminated("VELİ"), result: "Last card", emoji: "💀"),
        SimTurn(player: "Zeynep", action: "${l10n.coup} → Ali", result: "-1 card", emoji: "⚔️"),
        SimTurn(player: "Ali", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Zeynep", action: "${l10n.coup} → Ali", result: l10n.playerEliminated("ALİ"), emoji: "💀"),
        SimTurn(player: "🏆", action: l10n.playerWon("ZEYNEP"), result: "", emoji: "🎉"),
      ],
    ),
    GameSimulation(
      title: l10n.simLongBattle,
      description: l10n.simLongBattleDesc,
      players: ["Can", "Deniz", "Ece", "Fatma"],
      winner: "Deniz",
      turns: [
        SimTurn(player: "Can", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Deniz", action: l10n.foreignAid, result: "+2", emoji: "🤝"),
        SimTurn(player: "Ece", action: "${l10n.tax} (${l10n.duke})", result: "+3", emoji: "👑"),
        SimTurn(player: "Fatma", action: "${l10n.steal} → Ece", result: "+2", emoji: "🏴‍☠️"),
        SimTurn(player: "Ece", action: "${l10n.ambassador} ${l10n.block}!", result: "Blocked", emoji: "🛡️"),
        SimTurn(player: "Can", action: l10n.exchange, result: "2 cards", emoji: "🔄"),
        SimTurn(player: "Deniz", action: "${l10n.tax} (${l10n.duke})", result: "+3", emoji: "👑"),
        SimTurn(player: "Ece", action: "${l10n.assassinate} → Can", result: "-1 card", emoji: "🗡️"),
        SimTurn(player: "Fatma", action: "${l10n.coup} → Ece", result: "-1 card", emoji: "⚔️"),
        SimTurn(player: "Can", action: "${l10n.steal} → Deniz", result: "+2", emoji: "🏴‍☠️"),
        SimTurn(player: "Deniz", action: "${l10n.coup} → Can", result: l10n.playerEliminated("CAN"), emoji: "💀"),
        SimTurn(player: "Ece", action: l10n.income, result: "+1", emoji: "💰"),
        SimTurn(player: "Fatma", action: "${l10n.coup} → Ece", result: l10n.playerEliminated("ECE"), emoji: "💀"),
        SimTurn(player: "Deniz", action: "${l10n.coup} → Fatma", result: "-1 card", emoji: "⚔️"),
        SimTurn(player: "Fatma", action: "${l10n.assassinate} → Deniz", result: "-1 card", emoji: "🗡️"),
        SimTurn(player: "Deniz", action: "${l10n.coup} → Fatma", result: l10n.playerEliminated("FATMA"), emoji: "💀"),
        SimTurn(player: "🏆", action: l10n.playerWon("DENİZ"), result: "", emoji: "🎉"),
      ],
    ),
  ];
  }

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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.gameGuide,
                          style: const TextStyle(
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
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.actions),
                      Tab(text: AppLocalizations.of(context)!.characters),
                      Tab(text: AppLocalizations.of(context)!.simulations),
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
    final l10n = AppLocalizations.of(context)!;
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
                  label: Text(_isPlaying ? l10n.pauseUpperCase : l10n.playUpperCase),
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
    final l10n = AppLocalizations.of(context)!;
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
                   Text(l10n.abilitiesHeader, style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
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
                   Text(l10n.tipsHeader, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  Text(l10n.gameFlowHeader, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.bold)),
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
