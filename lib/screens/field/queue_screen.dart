import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/rainfall_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/services/database_service.dart';

class QueueScreen extends StatefulWidget {
  final UserModel user;

  const QueueScreen({super.key, required this.user});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final dbService = DatabaseService();
  bool isSyncing = false;

  void _triggerSync() async {
    setState(() {
      isSyncing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing offline submissions to database...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final syncCount = await dbService.syncOfflineSubmissions();
      
      if (mounted) {
        setState(() {
          isSyncing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(syncCount > 0 
                ? 'Successfully synced $syncCount report(s)!' 
                : 'Sync completed. No new uploads.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync failed. Please check internet connection.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = MockData.rainfallEntries;
    final pendingEntries = entries.where((e) => e.syncStatus == SyncStatus.pending).toList();
    final syncedEntries = entries.where((e) => e.syncStatus == SyncStatus.synced).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sync Queue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SYNC STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: pendingEntries.isEmpty ? AppColors.green : AppColors.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      pendingEntries.isEmpty ? Icons.cloud_done : Icons.cloud_upload,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingEntries.isEmpty ? 'All Synced' : '${pendingEntries.length} Pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pendingEntries.isEmpty
                              ? 'All submissions uploaded successfully'
                              : 'Waiting for internet connection',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SYNC NOW BUTTON
            if (pendingEntries.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSyncing ? null : _triggerSync,
                  icon: isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync, size: 20),
                  label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // PENDING ENTRIES
            if (pendingEntries.isNotEmpty) ...[
              const Text(
                'Pending Uploads',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...pendingEntries.map((entry) => _buildEntryCard(entry, isPending: true)),
              const SizedBox(height: 20),
            ],

            // SYNCED ENTRIES
            const Text(
              'Synced Submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (syncedEntries.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox, color: AppColors.textLight, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'No synced entries yet',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              )
            else
              ...syncedEntries.map((entry) => _buildEntryCard(entry, isPending: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(RainfallEntry entry, {required bool isPending}) {
    final station = MockData.stations.firstWhere(
      (s) => s.id == entry.stationId,
      orElse: () => MockData.stations.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: AppColors.yellow.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isPending ? AppColors.yellow : AppColors.green).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending ? Icons.cloud_upload : Icons.cloud_done,
              color: isPending ? AppColors.yellow : AppColors.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${station.villageName} — ${entry.rainfall} mm',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.formattedTime} • ${entry.formattedDate}',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isPending ? AppColors.yellow : AppColors.green).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPending ? 'Pending' : 'Synced',
              style: TextStyle(
                color: isPending ? AppColors.yellow : AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}