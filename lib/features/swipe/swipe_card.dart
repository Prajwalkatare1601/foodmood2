import 'dart:math';
import 'package:flutter/material.dart';
import 'swipe_controller.dart';

class SwipeCard extends StatefulWidget {
  final Meal meal;
  final bool isTop;
  final void Function(bool liked)? onSwipe;

  const SwipeCard({
    super.key,
    required this.meal,
    required this.isTop,
    this.onSwipe,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  double dx = 0;
  double dy = 0;

  static const double swipeThreshold = 120;

  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();

    /// ❤️ Heart pulse animation
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _heartScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTop) {
      return MealCard(meal: widget.meal);
    }

    /// === Framer-motion like transforms ===
    final rotation = dx * 0.0015;
    final cardOpacity = (1 - dx.abs() / 400).clamp(0.6, 1.0);
    final likeOpacity = (dx / swipeThreshold).clamp(0.0, 1.0);
    final nopeOpacity = (-dx / swipeThreshold).clamp(0.0, 1.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack, // 🎞 spring-like motion
      left: dx,
      top: dy,
      right: -dx,
      bottom: -dy,
      child: Opacity(
        opacity: cardOpacity,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              dx += details.delta.dx;
              dy += details.delta.dy;
            });
          },
          onPanEnd: (_) {
            if (dx > swipeThreshold) {
              _heartController.forward(from: 0);
              widget.onSwipe?.call(true);
            } else if (dx < -swipeThreshold) {
              widget.onSwipe?.call(false);
            }

            setState(() {
              dx = 0;
              dy = 0;
            });
          },
          child: Transform.rotate(
            angle: rotation,
            child: Stack(
              children: [
                MealCard(meal: widget.meal),

                /// ❤️ LIKE badge
                Positioned(
                  top: 32,
                  right: 32,
                  child: Opacity(
                    opacity: likeOpacity,
                    child: ScaleTransition(
                      scale: _heartScale,
                      child: _badge(
                        text: 'LIKE',
                        color: Colors.greenAccent,
                        icon: Icons.favorite,
                      ),
                    ),
                  ),
                ),

                /// ❌ NOPE badge
                Positioned(
                  top: 32,
                  left: 32,
                  child: Opacity(
                    opacity: nopeOpacity,
                    child: _badge(
                      text: 'NOPE',
                      color: Colors.redAccent,
                      icon: Icons.close,
                    ),
                  ),
                ),

                /// Bottom Tinder buttons
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: _bottomButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =======================
  /// UI helpers
  /// =======================
  Widget _badge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.close,
          color: Colors.redAccent,
          onTap: () => widget.onSwipe?.call(false),
        ),
        const SizedBox(width: 32),
        _circleButton(
          icon: Icons.favorite,
          color: Colors.greenAccent,
          onTap: () {
            _heartController.forward(from: 0);
            widget.onSwipe?.call(true);
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

/// =======================
/// PUBLIC CARD UI
/// =======================
class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 40), // top & bottom space
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(blurRadius: 25, color: Colors.black54),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// IMAGE
            Image.network(meal.imageUrl, fit: BoxFit.cover),

            /// GRADIENT
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),

            /// CONTENT (SAFE ZONE – no overlap with buttons)
            Positioned(
              left: 24,
              right: 24,
              bottom: 160, // 🔒 reserved space for heart/cross buttons
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TAGS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(
                        meal.dietType.toUpperCase(),
                        _dietColor(meal.dietType),
                      ),
                      _pill('${meal.calories} cal', Colors.white24),
                      _pill('⏱ ${meal.prepTime}', Colors.white24),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// MEAL NAME
                  Text(
                    meal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// MACROS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'C ${meal.carbs}g  |  P ${meal.protein}g  |  F ${meal.fat}g  |  Fi ${meal.fiber}g',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// ALLERGENS (optional)
                  if (meal.allergens.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Contains: ${meal.allergens.join(', ')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// Helpers
  /// =======================
  Widget _pill(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _dietColor(String diet) {
    switch (diet) {
      case 'veg':
        return Colors.green.withOpacity(0.85);
      case 'vegan':
        return Colors.teal.withOpacity(0.85);
      case 'non-veg':
        return Colors.redAccent.withOpacity(0.85);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }
}

