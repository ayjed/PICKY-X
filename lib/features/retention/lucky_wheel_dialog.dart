import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/life_service.dart';
import '../../services/wallet_service.dart';

class WheelPrize {
  final String label;
  final String icon;
  final Color color;
  final Function(WalletService, LifeService) apply;

  const WheelPrize({
    required this.label,
    required this.icon,
    required this.color,
    required this.apply,
  });
}

/// Interactive Lucky Spin Wheel dialog with smooth rotational physics.
class LuckyWheelDialog extends StatefulWidget {
  final WalletService walletService;
  final LifeService lifeService;

  const LuckyWheelDialog({
    super.key,
    required this.walletService,
    required this.lifeService,
  });

  @override
  State<LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<LuckyWheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _spinAnimation;
  final Random _random = Random();

  bool _isSpinning = false;
  double _currentAngle = 0.0;
  WheelPrize? _wonPrize;

  static final List<WheelPrize> prizes = [
    WheelPrize(
      label: '50 Coins',
      icon: '🪙',
      color: const Color(0xFF7B1FA2),
      apply: (w, l) => w.addCoins(50),
    ),
    WheelPrize(
      label: '1x Peek',
      icon: '👁️',
      color: const Color(0xFF1976D2),
      apply: (w, l) => w.addBooster('peek', 1),
    ),
    WheelPrize(
      label: '5 Gems',
      icon: '💎',
      color: const Color(0xFF0097A7),
      apply: (w, l) => w.addGems(5),
    ),
    WheelPrize(
      label: '100 Coins',
      icon: '🪙',
      color: const Color(0xFF388E3C),
      apply: (w, l) => w.addCoins(100),
    ),
    WheelPrize(
      label: '1x Freeze',
      icon: '❄️',
      color: const Color(0xFF0288D1),
      apply: (w, l) => w.addBooster('freeze', 1),
    ),
    WheelPrize(
      label: '+2 Lives',
      icon: '❤️',
      color: const Color(0xFFD81B60),
      apply: (w, l) => l.addLives(2),
    ),
    WheelPrize(
      label: '1x Wand',
      icon: '🪄',
      color: const Color(0xFFF57C00),
      apply: (w, l) => w.addBooster('wand', 1),
    ),
    WheelPrize(
      label: '25 GEMS JACKPOT!',
      icon: '💎',
      color: const Color(0xFFC2185B),
      apply: (w, l) => w.addGems(25),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wonPrize = null;
    });

    final targetIndex = _random.nextInt(prizes.length);
    final prizeAnglePerWedge = 2 * pi / prizes.length;
    // Angle offset to land on target wedge
    final targetWedgeCenterAngle = (targetIndex * prizeAnglePerWedge) + (prizeAnglePerWedge / 2);

    // Add 5 to 8 full rotations
    final fullRotations = (5 + _random.nextInt(4)) * 2 * pi;
    final endAngle = fullRotations + (2 * pi - targetWedgeCenterAngle);

    _spinAnimation = Tween<double>(begin: _currentAngle, end: _currentAngle + endAngle).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward(from: 0.0).then((_) {
      _currentAngle = (_currentAngle + endAngle) % (2 * pi);
      final prize = prizes[targetIndex];
      prize.apply(widget.walletService, widget.lifeService);

      if (mounted) {
        setState(() {
          _isSpinning = false;
          _wonPrize = prize;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentYellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.35),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                const Text(
                  'LUCKY SPIN WHEEL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentYellow,
                    letterSpacing: 0.8,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Wheel Widget
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning Disc
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final angle = _isSpinning ? _spinAnimation.value : _currentAngle;
                      return Transform.rotate(
                        angle: angle,
                        child: CustomPaint(
                          size: const Size(240, 240),
                          painter: _WheelPainter(prizes: prizes),
                        ),
                      );
                    },
                  ),

                  // Center Pin
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundDark,
                      border: Border.all(color: AppColors.accentYellow, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 18)),
                    ),
                  ),

                  // Top Indicator Arrow
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 0,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.transparent, width: 12),
                          right: BorderSide(color: Colors.transparent, width: 12),
                          top: BorderSide(color: Colors.white, width: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Won Prize Banner
            if (_wonPrize != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentGreen),
                ),
                child: Text(
                  '🎉 YOU WON: ${_wonPrize!.icon} ${_wonPrize!.label}!',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),

            // Spin Button
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: _isSpinning
                    ? const LinearGradient(colors: [Color(0xFF4A4468), Color(0xFF322E4A)])
                    : AppColors.playButtonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !_isSpinning
                    ? [
                        BoxShadow(
                          color: AppColors.accentPink.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _spinWheel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isSpinning ? 'SPINNING...' : 'SPIN FOR FREE! 🎁',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * sweepAngle;
      final paint = Paint()
        ..color = prizes[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw Icon in wedge
      final angle = startAngle + sweepAngle / 2;
      final iconDistance = radius * 0.65;
      final iconOffset = Offset(
        center.dx + iconDistance * cos(angle),
        center.dy + iconDistance * sin(angle),
      );

      final textSpan = TextSpan(
        text: prizes[i].icon,
        style: const TextStyle(fontSize: 18),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(iconOffset.dx - textPainter.width / 2, iconOffset.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
