import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/widgets/neon_button.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import '../providers/game_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/reference_sheet.dart';
import '../widgets/coin_display.dart';
import 'package:virelon/features/game/domain/models/player_model.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // Menu States
  bool _isSetupMode = false;
  bool _isPlusMode = false; // Normal mode by default
  Character _plusModeSpecial = Character.avukat;
  Character _plusModeVariant2 = Character.ambassador;
  bool _showShuffleAnimation = false; // For intro shuffle effect
  
  // Setup State
  final List<Player> _setupPlayers = [];
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _playerListScrollController = ScrollController();
  int _selectedAvatarIndex = 0;
  
  // Phase States
  List<Character> _exchangeSelectedCards = [];
  List<Character> _manipulationMyHand = [];
  Character? _manipulationTargetCard;
  Character? _manipulationDeckCard;

  // Mock Avatars (using Character icons/colors for now)
  final List<Character> _avatarOptions = Character.values;

  // ADS
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdReady = false;
  
  @override
  void initState() {
    super.initState();
    // Load Ads
    _loadBannerAd();
    _loadRewardedAd();
    _loadAppOpenAd();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _playerListScrollController.dispose();
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _loadRewardedAd() {
    // Test Ad Unit ID (Android): ca-app-pub-3940256099942544/5224354917
    // Test Ad Unit ID (iOS): ca-app-pub-3940256099942544/1712485313
    // Production: ca-app-pub-8339567586448961/5632321735
    
    const String adUnitId = 'ca-app-pub-3940256099942544/5224354917'; // TEST ID
    
    debugPrint('🎬 Loading rewarded ad...');
    
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad loaded successfully!');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('🚪 Ad dismissed');
              ad.dispose();
              _loadRewardedAd(); // Yeni reklam yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Ad failed to show: $error');
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-8339567586448961/8777359829', // Açılış Reklamı
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
          
          // İlk yüklendiğinde göster
          _showAppOpenAd();
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _isAppOpenAdReady = false;
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (_appOpenAd != null && _isAppOpenAdReady) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdReady = false;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdReady = false;
        },
      );
      _appOpenAd!.show();
    }
  }

  void _showRewardedAd(VoidCallback onRewarded) {
    if (_rewardedAd != null && _isRewardedAdReady) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(); // Plus Mode'u aç
        },
      );
      _isRewardedAdReady = false;
      _rewardedAd = null;
    }
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_setupPlayers.any((p) => p.name == name)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu isim zaten var!")));
      return;
    }
    if (_setupPlayers.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maksimum 8 oyuncu!")));
      return;
    }

    setState(() {
      _setupPlayers.add(Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        name: name,
        avatar: _avatarOptions[_selectedAvatarIndex].name, // Store enum name as avatar
      ));
      _nameController.clear();
      _selectedAvatarIndex = (_selectedAvatarIndex + 1) % _avatarOptions.length;
    });
    
    // Scroll to bottom after adding player
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_playerListScrollController.hasClients) {
        _playerListScrollController.animateTo(
          _playerListScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removePlayer(String id) {
    setState(() {
      _setupPlayers.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... existing ...
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    // --- Background (Animated) ---
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: Stack(
          children: [
            // Main Content Layer
            SafeArea(
              child: Builder(
                builder: (context) {
                  if (gameState.players.isEmpty) return _buildMenuFlow(context, notifier);
                  if (gameState.phase == GamePhase.assigningRoles) return _buildRoleDistributionUI(gameState, notifier);
                  if (gameState.phase == GamePhase.turnTransition) return _buildTurnTransitionUI(gameState, notifier);
                  if (gameState.phase == GamePhase.actionPending) return _buildActionPendingUI(gameState, notifier);
                  if (gameState.phase == GamePhase.kayyumBidding) return _buildKayyumBiddingUI(gameState, notifier);
                  if (gameState.phase == GamePhase.victimHandover) return _buildVictimHandoverUI(gameState, notifier);
                  if (gameState.phase == GamePhase.exchange) return _buildExchangeUI(gameState, notifier);
                  if (gameState.phase == GamePhase.investigation) return _buildInvestigationUI(gameState, notifier);
                  if (gameState.phase == GamePhase.challengeVerification) return _buildChallengeVerificationUI(gameState, notifier);
                  if (gameState.phase == GamePhase.resolution) return _buildResolutionUI(gameState, notifier);
                  return _buildGameUI(context, gameState, notifier);
                }
              ),
            ),

            // Animation Overlay Layer
            if (_showShuffleAnimation)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.95), // Dark overlay
                  child: _buildShuffleAnimation(),
                ).animate().fadeIn(duration: 300.ms),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  Widget _buildMenuFlow(BuildContext context, GameNotifier notifier) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Decorative Background Cards
        ...List.generate(6, (index) {
          final char = Character.values[index % Character.values.length];
          // Distribute cards across the screen width
          // Use scaling based on screen width to ensure coverage
          final double step = (size.width + 100) / 6;
          final double left = (index * step) - 50;

          return Positioned(
            left: left,
            top: 80.0 + ((index * 50) % 150), // Staggered vertical positions
            child: Transform.rotate(
              angle: 0.15 * (index % 2 == 0 ? 1 : -1),
              child: Opacity(
                opacity: 0.7, // Increased opacity for better visibility
                child: GameCardWidget(character: char, width: 140, height: 200)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: 30, duration: (3000 + index * 800).ms), // Slower, smoother animation
              ),
            ),
          );
        }),

        // Main Content Glass Overlay
        // Use SingleChildScrollView to avoid keyboard overflow on setup
        Center(
          child: SingleChildScrollView(
            child: _isSetupMode 
              ? _buildPassAndPlaySetup(notifier)
              : _buildMainMenu(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMenu() {
    return GlassContainer(
      width: 320,
      padding: const EdgeInsets.all(24),
      isGlowing: true,
      borderColor: AppTheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.token, size: 50, color: AppTheme.accent),
          const SizedBox(height: 16),
          Text("VIRELON", style: AppTheme.titleLarge.copyWith(fontSize: 32)),
          const SizedBox(height: 8),
          Text("PROTOCOL: COUP REFORMATION", style: AppTheme.body.copyWith(letterSpacing: 2, fontSize: 10, color: AppTheme.accent)),
          const SizedBox(height: 32),
          
          NeonButton(
            label: "ELDEN ELE OYNA",
            isLarge: true,
            icon: Icons.phone_android,
            onTap: () {
              setState(() => _isSetupMode = true);
            },
          ),
          const SizedBox(height: 12),
          NeonButton(
            label: "OYUN OLUŞTUR",
            icon: Icons.add_circle_outline,
            baseColor: Colors.deepPurple,
            onTap: () { /* TODO Online */ },
          ),
           const SizedBox(height: 12),
          NeonButton(
            label: "OYUNA KATIL",
            icon: Icons.login,
            baseColor: Colors.blueGrey,
            onTap: () { /* TODO Online */ },
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildPassAndPlaySetup(GameNotifier notifier) {
    return GlassContainer(
      width: 360, // Slightly wider for list
      padding: const EdgeInsets.all(20),
      isGlowing: true,
      borderColor: AppTheme.accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white), 
                onPressed: () => setState(() => _isSetupMode = false)
              ),
              Text("OYUN KURULUMU", style: AppTheme.titleMedium),
            ],
          ),
          
          const SizedBox(height: 20),


          // --- GAME MODE SELECTION ---
          const Text("OYUN MODU SEÇİN", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPlusMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isPlusMode ? AppTheme.primary.withOpacity(0.3) : Colors.transparent,
                      border: Border.all(color: !_isPlusMode ? AppTheme.primary : Colors.white24),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12))
                    ),
                    child: Center(
                      child: Text("NORMAL", style: TextStyle(
                        color: !_isPlusMode ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold
                      )),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isPlusMode) {
                      debugPrint('🎮 Plus Mode button tapped. Ad ready: $_isRewardedAdReady');
                      
                      // Ödüllü reklam göster
                      if (_isRewardedAdReady) {
                        debugPrint('📺 Showing rewarded ad...');
                        _showRewardedAd(() {
                          debugPrint('🎁 Reward earned! Enabling Plus Mode');
                          setState(() {
                            _isPlusMode = true;
                          });
                        });
                      } else {
                        // Reklam hazır değilse direkt aç (web/test için)
                        debugPrint('⚠️ Ad not ready, enabling Plus Mode directly (web/test mode)');
                        setState(() {
                          _isPlusMode = true;
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isPlusMode ? AppTheme.accent.withOpacity(0.3) : Colors.transparent,
                      border: Border.all(color: _isPlusMode ? AppTheme.accent : Colors.white24),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12))
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isPlusMode) const Icon(Icons.play_circle_fill, color: Colors.amber, size: 20),
                          if (!_isPlusMode) const SizedBox(width: 6),
                          Text(_isPlusMode ? "PLUS (ENTRİKA)" : "PLUS MODU", style: TextStyle(
                            color: _isPlusMode ? Colors.white : Colors.amber,
                            fontWeight: FontWeight.bold
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (_isPlusMode) ...[
             const SizedBox(height: 16),
             const Text("ÖZEL KARAKTER SEÇİMİ", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
             const SizedBox(height: 8),
             Row(
               children: [
                 Expanded(
                   child: GestureDetector(
                     onTap: () => setState(() => _plusModeSpecial = Character.avukat),
                     child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 10),
                       decoration: BoxDecoration(
                         color: _plusModeSpecial == Character.avukat ? Character.avukat.color.withOpacity(0.4) : Colors.transparent,
                         border: Border.all(color: _plusModeSpecial == Character.avukat ? Character.avukat.color : Colors.white24),
                         borderRadius: BorderRadius.circular(8)
                       ),
                       child: Column(
                          children: [
                             Icon(Character.avukat.icon, color: Colors.white),
                             const SizedBox(height: 4),
                             const Text("AVUKAT", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ]
                       )
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: GestureDetector(
                     onTap: () => setState(() => _plusModeSpecial = Character.countess),
                     child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 10),
                       decoration: BoxDecoration(
                         color: _plusModeSpecial == Character.countess ? Character.countess.color.withOpacity(0.4) : Colors.transparent,
                         border: Border.all(color: _plusModeSpecial == Character.countess ? Character.countess.color : Colors.white24),
                         borderRadius: BorderRadius.circular(8)
                       ),
                       child: Column(
                          children: [
                             Icon(Character.countess.icon, color: Colors.white),
                             const SizedBox(height: 4),
                             const Text("KONTES", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ]
                       )
                     ),
                   ),
                 ),
               ],
             ),

             const SizedBox(height: 16),
             Text("VARIANT SEÇİMİ (ELÇİ YERİNE)", style: TextStyle(color: Colors.white70, fontSize: 10)),
             const SizedBox(height: 8),
             Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _plusModeVariant2 = Character.ambassador),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _plusModeVariant2 == Character.ambassador ? Character.ambassador.color.withOpacity(0.4) : Colors.transparent,
                          border: Border.all(color: _plusModeVariant2 == Character.ambassador ? Character.ambassador.color : Colors.white24),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                           children: [
                              Icon(Character.ambassador.icon, color: Colors.white),
                              const SizedBox(height: 4),
                              const Text("ELÇİ", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                           ]
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _plusModeVariant2 = Character.gazeteci),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _plusModeVariant2 == Character.gazeteci ? Character.gazeteci.color.withOpacity(0.4) : Colors.transparent,
                          border: Border.all(color: _plusModeVariant2 == Character.gazeteci ? Character.gazeteci.color : Colors.white24),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                           children: [
                              Icon(Character.gazeteci.icon, color: Colors.white),
                              const SizedBox(height: 4),
                              const Text("GAZETECİ", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                           ]
                        )
                      ),
                    ),
                  ),
                ],
             ),
          ],

          const SizedBox(height: 20),
          
          // --- List of Added Players ---
          if (_setupPlayers.isNotEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black26, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10)
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _setupPlayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = _setupPlayers[index];
                  // Try to find character for avatar icon
                  final avatarChar = Character.values.firstWhere((c) => c.name == p.avatar, orElse: () => Character.duke);
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: avatarChar.color,
                          child: Icon(avatarChar.icon, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(p.name, style: AppTheme.body)),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.danger, size: 18),
                          onPressed: () => _removePlayer(p.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          else 
            const Center(child: Padding(
              padding: EdgeInsets.all(20), 
              child: Text("Henüz oyuncu eklenmedi", style: TextStyle(color: Colors.white54)),
            )),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 10),

          // --- Add Player Form ---
          Text("YENİ OYUNCU", style: AppTheme.chip),
          const SizedBox(height: 8),
          
          // Name Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black38,
              hintText: "Oyuncu Adı",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Avatar Selection (Horizontal)
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatarOptions.length,
              separatorBuilder: (_,__) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final char = _avatarOptions[index];
                final isSelected = index == _selectedAvatarIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = index),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: char.color.withOpacity(isSelected ? 0.8 : 0.2),
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: Icon(char.icon, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          NeonButton(
            label: "EKLE",
            icon: Icons.person_add,
            baseColor: Colors.blueAccent,
            onTap: _addPlayer,
          ),

          const SizedBox(height: 24),
          
          // Start Game Button
          Opacity(
            opacity: _setupPlayers.length >= 3 ? 1.0 : 0.5,
            child: NeonButton(
              label: "OYUNU BAŞLAT (${_setupPlayers.length})",
              isLarge: true,
              icon: Icons.play_arrow,
              baseColor: AppTheme.success,
              onTap: _setupPlayers.length >= 3 ? () {
                // 1. Show Shuffle Animation & Hide Setup
                setState(() {
                  _showShuffleAnimation = true;
                  _isSetupMode = false;
                });
                
                // 2. Start Game Logic (in background)
                notifier.startGame(
                    _setupPlayers, 
                    isPlusMode: _isPlusMode, 
                    plusSpecial: _isPlusMode ? _plusModeSpecial : null,
                    plusVariant2: _isPlusMode ? _plusModeVariant2 : null
                );
                
                // 3. Wait for animation then show Role UI
                Future.delayed(const Duration(seconds: 7), () {
                  if (mounted) {
                    setState(() => _showShuffleAnimation = false);
                  }
                });
              } : () {},
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildGameUI(BuildContext context, GameState gameState, GameNotifier notifier) {
    final currentPlayer = gameState.players.firstWhere((p) => p.id == gameState.currentPlayerId);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- TOP BAR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("VIRELON", style: AppTheme.titleMedium.copyWith(letterSpacing: 2)),
                  const SizedBox(width: 12),
                  // Hazine (Havuz)
                  // Hazine (Havuz) - Center'a taşındı
                  if (false) ...[
                    Container() 
                  ]
                ],
              ),
            ),
            
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.accent.withOpacity(0.1)
                      ),
                      child: Text(
                        gameState.phase.name.toUpperCase(), 
                        style: AppTheme.chip.copyWith(fontSize: 8),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (c) => const ReferenceSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        border: Border.all(color: Colors.cyan.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book, color: Colors.cyanAccent, size: 16),
                    ),
                  ),
                ],
              ),
            )
            ],
          ),
        ),

        // --- ENEMY PLAYERS ---
        SizedBox(
          height: 120, // Reduced height for top
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: gameState.players.length,
            itemBuilder: (context, index) {
              final player = gameState.players[index];
              if (player.id == currentPlayer.id) return const SizedBox.shrink();
              
              final isTurn = player.id == gameState.currentPlayerId;

              final ideology = player.ideology;
            Color? borderColor = isTurn ? AppTheme.warning : ideology?.color;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GlassContainer(
                width: 100,
                padding: const EdgeInsets.all(8),
                isGlowing: isTurn,
                borderColor: borderColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Character.values.firstWhere(
                            (c) => c.name == player.avatar, 
                            orElse: () => Character.duke 
                          ).color,
                          child: Icon(
                            Character.values.firstWhere(
                              (c) => c.name == player.avatar, 
                              orElse: () => Character.duke
                            ).icon, 
                            size: 18, 
                            color: Colors.white
                          ),
                        ),
                        if (ideology != null)
                           Container(
                             padding: const EdgeInsets.all(2),
                             decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: ideology.color, width: 1)),
                             child: ClipOval(
                                child: Image.asset(ideology.assetPath, width: 14, height: 14, fit: BoxFit.cover),
                             ),
                           )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(player.name, style: AppTheme.body.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis),
                    if (ideology != null)
                       Text(ideology.displayName, style: TextStyle(fontSize: 9, color: ideology.color, fontWeight: FontWeight.bold)),
                    
                    CoinDisplay(
                      amount: player.coins,
                      iconSize: 14,
                      textStyle: AppTheme.chip.copyWith(color: AppTheme.warning, fontSize: 11),
                    ),
                    // Kart Arkası Simgeleri
                    const SizedBox(height: 2),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(player.cards.length, (i) => 
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 1), child: Icon(Icons.style, size: 12, color: Colors.white38))
                      ),
                    )
                  ],
                ),
              ),
            );
            },
          ),
        ),
        
        const SizedBox(height: 16),

        // --- BOTTOM PANEL (PLAYER) ---
        GlassContainer(
          borderRadius: 0,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Character.values.firstWhere((c) => c.name == currentPlayer.avatar, orElse: () => Character.duke).color,
                          child: Icon(Character.values.firstWhere((c) => c.name == currentPlayer.avatar, orElse: () => Character.duke).icon, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("OPERATOR", style: AppTheme.chip),
                          Text(currentPlayer.name.toUpperCase(), style: AppTheme.titleMedium),
                          if (currentPlayer.ideology != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 6),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                 decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        currentPlayer.ideology!.color.withOpacity(0.3),
                                        currentPlayer.ideology!.color.withOpacity(0.1),
                                      ],
                                    ),
                                    border: Border.all(color: currentPlayer.ideology!.color, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: currentPlayer.ideology!.color.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                 ),
                                 child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                       Container(
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           border: Border.all(color: currentPlayer.ideology!.color, width: 2),
                                           boxShadow: [
                                             BoxShadow(
                                               color: currentPlayer.ideology!.color.withOpacity(0.5),
                                               blurRadius: 4,
                                             )
                                           ]
                                         ),
                                         child: ClipOval(
                                           child: Image.asset(
                                             currentPlayer.ideology!.assetPath, 
                                             width: 24, 
                                             height: 24, 
                                             fit: BoxFit.cover
                                           )
                                         ),
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         currentPlayer.ideology!.displayName.toUpperCase(), 
                                         style: TextStyle(
                                           color: currentPlayer.ideology!.color, 
                                           fontSize: 12, 
                                           fontWeight: FontWeight.bold,
                                           letterSpacing: 1,
                                         )
                                       )
                                    ]
                                 ),
                               ),
                             ),
                        ],
                      ),
                    ],
                  ),
                   CoinDisplay(
                     amount: currentPlayer.coins,
                     iconSize: 40,
                     textStyle: AppTheme.titleLarge.copyWith(color: AppTheme.warning, fontSize: 36),
                   )
                ],
              ),
              const SizedBox(height: 12),
              
              // Cards (BIGGER SIZE)
              // Cards (BIGGER SIZE) or Special Interaction
              if (gameState.phase == GamePhase.exchange)
                _buildExchangeUI(gameState, notifier)
              else if (gameState.phase == GamePhase.manipulation)
                _buildManipulationUI(gameState, notifier)
              else if (gameState.phase == GamePhase.investigation)
                _buildInvestigationUI(gameState, notifier)
              else
                SizedBox(
                  height: 315, // Kartlar + yetenekler için 
                  child: Center(
                    child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: currentPlayer.cards.length,
                    separatorBuilder: (_,__) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      return GameCardWidget(
                        character: currentPlayer.cards[index], 
                        width: 150, 
                        height: 230,
                        showAbilities: true,
                      ).animate().slideY(begin: 1, curve: Curves.easeOutBack, duration: 600.ms, delay: (index * 100).ms);
                    },
                  ),
                 ),
                ),

              const SizedBox(height: 16),

              // Controls
              if (gameState.phase == GamePhase.actionDeclaration)
                currentPlayer.coins >= 10 
                ? Column(
                    children: [
                       Text("10 ALTININ VAR! SALDIRMAK ZORUNDASIN!", 
                            style: AppTheme.chip.copyWith(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 16),
                       NeonButton(
                         label: "SALDIR (-7)", 
                         icon: Icons.gavel, 
                         baseColor: AppTheme.danger, 
                         isLarge: true, 
                         onTap: () => _showTargetDialog(context, GameAction.coup, notifier, gameState.players)
                       ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05)),
                    ],
                  )
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                       NeonButton(label: "GELİR", icon: Icons.download, onTap: () => notifier.performAction(GameAction.income)),
                       const SizedBox(width: 8),
                       NeonButton(label: "DIŞ YARDIM", icon: Icons.public, onTap: () => notifier.performAction(GameAction.foreignAid)),
                       const SizedBox(width: 8),
                       NeonButton(label: "VERGİ", icon: Icons.account_balance, baseColor: Colors.purpleAccent, onTap: () => notifier.performAction(GameAction.tax)),
                       const SizedBox(width: 8),
                       
                       // SUİKAST (SUİKASTÇI) - Min 3 Coins
                       if (currentPlayer.coins >= 3) ...[
                          NeonButton(
                            label: "SUİKAST (3)", 
                            icon: Icons.track_changes, 
                            baseColor: Colors.black87, 
                            onTap: () {
                              _showTargetDialog(context, GameAction.assassinate, notifier, gameState.players);
                            }
                          ),
                          const SizedBox(width: 8),
                       ],

                       // -- PLUS MODE ACTIONS --
                       if (_isPlusMode) ...[
                         if (currentPlayer.coins >= 1) ...[
                            NeonButton(label: "DÖNÜŞ (1)", icon: Icons.change_circle, baseColor: Colors.pinkAccent, onTap: () => notifier.performAction(GameAction.convertSelf)),
                            const SizedBox(width: 8),
                         ],
                         if (currentPlayer.coins >= 2) ...[
                            NeonButton(label: "BASKI (2)", icon: Icons.volunteer_activism, baseColor: Colors.deepOrange, onTap: () => _showTargetDialog(context, GameAction.convertOther, notifier, gameState.players)),
                            const SizedBox(width: 8),
                         ],
                         if (gameState.treasury > 0) ...[
                            NeonButton(label: "ZİMMET", icon: Icons.savings_outlined, baseColor: Colors.amber, onTap: () => notifier.performAction(GameAction.embezzle)),
                            const SizedBox(width: 8),
                         ],
                       ],

                       // Engizisyoncu/Elçi (Sorgu + Değişim)
                       if (_isPlusMode && _plusModeVariant2 == Character.ambassador) ...[
                           NeonButton(label: "SORGU", icon: Icons.search, baseColor: Colors.indigo, onTap: () => _showTargetDialog(context, GameAction.investigate, notifier, gameState.players)),
                           const SizedBox(width: 8),
                           NeonButton(label: "DEĞİŞİM", icon: Icons.compare_arrows, baseColor: Colors.green, onTap: () => notifier.performAction(GameAction.exchange)),
                           const SizedBox(width: 8),
                       ],

                       // Gazeteci (Manipüle)
                       if (_isPlusMode && _plusModeVariant2 == Character.gazeteci) ...[
                           NeonButton(label: "MANİPÜLE", icon: Icons.newspaper, baseColor: Colors.deepOrange, onTap: () => _showTargetDialog(context, GameAction.manipulate, notifier, gameState.players)),
                           const SizedBox(width: 8),
                       ],
                       
                       // KAYYUM (Avukat) - Eğer ölü ve paralı biri varsa
                       if (_isPlusMode && gameState.players.any((p) => !p.isAlive && p.coins > 0)) ...[
                          NeonButton(
                              label: "KAYYUM", 
                              icon: Icons.gavel, 
                              baseColor: Colors.deepPurple, 
                              onTap: () => _showTargetDialog(context, GameAction.kayyum, notifier, gameState.players)
                          ),
                          const SizedBox(width: 8),
                       ],

                       NeonButton(label: "ÇALMA", icon: Icons.pan_tool_alt, baseColor: Colors.blueAccent, onTap: () {
                          _showTargetDialog(context, GameAction.steal, notifier, gameState.players);
                       }),
                       const SizedBox(width: 8),
                       NeonButton(label: "SALDIR (7)", icon: Icons.gavel, baseColor: AppTheme.danger, onTap: () => _showTargetDialog(context, GameAction.coup, notifier, gameState.players)),
                    ],
                  ),
                ),
                
               if (gameState.phase == GamePhase.actionPending || gameState.phase == GamePhase.blockingWindow)
                 _buildActionPendingUI(gameState, notifier)
            ],
          ),
        ),
      ],
    );
  }

  // --- Shuffle Animation Widget ---
  Widget _buildShuffleAnimation() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style, size: 64, color: AppTheme.accent)
                  .animate(onPlay: (c) => c.repeat())
                  .shake(duration: 500.ms, hz: 3)
                  .tint(color: Colors.white, duration: 1.seconds),
              const SizedBox(height: 24),
              Text(
                "ROLLER DAĞITILIYOR...",
                style: AppTheme.titleMedium.copyWith(letterSpacing: 3),
              ).animate().fadeIn(duration: 500.ms).shimmer(duration: 1500.ms),
            ],
          ),
          
          // Flying Cards
          ...List.generate(10, (index) {
            return Positioned(
              child: GameCardWidget(
                 character: Character.values[index % Character.values.length],
                 width: 80,
                 height: 120,
              )
              .animate(onPlay: (c) => c.repeat())
              .move(
                 begin: Offset(50.0 * (index % 2 == 0 ? 1 : -1), 200),
                 end: Offset(0, 0),
                 duration: (600 + index * 100).ms,
                 curve: Curves.easeOutCirc
              )
              .fadeOut(delay: 500.ms)
              .scale(begin: const Offset(1,1), end: const Offset(0.5, 0.5)),
            );
          })
        ],
      ),
    );
  }

  // --- Challenge Verification UI (Kart Gösterme Ekranı) ---
  Widget _buildChallengeVerificationUI(GameState state, GameNotifier notifier) {
    final challengedId = state.blockerId ?? state.actionInitiatorId;
    if (challengedId == null) return const SizedBox.shrink();
    
    final challenged = state.players.firstWhere((p) => p.id == challengedId);
    final claimedChar = state.claimedCharacter;
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderColor: AppTheme.warning,
            isGlowing: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gavel, size: 48, color: AppTheme.warning)
                    .animate(onPlay: (c) => c.repeat())
                    .shake(duration: 1.seconds),
                
                const SizedBox(height: 16),
                
                Text(
                  "MEYDAN OKUMA!",
                  style: AppTheme.headline.copyWith(color: AppTheme.warning, fontSize: 22),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  "${challenged.name}, ${claimedChar?.displayName ?? 'kart'} kartını göstermelisin!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  "Elindeki kartlardan birini seç:",
                  style: AppTheme.body.copyWith(color: Colors.white54, fontSize: 12),
                ),
                
                const SizedBox(height: 16),
                
                // Kartları göster
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: challenged.cards.map((card) {
                    return GestureDetector(
                      onTap: () {
                        notifier.verifyChallenge(card);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameCardWidget(
                            character: card,
                            width: 90,
                            height: 135,
                          ).animate().scale(delay: 200.ms),
                          const SizedBox(height: 6),
                          Text(
                            "GÖSTER",
                            style: TextStyle(
                              color: card == claimedChar ? AppTheme.success : AppTheme.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                NeonButton(
                  label: "KARTIM YOK (BLÖF)",
                  icon: Icons.block,
                  baseColor: AppTheme.danger,
                  onTap: () {
                    notifier.verifyChallenge(null);
                  },
                ),
              ],
            ),
          ).animate().fadeIn().scale(),
        ),
      ),
    );
  }

  void _showTargetDialog(BuildContext context, GameAction action, GameNotifier notifier, List<Player> players) {
    final currentPlayerId = ref.read(gameStateProvider).currentPlayerId;
    
    List<Player> targets;
    if (action == GameAction.kayyum) {
       // Kayyum sadece ölü ve parası olanları hedefler
       targets = players.where((p) => !p.isAlive && p.coins > 0).toList();
    } else {
       // Diğerleri canlı rakipleri hedefler
       targets = players.where((p) => p.id != currentPlayerId && p.isAlive).toList();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "${action == GameAction.coup ? 'SALDIRI' : action == GameAction.assassinate ? 'BASKI' : 'HEDEF'} SEÇİN", 
          style: AppTheme.headline.copyWith(color: AppTheme.danger, fontSize: 24)
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: targets.length,
            separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final p = targets[index];
              final isTargetable = notifier.canTarget(p.id, action);
              
              return ListTile(
                enabled: isTargetable,
                leading: Opacity(
                  opacity: isTargetable ? 1.0 : 0.4,
                  child: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Text(p.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                title: Text(p.name, style: TextStyle(color: isTargetable ? Colors.white : Colors.white38)),
                trailing: isTargetable 
                   ? CoinDisplay(amount: p.coins, iconSize: 14) 
                   : const Icon(Icons.block, size: 16, color: Colors.white24),
                subtitle: !isTargetable 
                   ? Text("AYNI İTTİFAK (${p.ideology?.displayName})", style: const TextStyle(color: Colors.white24, fontSize: 10)) 
                   : null,
                onTap: isTargetable ? () {
                  Navigator.pop(context);
                  notifier.performAction(action, targetId: p.id);
                } : null,
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Role Distribution UI ---
  Widget _buildRoleDistributionUI(GameState state, GameNotifier notifier) {
    // Find first player who hasn't seen their role
    final playerToReveal = state.players.firstWhere(
      (p) => !state.rolesSeenBy.contains(p.id),
      orElse: () => state.players.first, // Should not happen if logic is correct
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "KART DAĞITIMI",
              style: AppTheme.headline.copyWith(fontSize: 32, letterSpacing: 4),
            ).animate().fadeIn().slideY(begin: -0.5),
            
            const SizedBox(height: 48),

            GlassContainer(
              padding: const EdgeInsets.all(32),
              isGlowing: true,
              borderColor: AppTheme.accent,
              child: Column(
                children: [
                   Icon(Icons.person_pin, size: 64, color: playerToReveal.avatar != null ? null : Colors.white), 
                   
                   const SizedBox(height: 24),
                   
                   Text(
                     "Sıradaki Oyuncu:",
                     style: AppTheme.body.copyWith(color: Colors.white70),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     playerToReveal.name.toUpperCase(),
                     style: AppTheme.headline.copyWith(color: AppTheme.accent, fontSize: 36),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   const Text(
                     "Telefonu bu oyuncuya verin.\nKartlarını görmek için aşağıdaki butona bas.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white54, height: 1.5),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   NeonButton(
                     label: "KARTLARI GÖSTER",
                     icon: Icons.visibility,
                     baseColor: AppTheme.accent,
                     isLarge: true,
                     onTap: () {
                       _showRoleRevealDialog(context, playerToReveal, notifier);
                     },
                   ),
                ],
              ),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }

  void _showRoleRevealDialog(BuildContext context, Player player, GameNotifier notifier) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              borderColor: AppTheme.accent,
              isGlowing: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text("KARTLARIN, ${player.name.toUpperCase()}", style: AppTheme.titleMedium, textAlign: TextAlign.center),
                   const SizedBox(height: 24),
                   
                   // Cards Container
                   Flexible(
                     child: SingleChildScrollView(
                       child: Wrap(
                         alignment: WrapAlignment.center,
                         runSpacing: 16,
                         spacing: 16,
                         children: player.cards.map((char) {
                           return GameCardWidget(
                             character: char,
                             width: 150, 
                             height: 230,
                           ).animate().flip(duration: 600.ms, direction: Axis.horizontal);
                         }).toList(),
                       ),
                     ),
                   ),

                   const SizedBox(height: 32),
                   const Text(
                     "Kartlarını ezberle ve kimseye gösterme!",
                     style: TextStyle(color: Colors.white54, fontSize: 14),
                   ),
                   const SizedBox(height: 24),

                   NeonButton(
                     label: "TAMAM, GİZLE",
                     icon: Icons.check,
                     baseColor: AppTheme.success,
                     onTap: () {
                       Navigator.of(context).pop();
                       notifier.confirmRoleSeen(player.id);
                     },
                   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Turn Transition UI ---
  Widget _buildTurnTransitionUI(GameState state, GameNotifier notifier) {
    // Find who's next (currentPlayer)
    final nextPlayer = state.players.firstWhere((p) => p.id == state.currentPlayerId);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phonelink_lock, size: 80, color: Colors.white54)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds),
            
            const SizedBox(height: 32),
            
            GlassContainer(
              padding: const EdgeInsets.all(32),
              isGlowing: true,
              borderColor: AppTheme.primary,
              child: Column(
                children: [
                   const Text(
                     "SIRADAKİ OYUNCU",
                     style: TextStyle(color: Colors.white70, letterSpacing: 2),
                   ),
                   const SizedBox(height: 16),
                   
                   Text(
                     nextPlayer.name.toUpperCase(),
                     style: AppTheme.headline.copyWith(color: AppTheme.primary, fontSize: 40),
                     textAlign: TextAlign.center,
                   ),
                   
                   const SizedBox(height: 32),
                   
                   const Text(
                     "Lütfen cihazı bu oyuncuya verin.\nHazır olduğunda butona bas.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white54, height: 1.5),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   NeonButton(
                     label: "HAZIRIM, BAŞLA",
                     icon: Icons.play_circle_fill,
                     baseColor: AppTheme.primary,
                     isLarge: true,
                     onTap: () {
                       notifier.readyForTurn();
                     },
                   ),
                ],
              ),
            ).animate().fadeIn().moveY(begin: 30, end: 0),
          ],
        ),
      ),
    );
  }
  // --- Action Pending UI (Bloklama/Meydan Okuma) ---
  Widget _buildActionPendingUI(GameState state, GameNotifier notifier) {
    if (state.actionInitiatorId == null) return const SizedBox.shrink();

    final initiator = state.players.firstWhere((p) => p.id == state.actionInitiatorId);
    // UI'ı gösteren kişinin ID'si (Genelde sıradaki oyuncu ama burada tepki veren kişi olmalı)
    // Şimdilik currentPlayer'ı alıyoruz ama logic olarak hatalı olabilir Pass&Play'de.
    // Ancak Single Device olduğu için ekranı o an elinde tutan kişi "Current" kabul edilir.
    // VE bloklama hakkı sadece ilgili kişiye gösterilmeli.
    final currentUser = state.players.firstWhere((p) => p.id == ref.read(gameStateProvider).currentPlayerId); // Aslında bu state.currentPlayerId değil, cihazın sahibi.
    
    // Doğru mantık: PassAndPlay'de actionPending ekranı geldiğinde cihazı hedef kişiye vermeli mi?
    // Veya herkes sırayla bakmalı mı?
    // Basitlik için: Hedef kişi kimse (actionTargetId) butonları o görür. Diğerleri sadece "Bekleyin" görür.
    // VEYA: Herkes her şeyi görür (Açık Masa).
    
    final isTarget = state.actionTargetId == currentUser.id; // Hedef oyuncu mu? (Steal/Assassinate için)

    List<Widget> blockButtons = [];
    
    if (currentUser.id != initiator.id) {
       if (state.currentAction == GameAction.foreignAid) {
          blockButtons.add(NeonButton(label: "DÜK İLE ENGELLE", icon: Icons.shield, baseColor: Colors.orangeAccent, 
             onTap: () => notifier.blockAction(currentUser.id, Character.duke)));
       } else if (state.currentAction == GameAction.steal && isTarget) {
          blockButtons.add(NeonButton(label: "YÜZBAŞI İLE ENGELLE", icon: Icons.shield, baseColor: Colors.blueAccent, 
             onTap: () => notifier.blockAction(currentUser.id, Character.captain)));
          blockButtons.add(const SizedBox(height: 10)); // Ara boşluk
           blockButtons.add(NeonButton(label: "ELÇİ İLE ENGELLE", icon: Icons.shield, baseColor: Colors.greenAccent, 
             onTap: () => notifier.blockAction(currentUser.id, Character.ambassador)));
           if (_isPlusMode && _plusModeVariant2 == Character.inquisitor) {
              blockButtons.add(const SizedBox(height: 10));
              blockButtons.add(NeonButton(label: "ENGİZİSYONCU İLE ENGELLE", icon: Icons.search, baseColor: Colors.orange, 
                 onTap: () => notifier.blockAction(currentUser.id, Character.inquisitor)));
           }
       } else if (state.currentAction == GameAction.assassinate && isTarget) {
          blockButtons.add(NeonButton(label: "KONTES İLE ENGELLE", icon: Icons.shield, baseColor: Colors.redAccent, 
             onTap: () => notifier.blockAction(currentUser.id, Character.countess)));
             
          if (_isPlusMode && _plusModeSpecial == Character.avukat) {
               blockButtons.add(const SizedBox(height: 10));
               blockButtons.add(NeonButton(label: "AVUKAT İLE ENGELLE", icon: Icons.gavel, baseColor: Colors.deepPurple, 
                  onTap: () => notifier.blockAction(currentUser.id, Character.avukat)));
          }
       } else if (state.currentAction == GameAction.manipulate && isTarget) {
            blockButtons.add(NeonButton(
               label: "GAZETECİ İLE ENGELLE", 
               icon: Icons.newspaper, 
               baseColor: Colors.deepOrange, 
               onTap: () => notifier.blockAction(currentUser.id, Character.gazeteci)
             ));
       }
    }

    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${initiator.name} HAMLE YAPTI:", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              state.currentAction?.displayName.toUpperCase() ?? "BİLİNMEYEN",
              style: AppTheme.headline.copyWith(fontSize: 32, color: AppTheme.primary),
            ),
            const SizedBox(height: 32),
            
            // --- BLOKLAMA DURUMU ---
            if (state.phase == GamePhase.blockingWindow)
               Column(
                 children: [
                    Text("${state.players.firstWhere((p)=>p.id==state.blockerId).name.toUpperCase()} ENGELLEDİ!", 
                         style: AppTheme.titleMedium.copyWith(color: AppTheme.warning)),
                    const SizedBox(height: 8),
                    Text("(${state.claimedCharacter?.displayName ?? ''} kartı olduğunu iddia ediyor)", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 16),
                    
                    // Hamle yapan kişi
                    if (currentUser.id == initiator.id) ...[
                      Text("SEN: ${currentUser.name.toUpperCase()}", 
                          style: AppTheme.body.copyWith(color: AppTheme.accent)),
                      const SizedBox(height: 8),
                      const Text("Bloklama iddiasını kabul ediyor musun?", 
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: NeonButton(label: "KABUL ET", baseColor: Colors.grey, onTap: () => notifier.passAction())),
                          const SizedBox(width: 12),
                          Expanded(child: NeonButton(label: "MEYDAN OKU", baseColor: AppTheme.danger, onTap: () => notifier.performChallenge(state.blockerId!))),
                        ],
                      )
                    ]
                    // Diğer oyuncular da meydan okuyabilir
                    else if (currentUser.id != state.blockerId) ...[
                      Text("SEN: ${currentUser.name.toUpperCase()}", 
                          style: AppTheme.body.copyWith(color: AppTheme.accent)),
                      const SizedBox(height: 8),
                      const Text("Bloklama iddiasına itiraz etmek ister misin?", 
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: NeonButton(label: "İZİN VER", baseColor: AppTheme.success, onTap: () => notifier.passAction())),
                          const SizedBox(width: 12),
                          Expanded(child: NeonButton(label: "MEYDAN OKU", baseColor: AppTheme.danger, onTap: () => notifier.performChallenge(state.blockerId!))),
                        ],
                      )
                    ]
                    // Bloklayan kişi bekliyor
                    else ...[
                      const CircularProgressIndicator(color: AppTheme.warning),
                      const SizedBox(height: 16),
                      const Text("Diğer oyuncuların kararı bekleniyor...", style: TextStyle(color: Colors.white54)),
                    ]
                 ],
               )

            // --- AKSİYON ONAY DURUMU ---
            else if (currentUser.id == initiator.id)
               Column(
                 children: [
                   const Icon(Icons.people, size: 48, color: AppTheme.primary),
                   const SizedBox(height: 16),
                   const Text("Hamlen yapıldı!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   const Text("İtiraz eden oyuncu var mı?", 
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.white70)),
                   const SizedBox(height: 24),
                   
                   // Oyuncu listesi
                   Text("Oyuncular:", style: AppTheme.body.copyWith(color: Colors.white54, fontSize: 12)),
                   const SizedBox(height: 12),
                   ...state.players.where((p) => p.id != initiator.id && p.isAlive).map((player) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: GestureDetector(
                         onTap: () {
                            // İtiraz tipini seç
                            final canBlock = state.currentAction == GameAction.foreignAid ||
                                           state.currentAction == GameAction.steal ||
                                           state.currentAction == GameAction.assassinate ||
                                           state.currentAction == GameAction.manipulate;
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text("${player.name} ne yapıyor?", style: AppTheme.titleMedium),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Bloklama seçeneği (sadece bloklanabilir hamleler için)
                                    if (canBlock) ...[
                                      NeonButton(
                                        label: "BLOKLA",
                                        icon: Icons.shield,
                                        baseColor: AppTheme.warning,
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showBlockSelectionDialog(context, player, state, notifier);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    // Meydan okuma (Foreign Aid hariç)
                                    if (state.currentAction != GameAction.foreignAid)
                                      NeonButton(
                                        label: "MEYDAN OKU",
                                        icon: Icons.warning,
                                        baseColor: AppTheme.danger,
                                        onTap: () {
                                          Navigator.pop(context);
                                          notifier.performChallenge(initiator.id);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                         },
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.05),
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(color: AppTheme.accent),
                           ),
                           child: Row(
                             children: [
                               Icon(Icons.person, size: 16, color: player.ideology?.color ?? Colors.white54),
                               const SizedBox(width: 8),
                               Text(player.name, style: const TextStyle(color: Colors.white)),
                               const Spacer(),
                               Text("${player.coins} 💰", style: const TextStyle(color: Colors.amber, fontSize: 12)),
                               const SizedBox(width: 8),
                               const Icon(Icons.touch_app, size: 16, color: AppTheme.accent),
                             ],
                           ),
                         ),
                       ),
                     );
                   }).toList(),
                   
                   const SizedBox(height: 24),
                   NeonButton(
                     label: "KİMSE İTİRAZ ETMİYOR",
                     icon: Icons.check_circle,
                     baseColor: AppTheme.success,
                     isLarge: true,
                     onTap: () => notifier.passAction(),
                   ),
                 ],
               )
             else 
               Column(
                 children: [
                   Text("SEN: ${currentUser.name.toUpperCase()}", 
                       style: AppTheme.titleMedium.copyWith(color: AppTheme.accent)),
                   const SizedBox(height: 8),
                   const Text("Bu hamleye nasıl tepki vermek istersin?", 
                       style: TextStyle(color: Colors.white70, fontSize: 14)),
                   const SizedBox(height: 24),
                   ...blockButtons,
                   if (blockButtons.isNotEmpty) const SizedBox(height: 16),
                   Row(
                     children: [
                       // Meydan Oku (Foreign Aid hariç)
                       if (state.currentAction != GameAction.foreignAid)
                         Expanded(
                           child: NeonButton(
                             label: "MEYDAN OKU",
                             icon: Icons.warning,
                             baseColor: AppTheme.danger,
                             onTap: () {
                               notifier.performChallenge(initiator.id);
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   backgroundColor: AppTheme.danger,
                                   content: Text("${initiator.name.toUpperCase()}'A MEYDAN OKUNDU! Kartlar kontrol edilecek...")
                                 )
                               );
                             },
                           ),
                         ),
                       if (state.currentAction != GameAction.foreignAid) const SizedBox(width: 16),
                       Expanded(
                         child: NeonButton(
                           label: "İZİN VER",
                           icon: Icons.check_circle,
                           baseColor: AppTheme.success,
                           onTap: () {
                             notifier.passAction(); 
                           },
                         ),
                       ),
                     ],
                   )
                 ],
               ),
          ],
        ),
      ),
    );
  }
  // --- Resolution (Lose Card) UI ---
  Widget _buildResolutionUI(GameState state, GameNotifier notifier) {
    final victimId = state.blockerId; 
    if (victimId == null) return const Center(child: Text("Hata: Kurban bulunamadı"));
    
    final victim = state.players.firstWhere((p) => p.id == victimId, orElse: () => state.players.first); 
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.dangerous, size: 80, color: AppTheme.danger)
               .animate(onPlay: (c) => c.repeat())
               .shake(duration: 1.seconds),
             
             const SizedBox(height: 32),
             
             GlassContainer(
               padding: const EdgeInsets.all(32),
               borderColor: AppTheme.danger,
               isGlowing: true,
               child: Column(
                 children: [
                   Text("KART KAYBETME ZAMANI!", style: AppTheme.headline.copyWith(color: AppTheme.danger, fontSize: 24)),
                   const SizedBox(height: 16),
                   Text(
                     "${victim.name.toUpperCase()}, bir kartını feda etmelisin.", 
                     style: const TextStyle(color: Colors.white70),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 32),
                   
                   Wrap(
                     spacing: 16,
                     runSpacing: 16,
                     alignment: WrapAlignment.center,
                     children: victim.cards.map((card) {
                       return GestureDetector(
                         onTap: () {
                           notifier.loseCard(victimId, card);
                         },
                         child: Column(
                           children: [
                             GameCardWidget(
                               character: card,
                               width: 100,
                               height: 150,
                             ).animate().shake(delay: 500.ms),
                             const SizedBox(height: 8),
                             const Text("FEDA ET", style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold))
                           ],
                         ),
                       );
                     }).toList(),
                   )
                 ],
               ),
             ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
  // --- Victim Handover UI ---
  Widget _buildVictimHandoverUI(GameState state, GameNotifier notifier) {
    final victimId = state.blockerId;
    if (victimId == null) return const Center(child: Text("Hata: Kurban ID yok"));
    
    final victim = state.players.firstWhere((p) => p.id == victimId, orElse: () => state.players.first);
    final isCoup = state.currentAction == GameAction.coup;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(isCoup ? Icons.flash_on : Icons.gavel, size: 80, color: AppTheme.danger)
                 .animate(onPlay: (c) => c.repeat(reverse: true))
                 .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1.seconds),
             
             const SizedBox(height: 32),
             
             GlassContainer(
               padding: const EdgeInsets.all(32),
               borderColor: AppTheme.danger,
               isGlowing: true,
               child: Column(
                 children: [
                   Text(isCoup ? "SALDIRI GERÇEKLEŞTİ!" : "MEYDAN OKUMA SONUCU:", style: AppTheme.chip.copyWith(color: Colors.white70)),
                   const SizedBox(height: 16),
                   Text(
                     isCoup ? "SALDIRIYA UĞRADIN!" : "BİRİSİ YANILDI!",
                     style: AppTheme.headline.copyWith(color: AppTheme.danger, fontSize: 32),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 32),
                   
                   Text(
                     "Telefonu FEDA ETMEK İÇİN\n${victim.name.toUpperCase()} adlı oyuncuya verin.",
                     textAlign: TextAlign.center,
                     style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   
                   const SizedBox(height: 16),
                   const Text(
                    "Kart seçimi yapılacak.",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                   ),

                   const SizedBox(height: 32),
                   
                   NeonButton(
                     label: "BEN ${victim.name.toUpperCase()}, HAZIRIM",
                     icon: Icons.fingerprint,
                     baseColor: AppTheme.danger,
                     isLarge: true,
                     onTap: () {
                       notifier.readyForResolution();
                     },
                   ),
                 ],
               ),
             ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }


  // --- Exchange UI ---
  Widget _buildExchangeUI(GameState state, GameNotifier notifier) {
      final currentPlayer = state.players.firstWhere((p) => p.id == state.currentPlayerId);
      final totalCards = currentPlayer.hand;
      final targetKeepCount = totalCards.length >= 3 ? totalCards.length - 2 : 1; 
      
      return Column(
        children: [
            Text("KART DEĞİŞİMİ: ${targetKeepCount} KART SEÇ", style: AppTheme.chip.copyWith(color: AppTheme.accent)),
            const SizedBox(height: 12),
            SizedBox(
               height: 140,
               child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: totalCards.length,
                  separatorBuilder: (_,__) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                      final card = totalCards[index];
                      // Basit seçim logic
                      return GestureDetector(
                         onTap: () {
                             setState(() {
                                 if (_exchangeSelectedCards.contains(card)) {
                                     _exchangeSelectedCards.remove(card); 
                                 } else {
                                     if (_exchangeSelectedCards.length < targetKeepCount) {
                                         _exchangeSelectedCards.add(card);
                                     }
                                 }
                             });
                         },
                         child: Opacity(
                             opacity: _exchangeSelectedCards.contains(card) ? 1.0 : 0.4,
                             child: Container(
                                decoration: BoxDecoration(
                                   border: _exchangeSelectedCards.contains(card) ? Border.all(color: AppTheme.success, width: 3) : null,
                                   borderRadius: BorderRadius.circular(12)
                                ),
                                child: GameCardWidget(character: card, width: 90, height: 140)
                             ),
                         ),
                      );
                  }
               ),
            ),
            const SizedBox(height: 16),
            if (_exchangeSelectedCards.length == targetKeepCount)
                NeonButton(label: "DEĞİŞİMİ ONAYLA", baseColor: AppTheme.success, onTap: () {
                    notifier.finalizeExchange(_exchangeSelectedCards);
                    setState(() => _exchangeSelectedCards = []); // Reset
                })
        ],
      );
  }

  // --- Manipulation UI ---
  Widget _buildManipulationUI(GameState state, GameNotifier notifier) {
      final pool = state.manipulationCards;
      
      // Havuzda kalanları hesapla (Manuel çıkar)
      List<Character> remainingPool = List.from(pool);
      for (var c in _manipulationMyHand) remainingPool.remove(c);
      if (_manipulationTargetCard != null) remainingPool.remove(_manipulationTargetCard);
      if (_manipulationDeckCard != null) remainingPool.remove(_manipulationDeckCard);
      
      final totalCards = pool.length;
      // Güvenlik: Eğer pool boşsa crash verme
      if (totalCards == 0) return const SizedBox.shrink();

      final myHandSize = totalCards - 2;

      bool isComplete = _manipulationMyHand.length == myHandSize && 
                        _manipulationTargetCard != null && 
                        _manipulationDeckCard != null;

      return Column(
         children: [
             Text("MANİPÜLASYON: KARTLARI DAĞIT", style: AppTheme.chip),
             const SizedBox(height: 8),
             
             // POOL
             SizedBox(
                height: 100,
                child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: remainingPool.length,
                   itemBuilder: (context, index) {
                      final card = remainingPool[index];
                      return GestureDetector(
                         onTap: () {
                            setState(() {
                                // Boş yere ekle öncelik sırasına göre
                                if (_manipulationMyHand.length < myHandSize) {
                                   _manipulationMyHand.add(card);
                                } else if (_manipulationTargetCard == null) {
                                    _manipulationTargetCard = card;
                                } else if (_manipulationDeckCard == null) {
                                    _manipulationDeckCard = card;
                                }
                            });
                         },
                         child: Padding(padding: const EdgeInsets.all(4), child: GameCardWidget(character: card, width: 60, height: 90)),
                      );
                   }
                ),
             ),
             
             const Divider(color: Colors.white24),
             
             // SLOTS
             SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      _buildSlot("BENİM ELİM ($myHandSize)", _manipulationMyHand, (c) => setState(() => _manipulationMyHand.remove(c))),
                      const SizedBox(width: 8),
                      _buildSlot("RAKİP (1)", _manipulationTargetCard != null ? [_manipulationTargetCard!] : [], (c) => setState(() => _manipulationTargetCard = null)),
                      const SizedBox(width: 8),
                      _buildSlot("DESTE (1)", _manipulationDeckCard != null ? [_manipulationDeckCard!] : [], (c) => setState(() => _manipulationDeckCard = null)),
                  ],
               ),
             ),
             
             const SizedBox(height: 16),
             if (isComplete)
                NeonButton(label: "DAĞITIMI ONAYLA", baseColor: AppTheme.success, onTap: () {
                    notifier.finalizeManipulation(_manipulationMyHand, _manipulationTargetCard!, _manipulationDeckCard!);
                    // Reset UI State
                    setState(() {
                       _manipulationMyHand = [];
                       _manipulationTargetCard = null;
                       _manipulationDeckCard = null;
                    });
                })
         ],
      );
  }


  void _showBlockSelectionDialog(BuildContext context, Player blocker, GameState state, GameNotifier notifier) {
    // Hangi kartlarla bloklanabilir?
    List<Character> possibleBlocks = [];
    
    if (state.currentAction == GameAction.foreignAid) {
      possibleBlocks.add(Character.duke);
    } else if (state.currentAction == GameAction.steal) {
      possibleBlocks.addAll([Character.captain, Character.ambassador]);
      if (_isPlusMode && _plusModeVariant2 == Character.inquisitor) {
        possibleBlocks.add(Character.inquisitor);
      }
    } else if (state.currentAction == GameAction.assassinate) {
      possibleBlocks.add(Character.countess);
      if (_isPlusMode && _plusModeSpecial == Character.avukat) {
        possibleBlocks.add(Character.avukat);
      }
    } else if (state.currentAction == GameAction.manipulate) {
      possibleBlocks.add(Character.gazeteci);
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("${blocker.name} hangi kartla blokluyor?", style: AppTheme.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: possibleBlocks.map((char) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeonButton(
                label: char.displayName.toUpperCase(),
                icon: char.icon,
                baseColor: char.color,
                onTap: () {
                  Navigator.pop(context);
                  notifier.blockAction(blocker.id, char);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSlot(String label, List<Character> cards, Function(Character) onRemove) {
     return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
        child: Column(
           children: [
               Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
               const SizedBox(height: 4),
               Row(
                  children: cards.map((c) => GestureDetector(
                     onTap: () => onRemove(c),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 2),
                       child: GameCardWidget(character: c, width: 40, height: 60),
                     ),
                  )).toList(),
               )
            ],
         ),
      );
   }

  // Çoklu Kayyum UI
  Widget _buildKayyumBiddingUI(GameState state, GameNotifier notifier) {
    final victim = state.players.firstWhere((p) => p.id == state.actionTargetId);
    final claimants = state.kayyumClaimants;
    final currentUser = state.players.firstWhere((p) => p.isTurn);
    
    bool isClaimant = claimants.contains(currentUser.id);
    bool canJoin = !isClaimant && currentUser.isAlive;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.background, Colors.black],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Başlık
              Icon(Icons.gavel, size: 80, color: Character.avukat.color)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2.seconds),
              const SizedBox(height: 24),
              
              Text(
                "KAYYUM İLANI",
                style: AppTheme.titleLarge.copyWith(fontSize: 32, letterSpacing: 3),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 16),
              
              // Kurban Bilgisi
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("${victim.name} ÖLDÜ!", style: AppTheme.titleMedium.copyWith(color: AppTheme.danger)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text("${victim.coins} ALTIN", style: AppTheme.chip.copyWith(color: Colors.amber, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Kayyum Listesi
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("KAYYUMLAR (${claimants.length})", style: AppTheme.titleMedium),
                    const SizedBox(height: 16),
                    ...claimants.map((id) {
                      final player = state.players.firstWhere((p) => p.id == id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Meydan okuma
                            if (currentUser.id != id && currentUser.isAlive) {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  backgroundColor: AppTheme.surface,
                                  title: Text("${player.name}'e Meydan Oku?", style: AppTheme.titleMedium),
                                  content: Text("${player.name}'in Avukat kartı olmadığını düşünüyor musun?", style: AppTheme.body),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c),
                                      child: Text("İPTAL", style: TextStyle(color: Colors.white54)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                      onPressed: () {
                                        Navigator.pop(c);
                                        notifier.performChallenge(currentUser.id, challengedId: player.id);
                                      },
                                      child: Text("MEYDAN OKU!", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Character.avukat.color.withOpacity(0.2),
                              border: Border.all(color: Character.avukat.color, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Character.avukat.icon, color: Character.avukat.color),
                                const SizedBox(width: 12),
                                Text(player.name.toUpperCase(), style: AppTheme.body.copyWith(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                if (currentUser.id != id && currentUser.isAlive)
                                  Icon(Icons.touch_app, color: Colors.white54, size: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Kullanıcı Bilgisi
              Text("SEN: ${currentUser.name.toUpperCase()}", style: AppTheme.chip.copyWith(fontSize: 14)),
              const SizedBox(height: 16),
              
              // Butonlar
              if (canJoin) ...[
                NeonButton(
                  label: "AVUKAT İLE KAYYUM OL!",
                  icon: Icons.gavel,
                  baseColor: Character.avukat.color,
                  isLarge: true,
                  onTap: () => notifier.joinKayyum(currentUser.id),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
                const SizedBox(height: 12),
              ],
              
              NeonButton(
                label: isClaimant ? "BAŞKA KAYYUM YOK, PAYLAŞ!" : "KAYYUM YOKTUR, DEVAM ET",
                icon: Icons.check_circle,
                baseColor: AppTheme.success,
                isLarge: true,
                onTap: () => notifier.finalizeKayyumBidding(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Engizisyoncu Sorgulama UI
  Widget _buildInvestigationUI(GameState state, GameNotifier notifier) {
    final revealedCard = state.investigatedCard;
    final targetId = state.actionTargetId!;
    final target = state.players.firstWhere((p) => p.id == targetId);
    final initiator = state.players.firstWhere((p) => p.id == state.actionInitiatorId!);
    
    if (revealedCard == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade900, Colors.black],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Character.inquisitor.icon, size: 70, color: Character.inquisitor.color),
               const SizedBox(height: 16),
               Text("SORGULAMA", style: AppTheme.titleLarge.copyWith(color: Character.inquisitor.color, letterSpacing: 3)),
               const SizedBox(height: 8),
               Text(
                 "${initiator.name} → ${target.name}'in kartını görüyor",
                 style: AppTheme.body.copyWith(color: Colors.white70),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 40),
               
               // Görülen Kart
               GlassContainer(
                 padding: const EdgeInsets.all(24),
                 isGlowing: true,
                 borderColor: revealedCard.color,
                 child: Column(
                   children: [
                      Text("GÖRÜLEN KART", style: AppTheme.chip.copyWith(color: Colors.white54)),
                      const SizedBox(height: 16),
                      GameCardWidget(character: revealedCard, width: 120, height: 180)
                          .animate()
                          .flipH(duration: 600.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      Text(
                        revealedCard.displayName.toUpperCase(),
                        style: AppTheme.titleMedium.copyWith(color: revealedCard.color),
                      ),
                   ],
                 ),
               ),
               
               const SizedBox(height: 40),
               
               // Karar Butonları
               Text("NE YAPMAK İSTERSİN?", style: AppTheme.body.copyWith(color: Colors.white54)),
               const SizedBox(height: 16),
               
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                    NeonButton(
                      label: "KART KALSIN",
                      icon: Icons.check_circle_outline,
                      baseColor: AppTheme.success,
                      isLarge: true,
                      onTap: () => notifier.finalizeInvestigation(false),
                    ),
                    const SizedBox(width: 16),
                    NeonButton(
                      label: "DEĞİŞTİR!",
                      icon: Icons.swap_horiz,
                      baseColor: AppTheme.danger,
                      isLarge: true,
                      onTap: () => notifier.finalizeInvestigation(true),
                    ),
                 ],
               ),
               
               const SizedBox(height: 24),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.black26,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.white10),
                 ),
                 child: Column(
                   children: [
                      Text("💡 TAKTİK İPUCU", style: AppTheme.chip.copyWith(color: Colors.amber)),
                      const SizedBox(height: 8),
                      Text(
                        "Eğer rakip blöf yapıyorsa, kartını değiştirerek\nblöfünü bozabilirsin!",
                        style: AppTheme.body.copyWith(fontSize: 11, color: Colors.white60),
                        textAlign: TextAlign.center,
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
}
