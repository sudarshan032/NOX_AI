import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/providers/app_providers.dart';
import 'package:nox_ai/data/models/call_model.dart';

class CallDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> callData;

  const CallDetailScreen({super.key, required this.callData});

  @override
  ConsumerState<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends ConsumerState<CallDetailScreen> {
  int _selectedTab = 0; // 0: AI Summary, 1: Transcript
  bool _isPlaying = false;
  final double _playbackProgress = 0.0;

  // Parsed from real API data
  TranscriptModel? _transcript;
  bool _isLoading = true;
  String? _error;

  // Parsed transcript messages
  List<Map<String, String>> _messages = [];
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _loadTranscript();
  }

  Future<void> _loadTranscript() async {
    final callId = widget.callData['id'] as String?;
    if (callId == null || callId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No call ID provided';
      });
      return;
    }

    try {
      final callsRepo = ref.read(callsRepositoryProvider);
      final transcript = await callsRepo.getTranscript(callId);
      if (mounted) {
        setState(() {
          _transcript = transcript;
          _isLoading = false;
          if (transcript != null) {
            _summary = transcript.summary ?? 'No summary available.';
            _messages = _parseTranscript(transcript.fullText ?? '');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load transcript';
        });
      }
    }
  }

  /// Parse "Caller: ...\nAssistant: ..." format into speaker/message list
  List<Map<String, String>> _parseTranscript(String fullText) {
    if (fullText.isEmpty) return [];
    final lines = fullText.split('\n');
    final messages = <Map<String, String>>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('Caller:')) {
        messages.add({
          'speaker': 'Caller',
          'message': trimmed.substring(7).trim(),
        });
      } else if (trimmed.startsWith('Assistant:')) {
        messages.add({
          'speaker': 'AI Agent',
          'message': trimmed.substring(10).trim(),
        });
      } else {
        // Continuation of previous message or unknown format
        if (messages.isNotEmpty) {
          messages.last['message'] = '${messages.last['message']!} $trimmed';
        } else {
          messages.add({'speaker': 'Unknown', 'message': trimmed});
        }
      }
    }
    return messages;
  }

  String get _callerName {
    return widget.callData['number'] as String?
        ?? widget.callData['phone_number'] as String?
        ?? 'Unknown Caller';
  }

  String get _callDirection {
    final type = widget.callData['type'] as String?
        ?? widget.callData['direction'] as String?
        ?? 'outgoing';
    return type == 'incoming' || type == 'inbound' ? 'Incoming Call' : 'Outgoing Call';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: context.gold),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileAvatar(),
                          const SizedBox(height: 16),
                          _buildCallerInfo(),
                          const SizedBox(height: 24),
                          _buildTabSwitcher(),
                          const SizedBox(height: 20),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else if (_transcript == null)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No transcript available for this call.',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else ...[
                            if (_selectedTab == 0) _buildAISummaryContent(),
                            if (_selectedTab == 1) _buildTranscriptContent(),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.share_outlined,
                  color: context.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
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
          _callerName,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _callDirection,
          style: TextStyle(
            color: context.textSecondary.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
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
    return Container(
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
                'AI Summary',
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
            _summary,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptContent() {
    if (_messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No transcript messages.',
          style: TextStyle(color: context.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: _messages.map((entry) {
        final isAgent = entry['speaker'] == 'AI Agent';
        return _TranscriptMessage(
          speaker: entry['speaker']!,
          message: entry['message']!,
          isAgent: isAgent,
        );
      }).toList(),
    );
  }
}

class _TranscriptMessage extends StatelessWidget {
  final String speaker;
  final String message;
  final bool isAgent;

  const _TranscriptMessage({
    required this.speaker,
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
          Row(
            mainAxisAlignment: isAgent
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Text(
                speaker.toUpperCase(),
                style: TextStyle(
                  color: isAgent ? context.textSecondary : context.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
