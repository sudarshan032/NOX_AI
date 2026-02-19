import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

class CallDetailScreen extends StatefulWidget {
  final Map<String, dynamic> callData;

  const CallDetailScreen({super.key, required this.callData});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  int _selectedTab = 0; // 0: AI Summary, 1: Transcript
  bool _isPlaying = false;
  final double _playbackProgress = 0.3; // Demo progress

  // TODO: Fetch call details from backend API
  // This is sample data for UI template
  final Map<String, dynamic> _callDetails = {
    'callerName': 'Alexandra Hamilton',
    'phoneNumber': '+1 (415) 555-0199',
    'callType': 'Incoming Call',
    'duration': '12m 04s',
    'audioDuration': '04:20',
    'successScore': 92,
    'sentiment': 'Positive',
    'executiveSummary':
        'Alexandra called to confirm the rescheduling of the Q3 board meeting. She expressed concerns about the timeline but was reassured by the AI agent regarding the new deliverables.',
    'keyOutcomes': [
      'Meeting rescheduled to March 14th, 2024 at 2:00 PM.',
      'Updated calendar invite sent to all stakeholders.',
      'Action: Send revised agenda PDF by Friday.',
    ],
    'flaggedByAI':
        'Caller mentioned "budget constraints" twice during negotiation phase.',
    'transcript': [
      {
        'speaker': 'AI Agent',
        'time': '10:45 AM',
        'message':
            "Good morning, this is Harrison's executive assistant. How may I help you today?",
      },
      {
        'speaker': 'Alexandra',
        'time': '10:45 AM',
        'message':
            "Hi, I'm calling about the board meeting scheduled for next Tuesday. I need to move it.",
      },
      {
        'speaker': 'AI Agent',
        'time': '10:46 AM',
        'message':
            "I can certainly help with that. Looking at Harrison's calendar, would Thursday the 14th at 2 PM work for you?",
      },
      {
        'speaker': 'Alexandra',
        'time': '10:46 AM',
        'message':
            "That actually works perfectly. Is the budget report still required beforehand?",
      },
      {
        'speaker': 'AI Agent',
        'time': '10:47 AM',
        'message':
            "Yes, Harrison would like to review the figures 24 hours prior. I can flag that as a priority task for you.",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Profile avatar
                    _buildProfileAvatar(),

                    const SizedBox(height: 16),

                    // Caller info
                    _buildCallerInfo(),

                    const SizedBox(height: 24),

                    // Audio player
                    _buildAudioPlayer(),

                    const SizedBox(height: 24),

                    // Tab switcher
                    _buildTabSwitcher(),

                    const SizedBox(height: 20),

                    // Tab content
                    if (_selectedTab == 0) _buildAISummaryContent(),
                    if (_selectedTab == 1) _buildTranscriptContent(),

                    const SizedBox(height: 24),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Icon(
                Icons.chevron_left,
                color: context.textPrimary,
                size: 24,
              ),
            ),
          ),

          // Right actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Share functionality
                },
                child: Icon(
                  Icons.share_outlined,
                  color: context.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // TODO: More options
                },
                child: Icon(
                  Icons.more_vert,
                  color: context.textPrimary,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.cardBg,
        border: Border.all(color: context.cardBorder, width: 2),
      ),
      child: Icon(Icons.person_outline, color: context.textSecondary, size: 40),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        Text(
          _callDetails['callerName'],
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_callDetails['phoneNumber']} • ${_callDetails['callType']} • ${_callDetails['duration']}',
          style: TextStyle(
            color: context.textSecondary.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.gold,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: context.bg,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Waveform visualization
          Expanded(child: _buildWaveform()),

          const SizedBox(width: 12),

          // Duration
          Text(
            _callDetails['audioDuration'],
            style: TextStyle(
              color: context.gold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    // Simple waveform representation
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(30, (index) {
          // Create varied heights for waveform effect
          final heights = [
            3.0,
            6.0,
            4.0,
            8.0,
            5.0,
            12.0,
            8.0,
            15.0,
            10.0,
            18.0,
            12.0,
            20.0,
            15.0,
            22.0,
            18.0,
            20.0,
            15.0,
            18.0,
            12.0,
            15.0,
            10.0,
            12.0,
            8.0,
            10.0,
            6.0,
            8.0,
            5.0,
            6.0,
            4.0,
            3.0,
          ];
          final height = heights[index % heights.length];
          final isPlayed = index < (_playbackProgress * 30);

          return Container(
            width: 2,
            height: height,
            decoration: BoxDecoration(
              color: isPlayed
                  ? context.gold
                  : context.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 0
                          ? context.gold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'AI SUMMARY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0
                        ? context.gold
                        : context.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 1
                          ? context.gold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'TRANSCRIPT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1
                        ? context.gold
                        : context.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryContent() {
    return Column(
      children: [
        // Score cards row
        Row(
          children: [
            // Success Score
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: context.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'SUCCESS SCORE',
                          style: TextStyle(
                            color: context.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_callDetails['successScore']}%',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Sentiment
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_alt,
                          color: context.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SENTIMENT',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _callDetails['sentiment'].toUpperCase(),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Executive Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: context.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Executive Summary',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _callDetails['executiveSummary'],
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Key Outcomes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: context.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Key Outcomes',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(_callDetails['keyOutcomes'] as List<String>).map((outcome) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          outcome,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Flagged by AI
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.flaggedRed.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.flaggedRed.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: const Color(0xFFE57373),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FLAGGED BY AI',
                    style: TextStyle(
                      color: const Color(0xFFE57373),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _callDetails['flaggedByAI'],
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptContent() {
    final transcript = _callDetails['transcript'] as List<Map<String, dynamic>>;

    return Column(
      children: transcript.map((entry) {
        final isAgent = entry['speaker'] == 'AI Agent';
        return _TranscriptMessage(
          speaker: entry['speaker'],
          time: entry['time'],
          message: entry['message'],
          isAgent: isAgent,
        );
      }).toList(),
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
                isSelected: false,
                onTap: () {
                  // Call back
                },
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                isSelected: false,
                onTap: () {
                  // Schedule follow-up
                },
              ),
              // Center mic button
              GestureDetector(
                onTap: () {
                  // Voice interaction
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
                icon: Icons.mail_outline,
                isSelected: false,
                onTap: () {
                  // Send email
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                isSelected: false,
                onTap: () {
                  // View contact
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranscriptMessage extends StatelessWidget {
  final String speaker;
  final String time;
  final String message;
  final bool isAgent;

  const _TranscriptMessage({
    required this.speaker,
    required this.time,
    required this.message,
    required this.isAgent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isAgent
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // Speaker and time
          Row(
            mainAxisAlignment: isAgent
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (!isAgent) ...[
                Text(
                  time,
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                speaker.toUpperCase(),
                style: TextStyle(
                  color: isAgent ? context.textSecondary : context.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              if (isAgent) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAgent ? context.cardBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAgent
                    ? context.cardBorder
                    : context.gold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Icon(
          icon,
          color: isSelected
              ? context.gold
              : context.textSecondary.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }
}
