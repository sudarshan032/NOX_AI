import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: Fetch notifications from backend API
  // Sample data for UI template
  final List<Map<String, dynamic>> _notifications = [
    // Today
    {
      'id': '1',
      'type': 'missed_call',
      'title': 'Missed Call',
      'description': 'You missed a call from +1 (415) 555-0199',
      'timestamp': '10 min ago',
      'timeGroup': 'Today',
      'isRead': false,
      'data': {'phoneNumber': '+1 (415) 555-0199'},
    },
    {
      'id': '2',
      'type': 'task_reminder',
      'title': 'Task Due Soon',
      'description': 'Review Q3 Strategy Document is due in 1 hour',
      'timestamp': '25 min ago',
      'timeGroup': 'Today',
      'isRead': false,
      'data': {'taskId': 'task_123'},
    },
    {
      'id': '3',
      'type': 'ai_agent',
      'title': 'Call Completed',
      'description':
          'NOX successfully handled call with Alexandra Hamilton. Summary ready.',
      'timestamp': '1h ago',
      'timeGroup': 'Today',
      'isRead': true,
      'data': {'callId': 'call_456'},
    },
    {
      'id': '4',
      'type': 'calendar',
      'title': 'Upcoming Meeting',
      'description': 'Board Review starts in 30 minutes',
      'timestamp': '2h ago',
      'timeGroup': 'Today',
      'isRead': true,
      'data': {'eventId': 'event_789'},
    },
    // Yesterday
    {
      'id': '5',
      'type': 'ai_agent',
      'title': 'New Memory Added',
      'description':
          'NOX saved "Client Renewal Preference" from your call with TechCorp',
      'timestamp': 'Yesterday, 4:30 PM',
      'timeGroup': 'Yesterday',
      'isRead': true,
      'data': {'memoryId': 'mem_101'},
    },
    {
      'id': '6',
      'type': 'completed_call',
      'title': 'Call Summary Ready',
      'description':
          'Transcript and AI summary available for call with Marcus Chen',
      'timestamp': 'Yesterday, 2:15 PM',
      'timeGroup': 'Yesterday',
      'isRead': true,
      'data': {'callId': 'call_102'},
    },
    {
      'id': '7',
      'type': 'task_completed',
      'title': 'Task Completed',
      'description': 'NOX marked "Send proposal to client" as complete',
      'timestamp': 'Yesterday, 11:00 AM',
      'timeGroup': 'Yesterday',
      'isRead': true,
      'data': {'taskId': 'task_103'},
    },
    // Earlier
    {
      'id': '8',
      'type': 'system',
      'title': 'Weekly Summary',
      'description':
          'Your NOX agent handled 23 calls and completed 15 tasks this week',
      'timestamp': 'Feb 15, 2026',
      'timeGroup': 'Earlier',
      'isRead': true,
      'data': {},
    },
    {
      'id': '9',
      'type': 'calendar',
      'title': 'Event Rescheduled',
      'description': 'Q3 Planning Session moved to March 14th at 2:00 PM',
      'timestamp': 'Feb 14, 2026',
      'timeGroup': 'Earlier',
      'isRead': true,
      'data': {'eventId': 'event_104'},
    },
    {
      'id': '10',
      'type': 'ai_agent',
      'title': 'Integration Connected',
      'description': 'Google Calendar successfully linked to your NOX account',
      'timestamp': 'Feb 12, 2026',
      'timeGroup': 'Earlier',
      'isRead': true,
      'data': {},
    },
  ];

  int get _unreadCount =>
      _notifications.where((n) => !(n['isRead'] as bool)).length;

  Map<String, List<Map<String, dynamic>>> get _groupedNotifications {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final notification in _notifications) {
      final group = notification['timeGroup'] as String;
      grouped[group]?.add(notification);
    }

    return grouped;
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.cardBorder, width: 1),
        ),
        title: Text(
          'Clear All Notifications',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _notifications.clear());
              Navigator.pop(context);
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.missedRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Content
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.chevron_left,
              color: context.textSecondary,
              size: 28,
            ),
          ),

          const SizedBox(width: 8),

          // Title with badge
          Expanded(
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.gold.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$_unreadCount new',
                      style: TextStyle(
                        color: context.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (_notifications.isNotEmpty) ...[
            GestureDetector(
              onTap: _markAllAsRead,
              child: Icon(
                Icons.done_all,
                color: context.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _clearAllNotifications,
              child: Icon(
                Icons.delete_outline,
                color: context.textSecondary,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: context.cardBorder, width: 1),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              color: context.textSecondary.withOpacity(0.5),
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: context.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    final grouped = _groupedNotifications;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Today
        if (grouped['Today']!.isNotEmpty) ...[
          _buildTimeGroupHeader('Today'),
          ...grouped['Today']!.map((n) => _buildNotificationItem(n)),
          const SizedBox(height: 16),
        ],

        // Yesterday
        if (grouped['Yesterday']!.isNotEmpty) ...[
          _buildTimeGroupHeader('Yesterday'),
          ...grouped['Yesterday']!.map((n) => _buildNotificationItem(n)),
          const SizedBox(height: 16),
        ],

        // Earlier
        if (grouped['Earlier']!.isNotEmpty) ...[
          _buildTimeGroupHeader('Earlier'),
          ...grouped['Earlier']!.map((n) => _buildNotificationItem(n)),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTimeGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.textSecondary.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final isRead = notification['isRead'] as bool;

    // Get icon and color based on type
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'missed_call':
        icon = Icons.phone_missed;
        iconColor = AppColors.missedRed;
        break;
      case 'completed_call':
        icon = Icons.phone_callback;
        iconColor = AppColors.successGreen;
        break;
      case 'task_reminder':
        icon = Icons.access_time;
        iconColor = context.gold;
        break;
      case 'task_completed':
        icon = Icons.check_circle_outline;
        iconColor = AppColors.successGreen;
        break;
      case 'calendar':
        icon = Icons.calendar_today_outlined;
        iconColor = AppColors.infoBlue;
        break;
      case 'ai_agent':
        icon = Icons.auto_awesome;
        iconColor = context.gold;
        break;
      case 'system':
        icon = Icons.info_outline;
        iconColor = context.textSecondary;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = context.textSecondary;
    }

    return GestureDetector(
      onTap: () {
        _markAsRead(notification['id']);
        _handleNotificationTap(notification);
      },
      child: Dismissible(
        key: Key(notification['id']),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.missedRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.delete_outline,
            color: AppColors.missedRed,
            size: 24,
          ),
        ),
        onDismissed: (direction) {
          setState(() {
            _notifications.removeWhere((n) => n['id'] == notification['id']);
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? context.cardBg : context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? context.cardBorder
                  : context.gold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['description'],
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['timestamp'],
                      style: TextStyle(
                        color: context.textSecondary.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String;

    // TODO: Navigate to relevant screen based on notification type
    // Examples:
    // - missed_call, completed_call -> Call detail screen
    // - task_reminder, task_completed -> Tasks screen
    // - calendar -> Calendar screen
    // - ai_agent (memory) -> Memory vault
    // - system -> Show info dialog

    switch (type) {
      case 'missed_call':
      case 'completed_call':
        // Navigate to call logs or call detail
        break;
      case 'task_reminder':
      case 'task_completed':
        // Navigate to tasks screen
        break;
      case 'calendar':
        // Navigate to calendar screen
        break;
      case 'ai_agent':
        // Navigate based on data (memory, call summary, etc.)
        break;
      case 'system':
        _showSystemNotificationDetail(notification);
        break;
    }
  }

  void _showSystemNotificationDetail(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, color: context.gold, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              notification['title'],
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              notification['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification['timestamp'],
              style: TextStyle(
                color: context.textSecondary.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Got It',
                      style: TextStyle(
                        color: context.bg,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
