import 'package:flutter/material.dart';

import '../../../../core/widgets/app_busy_indicator.dart';

/// A fixed-height primary action with a consistent busy state for auth forms.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const AppBusyIndicator(
              size: 22,
              color: Colors.white,
              trackColor: Color(0x55FFFFFF),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
