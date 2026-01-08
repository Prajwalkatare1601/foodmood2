import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../swipe/swipe_page.dart';

/// =======================
/// GLOBAL STATE
/// =======================
final selectedMealTypeProvider =
    StateProvider<MealType?>((ref) => null);

/// =======================
/// Meal type enum
/// =======================
enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
}

/// =======================
/// Model
/// =======================
class MealTypeOption {
  final MealType id;
  final String label;
  final String emoji;
  final String time;

  const MealTypeOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.time,
  });
}

/// =======================
/// Options
/// =======================
const mealTypeOptions = [
  MealTypeOption(
    id: MealType.breakfast,
    label: 'Breakfast',
    emoji: '🍳',
    time: 'Start your day right',
  ),
  MealTypeOption(
    id: MealType.lunch,
    label: 'Lunch',
    emoji: '🍛',
    time: 'Midday fuel',
  ),
  MealTypeOption(
    id: MealType.snacks,
    label: 'Snacks',
    emoji: '🍿',
    time: 'Quick bites',
  ),
  MealTypeOption(
    id: MealType.dinner,
    label: 'Dinner',
    emoji: '🍽️',
    time: 'End the day well',
  ),
];

/// =======================
/// PAGE
/// =======================
class MealTypePage extends ConsumerStatefulWidget {
  const MealTypePage({super.key});

  @override
  ConsumerState<MealTypePage> createState() => _MealTypePageState();
}

class _MealTypePageState extends ConsumerState<MealTypePage>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerOpacity =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);

    _headerSlide = Tween(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(_headerController);

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              /// HEADER
              FadeTransition(
                opacity: _headerOpacity,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Column(
                    children: const [
                      Text(
                        'What are you craving?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose your meal type to start swiping',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// OPTIONS
              Column(
                children: List.generate(mealTypeOptions.length, (index) {
                  final option = mealTypeOptions[index];

                  return _MealTypeCard(
                    option: option,
                    index: index,
                    onTap: () {
                      /// store selection
                      ref
                          .read(selectedMealTypeProvider.notifier)
                          .state = option.id;

                      /// navigate
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SwipePage(),
                        ),
                      );
                    },
                  );
                }),
              ),

              const Spacer(),

              const Text(
                'Swipe right on a meal you love 💕',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// CARD WIDGET
/// =======================
class _MealTypeCard extends StatefulWidget {
  final MealTypeOption option;
  final int index;
  final VoidCallback onTap;

  const _MealTypeCard({
    required this.option,
    required this.index,
    required this.onTap,
  });

  @override
  State<_MealTypeCard> createState() => _MealTypeCardState();
}

class _MealTypeCardState extends State<_MealTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black12,
                )
              ],
            ),
            child: Row(
              children: [
                /// Emoji
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.option.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),

                const SizedBox(width: 16),

                /// Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.option.label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.option.time,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                /// Arrow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
