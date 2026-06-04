import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/models/rainfall_model.dart';
import 'package:rainfall_app/models/location_models.dart';
import 'package:rainfall_app/utils/mock_data.dart';
import 'package:rainfall_app/utils/config.dart';
import 'package:rainfall_app/services/auth_service.dart';

class DatabaseService {
  /// Fetches all districts, blocks, villages, and stations from the Node.js API,
  /// maps relationships, and caches them in the in-memory MockData layer.
  Future<void> syncMetadataFromDatabase() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/metadata'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 1. Map Districts
      final districtsData = data['districts'] as List;
      final List<DistrictModel> fetchedDistricts = districtsData.map((d) {
        return DistrictModel(
          id: d['id'],
          name: d['name'],
          stateId: d['state_id'],
          blockIds: List<String>.from(d['block_ids']),
          centerLat: (d['center_lat'] as num).toDouble(),
          centerLng: (d['center_lng'] as num).toDouble(),
        );
      }).toList();

      // 2. Map Blocks
      final blocksData = data['blocks'] as List;
      final List<BlockModel> fetchedBlocks = blocksData.map((b) {
        return BlockModel(
          id: b['id'],
          name: b['name'],
          districtId: b['district_id'],
          villageIds: List<String>.from(b['village_ids']),
          centerLat: (b['center_lat'] as num).toDouble(),
          centerLng: (b['center_lng'] as num).toDouble(),
        );
      }).toList();

      // 3. Map Villages
      final villagesData = data['villages'] as List;
      final List<VillageModel> fetchedVillages = villagesData.map((v) {
        return VillageModel(
          id: v['id'],
          name: v['name'],
          blockId: v['block_id'],
          stationIds: List<String>.from(v['station_ids']),
        );
      }).toList();

      // 4. Map Stations
      final stationsData = data['stations'] as List;
      final List<StationModel> fetchedStations = stationsData.map((s) {
        final stationId = s['id'];
        final villageId = s['village_id'];

        final village = fetchedVillages.firstWhere((v) => v.id == villageId, orElse: () => VillageModel(id: villageId, name: 'Unknown', blockId: '', stationIds: []));
        final block = fetchedBlocks.firstWhere((b) => b.id == village.blockId, orElse: () => BlockModel(id: '', name: 'Unknown', districtId: '', villageIds: [], centerLat: 0, centerLng: 0));

        // Parse StationStatus Enum
        StationStatus status;
        switch (s['status']) {
          case 'reported':
            status = StationStatus.reported;
            break;
          case 'pendingSync':
            status = StationStatus.pendingSync;
            break;
          case 'missing':
          default:
            status = StationStatus.missing;
        }

        return StationModel(
          id: stationId,
          name: s['name'],
          villageId: villageId,
          villageName: village.name,
          blockId: block.id,
          blockName: block.name,
          districtId: block.districtId.isNotEmpty ? block.districtId : 'dist_raipur',
          lat: (s['lat'] as num).toDouble(),
          lng: (s['lng'] as num).toDouble(),
          status: status,
          todayRainfall: s['today_rainfall'] != null ? (s['today_rainfall'] as num).toDouble() : null,
          lastSubmission: s['last_submission'] ?? 'No submissions yet',
        );
      }).toList();

      // Update in-memory MockData with live values
      MockData.updateMetadata(
        districts: fetchedDistricts,
        blocks: fetchedBlocks,
        villages: fetchedVillages,
        stations: fetchedStations,
      );

