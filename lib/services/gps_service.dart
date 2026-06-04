import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/constants.dart';

class GpsService {
  /// Fetches the user's current GPS coordinates using the device's GPS hardware.
  /// Requests location permissions if they are not already granted.
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return a fallback coordinate near Abhanpur
      return const LatLng(21.2200, 81.7000);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return fallback
        return const LatLng(21.2200, 81.7000);
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, return fallback
      return const LatLng(21.2200, 81.7000);
    } 

    // Access the position of the device.
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // If position request fails or times out, try last known position
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
      } catch (_) {}
      
      // Fallback
      return const LatLng(21.2200, 81.7000);
    }
  }

  /// Calculates distance in meters between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  /// Checks if a user is within the required geofence radius of a station
  bool isWithinGeofence(LatLng userLocation, StationModel station) {
    final stationLocation = LatLng(station.lat, station.lng);
    final distance = calculateDistance(userLocation, stationLocation);
    
    return distance <= AppConstants.geofenceRadiusMeters;
  }
}
