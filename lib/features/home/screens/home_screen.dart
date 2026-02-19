import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/features/tasks/screens/tasks_screen.dart';
import 'package:nox_ai/features/calendar/screens/calendar_screen.dart';
import 'package:nox_ai/features/calls/screens/call_logs_screen.dart';
import 'package:nox_ai/features/profile/screens/profile_settings_screen.dart';
import 'package:nox_ai/features/notifications/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _agentActive = true;
  int _selectedNavIndex = 2; // Center mic button

  late AnimationController _orbController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - everything scrolls together
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo centered at top
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.asset(
                        context.logoPath,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.all_inclusive,
                            color: context.gold,
                            size: 200,
                          );
                        },
                      ),
                    ),
                  ),

                  // Orb and content below - moved up closer to logo
                  Transform.translate(
                    offset: const Offset(0, -80),
                    child: Column(
                      children: [
                        // Orb with animation
                        _buildOrb(),

                        const SizedBox(height: 20),

                        // Agent Active toggle
                        _buildAgentToggle(),

                        const SizedBox(height: 8),

                        // Listening status
                        Center(
                          child: Text(
                            _agentActive
                                ? 'LISTENING FOR COMMANDS...'
                                : 'AGENT INACTIVE',
                            style: TextStyle(
                              color: context.textSecondary.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Upcoming section
                        _buildUpcomingSection(),

                        const SizedBox(height: 24),

                        // Quick Tasks section
                        _buildQuickTasksSection(),

                        const SizedBox(height: 16), // Minimal bottom padding
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Notification bell - top left (positioned after scroll view to receive taps)
            Positioned(
              top: 20,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    fadeSlideRoute(const NotificationsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.cardBorder, width: 1),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: context.gold.withOpacity(0.8),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildOrb() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _agentActive = !_agentActive;
          });
        },
        child: SizedBox(
          width: 280,
          height: 280,
          child: AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return CustomPaint(
                painter: _OrbPainter(
                  animationValue: _orbController.value,
                  isActive: _agentActive,
                  orbBgColor: context.orbBg,
                ),
                child: Center(child: _EqualizerBars(isActive: _agentActive)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAgentToggle() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AGENT ACTIVE',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _agentActive = !_agentActive;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: _agentActive ? context.gold : context.cardBorder,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: _agentActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _agentActive
                          ? context.textPrimary
                          : context.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPCOMING',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  color: context.textSecondary.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Appointment cards - TODO: Replace with API data
        // Example: ListView.builder with appointments from backend
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _AppointmentCard(
                time: '--:--',
                period: '--',
                title: '--',
                subtitle: '--',
                hasVideo: false,
              ),
              const SizedBox(width: 12),
              _AppointmentCard(
                time: '--:--',
                period: '--',
                title: '--',
                subtitle: '--',
                hasVideo: false,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK TASKS',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Message input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    // TODO: Handle message submission
                    _messageController.clear();
                  },
                  style: TextStyle(color: context.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Message Agent...',
                    hintStyle: TextStyle(
                      color: context.textSecondary.withOpacity(0.5),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Handle send button
                  if (_messageController.text.isNotEmpty) {
                    _messageController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: context.gold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.cardBorder, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.phone_outlined,
                label: 'Call Logs',
                isSelected: _selectedNavIndex == 0,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(bottomNavRoute(const CallLogsScreen()));
                },
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                isSelected: _selectedNavIndex == 1,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(bottomNavRoute(const CalendarScreen()));
                },
              ),
              // Center mic button
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 2),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.cardBg,
                    border: Border.all(
                      color: _selectedNavIndex == 2
                          ? context.gold
                          : context.cardBorder,
                      width: 2,
                    ),
                    boxShadow: _selectedNavIndex == 2
                        ? [
                            BoxShadow(
                              color: context.gold.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.mic_outlined,
                    color: _selectedNavIndex == 2
                        ? context.gold
                        : context.textSecondary,
                    size: 32,
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.check_circle_outline,
                label: 'Tasks',
                isSelected: _selectedNavIndex == 3,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(bottomNavRoute(const TasksScreen()));
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: _selectedNavIndex == 4,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    bottomNavRoute(const ProfileSettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;
  final Color orbBgColor;

  _OrbPainter({
    required this.animationValue,
    required this.isActive,
    required this.orbBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.38;

    // Animated rings (only when active)
    if (isActive) {
      const int numRings = 3;
      for (int i = 0; i < numRings; i++) {
        final ringPhase = (animationValue + i / numRings) % 1.0;
        final ringRadius = radius * (1.1 + ringPhase * 0.5);
        final opacity = (1.0 - ringPhase).clamp(0.0, 1.0);
        final fadeOpacity = opacity * opacity * 0.25;

        if (fadeOpacity > 0.01) {
          final circlePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0 * (1.0 - ringPhase * 0.5)
            ..color = Color.fromRGBO(190, 138, 82, fadeOpacity);

          canvas.drawCircle(center, ringRadius, circlePaint);
        }
      }
    }

    // Static outer rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x15A07040);

    canvas.drawCircle(center, radius * 1.55, ringPaint);
    canvas.drawCircle(center, radius * 1.35, ringPaint);

    // Orb body
    final orbPaint = Paint()..color = orbBgColor;
    canvas.drawCircle(center, radius, orbPaint);

    // Copper-gold rim glow
    if (isActive) {
      final rimGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..shader = SweepGradient(
          colors: const [
            Color(0x00000000),
            Color(0x40C47830),
            Color(0x80D4883C),
            Color(0x40C47830),
            Color(0x00000000),
            Color(0x00000000),
            Color(0x40C47830),
            Color(0x80D4883C),
            Color(0x40C47830),
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
          transform: GradientRotation(animationValue * 2 * math.pi),
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, rimGlow);
    }

    // Bright rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          const Color(0x00000000),
          Color(isActive ? 0x55C47830 : 0x25C47830),
          Color(isActive ? 0xDDD4883C : 0x55D4883C),
          Color(isActive ? 0x55C47830 : 0x25C47830),
          const Color(0x00000000),
          const Color(0x00000000),
          Color(isActive ? 0x55C47830 : 0x25C47830),
          Color(isActive ? 0xDDD4883C : 0x55D4883C),
          Color(isActive ? 0x55C47830 : 0x25C47830),
          const Color(0x00000000),
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
        transform: const GradientRotation(0.8),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 1, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isActive != isActive ||
      oldDelegate.orbBgColor != orbBgColor;
}

class _EqualizerBars extends StatefulWidget {
  final bool isActive;

  const _EqualizerBars({required this.isActive});

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
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
    const barColor = Color(0xFFBE8A52);
    const barWidth = 6.0;
    const spacing = 5.0;

    final barConfigs = [
      [10.0, 24.0, 2.3, 0.0],
      [14.0, 36.0, 1.7, 0.4],
      [18.0, 44.0, 2.0, 0.2],
      [14.0, 36.0, 1.9, 0.6],
      [10.0, 24.0, 2.1, 0.8],
    ];
    final opacities = [0.75, 0.85, 1.0, 0.85, 0.75];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barConfigs.length, (index) {
            final config = barConfigs[index];
            final minH = config[0];
            final maxH = config[1];
            final freq = config[2];
            final phase = config[3];

            double height;
            if (widget.isActive) {
              final t = _controller.value * 2 * math.pi;
              final wave1 = math.sin(t * freq + phase * math.pi);
              final wave2 = math.sin(t * freq * 1.5 + phase * math.pi + 0.5);
              final combined = (wave1 * 0.6 + wave2 * 0.4 + 1) / 2;
              height = minH + (maxH - minH) * combined;
            } else {
              height = minH;
            }

            return Row(
              children: [
                if (index > 0) SizedBox(width: spacing),
                Opacity(
                  opacity: widget.isActive ? opacities[index] : 0.3,
                  child: Container(
                    width: barWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(barWidth / 2),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String time;
  final String period;
  final String title;
  final String subtitle;
  final bool hasVideo;

  const _AppointmentCard({
    required this.time,
    required this.period,
    required this.title,
    required this.subtitle,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  period,
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (hasVideo)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.cardBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.videocam_outlined,
                    color: context.textSecondary,
                    size: 18,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: context.cardBorder),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: context.textSecondary.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? context.gold
                  : context.textSecondary.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.gold
                    : context.textSecondary.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
