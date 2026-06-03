/// Sync status for offline-first rainfall entries.
enum SyncStatus {
  synced,
  pending,
  failed,
}

/// Represents a single rainfall data submission.
class RainfallEntry {
  final String id;
  final String stationId;
  final double rainfall; // in mm
  final DateTime timestamp;
  final double lat;
  final double lng;
  final String? remarks;
  final SyncStatus syncStatus;

  const RainfallEntry({
    required this.id,
    required this.stationId,
    required this.rainfall,
    required this.timestamp,
    required this.lat,
    required this.lng,
    this.remarks,
    this.syncStatus = SyncStatus.synced,
  });

  String get formattedTime {
    final hour = timestamp.hour > 12
        ? timestamp.hour - 12
        : timestamp.hour == 0
            ? 12
            : timestamp.hour;
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }
}
