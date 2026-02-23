import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nox_ai/core/constants/app_routes.dart';
import 'package:nox_ai/core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedNavIndex = 1; // Calendar tab selected

  late DateTime _currentMonth;
  late DateTime _selectedDate;
  int? _selectedTimeSlotStart; // Selected start slot (hour * 60 + minute)
  int? _selectedTimeSlotEnd; // Selected end slot (hour * 60 + minute)
  bool _isDragging = false;
  int? _dragStartSlot;

  // ScrollController for timeline
  final ScrollController _timelineScrollController = ScrollController();

  // Placeholder events - TODO: Replace with API data
  // ignore: unused_field
  final Map<int, List<Map<String, String>>> _events = {};

  // Event history storage - keyed by "YYYY-MM-DD_slotStart_slotEnd"
  // Events are stored after saving and become history once past
  final Map<String, Map<String, dynamic>> _eventHistory = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;

    // Initialize with sample history for demo (past events today)
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    // Add sample past events (e.g., morning meeting at 9:00-9:30)
    if (now.hour > 9) {
      _eventHistory['${dateKey}_540_570'] = {
        'title': 'Team standup',
        'startSlot': 540, // 9:00
        'endSlot': 570, // 9:30
      };
    }
    if (now.hour > 10) {
      _eventHistory['${dateKey}_600_660'] = {
        'title': 'Project review',
        'startSlot': 600, // 10:00
        'endSlot': 660, // 11:00
      };
    }

    // Auto-scroll to current time on initial load
    _scrollTimelineToTop(_selectedDate);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _scrollTimelineToTop(DateTime date) {
    // Wait for the next frame to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timelineScrollController.hasClients) {
        final now = DateTime.now();
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        if (isToday) {
          // For today, scroll to current time position
          // Each hour slot has variable heights, approximate scroll position
          final currentSlot = now.hour * 60 + now.minute;
          // Approximate: ~20px for hour markers, ~4px for minute markers
          // Average ~6px per slot for rough calculation
          final scrollPosition = (currentSlot * 5.0).clamp(
            0.0,
            _timelineScrollController.position.maxScrollExtent,
          );
          _timelineScrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          // For other dates, scroll to top
          _timelineScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Month navigation header
            _buildMonthHeader(),

            const SizedBox(height: 20),

            // Calendar grid
            _buildCalendarGrid(),

            const SizedBox(height: 16),

            // Selected date header
            _buildSelectedDateHeader(),

            // Timeline view
            Expanded(child: _buildTimelineView()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMonthHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = monthNames[_currentMonth.month - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _previousMonth,
            child: Icon(Icons.chevron_left, color: context.gold, size: 32),
          ),
          Text(
            '$monthName ${_currentMonth.year}',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: _nextMonth,
            child: Icon(Icons.chevron_right, color: context.gold, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Build calendar rows
    List<Widget> rows = [];

    // Days row
    List<Widget> currentRow = [];

    // Add empty cells for days before the 1st
    for (int i = 0; i < startingWeekday; i++) {
      currentRow.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isToday =
          DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final hasEvent = _hasEventOnDay(day);

      currentRow.add(
        Expanded(
          child: _CalendarDay(
            day: day,
            isSelected: isSelected,
            isToday: isToday,
            hasEvent: hasEvent,
            eventInfo: _getEventInfoForDay(day),
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlotStart =
                    null; // Reset time slot when date changes
                _selectedTimeSlotEnd = null;
              });
              // Auto-scroll timeline to top (or current time for today)
              _scrollTimelineToTop(date);
            },
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: currentRow),
          ),
        );
        currentRow = [];
      }
    }

    // Add remaining cells
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const Expanded(child: SizedBox()));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: currentRow),
        ),
      );
    }

    return Column(children: rows);
  }

  bool _hasEventOnDay(int day) {
    // Placeholder - return false for now, events will come from backend
    return false;
  }

  Map<String, String>? _getEventInfoForDay(int day) {
    // Placeholder - return null for now, events will come from backend
    return null;
  }

  Widget _buildSelectedDateHeader() {
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = weekdays[_selectedDate.weekday % 7];
    final month = months[_selectedDate.month - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$weekday, $month ${_selectedDate.day}, ${_selectedDate.year}',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  String _formatSlotTime(int slot) {
    final hour = slot ~/ 60;
    final minute = slot % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int? _parseTimeToSlot(String time) {
    // Parse time string like "14:30" to slot number
    final regex = RegExp(r'^(\d{1,2}):?(\d{0,2})$');
    final match = regex.firstMatch(time.trim());
    if (match != null) {
      final hour = int.tryParse(match.group(1) ?? '') ?? -1;
      final minute = int.tryParse(match.group(2) ?? '') ?? 0;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return hour * 60 + minute;
      }
    }
    return null;
  }

  Map<String, dynamic>? _getHistoryEventAtSlot(String dateKey, int slot) {
    // Check if any history event spans this slot
    for (final entry in _eventHistory.entries) {
      if (entry.key.startsWith(dateKey)) {
        final event = entry.value;
        final startSlot = event['startSlot'] as int?;
        final endSlot = event['endSlot'] as int?;
        if (startSlot != null && endSlot != null) {
          if (slot >= startSlot && slot <= endSlot) {
            return event;
          }
        }
      }
    }
    return null;
  }

  void _showHistoryEventDialog(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // History badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        color: context.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Past Event',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Event title
                Text(
                  event['title'] ?? 'Untitled Event',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Time range
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: context.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatSlotTime(event['startSlot'] ?? 0)} - ${_formatSlotTime((event['endSlot'] ?? 0) + 1)}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentSlot = currentHour * 60 + currentMinute;

    // Check if selected date is today
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    // Check if selected date is in the past
    final isPastDate = _selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );

    // Get history events for this date
    final dateKey =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    // Always show full day (0-1440), but restrict selection based on time
    const startSlot = 0;
    const endSlot = 24 * 60; // 1440 slots total (24 hours * 60 minutes)

    // Generate all slots for the day
    final slots = List.generate(
      endSlot - startSlot,
      (index) => startSlot + index,
    );

    return GestureDetector(
      onVerticalDragStart: (details) {
        // Not used directly, handled per slot
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      child: SingleChildScrollView(
        controller: _timelineScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ...slots.map((slotValue) {
              final hour = slotValue ~/ 60;
              final minute = slotValue % 60;
              final timeLabel =
                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

              // Check if current time line should appear in this slot
              final showCurrentTimeLine =
                  isToday && currentHour == hour && currentMinute == minute;

              // Check if this slot is within selected range
              final isInRange =
                  _selectedTimeSlotStart != null &&
                  _selectedTimeSlotEnd != null &&
                  slotValue >= _selectedTimeSlotStart! &&
                  slotValue <= _selectedTimeSlotEnd!;

              final isRangeStart = slotValue == _selectedTimeSlotStart;
              final isRangeEnd = slotValue == _selectedTimeSlotEnd;

              // Determine if this slot is in the past
              final bool isSlotPast =
                  isPastDate || (isToday && slotValue < currentSlot);

              // Check for history events at this slot
              final historyEvent = _getHistoryEventAtSlot(dateKey, slotValue);

              // Placeholder event slot - TODO: Replace with API data
              final hasEvent = historyEvent != null;

              return _TimelineSlot(
                time: timeLabel,
                showCurrentTimeLine: showCurrentTimeLine,
                currentMinute: currentMinute,
                isSelected: isInRange,
                isRangeStart: isRangeStart,
                isRangeEnd: isRangeEnd,
                selectedStartTime:
                    isRangeStart && _selectedTimeSlotStart != null
                    ? _formatSlotTime(_selectedTimeSlotStart!)
                    : null,
                selectedEndTime: isRangeEnd && _selectedTimeSlotEnd != null
                    ? _formatSlotTime(_selectedTimeSlotEnd! + 1)
                    : null,
                event: hasEvent ? historyEvent : null,
                isPast: isSlotPast,
                onTap: isSlotPast
                    ? (historyEvent != null
                          ? () => _showHistoryEventDialog(historyEvent)
                          : null)
                    : () {
                        if (isInRange) {
                          // Tapped on selected range - show quick task dialog
                          _showQuickTaskDialog();
                        } else {
                          // Select single slot
                          setState(() {
                            _selectedTimeSlotStart = slotValue;
                            _selectedTimeSlotEnd = slotValue;
                          });
                        }
                      },
                onDragStart: isSlotPast
                    ? null
                    : () {
                        setState(() {
                          _isDragging = true;
                          _dragStartSlot = slotValue;
                          _selectedTimeSlotStart = slotValue;
                          _selectedTimeSlotEnd = slotValue;
                        });
                      },
                onDragUpdate: isSlotPast
                    ? null
                    : (slot) {
                        if (_isDragging && _dragStartSlot != null) {
                          // Prevent dragging into past slots
                          final validSlot = isToday && slot < currentSlot
                              ? currentSlot
                              : slot;
                          setState(() {
                            if (validSlot >= _dragStartSlot!) {
                              _selectedTimeSlotStart = _dragStartSlot;
                              _selectedTimeSlotEnd = validSlot;
                            } else {
                              _selectedTimeSlotStart = validSlot;
                              _selectedTimeSlotEnd = _dragStartSlot;
                            }
                          });
                        }
                      },
                slotValue: slotValue,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showQuickTaskDialog() {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController(
      text: _formatSlotTime(_selectedTimeSlotStart ?? 0),
    );
    final TextEditingController endTimeController = TextEditingController(
      text: _formatSlotTime((_selectedTimeSlotEnd ?? 0) + 1),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time range display
                    Text(
                      'New Event',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Editable time range inputs
                    Row(
                      children: [
                        // Start time input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.gold.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: startTimeController,
                              style: TextStyle(
                                color: context.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                hintText: 'HH:MM',
                                hintStyle: TextStyle(
                                  color: context.textSecondary.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                prefixIcon: Icon(
                                  Icons.play_arrow,
                                  color: context.gold.withOpacity(0.6),
                                  size: 18,
                                ),
                              ),
                              onChanged: (value) {
                                // Parse and update start time
                                final slot = _parseTimeToSlot(value);
                                if (slot != null) {
                                  setState(() {
                                    _selectedTimeSlotStart = slot;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '—',
                            style: TextStyle(
                              color: context.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        // End time input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.gold.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: endTimeController,
                              style: TextStyle(
                                color: context.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                hintText: 'HH:MM',
                                hintStyle: TextStyle(
                                  color: context.textSecondary.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                prefixIcon: Icon(
                                  Icons.stop,
                                  color: context.gold.withOpacity(0.6),
                                  size: 18,
                                ),
                              ),
                              onChanged: (value) {
                                // Parse and update end time
                                final slot = _parseTimeToSlot(value);
                                if (slot != null && slot > 0) {
                                  setState(() {
                                    _selectedTimeSlotEnd = slot - 1;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Message Agent input field
                    Container(
                      decoration: BoxDecoration(
                        color: context.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.cardBorder, width: 1),
                      ),
                      child: TextField(
                        controller: taskController,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message Agent...',
                          hintStyle: TextStyle(
                            color: context.textSecondary.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.auto_awesome,
                            color: context.gold.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons row
                    Row(
                      children: [
                        // Mic button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement voice input
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: context.bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.cardBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_outlined,
                                    color: context.gold,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Voice',
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Save button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Save event to history
                              if (_selectedTimeSlotStart != null &&
                                  _selectedTimeSlotEnd != null) {
                                final dateKey =
                                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                                final eventKey =
                                    '${dateKey}_${_selectedTimeSlotStart}_$_selectedTimeSlotEnd';
                                setState(() {
                                  _eventHistory[eventKey] = {
                                    'title': taskController.text.isNotEmpty
                                        ? taskController.text
                                        : 'Event',
                                    'startSlot': _selectedTimeSlotStart,
                                    'endSlot': _selectedTimeSlotEnd,
                                  };
                                  // Clear selection
                                  _selectedTimeSlotStart = null;
                                  _selectedTimeSlotEnd = null;
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.gold.withOpacity(0.8),
                                    context.gold.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: context.bg,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      color: context.bg,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                onTap: () => setState(() => _selectedNavIndex = 1),
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

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasEvent;
  final Map<String, String>? eventInfo;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasEvent,
    this.eventInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            // Day number with selection circle
            Container(
              width: 36,
              height: 36,
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          context.gold.withOpacity(0.4),
                          context.gold.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      border: Border.all(
                        color: context.gold.withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.gold.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? context.gold
                        : (isToday ? context.gold : context.textPrimary),
                    fontSize: 16,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Event indicator bar
            if (hasEvent)
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: context.gold.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 4),

            // Event info preview (if any)
            if (eventInfo != null) ...[
              const SizedBox(height: 2),
              Text(
                eventInfo!['time'] ?? '',
                style: TextStyle(
                  color: context.textSecondary.withOpacity(0.7),
                  fontSize: 8,
                ),
              ),
              Text(
                eventInfo!['title'] ?? '',
                style: TextStyle(color: context.textSecondary, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineSlot extends StatelessWidget {
  final String time;
  final bool showCurrentTimeLine;
  final int currentMinute;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final Map<String, dynamic>? event;
  final VoidCallback? onTap;
  final VoidCallback? onDragStart;
  final Function(int)? onDragUpdate;
  final int slotValue;
  final bool isPast;

  const _TimelineSlot({
    required this.time,
    required this.showCurrentTimeLine,
    required this.currentMinute,
    this.isSelected = false,
    this.isRangeStart = false,
    this.isRangeEnd = false,
    this.selectedStartTime,
    this.selectedEndTime,
    this.event,
    this.onTap,
    this.onDragStart,
    this.onDragUpdate,
    required this.slotValue,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    const pastColor = Color(0xFF4A4A42); // Dimmed color for past slots

    // Slot represents minute, so slotValue % 60 == 0 is on the hour
    final isOnHour = slotValue % 60 == 0;
    final isOn15Min = slotValue % 15 == 0;
    final isOn5Min = slotValue % 5 == 0;

    // Use dimmed colors for past slots
    final slotTextColor = isPast ? pastColor : context.textSecondary;
    final slotLineColor = isPast
        ? pastColor.withOpacity(0.3)
        : context.cardBorder;

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) {
        onDragStart?.call();
      },
      onLongPressMoveUpdate: (details) {
        // Calculate which minute slot we're in based on vertical movement
        final dy = details.localOffsetFromOrigin.dy;
        final slotOffset = (dy / 4).round(); // 4px per minute slot
        final newSlot = slotValue + slotOffset;
        if (newSlot >= 0 && newSlot < 1440) {
          onDragUpdate?.call(newSlot);
        }
      },
      onVerticalDragStart: (_) {
        onDragStart?.call();
      },
      onVerticalDragUpdate: (details) {
        final dy = details.localPosition.dy;
        final slotOffset = (dy / 4).round();
        final newSlot = slotValue + slotOffset;
        if (newSlot >= 0 && newSlot < 1440) {
          onDragUpdate?.call(newSlot);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: isOnHour
            ? 20
            : (isOn15Min ? 12 : (isOn5Min ? 6 : 4)), // Variable height
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection highlight with range styling
            if (isSelected)
              Positioned(
                top: isRangeStart ? 1 : 0,
                left: 50,
                right: 0,
                bottom: isRangeEnd ? 1 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.vertical(
                      top: isRangeStart
                          ? const Radius.circular(4)
                          : Radius.zero,
                      bottom: isRangeEnd
                          ? const Radius.circular(4)
                          : Radius.zero,
                    ),
                    border: Border(
                      left: BorderSide(
                        color: context.gold.withOpacity(0.6),
                        width: 3,
                      ),
                      top: isRangeStart
                          ? BorderSide(
                              color: context.gold.withOpacity(0.4),
                              width: 1,
                            )
                          : BorderSide.none,
                      right: BorderSide(
                        color: context.gold.withOpacity(0.4),
                        width: 1,
                      ),
                      bottom: isRangeEnd
                          ? BorderSide(
                              color: context.gold.withOpacity(0.4),
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: isRangeStart && selectedStartTime != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            selectedStartTime!,
                            style: TextStyle(
                              color: context.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
              ),

            // Start time indicator at top of selection
            if (isRangeStart && selectedStartTime != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: context.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedStartTime!,
                        style: TextStyle(
                          color: context.bg,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 2, color: context.gold)),
                  ],
                ),
              ),

            // End time indicator at bottom of selection
            if (isRangeEnd && selectedEndTime != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: context.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedEndTime!,
                        style: TextStyle(
                          color: context.bg,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 2, color: context.gold)),
                  ],
                ),
              ),

            // Time label and line
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 55,
                  child: (isOnHour || isOn15Min)
                      ? Text(
                          time,
                          style: TextStyle(
                            color: slotTextColor.withOpacity(
                              isPast ? 0.5 : 0.7,
                            ),
                            fontSize: isOnHour ? 11 : 10,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Container(
                    height: isOnHour
                        ? 1
                        : (isOn15Min ? 0.5 : (isOn5Min ? 0.3 : 0)),
                    margin: const EdgeInsets.only(top: 4),
                    color: isOnHour
                        ? slotLineColor
                        : slotLineColor.withOpacity(isOn15Min ? 0.4 : 0.2),
                  ),
                ),
              ],
            ),

            // History event indicator for past slots
            if (isPast && event != null && isOnHour)
              Positioned(
                top: 2,
                left: 55,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pastColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: pastColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, color: pastColor, size: 10),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event!['title'] ?? 'Past event',
                          style: TextStyle(
                            color: pastColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Current time indicator
            if (showCurrentTimeLine)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: context.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: context.bg,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 2, color: context.gold)),
                  ],
                ),
              ),

            // Event card (only show on range start for multi-slot events)
            if (event != null && isRangeStart)
              Positioned(
                top: 4,
                left: 55,
                right: 0,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: context.gold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    event!['title'] ?? '--',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
