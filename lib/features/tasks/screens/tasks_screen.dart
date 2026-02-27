import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nox_ai/core/constants/app_routes.dart';
import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/data/models/task_model.dart';
import 'package:nox_ai/providers/app_providers.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _selectedDateFilter = 1; // 0=Yesterday, 1=Today, 2=Tomorrow
  int _selectedNavIndex = 3;

  final TextEditingController _messageController = TextEditingController();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await ref.read(tasksRepositoryProvider).listTasks();
      if (mounted) setState(() { _tasks = tasks; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SizedBox(height: 20),
            Text(
              'TASKS',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 20),

            // Date filter tabs
            _buildDateFilterTabs(),

            const SizedBox(height: 24),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasks section based on selected date filter
                    _buildTasksSection(),

                    const SizedBox(height: 24),

                    // Upcoming section
                    _buildUpcomingSection(),

                    const SizedBox(height: 24),

                    // Quick Tasks section
                    _buildQuickTasksSection(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDateFilterTabs() {
    final tabs = ['YESTERDAY', 'TODAY', 'TOMORROW'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedDateFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDateFilter = index),
              child: Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 6,
                  right: index == tabs.length - 1 ? 0 : 6,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? context.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? context.gold : context.cardBorder,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? context.bg : context.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTasksSection() {
    // Section title based on selected filter
    final sectionTitles = ['YESTERDAY', 'DUE TODAY', 'TOMORROW'];
    final sectionTitle = sectionTitles[_selectedDateFilter];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Task cards based on selected date filter
        ..._getTasksForFilter(),
      ],
    );
  }

  List<Widget> _getTasksForFilter() {
    if (_isLoading) {
      return [const Center(child: CircularProgressIndicator())];
    }

    // Filter tasks by date based on selected tab
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    List<TaskModel> filtered;
    switch (_selectedDateFilter) {
      case 0: // Yesterday
        filtered = _tasks.where((t) {
          final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
          return d == yesterday;
        }).toList();
      case 2: // Tomorrow
        filtered = _tasks.where((t) {
          if (t.preferredDate == null) return false;
          try {
            final d = DateTime.parse(t.preferredDate!);
            return DateTime(d.year, d.month, d.day) == tomorrow;
          } catch (_) { return false; }
        }).toList();
      default: // Today (active tasks created today or with today's preferred date)
        filtered = _tasks.where((t) {
          if (!t.isActive) return false;
          // Show if created today
          final created = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
          if (created == today) return true;
          // Show if preferred date is today
          if (t.preferredDate != null) {
            try {
              final d = DateTime.parse(t.preferredDate!);
              if (DateTime(d.year, d.month, d.day) == today) return true;
            } catch (_) {}
          }
          return false;
        }).toList();
    }

    if (filtered.isEmpty) {
      return [
        Center(
          child: Text(
            'No tasks',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < filtered.length; i++) {
      final task = filtered[i];
      if (i > 0) widgets.add(const SizedBox(height: 12));
      widgets.add(_TaskCard(
        title: task.displayTitle,
        subtitle: task.description.isNotEmpty ? task.description : '--',
        priority: _priorityLabel(task.status),
        showPriority: task.status != 'created',
        isCompleted: task.isCompleted,
      ));
    }
    return widgets;
  }

  String? _priorityLabel(String status) {
    switch (status) {
      case 'calling': return 'ACTIVE';
      case 'awaiting_approval': return 'PENDING';
      case 'completed': return null;
      case 'failed': return 'FAILED';
      default: return null;
    }
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
                onTap: () => context.go(AppRoutes.callLogs),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                isSelected: _selectedNavIndex == 1,
                onTap: () => context.go(AppRoutes.calendar),
              ),
              // Center mic button
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
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
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: _selectedNavIndex == 4,
                onTap: () => context.go(AppRoutes.profileSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? priority;
  final bool showPriority;
  final bool showDot;
  final bool isCompleted;
  final Color? priorityColor;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    this.priority,
    this.showPriority = false,
    this.showDot = false,
    this.isCompleted = false,
    this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF81C784);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          // Checkbox circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? green.withOpacity(0.2) : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? green
                    : context.textSecondary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(Icons.check, color: green, size: 18)
                : null,
          ),

          const SizedBox(width: 14),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted
                        ? context.textSecondary.withOpacity(0.5)
                        : context.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(
                      isCompleted ? 0.4 : 0.7,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Priority badge or dot
          if (showPriority && priority != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor?.withOpacity(0.2) ?? context.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priority!,
                style: TextStyle(
                  color: priorityColor ?? context.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (showDot)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.gold.withOpacity(0.7),
              ),
            ),
        ],
      ),
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
