import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/providers/app_providers.dart';

class MakeCallSheet extends ConsumerStatefulWidget {
  const MakeCallSheet({super.key});

  @override
  ConsumerState<MakeCallSheet> createState() => _MakeCallSheetState();
}

class _MakeCallSheetState extends ConsumerState<MakeCallSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  String _selectedCode = '+91';
  bool _isLoading = false;

  static const _countryCodes = ['+91', '+1', '+44', '+61', '+971', '+65', '+86'];

  @override
  void dispose() {
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _makeCall() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final fullNumber = '$_selectedCode$phone';

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(callsRepositoryProvider).makeOutboundCall(
        phoneNumber: fullNumber,
        context: {
          if (_purposeController.text.trim().isNotEmpty)
            'reason_for_call': _purposeController.text.trim(),
        },
      );

      if (!mounted) return;

      final provider = result['provider'] ?? 'pipecat';
      final voiceBotUrl = result['voice_bot_url'] as String?;

      if (provider == 'pipecat' && voiceBotUrl != null && voiceBotUrl.isNotEmpty) {
        // Show Pipecat browser dialog
        _showPipecatDialog(voiceBotUrl, result['message'] ?? '');
      } else {
        // Phone call initiated
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Call initiated successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to initiate call: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPipecatDialog(String url, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ctx.cardBorder),
        ),
        title: Row(
          children: [
            Icon(Icons.open_in_browser, color: ctx.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Browser Voice Call',
                style: TextStyle(color: ctx.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: ctx.textSecondary, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ctx.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ctx.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: TextStyle(color: ctx.gold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text('URL copied'),
                          backgroundColor: ctx.gold,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.copy, color: ctx.textSecondary, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text('Close', style: TextStyle(color: ctx.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) Navigator.pop(context, true);
            },
            child: Text('Open in Browser', style: TextStyle(color: ctx.gold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Icon(Icons.call_outlined, color: context.gold, size: 22),
                const SizedBox(width: 10),
                Text(
                  'MAKE A CALL',
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
                  child: Icon(Icons.close, color: context.textSecondary, size: 24),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone number input
                Text(
                  'PHONE NUMBER',
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Country code dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCode,
                          dropdownColor: context.cardBg,
                          style: TextStyle(color: context.textPrimary, fontSize: 16),
                          items: _countryCodes.map((code) {
                            return DropdownMenuItem(value: code, child: Text(code));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCode = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.cardBorder),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: context.textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Purpose field
                Text(
                  'PURPOSE (OPTIONAL)',
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.cardBorder),
                  ),
                  child: TextField(
                    controller: _purposeController,
                    maxLines: 3,
                    style: TextStyle(color: context.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Schedule a dentist appointment...',
                      hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Call button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _makeCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.gold,
                      foregroundColor: context.bg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(context.bg),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.call, size: 20, color: context.bg),
                              const SizedBox(width: 10),
                              Text(
                                'INITIATE AI CALL',
                                style: TextStyle(
                                  color: context.bg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
