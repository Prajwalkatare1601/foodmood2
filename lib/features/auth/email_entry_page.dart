import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'otp_page.dart';

class EmailEntryPage extends ConsumerStatefulWidget {
  const EmailEntryPage({super.key});

  @override
  ConsumerState<EmailEntryPage> createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends ConsumerState<EmailEntryPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Continue with Email',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            const Text(
              'Enter your email address',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'We’ll send you a one-time verification code.',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        if (email.isEmpty) return;

                        setState(() => _loading = true);
                        try {
                          await auth.signInWithEmail(email);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpPage(
                                phoneOrEmail: email,
                                isPhone: false,
                              ),
                            ),
                          );
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to send OTP'),
                            ),
                          );
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
