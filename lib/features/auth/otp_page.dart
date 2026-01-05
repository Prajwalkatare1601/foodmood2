import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import '../home/home_page.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneOrEmail;
  final bool isPhone;

  const OtpPage({
    super.key,
    required this.phoneOrEmail,
    required this.isPhone,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isPhone
                  ? 'Enter the code sent to ${widget.phoneOrEmail}'
                  : 'Enter the code sent to your email',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '6-digit OTP',
                counterText: '',
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
                        setState(() => _loading = true);
                        try {
                          await auth.verifyOtp(
                            otp: _otpController.text.trim(),
                            phoneOrEmail: widget.phoneOrEmail,
                            isPhone: widget.isPhone,
                          );

                          // ✅ OTP verified → session created
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                            (_) => false,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid OTP'),
                            ),
                          );
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
