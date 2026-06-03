import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/screens/field/rainfall_entry_screen.dart';

class GisScreen extends StatelessWidget {
  final UserModel user;

  const GisScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final station = MockData.getAssignedStation(user.assignedAreaId);
    final stationLocation = LatLng(station.lat, station.lng);

    // Simulated user location (slightly offset from station)
    final userLocation = LatLng(station.lat + 0.0004, station.lng + 0.0004);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPS Verification'),
      ),
      body: Column(
        children: [
          // MAP SECTION
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: stationLocation,
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.rainfall_app',
                    ),
                    // Geofence circle
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: stationLocation,
                          radius: 20,
                          useRadiusInMeter: true,
                          color: AppColors.green.withValues(alpha: 0.2),
                          borderColor: AppColors.green,
                          borderStrokeWidth: 3,
                        ),
                      ],
                    ),
                    // Markers
                    MarkerLayer(
                      markers: [
                        // Station
                        Marker(
                          point: stationLocation,
                          width: 90,
                          height: 90,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.water_drop, color: Colors.white, size: 30),
                              ),
                              const SizedBox(height: 6),
                              const Text('Station', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // User
                        Marker(
                          point: userLocation,
                          width: 90,
                          height: 90,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                              const SizedBox(height: 6),
                              const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // GPS Status Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.green,
                          child: Icon(Icons.gps_fixed, color: Colors.white),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GPS Verified',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Distance: 12 meters',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // BOTTOM SECTION
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Station Information',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _infoTile(Icons.location_on, 'Station ID', station.id),
                    const SizedBox(height: 18),
                    _infoTile(Icons.home_work, 'Village', station.villageName),
                    const SizedBox(height: 18),
                    _infoTile(Icons.social_distance, 'Allowed Radius', '20 meters'),
                    const SizedBox(height: 18),
                    _infoTile(Icons.straighten, 'Current Distance', '12 meters'),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RainfallEntryScreen(user: user),
                            ),
                          );
                        },
                        child: const Text('Continue To Rainfall Entry'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}