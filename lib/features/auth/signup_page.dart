import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'otp_page.dart';
import 'email_entry_page.dart';
import '../onboarding/onboarding_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              const Text(
                'Log in or sign up',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Save your Food Mood and preferences',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 32),

              // PHONE INPUT
              Row(
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '+91',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter mobile number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE23744), // Zomato-like red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty) {
                        await auth.signInWithPhone('+91$phone');

                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OtpPage(
                                phoneOrEmail: '+91$phone',
                                isPhone: true,
                                ),
                            ),
                            );
                        }
                    },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // OR DIVIDER
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // SOCIAL BUTTONS
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: () async {
                        final success = await auth.signInWithGoogle();

                        if (!mounted) return;

                        if (success) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const OnboardingPage()),
                            (_) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google sign-in failed')),
                          );
                        }
                      },

                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SocialButton(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EmailEntryPage(),
                        ),
                        );
                    },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context, auth) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'you@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await auth.signInWithEmail(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
