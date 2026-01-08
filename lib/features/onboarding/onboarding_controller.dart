import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_state.dart';
import '../supabase/supabase_client.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  (ref) => OnboardingController(),
);

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(OnboardingState());

  // ---------- UI ACTIONS ----------

  void setDietPreference(String value) {
    state = state.copyWith(dietPreference: value);
  }

  void toggleRestriction(String value) {
    final list = [...state.foodRestrictions];

    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }

    state = state.copyWith(foodRestrictions: list);
  }

  void toggleAllergy(String value) {
    final list = [...state.allergies];

    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }

    state = state.copyWith(allergies: list);
  }

  // ---------- SAVE TO SUPABASE ----------

  Future<void> submitOnboardingAnswers() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await supabase.from('user_onboarding_answers').upsert({
  'user_id': user.id,
  'diet_preference': state.dietPreference,
  'food_restrictions': state.foodRestrictions,
  'allergies': state.allergies,
});

  }
}
