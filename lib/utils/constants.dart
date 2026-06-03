import 'package:latlong2/latlong.dart';

/// Application-wide constants.
class AppConstants {

  // GEOFENCING
  static const double geofenceRadiusMeters = 20.0;

  // MAP DEFAULTS
  static const double defaultMapZoom = 17.0;
  static const double blockMapZoom = 13.0;
  static const double districtMapZoom = 10.0;
  static const double stateMapZoom = 7.0;

  // Chhattisgarh center (approx)
  static final LatLng chhattisgarhCenter = LatLng(21.27, 81.87);

  // Raipur district center (approx)
  static final LatLng raipurCenter = LatLng(21.25, 81.63);

  // SUBMISSION
  static const String submissionCutoff = '08:30 AM';

  // DATE FORMATS
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
