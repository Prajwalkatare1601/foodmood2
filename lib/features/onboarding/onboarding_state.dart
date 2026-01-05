import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final List<String> allergies;
  final List<String> foodRestrictions;
  final String dietPreference;

  const OnboardingState({
    this.allergies = const [],
    this.foodRestrictions = const [],
    this.dietPreference = '',
  });

  OnboardingState copyWith({
    List<String>? allergies,
    List<String>? foodRestrictions,
    String? dietPreference,
  }) {
    return OnboardingState(
      allergies: allergies ?? this.allergies,
      foodRestrictions: foodRestrictions ?? this.foodRestrictions,
      dietPreference: dietPreference ?? this.dietPreference,
    );
  }

  bool get isComplete =>
      dietPreference.isNotEmpty; // minimal completion rule

  @override
  List<Object?> get props => [allergies, foodRestrictions, dietPreference];
}
