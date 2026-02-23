import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nox_ai/core/constants/app_routes.dart';
import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/core/theme/theme_provider.dart';
import 'package:nox_ai/providers/app_providers.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  int _selectedNavIndex = 4;

  String _selectedPersonality = 'Executive';
  bool _notificationsEnabled = true;
  bool _callNotifications = true;
  bool _taskReminders = true;
  bool _calendarAlerts = true;
  String _selectedLanguage = 'English (US)';
  String _userName = '--';
  String _userPhone = '--';

  bool _googleCalendarConnected = false;
  bool _gmailConnected = false;
  bool _whatsappConnected = false;

  final Map<String, bool> _appIntegrations = {
    'Microsoft Outlook': false,
    'Slack': false,
    'Zoom': false,
    'Salesforce': false,
  };

  bool _voiceRecording = true;
  bool _callTranscription = true;
  bool _dataAnalytics = true;
  bool _personalizedSuggestions = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await ref.read(userRepositoryProvider).getMe();
      if (mounted) {
        setState(() {
          _userName = user.name ?? '--';
          _userPhone = user.phoneNumber;
          _googleCalendarConnected = user.calendarConnected;
          _gmailConnected = user.gmailConnected;
          _whatsappConnected = user.whatsappOptIn;
        });
      }
    } catch (_) {}
  }

  Future<void> _connectGoogle() async {
    try {
      final url = await ref.read(calendarRepositoryProvider).getGoogleAuthUrl();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _signOut() async {
    await ref.read(authStateProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.createAccount);
  }

  String _getAppearanceName() {
    switch (ThemeProvider().themeMode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'ACCOUNT',
                  style: TextStyle(
                    color: context.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 24),

                // Profile card
                _buildProfileCard(),

                const SizedBox(height: 32),

                // AI Configuration section
                _buildSectionTitle('AI CONFIGURATION'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _SettingsItem(
                    icon: Icons.auto_awesome_outlined,
                    label: 'AI Personality',
                    value: _selectedPersonality,
                    onTap: () => _showAIPersonalitySheet(),
                  ),
                  _SettingsItem(
                    icon: Icons.public_outlined,
                    label: 'Memory Vault',
                    value: '142 Facts',
                    onTap: () => context.go(AppRoutes.memories),
                  ),
                ]),

                const SizedBox(height: 24),

                // Preferences section
                _buildSectionTitle('PREFERENCES'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _SettingsItem(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notifications',
                    value: _notificationsEnabled ? 'On' : 'Off',
                    onTap: () => _showNotificationsSheet(),
                  ),
                  _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Appearance',
                    value: _getAppearanceName(),
                    onTap: () => _showAppearanceSheet(),
                  ),
                  _SettingsItem(
                    icon: Icons.phone_android_outlined,
                    label: 'App Integrations',
                    value:
                        '${_appIntegrations.values.where((v) => v).length + (_googleCalendarConnected ? 1 : 0) + (_gmailConnected ? 1 : 0) + (_whatsappConnected ? 1 : 0)} Active',
                    onTap: () => _showAppIntegrationsSheet(),
                  ),
                ]),

                const SizedBox(height: 24),

                // Account & Security section
                _buildSectionTitle('ACCOUNT & SECURITY'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    label: 'Privacy & Permissions',
                    onTap: () => _showPrivacySheet(),
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    value: _selectedLanguage,
                    onTap: () => _showLanguageSheet(),
                  ),
                ]),

                const SizedBox(height: 24),

                // Support section
                _buildSectionTitle('SUPPORT'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _SettingsItem(
                    icon: Icons.help_outline,
                    label: 'Help Center',
                    onTap: () => _showHelpCenterSheet(),
                  ),
                  _SettingsItem(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    isSignOut: true,
                    onTap: () => _showSignOutDialog(),
                  ),
                ]),

                const SizedBox(height: 32),

                // Version
                Center(
                  child: Text(
                    'NOX AI V1.0.4',
                    style: TextStyle(
                      color: context.textSecondary.withOpacity(0.5),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.bg,
              border: Border.all(
                color: context.gold.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(Icons.person_outline, color: context.gold, size: 28),
          ),

          const SizedBox(width: 16),

          // Name and plan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName.toUpperCase(),
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: context.gold.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'PREMIUM PLAN',
                  style: TextStyle(
                    color: context.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.textSecondary.withOpacity(0.7),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _buildSettingsRow(item),
              if (!isLast)
                Divider(color: context.cardBorder, height: 1, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsRow(_SettingsItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Icon(
              item.icon,
              color: item.isSignOut ? AppColors.signOutRed : context.gold,
              size: 22,
            ),

            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: item.isSignOut
                      ? AppColors.signOutRed
                      : context.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Value and chevron
            if (item.value != null) ...[
              Text(
                item.value!,
                style: TextStyle(
                  color: context.textSecondary.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
            ],

            if (!item.isSignOut)
              Icon(
                Icons.chevron_right,
                color: context.textSecondary.withOpacity(0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== SUB-CATEGORY BOTTOM SHEETS ====================

  void _showAIPersonalitySheet() {
    final personalities = [
      {'name': 'Executive', 'desc': 'Formal, efficient, business-focused'},
      {'name': 'Professional', 'desc': 'Balanced, clear, and courteous'},
      {'name': 'Friendly', 'desc': 'Warm, conversational, approachable'},
      {'name': 'Casual', 'desc': 'Relaxed, informal, easy-going'},
      {'name': 'Concise', 'desc': 'Brief, direct, to-the-point'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetContainer(
        title: 'AI Personality',
        child: Column(
          children: personalities.map((p) {
            final isSelected = _selectedPersonality == p['name'];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedPersonality = p['name']!);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.gold.withOpacity(0.1)
                      : context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? context.gold : context.cardBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name']!,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['desc']!,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: context.gold, size: 24),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => _buildBottomSheetContainer(
          title: 'Notifications',
          child: Column(
            children: [
              _buildToggleRow(
                'All Notifications',
                'Master toggle for all notifications',
                _notificationsEnabled,
                (val) {
                  setSheetState(() {
                    _notificationsEnabled = val;
                    if (!val) {
                      _callNotifications = false;
                      _taskReminders = false;
                      _calendarAlerts = false;
                    }
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Divider(color: context.cardBorder),
              const SizedBox(height: 8),
              _buildToggleRow(
                'Call Notifications',
                'Alerts for incoming and missed calls',
                _callNotifications && _notificationsEnabled,
                _notificationsEnabled
                    ? (val) {
                        setSheetState(() => _callNotifications = val);
                        setState(() {});
                      }
                    : null,
              ),
              _buildToggleRow(
                'Task Reminders',
                'Reminders for upcoming tasks',
                _taskReminders && _notificationsEnabled,
                _notificationsEnabled
                    ? (val) {
                        setSheetState(() => _taskReminders = val);
                        setState(() {});
                      }
                    : null,
              ),
              _buildToggleRow(
                'Calendar Alerts',
                'Notifications for scheduled events',
                _calendarAlerts && _notificationsEnabled,
                _notificationsEnabled
                    ? (val) {
                        setSheetState(() => _calendarAlerts = val);
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceSheet() {
    final themeProvider = ThemeProvider();
    final currentMode = themeProvider.themeMode;

    final appearances = [
      {
        'name': 'Dark',
        'icon': Icons.dark_mode_outlined,
        'mode': ThemeMode.dark,
      },
      {
        'name': 'Light',
        'icon': Icons.light_mode_outlined,
        'mode': ThemeMode.light,
      },
      {
        'name': 'System',
        'icon': Icons.settings_brightness_outlined,
        'mode': ThemeMode.system,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return _buildBottomSheetContainer(
            title: 'Appearance',
            child: Column(
              children: appearances.map((a) {
                final isSelected = currentMode == a['mode'];
                return GestureDetector(
                  onTap: () {
                    themeProvider.setThemeMode(a['mode'] as ThemeMode);
                    Navigator.pop(sheetContext);
                    setState(() {}); // Rebuild main screen
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.gold.withOpacity(0.1)
                          : context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? context.gold : context.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          a['icon'] as IconData,
                          color: isSelected
                              ? context.gold
                              : context.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            a['name'] as String,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: context.gold,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _disconnectGoogle() async {
    try {
      await ref.read(calendarRepositoryProvider).disconnectGoogle();
      if (mounted) {
        setState(() {
          _googleCalendarConnected = false;
          _gmailConnected = false;
        });
      }
    } catch (_) {}
  }

  void _showAppIntegrationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => _buildBottomSheetContainer(
          title: 'App Integrations',
          child: Column(
            children: [
              // Google Calendar
              _buildIntegrationRow(
                icon: Icons.calendar_today_outlined,
                title: 'Google Calendar',
                subtitle: _googleCalendarConnected ? 'Connected' : 'Not connected',
                isConnected: _googleCalendarConnected,
                onTap: () {
                  if (_googleCalendarConnected) {
                    _disconnectGoogle();
                    setSheetState(() {});
                  } else {
                    _connectGoogle();
                    Navigator.pop(context);
                  }
                },
              ),

              // Gmail
              _buildIntegrationRow(
                icon: Icons.mail_outline,
                title: 'Gmail',
                subtitle: _gmailConnected ? 'Connected' : 'Not connected',
                isConnected: _gmailConnected,
                onTap: () {
                  if (!_gmailConnected) {
                    _connectGoogle(); // Same OAuth flow covers both
                    Navigator.pop(context);
                  }
                },
              ),

              // WhatsApp
              _buildIntegrationRow(
                icon: Icons.chat_outlined,
                title: 'WhatsApp',
                subtitle: _whatsappConnected ? 'Connected' : 'Not connected',
                isConnected: _whatsappConnected,
                onTap: () {
                  setSheetState(() => _whatsappConnected = !_whatsappConnected);
                  setState(() {});
                },
              ),

              const SizedBox(height: 8),
              Divider(color: context.cardBorder),
              const SizedBox(height: 8),

              // Other integrations
              ..._appIntegrations.entries.map((entry) {
                return _buildToggleRow(
                  entry.key,
                  entry.value ? 'Connected' : 'Not connected',
                  entry.value,
                  (val) {
                    setSheetState(() => _appIntegrations[entry.key] = val);
                    setState(() {});
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegrationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isConnected ? context.gold.withOpacity(0.08) : context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected ? context.gold.withOpacity(0.4) : context.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isConnected ? context.gold : context.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isConnected ? context.gold : context.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected ? context.gold.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected ? context.gold : context.cardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                isConnected ? 'DISCONNECT' : 'CONNECT',
                style: TextStyle(
                  color: isConnected ? context.gold : context.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => _buildBottomSheetContainer(
          title: 'Privacy & Permissions',
          child: Column(
            children: [
              _buildToggleRow(
                'Voice Recording',
                'Allow NOX to record calls for analysis',
                _voiceRecording,
                (val) {
                  setSheetState(() => _voiceRecording = val);
                  setState(() {});
                },
              ),
              _buildToggleRow(
                'Call Transcription',
                'Automatically transcribe call audio',
                _callTranscription,
                (val) {
                  setSheetState(() => _callTranscription = val);
                  setState(() {});
                },
              ),
              _buildToggleRow(
                'Data Analytics',
                'Help improve NOX with usage data',
                _dataAnalytics,
                (val) {
                  setSheetState(() => _dataAnalytics = val);
                  setState(() {});
                },
              ),
              _buildToggleRow(
                'Personalized Suggestions',
                'AI-powered recommendations',
                _personalizedSuggestions,
                (val) {
                  setSheetState(() => _personalizedSuggestions = val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to data management
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.cardBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.signOutRed,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Delete My Data',
                          style: TextStyle(
                            color: AppColors.signOutRed,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.textSecondary.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    final languages = [
      'English (US)',
      'English (UK)',
      'Spanish',
      'French',
      'German',
      'Portuguese',
      'Italian',
      'Japanese',
      'Chinese (Simplified)',
      'Korean',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetContainer(
        title: 'Language',
        child: Column(
          children: languages.map((lang) {
            final isSelected = _selectedLanguage == lang;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.gold.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: context.gold, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: context.gold, size: 22),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHelpCenterSheet() {
    final helpItems = [
      {
        'icon': Icons.menu_book_outlined,
        'title': 'User Guide',
        'subtitle': 'Learn how to use NOX',
      },
      {
        'icon': Icons.live_help_outlined,
        'title': 'FAQs',
        'subtitle': 'Frequently asked questions',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Contact Support',
        'subtitle': 'Get help from our team',
      },
      {
        'icon': Icons.bug_report_outlined,
        'title': 'Report a Bug',
        'subtitle': 'Help us improve',
      },
      {
        'icon': Icons.star_outline,
        'title': 'Rate NOX',
        'subtitle': 'Share your feedback',
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Terms of Service',
        'subtitle': 'Legal information',
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'subtitle': 'How we handle your data',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetContainer(
        title: 'Help Center',
        child: Column(
          children: helpItems.map((item) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to specific help page
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cardBorder, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: context.gold,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.textSecondary.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.cardBorder, width: 1),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your NOX account?',
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
              Navigator.pop(context);
              _signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.signOutRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildBottomSheetContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: context.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: context.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool)? onChanged,
  ) {
    final isDisabled = onChanged == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDisabled
                        ? context.textSecondary
                        : context.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(
                      isDisabled ? 0.5 : 0.7,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.gold,
            activeTrackColor: context.gold.withOpacity(0.3),
            inactiveThumbColor: context.textSecondary,
            inactiveTrackColor: context.cardBorder,
          ),
        ],
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
                onTap: () => setState(() => _selectedNavIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final bool isSignOut;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.isSignOut = false,
    required this.onTap,
  });
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
    const textSecondary = Color(0xFFB7A58B);
    const gold = Color(0xFFBE8A52);

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
              color: isSelected ? gold : textSecondary.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? gold : textSecondary.withOpacity(0.6),
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
