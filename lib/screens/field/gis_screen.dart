import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/services/gps_service.dart';
import 'package:rainfall_app/screens/field/rainfall_entry_screen.dart';

class GisScreen extends StatefulWidget {
  final UserModel user;

  const GisScreen({super.key, required this.user});

  @override
  State<GisScreen> createState() => _GisScreenState();
}

class _GisScreenState extends State<GisScreen> {
  final gpsService = GpsService();
  
  bool isCheckingGps = true;
  LatLng? userLocation;
  double distanceMeters = 0.0;
  bool isWithinRange = false;

  @override
  void initState() {
    super.initState();
    _fetchGpsLocation();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      isCheckingGps = true;
    });

    try {
      final station = MockData.getAssignedStation(widget.user.assignedAreaId);
      final loc = await gpsService.getCurrentLocation();
      final dist = gpsService.calculateDistance(loc, LatLng(station.lat, station.lng));
      final within = gpsService.isWithinGeofence(loc, station);

      setState(() {
        userLocation = loc;
        distanceMeters = dist;
        isWithinRange = within;
        isCheckingGps = false;
      });
    } catch (e) {
      setState(() {
        isCheckingGps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final station = MockData.getAssignedStation(widget.user.assignedAreaId);
    final stationLocation = LatLng(station.lat, station.lng);
    
    // Fallback if GPS not loaded yet
    final mapCenter = stationLocation;
    final currentUserLoc = userLocation ?? LatLng(station.lat + 0.0002, station.lng + 0.0002);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPS Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchGpsLocation,
          )
        ],
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
                    initialCenter: mapCenter,
                    initialZoom: 17.5,
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
                          radius: 20, // 20-meter geofence radius
                          useRadiusInMeter: true,
                          color: (isWithinRange ? AppColors.green : AppColors.red).withValues(alpha: 0.15),
                          borderColor: isWithinRange ? AppColors.green : AppColors.red,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    // Markers
                    MarkerLayer(
                      markers: [
                        // Station Marker
                        Marker(
                          point: stationLocation,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.water_drop, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 4),
                              const Text('Station', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                        // User Marker
                        Marker(
                          point: currentUserLoc,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isWithinRange ? AppColors.green : AppColors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 4),
                              const Text('You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // GPS Status Badge Overlay
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isCheckingGps 
                              ? AppColors.primary 
                              : (isWithinRange ? AppColors.green : AppColors.red),
                          child: Icon(
                            isCheckingGps 
                                ? Icons.sync 
                                : (isWithinRange ? Icons.gps_fixed : Icons.gps_off), 
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckingGps 
                                    ? 'Verifying Location...' 
                                    : (isWithinRange ? 'GPS Verified' : 'Outside Geofence'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCheckingGps 
                                    ? 'Acquiring GPS lock...' 
                                    : 'Distance: ${distanceMeters.toStringAsFixed(1)} meters',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                    _infoTile(Icons.straighten, 'Current Distance', 
                        isCheckingGps ? 'Calculating...' : '${distanceMeters.toStringAsFixed(1)} meters'),
                    const SizedBox(height: 30),
                    
                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isCheckingGps ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RainfallEntryScreen(user: widget.user),
                            ),
                          ).then((_) {
                            // Refresh this page when returning
                            _fetchGpsLocation();
                          });
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

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 14),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}