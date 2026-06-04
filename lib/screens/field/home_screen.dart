import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/helpers.dart';
import 'package:rainfall_app/widgets/cards/metric_card.dart';
import 'package:rainfall_app/widgets/common/status_chip.dart';
import 'package:rainfall_app/screens/field/gis_screen.dart';
import 'package:rainfall_app/services/database_service.dart';

class FieldHomeScreen extends StatefulWidget {
  final UserModel user;

  const FieldHomeScreen({super.key, required this.user});

  @override
  State<FieldHomeScreen> createState() => _FieldHomeScreenState();
}

class _FieldHomeScreenState extends State<FieldHomeScreen> {
  final dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final station = MockData.getAssignedStation(widget.user.assignedAreaId);
    final bool submittedToday = station.status == StationStatus.reported || station.status == StationStatus.pendingSync;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await dbService.syncMetadataFromDatabase();
              if (mounted) setState(() {});
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync failed: ${e.toString()}'),
                    backgroundColor: AppColors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.user.role.displayName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // STATUS CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TODAY'S STATUS",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        submittedToday ? 'Submission Completed' : 'Submission Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cut off 08:30 AM',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      submittedToday
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Rainfall submitted: ${station.todayRainfall ?? 0} mm',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GisScreen(user: widget.user),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                                child: const Text(
                                  'Start Submission',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // OVERVIEW
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: MetricCard(title: 'Assigned', value: '01', color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Pending',
                        value: submittedToday ? '00' : '01',
                        color: AppColors.yellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Rainfall',
                        value: station.todayRainfall != null
                            ? '${station.todayRainfall!.toStringAsFixed(1)} mm'
                            : '-- mm',
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: MetricCard(title: 'Week', value: '124 mm', color: Colors.purple),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // MY STATION
                const Text(
                  'My Station',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _buildStationCard(station),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(StationModel station) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    station.id,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.blockName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              StatusChip(status: station.status),
            ],
          ),
          const SizedBox(height: 12),
          if (station.lastSubmission != null)
            Text(
              'Last: ${station.lastSubmission}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
        ],
      ),
    );
  }
}