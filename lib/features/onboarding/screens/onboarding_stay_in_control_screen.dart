import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/features/auth/screens/email_verification_screen.dart';

class OnboardingStayInControlScreen extends StatelessWidget {
  const OnboardingStayInControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

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
                        children: [
                          SizedBox(height: height * 0.04),

                          // Title at top
                          Text(
                            'Stay in control',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28,
                                  letterSpacing: 0.3,
                                ),
                          ),

                          SizedBox(height: height * 0.02),

                          // Vault image
                          _VaultImage(maxSize: width * 0.85),

                          const SizedBox(height: 24),

                          // Title below image
                          Text(
                            'Stay in control',
                            textAlign: TextAlign.center,
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
                            'Review calls anytime. Your AI agent only acts on\nyour behalf with your approval and stores sensitive\ndata in a secure memory vault.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                          ),

                          const SizedBox(height: 16),

                          // Enable Agent button
                          const _EnableAgentButton(),

                          const SizedBox(height: 8),

                          // Privacy disclaimer
                          RichText(
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
                                      // Handle privacy policy tap
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'AI Safety Guidelines',
                                  style: TextStyle(
                                    color: context.gold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Handle AI safety guidelines tap
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),

                          // Logo
                          Image.asset(context.logoPath, height: 180),

                          const SizedBox(height: 12),
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

    // Very subtle warm haze to support the gold theme
    final haze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.08, -0.15),
        radius: 0.65,
        colors: [const Color(0x40C09050), const Color(0x00000000)],
        stops: const [0.0, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, haze);

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

class _VaultImage extends StatefulWidget {
  final double maxSize;

  const _VaultImage({required this.maxSize});

  @override
  State<_VaultImage> createState() => _VaultImageState();
}

class _VaultImageState extends State<_VaultImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = widget.maxSize * 0.95;

    final orbDiameter = widget.maxSize * 0.85;

    return SizedBox(
      width: widget.maxSize,
      height: widget.maxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated orb rings (behind)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.maxSize, widget.maxSize),
                painter: _OrbPainter(
                  orbRadius: orbDiameter / 2,
                  animationValue: _controller.value,
                ),
              );
            },
          ),
          // Vault image
          Image.asset(
            'assets/brand/vault.png',
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF080706),
                  border: Border.all(
                    color: const Color(0xFFBE8A52).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Color(0xFFBE8A52), size: 80),
                ),
              );
            },
          ),
          // Animated sparkles (front)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.maxSize, widget.maxSize),
                painter: _GlowPainter(
                  animationValue: _controller.value,
                  radius: imageSize / 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double orbRadius;
  final double animationValue;

  _OrbPainter({required this.orbRadius, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = orbRadius;

    // Animated complete circle rings expanding outward (ripple/pulse effect)
    const int numRings = 4;
    for (int i = 0; i < numRings; i++) {
      final ringPhase = (animationValue + i / numRings) % 1.0;
      final ringRadius = radius * (1.08 + ringPhase * 0.82);
      final opacity = (1.0 - ringPhase).clamp(0.0, 1.0);
      final fadeOpacity =
          opacity * opacity * 0.35; // Quadratic fade for smoother effect

      if (fadeOpacity > 0.01) {
        // Complete circle ring - copper gold
        final circlePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * (1.0 - ringPhase * 0.6)
          ..color = Color.fromRGBO(190, 130, 70, fadeOpacity);

        canvas.drawCircle(center, ringRadius, circlePaint);
      }
    }

    // Static outer rings (very subtle copper)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x12A07040);

    canvas.drawCircle(center, radius * 1.85, ringPaint);
    canvas.drawCircle(center, radius * 1.48, ringPaint);
    canvas.drawCircle(center, radius * 1.18, ringPaint);

    // Outer glow bloom - TWO arcs: top-right and bottom-left
    final outerBloom = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..shader = SweepGradient(
        colors: const [
          Color(0x00000000),
          Color(0x20C47830),
          Color(0x50C47830),
          Color(0x20C47830),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x20C47830),
          Color(0x50C47830),
          Color(0x20C47830),
          Color(0x00000000),
        ],
        stops: const [
          0.0,
          0.08,
          0.15,
          0.22,
          0.35,
          0.50,
          0.58,
          0.65,
          0.72,
          0.85,
        ],
        transform: const GradientRotation(1.15),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.12));

    canvas.drawCircle(center, radius * 1.12, outerBloom);

    // Bright copper-gold rim - TWO arcs
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = SweepGradient(
        colors: const [
          Color(0x00000000),
          Color(0x55C47830),
          Color(0xDDD4883C),
          Color(0xFFD4883C),
          Color(0xDDD4883C),
          Color(0x55C47830),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x55C47830),
          Color(0xDDD4883C),
          Color(0xFFD4883C),
          Color(0xDDD4883C),
          Color(0x55C47830),
          Color(0x00000000),
        ],
        stops: const [
          0.0,
          0.05,
          0.10,
          0.15,
          0.20,
          0.25,
          0.35,
          0.50,
          0.55,
          0.60,
          0.65,
          0.70,
          0.75,
          0.85,
        ],
        transform: const GradientRotation(1.15),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 1.2, rimPaint);

    // Soft glow behind the rim - TWO arcs copper-gold
    final rimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = SweepGradient(
        colors: const [
          Color(0x00000000),
          Color(0x30C47830),
          Color(0x70D4883C),
          Color(0x30C47830),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x30C47830),
          Color(0x70D4883C),
          Color(0x30C47830),
          Color(0x00000000),
        ],
        stops: const [
          0.0,
          0.06,
          0.15,
          0.24,
          0.38,
          0.50,
          0.56,
          0.65,
          0.74,
          0.88,
        ],
        transform: const GradientRotation(1.15),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius + 3, rimGlow);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _GlowPainter extends CustomPainter {
  final double animationValue;
  final double radius;

  _GlowPainter({required this.animationValue, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Animated sparkle particles
    final sparkPaint = Paint()
      ..color = const Color(0xFFD4883C)
      ..style = PaintingStyle.fill;

    final rnd = math.Random(42);
    for (int i = 0; i < 150; i++) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final baseRadius = radius * (0.5 + rnd.nextDouble() * 0.7);
      final phase = (animationValue + i / 150) % 1.0;
      final sparkRadius = baseRadius * (0.8 + phase * 0.4);

      final x = center.dx + math.cos(angle) * sparkRadius;
      final y = center.dy + math.sin(angle) * sparkRadius;

      final opacity = (1 - phase) * rnd.nextDouble() * 0.6;
      sparkPaint.color = Color.fromRGBO(212, 136, 60, opacity);

      final sparkSize = 1.0 + rnd.nextDouble() * 2.0;
      canvas.drawCircle(Offset(x, y), sparkSize, sparkPaint);
    }

    // Outer glow
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..color = const Color(0x30C47830);

    canvas.drawCircle(center, radius * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _EnableAgentButton extends StatelessWidget {
  const _EnableAgentButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          onTap: () {
            Navigator.of(
              context,
            ).pushReplacement(fadeSlideRoute(const EmailVerificationScreen()));
          },
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Grant Access',
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
