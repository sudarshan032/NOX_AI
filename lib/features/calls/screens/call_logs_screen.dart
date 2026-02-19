import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/features/home/screens/home_screen.dart';
import 'package:nox_ai/features/tasks/screens/tasks_screen.dart';
import 'package:nox_ai/features/calendar/screens/calendar_screen.dart';
import 'package:nox_ai/features/calls/screens/call_detail_screen.dart';
import 'package:nox_ai/features/profile/screens/profile_settings_screen.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  int _selectedNavIndex = 0; // Logs tab selected
  int _selectedFilter =
      0; // 0: All, 1: Connected, 2: No Answer, 3: Failed, 4: Inbound

  final TextEditingController _searchController = TextEditingController();

  // TODO: Fetch call logs from backend API
  // This is sample/placeholder data for UI template
  // Replace with actual API call: await CallLogsService.fetchLogs()
  final List<Map<String, dynamic>> _callLogs = [
    {
      'number': '+91 76750 53840',
      'date': 'FEB 13, 2026',
      'time': '10:45 AM',
      'status': 'connected',
      'duration': '12m 4s',
      'type': 'outgoing',
    },
    {
      'number': '+91 76750 53840',
      'date': 'FEB 10, 2026',
      'time': '09:12 AM',
      'status': 'no_answer',
      'duration': null,
      'type': 'outgoing',
    },
    {
      'number': '+1 415 555 0199',
      'date': 'FEB 10, 2026',
      'time': '04:30 PM',
      'status': 'connected',
      'duration': '4m 22s',
      'type': 'incoming',
    },
    {
      'number': '+91 76750 53840',
      'date': 'FEB 09, 2026',
      'time': '02:15 PM',
      'status': 'connected',
      'duration': '1h 05m',
      'type': 'outgoing',
    },
    {
      'number': '+91 76750 53840',
      'date': 'FEB 08, 2026',
      'time': '11:20 AM',
      'status': 'failed',
      'duration': null,
      'type': 'outgoing',
    },
  ];

  List<Map<String, dynamic>> get _filteredLogs {
    final searchQuery = _searchController.text.toLowerCase();

    return _callLogs.where((log) {
      // Filter by status/type
      if (_selectedFilter == 1 && log['status'] != 'connected') return false;
      if (_selectedFilter == 2 && log['status'] != 'no_answer') return false;
      if (_selectedFilter == 3 && log['status'] != 'failed') return false;
      if (_selectedFilter == 4 && log['type'] != 'incoming') return false;

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final number = (log['number'] as String).toLowerCase();
        if (!number.contains(searchQuery)) return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            Text(
              'CALL LOGS',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 20),

            // Filter tabs
            _buildFilterTabs(),

            const SizedBox(height: 16),

            // Search bar
            _buildSearchBar(),

            const SizedBox(height: 8),

            // Call logs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredLogs.length,
                itemBuilder: (context, index) {
                  return _CallLogItem(
                    data: _filteredLogs[index],
                    onTap: () {
                      Navigator.of(context).push(
                        fadeSlideRoute(
                          CallDetailScreen(callData: _filteredLogs[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterTab(
            label: 'ALL',
            isSelected: _selectedFilter == 0,
            onTap: () => setState(() => _selectedFilter = 0),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: 'CONNECTED',
            isSelected: _selectedFilter == 1,
            onTap: () => setState(() => _selectedFilter = 1),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: 'NO ANSWER',
            isSelected: _selectedFilter == 2,
            onTap: () => setState(() => _selectedFilter = 2),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: 'FAILED',
            isSelected: _selectedFilter == 3,
            onTap: () => setState(() => _selectedFilter = 3),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: 'INBOUND',
            isSelected: _selectedFilter == 4,
            onTap: () => setState(() => _selectedFilter = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: context.textPrimary, fontSize: 16),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search logs',
            hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.textSecondary.withOpacity(0.5),
            ),
          ),
        ),
      ),
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
                onTap: () => setState(() => _selectedNavIndex = 0),
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
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(bottomNavRoute(const HomeScreen()));
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.cardBg,
                    border: Border.all(color: context.cardBorder, width: 2),
                  ),
                  child: Icon(
                    Icons.mic_outlined,
                    color: context.textSecondary,
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

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.gold : context.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.bg : context.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _CallLogItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const _CallLogItem({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    const failedRed = Color(0xFFD4614A);

    final status = data['status'] as String;
    final type = data['type'] as String;
    final duration = data['duration'] as String?;

    // Determine icon and colors based on call type and status
    IconData callIcon;

    if (status == 'failed') {
      callIcon = Icons.phone_disabled_outlined;
    } else if (status == 'no_answer') {
      callIcon = Icons.call_missed_outgoing;
    } else if (type == 'incoming') {
      callIcon = Icons.call_received;
    } else {
      callIcon = Icons.call_made;
    }

    // Status badge styling
    String statusText;
    Color statusColor;
    Color statusBorderColor;

    switch (status) {
      case 'connected':
        statusText = 'CONNECTED';
        statusColor = context.gold.withOpacity(0.1);
        statusBorderColor = context.gold.withOpacity(0.4);
        break;
      case 'no_answer':
        statusText = 'NO ANSWER';
        statusColor = Colors.transparent;
        statusBorderColor = context.cardBorder;
        break;
      case 'failed':
        statusText = 'FAILED';
        statusColor = failedRed.withOpacity(0.1);
        statusBorderColor = failedRed.withOpacity(0.4);
        break;
      default:
        statusText = status.toUpperCase();
        statusColor = Colors.transparent;
        statusBorderColor = context.cardBorder;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            // Call icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardBg,
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Icon(
                callIcon,
                color: status == 'failed' ? failedRed : context.gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Phone number and date/time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['number'] ?? '',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['date']} • ${data['time']}',
                    style: TextStyle(
                      color: context.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge and duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusBorderColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: status == 'failed'
                          ? failedRed
                          : (status == 'connected'
                                ? context.gold
                                : context.textSecondary),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (duration != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    duration,
                    style: TextStyle(
                      color: context.gold.withOpacity(0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
