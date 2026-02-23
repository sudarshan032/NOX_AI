import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox_ai/core/constants/app_routes.dart';
import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _navigate);
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    _navigated = true;
    final isAuth = ref.read(authStateProvider).isAuthenticated;
    context.go(isAuth ? AppRoutes.home : AppRoutes.onboardingMeetAgent);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

            final orbDiameter = (math.min(width, height) * 0.40).clamp(
              210.0,
              300.0,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                _Background(isDark: isDark),
                // Orb in upper portion
                Align(
                  alignment: const Alignment(0, -0.52),
                  child: _Orb(diameter: orbDiameter),
                ),
                // Text content below orb
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * 0.56,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hello!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                              letterSpacing: 0.3,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Your AI is booting up...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _LoadingDots(),
                    ],
                  ),
                ),
                // Logo at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: Image.asset(context.logoPath, height: 250),
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
  final bool isDark;

  const _Background({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (isDark) {
      final base = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF0B0B0B), Color(0xFF000000)],
          stops: [0, 0.55, 1],
        ).createShader(rect);
      canvas.drawRect(rect, base);

      // Subtle vignette.
      final vignette = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 1.1,
          colors: [const Color(0x00000000), const Color(0xCC000000)],
          stops: const [0.45, 1.0],
        ).createShader(rect);
      canvas.drawRect(rect, vignette);

      // Very subtle warm haze to support the gold theme.
      final haze = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.08, -0.32),
          radius: 0.55,
          colors: [const Color(0x30C09050), const Color(0x00000000)],
          stops: const [0.0, 1.0],
        ).createShader(rect);
      canvas.drawRect(rect, haze);

      // Film-grain style noise (subtle).
      final noisePaint = Paint()..color = const Color(0x08FFFFFF);
      final rnd = math.Random(7);
      final count = ((size.width * size.height) / 1800)
          .clamp(600, 2200)
          .toInt();
      for (var i = 0; i < count; i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), noisePaint);
      }
    } else {
      // Light mode background
      final base = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F6F3), Color(0xFFFFFBF7), Color(0xFFF8F6F3)],
          stops: [0, 0.55, 1],
        ).createShader(rect);
      canvas.drawRect(rect, base);

      // Subtle warm haze for light mode.
      final haze = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.08, -0.32),
          radius: 0.55,
          colors: [const Color(0x20D4A86A), const Color(0x00000000)],
          stops: const [0.0, 1.0],
        ).createShader(rect);
      canvas.drawRect(rect, haze);

      // Film-grain style noise (subtle) for light mode.
      final noisePaint = Paint()..color = const Color(0x06000000);
      final rnd = math.Random(7);
      final count = ((size.width * size.height) / 1800)
          .clamp(600, 2200)
          .toInt();
      for (var i = 0; i < count; i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), noisePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _Orb extends StatefulWidget {
  final double diameter;

  const _Orb({required this.diameter});

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
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
    final canvasSize = widget.diameter * 1.95;
    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(canvasSize, canvasSize),
                painter: _OrbPainter(
                  orbRadius: widget.diameter / 2,
                  animationValue: _controller.value,
                ),
              );
            },
          ),
          SizedBox(
            width: widget.diameter,
            height: widget.diameter,
            child: const Center(child: _EqualizerMark()),
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

    // Static outer rings (very subtle copper).
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
        transform: const GradientRotation(
          1.15,
        ), // Rotate to top-left / bottom-right
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.12));

    canvas.drawCircle(center, radius * 1.12, outerBloom);

    // Orb body (dark sphere) - uniform dark color
    final orbPaint = Paint()..color = const Color(0xFF080706);

    canvas.drawCircle(center, radius, orbPaint);

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

class _EqualizerMark extends StatefulWidget {
  const _EqualizerMark();

  @override
  State<_EqualizerMark> createState() => _EqualizerMarkState();
}

class _EqualizerMarkState extends State<_EqualizerMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFFBE8A52); // copper gold
    const barWidth = 7.0;
    const spacing = 6.0;

    // Base heights and animation parameters for each bar
    // Each bar has: [minHeight, maxHeight, frequency multiplier, phase offset]
    final barConfigs = [
      [12.0, 28.0, 2.3, 0.0], // Left outer
      [16.0, 40.0, 1.7, 0.4], // Left inner
      [20.0, 48.0, 2.0, 0.2], // Center (tallest)
      [16.0, 40.0, 1.9, 0.6], // Right inner
      [12.0, 28.0, 2.1, 0.8], // Right outer
    ];
    final opacities = [0.85, 0.95, 1.0, 0.95, 0.85];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 70,
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(barConfigs.length, (index) {
              final config = barConfigs[index];
              final minH = config[0];
              final maxH = config[1];
              final freq = config[2];
              final phase = config[3];

              // Create organic voice-like animation
              final t = _controller.value * 2 * math.pi;
              final wave1 = math.sin(t * freq + phase * math.pi);
              final wave2 = math.sin(t * freq * 1.5 + phase * math.pi + 0.5);
              final combined =
                  (wave1 * 0.6 + wave2 * 0.4 + 1) / 2; // Normalize to 0-1

              final height = minH + (maxH - minH) * combined;

              return Row(
                children: [
                  if (index > 0) SizedBox(width: spacing),
                  _Bar(
                    h: height,
                    w: barWidth,
                    color: barColor,
                    opacity: opacities[index],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final double h;
  final double w;
  final Color color;
  final double opacity;

  const _Bar({
    required this.h,
    required this.w,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(w / 2),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotSize = 6.0;
    const activeColor = Color(0x88C0A070);
    const inactiveColor = Color(0x22C0A070);

    Widget dot(int index) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = (_controller.value * 3 - index / 3).clamp(0.0, 1.0);
          final opacity = (math.sin(progress * math.pi) * 0.7 + 0.3).clamp(
            0.0,
            1.0,
          );
          return Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: Color.lerp(inactiveColor, activeColor, opacity),
              shape: BoxShape.circle,
            ),
          );
        },
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(0),
        const SizedBox(width: 10),
        dot(1),
        const SizedBox(width: 10),
        dot(2),
      ],
    );
  }
}
