import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../result/result_page.dart';
import 'swipe_controller.dart';
import 'swipe_card.dart';
import '../meal_type/meal_type_page.dart';

class SwipePage extends ConsumerWidget {
  const SwipePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealType = ref.watch(selectedMealTypeProvider);
    final index = ref.watch(swipeIndexProvider);

    if (mealType == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No meal type selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final mealsAsync = ref.watch(mealsProvider(mealType));

return Scaffold(
  backgroundColor: Colors.black,
  body: SafeArea(
    child: Column(
      children: [
        /// =======================
        /// TOP BAR
        /// =======================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

                /// ⬅️ Back
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
 

              /// 🍽 Meal type title
              Text(
                mealType.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

             /// 🔀 Reshuffle
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white),
                onPressed: () {
                  ref.read(swipeIndexProvider.notifier).state = 0;
                },
              ),
            ],
          ),
        ),

        /// =======================
        /// CARDS
        /// =======================
        Expanded(
          child: mealsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (meals) {
              if (meals.isEmpty) {
                return const Center(
                  child: Text(
                    'No meals found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final currentIndex = index % meals.length;
              final nextIndex = (currentIndex + 1) % meals.length;

              return Stack(
                children: [
                  SwipeCard(
                    meal: meals[nextIndex],
                    isTop: false,
                  ),
                  SwipeCard(
  meal: meals[currentIndex],
  isTop: true,
  onSwipe: (liked) {
    if (liked) {
      /// ❤️ GO TO RESULT PAGE
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            meal: meals[currentIndex],
            onUseMeal: () {
              // TODO: save meal / proceed
              Navigator.pop(context);
            },
            onReshuffle: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      /// ❌ JUST MOVE TO NEXT CARD
      ref
          .read(swipeIndexProvider.notifier)
          .swipeNext(meals.length);
    }
  },
),

                ],
              );
            },
          ),
        ),
      ],
    ),
  ),
);

  }
}
