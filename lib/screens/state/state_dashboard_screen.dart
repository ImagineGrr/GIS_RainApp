import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/widgets/common/app_header.dart';
import 'package:rainfall_app/widgets/cards/compliance_card.dart';
import 'package:rainfall_app/widgets/cards/summary_card.dart';
import 'package:rainfall_app/widgets/cards/area_list_tile.dart';

class StateDashboardScreen extends StatelessWidget {
  final UserModel user;

  const StateDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // For MVP, State level sees all stations across all districts
    final stateStations = MockData.stations;
    final districts = MockData.districts;
    
    final reported = MockData.countReported(stateStations);
    final missing = MockData.countMissing(stateStations);
    final pending = MockData.countPending(stateStations);
    final avgRainfall = MockData.getAverageRainfall(stateStations);
    
    final totalRainfall = stateStations
        .where((s) => s.todayRainfall != null)
        .fold<double>(0, (sum, s) => sum + s.todayRainfall!);

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
                roleLabel: '${user.role.displayName} • ${user.assignedAreaName}',
              ),

              const SizedBox(height: 24),

              // STATE COMPLIANCE
              ComplianceCard(
                reported: reported + pending,
                total: stateStations.length,
                label: 'stations reported statewide today',
              ),

              const SizedBox(height: 20),

              // METRICS
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Stations',
                      value: '${stateStations.length}',
                      icon: Icons.location_city,
                      color: AppColors.primary,
                      subtitle: 'Active',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Missing Reports',
                      value: '$missing',
                      icon: Icons.warning_rounded,
                      color: AppColors.red,
                      subtitle: 'Critical',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Statewide Avg',
                      value: '${avgRainfall.toStringAsFixed(1)} mm',
                      icon: Icons.water_drop,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Rainfall',
                      value: '${totalRainfall.toStringAsFixed(0)} mm',
                      icon: Icons.add_circle_outline,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // DISTRICT-WISE BREAKDOWN
              const Text(
                'District Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...districts.map((district) {
                final distStns = MockData.getStationsForDistrict(district.id);
                final distReported = MockData.countReported(distStns) +
                    MockData.countPending(distStns);
                final worstStatus = distStns.any((s) => s.status == StationStatus.missing)
                    ? StationStatus.missing
                    : distStns.any((s) => s.status == StationStatus.pendingSync)
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
                          title: district.name,
                          subtitle: '${district.blockIds.length} Blocks',
                          totalStations: distStns.length,
                          reportedStations: distReported,
                          worstStatus: worstStatus,
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
}
