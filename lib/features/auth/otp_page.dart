import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import '../onboarding/onboarding_page.dart';

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
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
    List.generate(6, (_) => FocusNode());

    void _resetOtp() {
    for (final controller in _controllers) {
        controller.clear();
    }
    _focusNodes.first.requestFocus();
    }


  bool _loading = false;

  String get _otp =>
      _controllers.map((c) => c.text).join();

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
          'Login with OTP',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Text(
                widget.isPhone
                    ? 'To confirm your mobile number,\nplease enter the OTP we sent to'
                    : 'To confirm your email address,\nplease enter the OTP we sent to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _maskContact(widget.phoneOrEmail),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                6,
                (index) => _OtpBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autoFocus: index == 0,
                    onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                }
                setState(() {}); // 👈 THIS IS THE FIX
                },
                ),
                ),
              ),

              const SizedBox(height: 32),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE23744),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loading || _otp.length != 6
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            await auth.verifyOtp(
                              otp: _otp,
                              phoneOrEmail: widget.phoneOrEmail,
                              isPhone: widget.isPhone,
                            );

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnboardingPage(),
                              ),
                              (_) => false,
                            );
                            } catch (_) {
                            _resetOtp();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                content: Text('Incorrect OTP. Please try again.'),
                                ),
                            );
                            }finally {
                            setState(() => _loading = false);
                          }
                        },
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // RESEND
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE23744)),
                  ),
                  onPressed: () async {
                    if (widget.isPhone) {
                      await auth.signInWithPhone(widget.phoneOrEmail);
                    } else {
                      await auth.signInWithEmail(widget.phoneOrEmail);
                    }
                  },
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: Color(0xFFE23744),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Valid for 10 minutes',
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

  String _maskContact(String value) {
    if (value.contains('@')) {
      final parts = value.split('@');
      return '${parts[0][0]}***${parts[0].substring(parts[0].length - 1)}@${parts[1]}';
    }
    return '${value.substring(0, 3)}*****${value.substring(value.length - 2)}';
  }
}

// ---------------- OTP BOX ----------------

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;
  final ValueChanged<String> onChanged;


const _OtpBox({
  required this.controller,
  required this.focusNode,
  required this.autoFocus,
  required this.onChanged,
});


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE23744)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
