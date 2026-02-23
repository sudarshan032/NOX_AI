import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nox_ai/core/constants/app_routes.dart';
import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/core/utils/page_transitions.dart';
import 'package:nox_ai/features/calls/screens/call_detail_screen.dart';
import 'package:nox_ai/features/calls/screens/make_call_sheet.dart';
import 'package:nox_ai/providers/app_providers.dart';

class CallLogsScreen extends ConsumerStatefulWidget {
  const CallLogsScreen({super.key});

  @override
  ConsumerState<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends ConsumerState<CallLogsScreen> {
  int _selectedNavIndex = 0;
  int _selectedFilter = 0; // 0: All, 1: Connected, 2: No Answer, 3: Failed, 4: Inbound

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _callLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    try {
      final calls = await ref.read(callsRepositoryProvider).listCalls();
      if (!mounted) return;
      setState(() {
        _callLogs = calls.map((c) {
          final dt = c.startedAt ?? c.createdAt;
          return {
            'id': c.id,
            'number': c.phoneNumber ?? '--',
            'date': DateFormat('MMM dd, yyyy').format(dt).toUpperCase(),
            'time': DateFormat('hh:mm a').format(dt),
            'status': _mapStatus(c.status),
            'duration': c.durationDisplay == '--' ? null : c.durationDisplay,
            'type': c.direction == 'inbound' ? 'incoming' : 'outgoing',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'completed': return 'connected';
      case 'no_answer': return 'no_answer';
      case 'failed': return 'failed';
      default: return status;
    }
  }

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

  void _showMakeCallSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const MakeCallSheet(),
      ),
    );
    if (result == true) {
      _loadCalls(); // Refresh list after call initiated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title row with Make Call button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CALL LOGS',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showMakeCallSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call, color: context.bg, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'CALL',
                            style: TextStyle(
                              color: context.bg,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter tabs
            _buildFilterTabs(),

            const SizedBox(height: 16),

            // Search bar
            _buildSearchBar(),

            const SizedBox(height: 8),

            // Call logs list or empty state
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(context.gold),
                        strokeWidth: 2.5,
                      ),
                    )
                  : _filteredLogs.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadCalls,
                          color: context.gold,
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMakeCallSheet,
        backgroundColor: context.gold,
        child: Icon(Icons.call, color: context.bg),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardBg,
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Icon(
                Icons.phone_outlined,
                color: context.textSecondary.withOpacity(0.5),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No calls yet',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first AI call by tapping\nthe button below',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary.withOpacity(0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _showMakeCallSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: context.gold,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: context.bg, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'MAKE A CALL',
                      style: TextStyle(
                        color: context.bg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                onTap: () => context.go(AppRoutes.tasks),
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
