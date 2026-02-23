import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/providers/app_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, this.phone = ''});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  bool _isLoading = false;
  String? _error;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _remainingSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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

                          // Description with phone
                          Text(
                            'Enter the 6 digit code sent to ${widget.phone.isNotEmpty ? widget.phone : 'your email'}',
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

                          // OTP input boxes
                          Row(
                            children: List.generate(6, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 0 : 4,
                                    right: index == 5 ? 0 : 4,
                                  ),
                                  child: _OtpInputBox(
                                    controller: _otpControllers[index],
                                    focusNode: _focusNodes[index],
                                    onChanged: (value) =>
                                        _onOtpChanged(index, value),
                                    onKeyEvent: (event) =>
                                        _onKeyPressed(index, event),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 24),

                          // Resend OTP row
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: "Didn't receive OTP? "),
                                  TextSpan(
                                    text: 'Resend OTP',
                                    style: TextStyle(
                                      color: context.gold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _remainingSeconds == 0
                                          ? () async {
                                              _startTimer();
                                              try {
                                                await ref.read(authStateProvider.notifier).sendOtp(widget.phone);
                                              } catch (_) {}
                                            }
                                          : null,
                                  ),
                                  TextSpan(
                                    text: ':  $_formattedTime',
                                    style: TextStyle(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.15),

                          // Error
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                            const SizedBox(height: 8),
                          ],

                          // Verify button
                          _VerifyButton(
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : () async {
                              final otp = _otpControllers.map((c) => c.text).join();
                              if (otp.length < 6) {
                                setState(() => _error = 'Enter the full 6-digit OTP');
                                return;
                              }
                              setState(() { _isLoading = true; _error = null; });
                              try {
                                debugPrint('[AUTH] Verifying OTP for phone=${widget.phone}, otp=$otp');
                                await ref.read(authStateProvider.notifier).verifyOtp(widget.phone, otp);
                                debugPrint('[AUTH] verifyOtp SUCCESS - should redirect to home');
                              } catch (e) {
                                debugPrint('[AUTH] verifyOtp ERROR: $e');
                                if (mounted) {
                                  setState(() {
                                    _error = 'Verification failed: $e';
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                          ),

                          const SizedBox(height: 16),

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
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: context.gold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Handle tap
                                      },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'AI Safety',
                                    style: TextStyle(
                                      color: context.gold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Handle tap
                                      },
                                  ),
                                  const TextSpan(text: ' Guidelines..'),
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

class _OtpInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKeyEvent;

  const _OtpInputBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 50 / 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onKeyEvent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB7A58B).withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              color: Color(0xFFECE4D6),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _VerifyButton({required this.onPressed, this.isLoading = false});

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
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A1208), strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Verify',
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
