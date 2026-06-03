import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/helpers.dart';
import 'package:rainfall_app/widgets/common/app_header.dart';
import 'package:rainfall_app/widgets/cards/compliance_card.dart';
import 'package:rainfall_app/widgets/cards/summary_card.dart';
import 'package:rainfall_app/widgets/cards/area_list_tile.dart';

class BlockDashboardScreen extends StatelessWidget {
  final UserModel user;

  const BlockDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final block = MockData.getBlock(user.assignedAreaId);
    final blockStations = MockData.getStationsForBlock(block.id);
    final blockVillages = MockData.getVillagesForBlock(block.id);
    final reported = MockData.countReported(blockStations);
    final missing = MockData.countMissing(blockStations);
    final pending = MockData.countPending(blockStations);
    final avgRainfall = MockData.getAverageRainfall(blockStations);
    final highestStation = MockData.getHighestRainfallStation(blockStations);
    final missingStations = MockData.getMissingStations(blockStations);

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
                roleLabel: '${user.role.displayName} • ${block.name}',
              ),

              const SizedBox(height: 24),

              // COMPLIANCE CARD
              ComplianceCard(
                reported: reported + pending,
                total: blockStations.length,
                label: 'stations reported today',
              ),

              const SizedBox(height: 20),

              // METRICS ROW
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Stations',
                      value: '${blockStations.length}',
                      icon: Icons.location_on,
                      color: AppColors.primary,
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
                      title: 'Pending Sync',
                      value: '$pending',
                      icon: Icons.sync,
                      color: AppColors.yellow,
                    ),
                  ),
                ],
              ),

              // MISSING STATION ALERTS
              if (missingStations.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Missing Reports ($missing)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...missingStations.map((station) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppColors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${station.villageName} (${station.id})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                station.lastSubmission ?? 'No data received',
                                style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],

              // HIGHEST RAINFALL
              if (highestStation != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Highest Rainfall Today',
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
                              highestStation.villageName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              // VILLAGE-WISE BREAKDOWN
              const Text(
                'Villages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...blockVillages.map((village) {
                final villageStations = blockStations
                    .where((s) => s.villageId == village.id)
                    .toList();
                final villageReported = MockData.countReported(villageStations) +
                    MockData.countPending(villageStations);
                final worstStatus = villageStations.any((s) => s.status == StationStatus.missing)
                    ? StationStatus.missing
                    : villageStations.any((s) => s.status == StationStatus.pendingSync)
                        ? StationStatus.pendingSync
                        : StationStatus.reported;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AreaListTile(
                    title: village.name,
                    subtitle: '${villageStations.length} station(s)',
                    totalStations: villageStations.length,
                    reportedStations: villageReported,
                    worstStatus: worstStatus,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
