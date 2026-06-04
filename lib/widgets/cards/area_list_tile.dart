import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/widgets/common/status_chip.dart';
import 'package:rainfall_app/models/station_model.dart';

/// Reusable list tile for area drill-down (village/block/district rows).
class AreaListTile extends StatelessWidget {

  final String title;
  final String subtitle;
  final int totalStations;
  final int reportedStations;
  final StationStatus worstStatus; // Overall status indicator
  final VoidCallback? onTap;

  const AreaListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totalStations,
    required this.reportedStations,
    required this.worstStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: worstStatus.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: worstStatus.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: status + count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: worstStatus),
                const SizedBox(height: 6),
                Text(
                  '$reportedStations/$totalStations',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
