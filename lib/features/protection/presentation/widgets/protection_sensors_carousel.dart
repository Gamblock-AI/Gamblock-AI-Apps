import 'package:flutter/material.dart';
import '../../domain/entities/protection_status.dart';
import 'protection_sensors_grid.dart';

/// Legacy alias for [ProtectionSensorsGrid].
class ProtectionSensorsCarousel extends StatelessWidget {
  const ProtectionSensorsCarousel({super.key, required this.status});

  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    return ProtectionSensorsGrid(status: status);
  }
}
