import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/widgets/common/status_chip.dart';

class BlockStationsScreen extends StatelessWidget {
  final UserModel user;

  const BlockStationsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final block = MockData.getBlock(user.assignedAreaId);
    final blockStations = MockData.getStationsForBlock(block.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${block.name} — Stations')),
      body: Column(
        children: [
          // FILTER CHIPS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _filterChip('All', blockStations.length, AppColors.primary),
                const SizedBox(width: 8),
                _filterChip('Reported', MockData.countReported(blockStations), AppColors.green),
                const SizedBox(width: 8),
                _filterChip('Missing', MockData.countMissing(blockStations), AppColors.red),
                const SizedBox(width: 8),
                _filterChip('Pending', MockData.countPending(blockStations), AppColors.yellow),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // STATION LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: blockStations.length,
              itemBuilder: (context, index) {
                return _buildStationTile(blockStations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label ($count)',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStationTile(StationModel station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Station icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: station.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.water_drop, color: station.status.color),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      station.id,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: station.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${station.villageName} Village',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
                if (station.todayRainfall != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Today: ${station.todayRainfall} mm',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ] else if (station.lastSubmission != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last: ${station.lastSubmission}',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
