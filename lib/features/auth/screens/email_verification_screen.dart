import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/features/auth/screens/otp_verification_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Background with subtle effects
                const _Background(),

                // Main content
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo centered
                          Center(
                            child: Image.asset(context.logoPath, height: 220),
                          ),

                          // Title
                          Text(
                            'Verify your Email',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28,
                                  letterSpacing: 0.3,
                                ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            "We'll send a 6 digit code to verify your account\nand get AIVoice agent ready",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                          ),

                          const SizedBox(height: 32),

                          // Email input field
                          _EmailInputField(controller: _emailController),

                          const SizedBox(height: 24),

                          // Get OTP button
                          _GetOTPButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                fadeSlideRoute(
                                  OtpVerificationScreen(
                                    email: _emailController.text.isNotEmpty
                                        ? _emailController.text
                                        : 'your-email@gmail.com',
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Privacy disclaimer
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By enabling, you agree to our ',
                                  ),
                                  TextSpan(
                                    text:
                                        'Privacy Policy and AI Safety Guidelines',
                                    style: TextStyle(
                                      color: context.gold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Handle tap
                                      },
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF000000), Color(0xFF0B0B0B), Color(0xFF000000)],
        stops: [0, 0.55, 1],
      ).createShader(rect);

    canvas.drawRect(rect, base);

    // Subtle vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.25),
        radius: 1.1,
        colors: [const Color(0x00000000), const Color(0xCC000000)],
        stops: const [0.45, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignette);

    // Film-grain style noise (subtle)
    final noisePaint = Paint()..color = const Color(0x08FFFFFF);
    final rnd = math.Random(7);
    final count = ((size.width * size.height) / 1800).clamp(600, 2200).toInt();
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBE8A52).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Color(0xFFECE4D6), fontSize: 16),
        decoration: InputDecoration(
          hintText: 'your-email@gmail.com',
          hintStyle: TextStyle(
            color: const Color(0xFFB7A58B).withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.email_outlined,
              color: const Color(0xFFBE8A52).withOpacity(0.8),
              size: 24,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _GetOTPButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GetOTPButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4883C), Color(0xFFBE8A52), Color(0xFFA07040)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE8A52).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Text(
              'Get OTP',
              style: TextStyle(
                color: Color(0xFF1A1208),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
