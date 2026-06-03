import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';

class AggregateMapMarker {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int total;
  final int reported;
  final Color statusColor;

  AggregateMapMarker({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.total,
    required this.reported,
    required this.statusColor,
  });
}

/// Shared GIS map component used by Block, District, and State dashboards.
/// Color-codes station markers: Green=reported, Red=missing, Yellow=pending.
class GisMapWidget extends StatelessWidget {

  final LatLng center;
  final double zoom;
  final List<StationModel>? stations;
  final List<AggregateMapMarker>? aggregateMarkers;
  final bool showLegend;
  final void Function(StationModel station)? onStationTap;
  final void Function(AggregateMapMarker marker)? onAggregateTap;

  const GisMapWidget({
    super.key,
    required this.center,
    required this.zoom,
    this.stations,
    this.aggregateMarkers,
    this.showLegend = true,
    this.onStationTap,
    this.onAggregateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
          ),
          children: [
            // Map Tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.rainfall_app',
            ),

            // Station Markers
            if (stations != null)
              MarkerLayer(
                markers: stations!.map((station) {
                  return Marker(
                    point: LatLng(station.lat, station.lng),
                    width: 60,
                    height: 70,
                    child: GestureDetector(
                      onTap: () => onStationTap?.call(station),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: station.status.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: station.status.color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              station.id,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Aggregate Markers
            if (aggregateMarkers != null)
              MarkerLayer(
                markers: aggregateMarkers!.map((marker) {
                  return Marker(
                    point: LatLng(marker.lat, marker.lng),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => onAggregateTap?.call(marker),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: marker.statusColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: marker.statusColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              '${marker.reported}/${marker.total}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              marker.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),

        // Legend Overlay
        if (showLegend)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem(AppColors.green, 'Reported'),
                  const SizedBox(height: 6),
                  _legendItem(AppColors.red, 'Missing'),
                  const SizedBox(height: 6),
                  _legendItem(AppColors.yellow, 'Pending Sync'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet to show station details when a marker is tapped.
void showStationInfoSheet(BuildContext context, StationModel station) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Station header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: station.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: station.status.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${station.villageName} • ${station.blockName}',
                        style: const TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Details
            _infoRow('Station ID', station.id),
            _infoRow('Status', station.status.displayName),
            _infoRow(
              'Today\'s Rainfall',
              station.todayRainfall != null
                  ? '${station.todayRainfall} mm'
                  : 'Not reported',
            ),
            if (station.lastSubmission != null)
              _infoRow('Last Submission', station.lastSubmission!),
            _infoRow('Coordinates', '${station.lat.toStringAsFixed(4)}, ${station.lng.toStringAsFixed(4)}'),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

/// Bottom sheet to show aggregated area details when a marker is tapped.
void showAggregateInfoSheet(BuildContext context, AggregateMapMarker marker) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: marker.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${marker.reported}/${marker.total}',
                      style: TextStyle(
                        color: marker.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Aggregated Area',
                        style: TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Details
            _infoRow('Area ID', marker.id),
            _infoRow('Reported', '${marker.reported} stations'),
            _infoRow('Missing/Pending', '${marker.total - marker.reported} stations'),
            _infoRow('Total Stations', '${marker.total} stations'),
            if (marker.total > 0)
              _infoRow('Compliance', '${((marker.reported / marker.total) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

