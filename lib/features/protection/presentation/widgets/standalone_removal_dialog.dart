import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Confirmation dialog gating standalone (partnerless) app removal.
///
/// Requires the user to wait out a countdown and type the confirmation phrase
/// before removal is allowed. This is the primary anti-accidental-removal
/// friction for students without an active accountability partner.
class StandaloneRemovalDialog extends StatefulWidget {
  const StandaloneRemovalDialog({
    super.key,
    this.countdownSeconds = 10,
    this.confirmPhrase = 'HAPUS',
  });

  final int countdownSeconds;
  final String confirmPhrase;

  @override
  State<StandaloneRemovalDialog> createState() => _StandaloneRemovalDialogState();
}

class _StandaloneRemovalDialogState extends State<StandaloneRemovalDialog> {
  late int _remaining;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  String? _mismatchError;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _gateOpen =>
      _remaining <= 0 && _controller.text.trim() == widget.confirmPhrase;

  void _confirm() {
    if (_remaining > 0) return;
    if (_controller.text.trim() != widget.confirmPhrase) {
      setState(() => _mismatchError = widget.confirmPhrase);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.protectionStandaloneRemovalTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.protectionStandaloneRemovalBody(
                widget.confirmPhrase,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.protectionStandaloneRemovalCountdown(_remaining),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              enabled: _remaining <= 0,
              autofocus: _remaining <= 0,
              onChanged: (_) {
                if (_mismatchError != null) {
                  setState(() => _mismatchError = null);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.confirmPhrase,
                errorText: _mismatchError == null
                    ? null
                    : l10n.protectionStandaloneRemovalPhraseMismatch(
                        widget.confirmPhrase,
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _gateOpen ? _confirm : null,
          child: Text(l10n.protectionStandaloneRemovalButton),
        ),
      ],
    );
  }
}
