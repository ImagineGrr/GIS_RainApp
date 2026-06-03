import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/constants.dart';

class GpsService {
  /// Mock method to get current location
  Future<LatLng> getCurrentLocation() async {
    // In a real app, use the geolocator package:
    // Position position = await Geolocator.getCurrentPosition();
    // return LatLng(position.latitude, position.longitude);
    
    // For MVP, we return a mock location close to Abhanpur
    return const LatLng(21.0500, 81.7500); 
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
