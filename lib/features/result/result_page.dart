import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../swipe/swipe_controller.dart';
import 'meal_success_page.dart';

class ResultPage extends StatelessWidget {
  final Meal meal;
  final VoidCallback onUseMeal;
  final VoidCallback onReshuffle;

  const ResultPage({
    super.key,
    required this.meal,
    required this.onUseMeal,
    required this.onReshuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          /// =======================
          /// CONTENT
          /// =======================
          CustomScrollView(
            slivers: [
              /// HERO IMAGE
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onReshuffle,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        meal.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _successBadge(),
                      ),
                    ],
                  ),
                ),
              ),

              /// BODY
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// QUICK STATS
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill(
                            meal.dietType.toUpperCase(),
                            _dietColor(meal.dietType),
                          ),
                          _pill('${meal.calories} cal', Colors.grey.shade800),
                          _pill('⏱ ${meal.prepTime}', Colors.grey.shade800),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// TITLE
                      Text(
                        meal.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Nutrition per serving', '📊'),
                      _macroCard(context),

                      const SizedBox(height: 24),


                      _sectionTitle('Ingredients', '🥘'),
                      _ingredientsCard(context),

                      const SizedBox(height: 24),

                      _sectionTitle('Recipe', '👨‍🍳'),
                      _recipeCard(context),

                      const SizedBox(height: 24),

                      _sectionTitle('Watch how to make it', '▶️'),
                      _youtubeButton(),



                    ],
                  ),
                ),
              ),
            ],
          ),

          /// =======================
          /// FIXED BOTTOM ACTIONS
          /// =======================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReshuffle,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reshuffle'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MealSuccessPage(meal: meal),
    ),
  );
},
                      icon: const Icon(Icons.check),
                      label: const Text('Use This Meal'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// SECTIONS
  /// =======================

Widget _macroCard(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _macro('Carbs', meal.carbs, Colors.blue),
        _macro('Protein', meal.protein, Colors.green),
        _macro('Fat', meal.fat, Colors.redAccent),
        _macro('Fiber', meal.fiber, Colors.orange),
      ],
    ),
  );
}


Widget _ingredientsCard(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Wrap(
      spacing: 12,
      runSpacing: 8,
      children: meal.ingredients.map(
        (e) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 6),
            const SizedBox(width: 6),
            Text(e),
          ],
        ),
      ).toList(),
    ),
  );
}
Widget _recipeCard(BuildContext context) {
  if (meal.recipe.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: const Text(
        'Recipe steps not available.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Column(
      children: List.generate(
        meal.recipe.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// STEP NUMBER
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// STEP TEXT
              Expanded(
                child: Text(
                  meal.recipe[index],
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _youtubeButton() {
    return ElevatedButton.icon(
      onPressed: () {
        final url =
            'https://www.youtube.com/results?search_query=${Uri.encodeComponent('${meal.name} recipe')}';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      icon: const Icon(Icons.play_circle),
      label: const Text('Search on YouTube'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  /// =======================
  /// UI HELPERS
  /// =======================

  Widget _macro(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '${value}g',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _sectionTitle(String text, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _successBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.check, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'Selected!',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Color _dietColor(String diet) {
    switch (diet) {
      case 'veg':
        return Colors.green;
      case 'vegan':
        return Colors.teal;
      case 'non-veg':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        blurRadius: 12,
        color: Colors.black12,
      ),
    ],
  );
}

}
