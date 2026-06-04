import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/constants.dart';
import 'package:rainfall_app/widgets/map/gis_map_widget.dart';

class BlockMapScreen extends StatelessWidget {
  final UserModel user;

  const BlockMapScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final block = MockData.getBlock(user.assignedAreaId);
    final blockStations = MockData.getStationsForBlock(block.id);

    return Scaffold(
      appBar: AppBar(title: Text('${block.name} — Map')),
      body: GisMapWidget(
        center: LatLng(block.centerLat, block.centerLng),
        zoom: AppConstants.blockMapZoom,
        stations: blockStations,
        onStationTap: (station) {
          showStationInfoSheet(context, station);
        },
      ),
    );
  }
}
