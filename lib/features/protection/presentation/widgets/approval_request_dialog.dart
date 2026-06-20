import 'package:flutter/material.dart';

/// Confirmation dialog for submitting an uninstall/pause approval request to
/// the accountability partner (PRD §5). Calls [onConfirm] when approved.
class ApprovalRequestDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const ApprovalRequestDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajukan Izin Pencopotan'),
      content: const Text(
          'Permohonan ini akan dikirim ke Accountability Partner Anda untuk disetujui. '
          'Aplikasi tetap terkunci sampai ada persetujuan.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}