      try {
        await fetchRainfallHistory();
      } catch (e) {
        print('Silent error fetching history: $e');
      }
    } else {
      throw Exception('Failed to sync metadata: ${response.body}');
    }
  }

  /// Fetches historical rainfall reports from the Node.js API,
  /// and updates MockData.rainfallEntries while preserving local pending sync items.
  Future<void> fetchRainfallHistory() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/rainfall/history'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      
      final List<RainfallEntry> fetchedEntries = data.map((e) {
        return RainfallEntry(
          id: e['id'].toString(),
          stationId: e['station_id'],
          rainfall: (e['rainfall'] as num).toDouble(),
          timestamp: DateTime.parse(e['timestamp']).toLocal(),
          lat: (e['lat'] as num).toDouble(),
          lng: (e['lng'] as num).toDouble(),
          remarks: e['remarks'],
          syncStatus: SyncStatus.synced,
        );
      }).toList();

      // Merge: keep local pending sync entries at the top
      final pending = MockData.rainfallEntries.where((e) => e.syncStatus == SyncStatus.pending).toList();
      
      MockData.rainfallEntries = [
        ...pending,
        ...fetchedEntries,
      ];
    } else {
      throw Exception('Failed to fetch rainfall history: ${response.body}');
    }
  }

  /// Submits a rainfall report to the database.
  /// If offline or upload fails, saves to MockData as pendingSync.
  Future<bool> submitRainfall({
    required String stationId,
    required double rainfall,
    required double lat,
    required double lng,
    String? remarks,
  }) async {
    // Generate a temporary UUID for local offline storage
    final entryId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    final localEntry = RainfallEntry(
      id: entryId,
      stationId: stationId,
      rainfall: rainfall,
      timestamp: timestamp,
      lat: lat,
      lng: lng,
      remarks: remarks,
      syncStatus: SyncStatus.pending,
    );

    // Save locally to MockData first (Offline first!)
    MockData.rainfallEntries.insert(0, localEntry);
    
    // Update local station to show pending sync status
    MockData.updateStationStatus(
      stationId: stationId,
      status: StationStatus.pendingSync,
      todayRainfall: rainfall,
      lastSubmission: 'Today • $rainfall mm (pending)',
    );

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/rainfall/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'station_id': stationId,
          'rainfall': rainfall,
          'lat': lat,
          'lng': lng,
          'remarks': remarks,
        }),
      );

      if (response.statusCode == 200) {
        // Success! Remove local temporary entry and insert the synced one
        final idx = MockData.rainfallEntries.indexWhere((e) => e.id == entryId);
        if (idx != -1) {
          MockData.rainfallEntries[idx] = RainfallEntry(
            id: entryId,
            stationId: stationId,
            rainfall: rainfall,
            timestamp: timestamp,
            lat: lat,
            lng: lng,
            remarks: remarks,
            syncStatus: SyncStatus.synced,
          );
        }

        // Update station status to reported
        MockData.updateStationStatus(
          stationId: stationId,
          status: StationStatus.reported,
          todayRainfall: rainfall,
          lastSubmission: 'Today • $rainfall mm',
        );
        return true;
      }
    } catch (e) {
      print('Upload failed, saved offline: $e');
    }

    return false;
  }

  /// Syncs all pending local submissions to the cloud
  Future<int> syncOfflineSubmissions(String stationId) async {
    int syncCount = 0;
    final pending = MockData.rainfallEntries
        .where((e) => e.syncStatus == SyncStatus.pending && e.stationId == stationId)
        .toList();

    for (var entry in pending) {
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/rainfall/submit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          body: jsonEncode({
            'station_id': entry.stationId,
            'rainfall': entry.rainfall,
            'lat': entry.lat,
            'lng': entry.lng,
            'remarks': entry.remarks,
          }),
        );

        if (response.statusCode == 200) {
          // Update local status to Synced
          final idx = MockData.rainfallEntries.indexWhere((e) => e.id == entry.id);
          if (idx != -1) {
            MockData.rainfallEntries[idx] = RainfallEntry(
              id: entry.id,
              stationId: entry.stationId,
              rainfall: entry.rainfall,
              timestamp: entry.timestamp,
              lat: entry.lat,
              lng: entry.lng,
              remarks: entry.remarks,
              syncStatus: SyncStatus.synced,
            );
          }

          // Update station status to reported
          MockData.updateStationStatus(
            stationId: entry.stationId,
            status: StationStatus.reported,
            todayRainfall: entry.rainfall,
            lastSubmission: 'Today • ${entry.rainfall} mm',
          );
          syncCount++;
        }
      } catch (e) {
        print('Error syncing entry ${entry.id}: $e');
      }
    }

    return syncCount;
  }
}
