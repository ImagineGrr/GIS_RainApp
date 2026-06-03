import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/constants.dart';
import 'package:rainfall_app/widgets/map/gis_map_widget.dart';

class DistrictMapScreen extends StatelessWidget {
  final UserModel user;

  const DistrictMapScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final district = MockData.getDistrict(user.assignedAreaId);
    final districtBlocks = MockData.getBlocksForDistrict(district.id);
    
    final aggregateMarkers = districtBlocks.map((block) {
      final blockStns = MockData.getStationsForBlock(block.id);
      final reported = MockData.countReported(blockStns) + MockData.countPending(blockStns);
      final total = blockStns.length;
      
      final worstStatus = blockStns.any((s) => s.status == StationStatus.missing)
          ? StationStatus.missing
          : blockStns.any((s) => s.status == StationStatus.pendingSync)
              ? StationStatus.pendingSync
              : StationStatus.reported;
              
      return AggregateMapMarker(
        id: block.id,
        name: block.name,
        lat: block.centerLat,
        lng: block.centerLng,
        total: total,
        reported: reported,
        statusColor: worstStatus.color,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${district.name} District — GIS')),
      body: GisMapWidget(
        center: LatLng(district.centerLat, district.centerLng),
        zoom: AppConstants.districtMapZoom,
        aggregateMarkers: aggregateMarkers,
        onAggregateTap: (marker) {
          showAggregateInfoSheet(context, marker);
        },
      ),
    );
  }
}
