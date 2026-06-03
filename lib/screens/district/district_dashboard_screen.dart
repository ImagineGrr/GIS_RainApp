import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/widgets/common/app_header.dart';
import 'package:rainfall_app/widgets/cards/compliance_card.dart';
import 'package:rainfall_app/widgets/cards/summary_card.dart';
import 'package:rainfall_app/widgets/cards/area_list_tile.dart';

class DistrictDashboardScreen extends StatelessWidget {
  final UserModel user;

  const DistrictDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final district = MockData.getDistrict(user.assignedAreaId);
    final districtStations = MockData.getStationsForDistrict(district.id);
    final districtBlocks = MockData.getBlocksForDistrict(district.id);
    final reported = MockData.countReported(districtStations);
    final missing = MockData.countMissing(districtStations);
    final pending = MockData.countPending(districtStations);
    final avgRainfall = MockData.getAverageRainfall(districtStations);
    final highestStation = MockData.getHighestRainfallStation(districtStations);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              AppHeader(
                userName: user.name,
                roleLabel: '${user.role.displayName} • ${district.name}',
              ),

              const SizedBox(height: 24),

              // COMPLIANCE
              ComplianceCard(
                reported: reported + pending,
                total: districtStations.length,
                label: 'stations reported across ${districtBlocks.length} blocks',
              ),

              const SizedBox(height: 20),

              // METRICS
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Stations',
                      value: '${districtStations.length}',
                      icon: Icons.location_on,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Blocks',
                      value: '${districtBlocks.length}',
                      icon: Icons.grid_view,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Avg Rainfall',
                      value: '${avgRainfall.toStringAsFixed(1)} mm',
                      icon: Icons.water_drop,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Missing',
                      value: '$missing',
                      icon: Icons.error_outline,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),

              // HIGHEST RAINFALL
              if (highestStation != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Top Station Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.trending_up, color: AppColors.green, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${highestStation.villageName} (${highestStation.blockName})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              highestStation.id,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${highestStation.todayRainfall!.toStringAsFixed(0)} mm',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // BLOCK-WISE BREAKDOWN
              const Text(
                'Block-wise Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...districtBlocks.map((block) {
                final blockStns = MockData.getStationsForBlock(block.id);
                final blockReported = MockData.countReported(blockStns) +
                    MockData.countPending(blockStns);
                final blockMissing = MockData.countMissing(blockStns);
                final blockAvg = MockData.getAverageRainfall(blockStns);
                final worstStatus = blockStns.any((s) => s.status == StationStatus.missing)
                    ? StationStatus.missing
                    : blockStns.any((s) => s.status == StationStatus.pendingSync)
                        ? StationStatus.pendingSync
                        : StationStatus.reported;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AreaListTile(
                          title: block.name,
                          subtitle: '${MockData.getVillagesForBlock(block.id).length} villages',
                          totalStations: blockStns.length,
                          reportedStations: blockReported,
                          worstStatus: worstStatus,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _blockStat('Stations', '${blockStns.length}', AppColors.primary),
                            _blockStat('Reported', '$blockReported', AppColors.green),
                            _blockStat('Missing', '$blockMissing', AppColors.red),
                            _blockStat('Avg', '${blockAvg.toStringAsFixed(0)} mm', AppColors.textDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blockStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
