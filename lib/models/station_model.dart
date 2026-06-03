import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';

/// Status of a rainfall station's daily reporting.
enum StationStatus {
  reported,    // Green — data submitted today
  missing,     // Red — no data received today
  pendingSync, // Yellow — data entered but not uploaded
}

/// Extension for display and color properties of station status.
extension StationStatusExtension on StationStatus {
  String get displayName {
    switch (this) {
      case StationStatus.reported:
        return 'Reported';
      case StationStatus.missing:
        return 'Missing';
      case StationStatus.pendingSync:
        return 'Pending Sync';
    }
  }

  Color get color {
    switch (this) {
      case StationStatus.reported:
        return AppColors.green;
      case StationStatus.missing:
        return AppColors.red;
      case StationStatus.pendingSync:
        return AppColors.yellow;
    }
  }

  IconData get icon {
    switch (this) {
      case StationStatus.reported:
        return Icons.check_circle;
      case StationStatus.missing:
        return Icons.error;
      case StationStatus.pendingSync:
        return Icons.sync;
    }
  }
}

/// Represents a rainfall monitoring station.
class StationModel {
  final String id;
  final String name;
  final String villageId;
  final String villageName;
  final String blockId;
  final String blockName;
  final String districtId;
  final double lat;
  final double lng;
  final StationStatus status;
  final double? todayRainfall; // mm, null if not reported
  final String? lastSubmission; // e.g. "Yesterday • 22 mm"

  const StationModel({
    required this.id,
    required this.name,
    required this.villageId,
    required this.villageName,
    required this.blockId,
    required this.blockName,
    required this.districtId,
    required this.lat,
    required this.lng,
    required this.status,
    this.todayRainfall,
    this.lastSubmission,
  });
}
