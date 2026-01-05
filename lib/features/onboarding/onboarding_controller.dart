import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_state.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  (ref) => OnboardingController(),
);

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  // ---------- ALLERGIES ----------

  void toggleAllergy(String value) {
    if (value == 'No allergies') {
      state = state.copyWith(allergies: ['No allergies']);
      return;
    }

    final list = [...state.allergies];
    list.remove('No allergies');

    list.contains(value) ? list.remove(value) : list.add(value);

    state = state.copyWith(allergies: list);
  }

  // ---------- FOOD RESTRICTIONS ----------

  void toggleRestriction(String value) {
    if (value == 'No restrictions') {
      state = state.copyWith(foodRestrictions: ['No restrictions']);
      return;
    }

    final list = [...state.foodRestrictions];
    list.remove('No restrictions');

    list.contains(value) ? list.remove(value) : list.add(value);

    state = state.copyWith(foodRestrictions: list);
  }

  // ---------- DIET PREFERENCE ----------

  void setDietPreference(String value) {
    // Reset restrictions when diet changes
    List<String> restrictions = [];

    if (value == 'veg' || value == 'vegan') {
      restrictions.addAll([
        'Avoid Beef',
        'Avoid Pork',
        'Avoid Seafood',
      ]);
    }

    state = state.copyWith(
      dietPreference: value,
      foodRestrictions: restrictions,
    );
  }

  // ---------- RESET ----------

  void reset() {
    state = const OnboardingState();
  }
}
