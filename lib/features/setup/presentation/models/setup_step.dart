import 'package:flutter/material.dart';

/// Immutable presentation data for one setup checklist item.
class SetupStep {
  const SetupStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.isComplete,
    this.onAction,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool isComplete;
  final VoidCallback? onAction;
  final String? actionLabel;
}
