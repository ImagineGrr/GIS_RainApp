import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/constants.dart';
import 'package:rainfall_app/widgets/map/gis_map_widget.dart';

class StateMapScreen extends StatefulWidget {
  final UserModel user;

  const StateMapScreen({super.key, required this.user});

  @override
  State<StateMapScreen> createState() => _StateMapScreenState();
}

class _StateMapScreenState extends State<StateMapScreen> {
  String? selectedDistrictId;
  String? selectedBlockId;

  @override
  Widget build(BuildContext context) {
    // LEVEL 3: BLOCK STATIONS VIEW
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
                heroTag: 'back_to_dist',
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

    // LEVEL 2: DISTRICT BLOCKS VIEW
    if (selectedDistrictId != null) {
      final district = MockData.getDistrict(selectedDistrictId!);
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
        body: Stack(
          children: [
            GisMapWidget(
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
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.extended(
                heroTag: 'back_to_state',
                onPressed: () => setState(() => selectedDistrictId = null),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to State'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // LEVEL 1: STATEWIDE DISTRICTS VIEW
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
          showAggregateInfoSheet(
            context,
            marker,
            actionLabel: 'View Blocks in District',
            onActionTap: () {
              setState(() => selectedDistrictId = marker.id);
            },
          );
        },
      ),
    );
  }
}

