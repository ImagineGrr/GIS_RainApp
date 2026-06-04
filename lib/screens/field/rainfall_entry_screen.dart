import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/helpers.dart';
import 'package:rainfall_app/services/gps_service.dart';
import 'package:rainfall_app/services/database_service.dart';
import 'package:rainfall_app/widgets/input/custom_textfield.dart';

class RainfallEntryScreen extends StatefulWidget {
  final UserModel user;

  const RainfallEntryScreen({super.key, required this.user});

  @override
  State<RainfallEntryScreen> createState() => _RainfallEntryScreenState();
}

class _RainfallEntryScreenState extends State<RainfallEntryScreen> {
  final rainfallController = TextEditingController();
  final notesController = TextEditingController();
  final gpsService = GpsService();
  final dbService = DatabaseService();

  bool isCheckingGps = true;
  bool isWithinRange = false;
  double distanceMeters = 0.0;
  LatLng? userLocation;
  bool isSubmitting = false;
  bool isMockGpsEnabled = false;

  @override
  void initState() {
    super.initState();
    final station = MockData.getAssignedStation(widget.user.assignedAreaId);
    if (station.todayRainfall != null) {
      rainfallController.text = station.todayRainfall.toString();
    }
    for (var entry in MockData.rainfallEntries) {
      if (entry.stationId == station.id) {
        final now = DateTime.now();
        if (entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month &&
            entry.timestamp.day == now.day) {
          if (entry.remarks != null) {
            notesController.text = entry.remarks!;
          }
          break;
        }
      }
    }
    _checkGeofence();
  }

  Future<void> _checkGeofence() async {
    setState(() {
      isCheckingGps = true;
    });

    try {
      final station = MockData.getAssignedStation(widget.user.assignedAreaId);
      LatLng loc;
      double distance;
      bool within;

      if (isMockGpsEnabled) {
        loc = LatLng(station.lat, station.lng);
        distance = 0.0;
        within = true;
      } else {
        loc = await gpsService.getCurrentLocation();
        distance = gpsService.calculateDistance(loc, LatLng(station.lat, station.lng));
        within = gpsService.isWithinGeofence(loc, station);
      }

      setState(() {
        userLocation = loc;
        distanceMeters = distance;
        isWithinRange = within;
        isCheckingGps = false;
      });
    } catch (e) {
      setState(() {
        isCheckingGps = false;
      });
    }
  }

  void _submit() async {
    if (!isWithinRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot submit: You are outside the station geofence range.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final rainfallVal = double.tryParse(rainfallController.text.trim());
    if (rainfallVal == null || rainfallVal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid rainfall value'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS coordinates not available. Please verify your location.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final success = await dbService.submitRainfall(
      stationId: widget.user.assignedAreaId,
      rainfall: rainfallVal,
      lat: userLocation!.latitude,
      lng: userLocation!.longitude,
      remarks: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rainfall submitted successfully!' : 'Offline: Rainfall saved to Sync Queue'),
        backgroundColor: success ? AppColors.green : AppColors.yellow,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final station = MockData.getAssignedStation(widget.user.assignedAreaId);
    final now = DateTime.now();
    final alreadyReported = station.status == StationStatus.reported || station.status == StationStatus.pendingSync;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Rainfall Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WARNING BANNER (IF ALREADY SUBMITTED TODAY)
            if (alreadyReported)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (station.status == StationStatus.pendingSync ? AppColors.yellow : AppColors.green).withValues(alpha: 0.1),
                  border: Border.all(
                    color: (station.status == StationStatus.pendingSync ? AppColors.yellow : AppColors.green).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (station.status == StationStatus.pendingSync ? AppColors.yellow : AppColors.green).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        station.status == StationStatus.pendingSync ? Icons.sync : Icons.check_circle_outline,
                        color: station.status == StationStatus.pendingSync ? AppColors.yellow : AppColors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.status == StationStatus.pendingSync ? 'Rainfall Entry Pending Sync' : 'Rainfall Already Submitted',
                            style: TextStyle(
                              color: station.status == StationStatus.pendingSync ? AppColors.yellow : AppColors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            station.status == StationStatus.pendingSync
                                ? "Today's rainfall recorded: ${station.todayRainfall ?? 0.0} mm (Stored in Sync Queue)"
                                : "Today's rainfall has already been uploaded: ${station.todayRainfall ?? 0.0} mm",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // DEVELOPER MOCK GPS SWITCH
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bug_report, color: Colors.amber),
                      const SizedBox(width: 10),
                      const Text(
                        'Mock GPS (For Testing)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                  Switch(
                    value: isMockGpsEnabled,
                    activeThumbColor: Colors.amber,
                    onChanged: (val) {
                      setState(() {
                        isMockGpsEnabled = val;
                      });
                      _checkGeofence();
                    },
                  ),
                ],
              ),
            ),

            // STATION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.water_drop, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Village: ${station.villageName} • Block: ${station.blockName}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Geofence status display
                  if (isCheckingGps)
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        const Text('Verifying GPS Geofence (20m)...', style: TextStyle(color: AppColors.textLight)),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: (isWithinRange ? AppColors.green : AppColors.red).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWithinRange ? Icons.gps_fixed : Icons.gps_off,
                                color: isWithinRange ? AppColors.green : AppColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isWithinRange ? 'Geofence: Inside (Verified)' : 'Geofence: Outside Range',
                                style: TextStyle(
                                  color: isWithinRange ? AppColors.green : AppColors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${distanceMeters.toStringAsFixed(1)}m away',
                          style: TextStyle(
                            color: isWithinRange ? AppColors.green : AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ENTRY TITLE
            const Text(
              'Rainfall Measurement',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter rainfall in millimeters',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // RAINFALL INPUT
            CustomTextField(
              hintText: 'Enter rainfall (mm)',
              icon: Icons.cloud,
              controller: rainfallController,
              keyboardType: TextInputType.number,
              enabled: !alreadyReported,
            ),
            const SizedBox(height: 20),

            // NOTES INPUT
            CustomTextField(
              hintText: 'Additional notes',
              icon: Icons.note_alt,
              controller: notesController,
              maxLines: 4,
              enabled: !alreadyReported,
            ),
            const SizedBox(height: 28),

            // TIMESTAMP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.access_time, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submission Time',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatTime(now)} • ${formatDate(now)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: (isCheckingGps || isSubmitting || !isWithinRange || alreadyReported) ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Rainfall'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    rainfallController.dispose();
    notesController.dispose();
    super.dispose();
  }
}