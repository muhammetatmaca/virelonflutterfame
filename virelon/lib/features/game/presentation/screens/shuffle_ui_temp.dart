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
