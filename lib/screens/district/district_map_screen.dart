import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/constants.dart';
import 'package:rainfall_app/widgets/map/gis_map_widget.dart';

class DistrictMapScreen extends StatefulWidget {
  final UserModel user;

  const DistrictMapScreen({super.key, required this.user});

  @override
  State<DistrictMapScreen> createState() => _DistrictMapScreenState();
}

class _DistrictMapScreenState extends State<DistrictMapScreen> {
  String? selectedBlockId;

  @override
  Widget build(BuildContext context) {
    final district = MockData.getDistrict(widget.user.assignedAreaId);

    // If a block is selected, show its stations. Otherwise, show block aggregates.
    if (selectedBlockId != null) {
      final block = MockData.getBlock(selectedBlockId!);
      final blockStations = MockData.getStationsForBlock(block.id);

      return Scaffold(
        appBar: AppBar(title: Text('${block.name} Block — GIS')),
        body: Stack(
          children: [
            GisMapWidget(
              center: LatLng(block.centerLat, block.centerLng),
              zoom: AppConstants.blockMapZoom,
              stations: blockStations,
              onStationTap: (station) {
                showStationInfoSheet(context, station);
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.extended(
                heroTag: 'back_btn',
                onPressed: () => setState(() => selectedBlockId = null),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to District'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Default: Show block aggregates for the district
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
          showAggregateInfoSheet(
            context,
            marker,
            actionLabel: 'View Villages in Block',
            onActionTap: () {
              setState(() => selectedBlockId = marker.id);
            },
          );
        },
      ),
    );
  }
}

