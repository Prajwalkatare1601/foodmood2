import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_controller.dart';
import '../home/home_page.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int step = 0;

  void next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    final canProceed = step == 0
        ? state.dietPreference.isNotEmpty
        : true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i <= step ? Colors.black : Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _buildStep(step, state, controller),
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canProceed ? next : null,
                    child: Text(
                      step == 2 ? 'Start Swiping' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- STEPS ----------

  Widget _buildStep(int step, state, controller) {
    switch (step) {
      case 0:
        return _Question(
          key: const ValueKey(0),
          title: 'What do you usually eat?',
          child: Column(
            children: [
              _card('🥦', 'Vegetarian',
                  state.dietPreference == 'veg',
                  () => controller.setDietPreference('veg')),
              _card('🍗', 'Non-Vegetarian',
                  state.dietPreference == 'non-veg',
                  () => controller.setDietPreference('non-veg')),
              _card('🌱', 'vegan',
                  state.dietPreference == 'vegan',
                  () => controller.setDietPreference('vegan')),
            ],
          ),
        );

case 1:
  final diet = state.dietPreference;
  final isVegOrVegan = diet == 'veg' || diet == 'vegan';

  return _Question(
    key: const ValueKey(1),
    title: 'Any foods you never eat?',
    subtitle: isVegOrVegan
        ? 'Optional — helps us avoid certain ingredients'
        : null,
    child: Column(
      children: isVegOrVegan
          ? [
              _multiCard(
                '🧅',
                'Avoid Onion',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🧄',
                'Avoid Garlic',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🍷',
                'Avoid Alcohol',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🍽️',
                'No restrictions',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
            ]
          : [
              _multiCard(
                '🥩',
                'Avoid Beef',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🐖',
                'Avoid Pork',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🐟',
                'Avoid Seafood',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🍷',
                'Avoid Alcohol',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
              _multiCard(
                '🍽️',
                'No restrictions',
                state.foodRestrictions,
                controller.toggleRestriction,
              ),
            ],
    ),
  );



        case 2:
          return _Question(
            key: const ValueKey(2),
            title: 'Any food allergies?',
            subtitle: 'We’ll always avoid these',
            child: Column(
              children: [
                _multiCard(
                  '🥜',
                  'Nuts',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '🥛',
                  'Dairy',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '🍳',
                  'Eggs',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '🌾',
                  'Gluten',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '🌱',
                  'Soy',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '🐟',
                  'Seafood',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '⚪',
                  'Sesame',
                  state.allergies,
                  controller.toggleAllergy,
                ),
                _multiCard(
                  '✨',
                  'No allergies',
                  state.allergies,
                  controller.toggleAllergy,
                ),
              ],
            ),
          );


      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- UI COMPONENTS ----------

  Widget _card(String emoji, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black : Colors.black12,
            width: 2,
          ),
          color: selected ? Colors.black12 : Colors.white,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _multiCard(
    String emoji,
    String label,
    List<String> selected,
    Function(String) onTap,
  ) {
    final isSelected = selected.contains(label);
    return _card(emoji, label, isSelected, () => onTap(label));
  }
}

class _Question extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Question({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.black54),
            ),
          ],

          const SizedBox(height: 24),

          // 🔽 SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96), // 👈 IMPORTANT
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
