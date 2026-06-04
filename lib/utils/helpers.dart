import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';

/// Returns a time-based greeting string.
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

/// Formats a DateTime to a readable date string.
String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Formats a DateTime to a readable time string.
String formatTime(DateTime date) {
  final hour = date.hour > 12
      ? date.hour - 12
      : date.hour == 0
          ? 12
          : date.hour;
  final period = date.hour >= 12 ? 'PM' : 'AM';
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

/// Calculates distance between two GPS coordinates in meters.
/// Uses the Haversine formula.
double calculateDistance(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const earthRadius = 6371000.0; // meters
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * pi / 180;

/// Returns the status color for station status.
Color getStatusColor(StationStatus status) {
  switch (status) {
    case StationStatus.reported:
      return AppColors.green;
    case StationStatus.missing:
      return AppColors.red;
    case StationStatus.pendingSync:
      return AppColors.yellow;
  }
}

/// Calculates compliance percentage.
double calculateCompliance(int reported, int total) {
  if (total == 0) return 0;
  return (reported / total) * 100;
}
