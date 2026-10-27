import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../models/card_model.dart';

/// Interactive Memory Card widget with 3D flip animation, ice barriers, bombs, and accessibility.
class MemoryCard extends StatelessWidget {
  final CardModel card;
  final int index;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.card,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFaceUp = card.isEffectivelyFaceUp || card.isMatched;

    return Semantics(
      label: card.isMatched
          ? '${card.semanticLabel}, Matched'
          : card.isFaceUp
              ? '${card.semanticLabel}, Revealed'
              : card.isFrozen
                  ? 'Frozen Card ${index + 1}'
                  : 'Hidden Card ${index + 1}',
      button: !card.isMatched,
      child: GestureDetector(
        onTap: card.isMatched ? null : onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: isFaceUp ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, val, child) {
            final isUnder = (val > 0.5);
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(val * pi);

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: isUnder
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildFrontFace(),
                    )
                  : _buildBackFace(),
            );
          },
        ),
      ),
    );
  }

  /// Front Face (Revealed / Matched Symbol)
  Widget _buildFrontFace() {
    return Container(
      decoration: BoxDecoration(
        color: card.isMatched
            ? AppColors.accentGreen.withOpacity(0.2)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.isMatched
              ? AppColors.accentGreen
              : card.isPeekRevealed
                  ? AppColors.accentCyan
                  : AppColors.accentYellow,
          width: card.isMatched ? 3.0 : 2.5,
        ),
        boxShadow: [
          if (card.isMatched)
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.5),
              blurRadius: 14,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: (card.isPeekRevealed ? AppColors.accentCyan : AppColors.accentYellow).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            card.assetName,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              card.pairKey.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Back Face (Hidden State with Ice / Bomb overlays)
  Widget _buildBackFace() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: card.isFrozen ? AppColors.accentCyan : AppColors.surfaceCardBorder,
              width: card.isFrozen ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: card.isFrozen ? AppColors.accentCyan.withOpacity(0.3) : Colors.black.withOpacity(0.35),
                blurRadius: card.isFrozen ? 10 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              AppAssets.cardBack,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.cardBackGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Ice Barrier Overlay
        if (card.isFrozen)
          Container(
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.ac_unit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

        // Bomb Countdown Overlay
        if (card.isBomb)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.accentPink,
                shape: BoxShape.circle,
              ),
              child: const Text('💣', style: TextStyle(fontSize: 10)),
            ),
          ),
      ],
    );
  }
}
