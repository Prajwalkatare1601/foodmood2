import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../meal_type/meal_type_page.dart';

/// =======================
/// Meal Model
/// =======================
class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final String dietType;
  final int calories;
  final String prepTime;
  final List<String> allergens;

  /// Macros
  final int carbs;
  final int protein;
  final int fat;
  final int fiber;

  /// NEW
  final List<String> ingredients;
  final List<String> recipe;

  Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dietType,
    required this.calories,
    required this.prepTime,
    required this.allergens,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.ingredients,
    required this.recipe,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      dietType: json['diet_type'],
      calories: json['calories'],
      prepTime: json['prep_time'],
      allergens: List<String>.from(json['allergens'] ?? []),
      carbs: json['carbs'],
      protein: json['protein'],
      fat: json['fat'],
      fiber: json['fiber'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      recipe: List<String>.from(json['recipe'] ?? []),
    );
  }
}

/// =======================
/// Swipe Index Controller
/// =======================
class SwipeController extends StateNotifier<int> {
  SwipeController() : super(0);

  /// Move to next card safely
  void swipeNext(int totalMeals) {
    if (totalMeals == 0) return;

    if (state >= totalMeals - 1) {
      state = 0; // loop back
    } else {
      state++;
    }
  }

  /// Reset when meal type changes
  void reset() {
    state = 0;
  }
}

/// =======================
/// Providers
/// =======================

final swipeIndexProvider =
    StateNotifierProvider<SwipeController, int>((ref) {
  return SwipeController();
});

final mealsProvider =
    FutureProvider.family<List<Meal>, MealType>((ref, mealType) async {
  print('🟡 Fetching meals for: ${mealType.name}');

  final response = await Supabase.instance.client
      .from('meals')
      .select()
      .eq('food_time', mealType.name)
      .order('created_at');

  print('🟢 Raw Supabase response:');
  print(response);

  if (response is! List || response.isEmpty) {
    print('⚠️ No meals found for ${mealType.name}');
    return [];
  }

  return response
      .map((e) => Meal.fromJson(e))
      .toList();
});
