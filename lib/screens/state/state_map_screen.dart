import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/constants.dart';
import 'package:rainfall_app/widgets/map/gis_map_widget.dart';

class StateMapScreen extends StatelessWidget {
  final UserModel user;

  const StateMapScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final districts = MockData.districts;
    
    final aggregateMarkers = districts.map((district) {
      final distStns = MockData.getStationsForDistrict(district.id);
      final reported = MockData.countReported(distStns) + MockData.countPending(distStns);
      final total = distStns.length;
      
      final worstStatus = distStns.any((s) => s.status == StationStatus.missing)
          ? StationStatus.missing
          : distStns.any((s) => s.status == StationStatus.pendingSync)
              ? StationStatus.pendingSync
              : StationStatus.reported;
              
      return AggregateMapMarker(
        id: district.id,
        name: district.name,
        lat: district.centerLat,
        lng: district.centerLng,
        total: total,
        reported: reported,
        statusColor: worstStatus.color,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Chhattisgarh — GIS Map')),
      body: GisMapWidget(
        center: AppConstants.chhattisgarhCenter,
        zoom: AppConstants.stateMapZoom,
        aggregateMarkers: aggregateMarkers,
        onAggregateTap: (marker) {
          showAggregateInfoSheet(context, marker);
        },
      ),
    );
  }
}
