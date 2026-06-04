import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/models/rainfall_model.dart';
import 'package:rainfall_app/models/location_models.dart';
import 'package:rainfall_app/utils/mock_data.dart';

class DatabaseService {
  static final client = Supabase.instance.client;

  /// Fetches all districts, blocks, villages, and stations from Supabase,
  /// maps relationships, and caches them in the in-memory MockData layer.
  Future<void> syncMetadataFromDatabase() async {
    try {
      // 1. Fetch Districts
      final districtsData = await client.from('districts').select();
      final List<DistrictModel> fetchedDistricts = [];
      for (var d in districtsData) {
        final distId = d['id'] as String;
        // Fetch blocks associated with this district
        final blocksForDist = await client.from('blocks').select('id').eq('district_id', distId);
        final List<String> blockIds = (blocksForDist as List).map((b) => b['id'] as String).toList();
        
        fetchedDistricts.add(DistrictModel(
          id: distId,
          name: d['name'] as String,
          stateId: 'state_cg',
          blockIds: blockIds,
          centerLat: (d['center_lat'] as num).toDouble(),
          centerLng: (d['center_lng'] as num).toDouble(),
        ));
      }

      // 2. Fetch Blocks
      final blocksData = await client.from('blocks').select();
      final List<BlockModel> fetchedBlocks = [];
      for (var b in blocksData) {
        final blockId = b['id'] as String;
        // Fetch villages associated with this block
        final villagesForBlock = await client.from('villages').select('id').eq('block_id', blockId);
        final List<String> villageIds = (villagesForBlock as List).map((v) => v['id'] as String).toList();
        
        fetchedBlocks.add(BlockModel(
          id: blockId,
          name: b['name'] as String,
          districtId: b['district_id'] as String,
          villageIds: villageIds,
          centerLat: (b['center_lat'] as num).toDouble(),
          centerLng: (b['center_lng'] as num).toDouble(),
        ));
      }

      // 3. Fetch Villages
      final villagesData = await client.from('villages').select();
      final List<VillageModel> fetchedVillages = [];
      for (var v in villagesData) {
        final villageId = v['id'] as String;
        // Fetch stations associated with this village
        final stationsForVillage = await client.from('stations').select('id').eq('village_id', villageId);
        final List<String> stationIds = (stationsForVillage as List).map((s) => s['id'] as String).toList();
        
        fetchedVillages.add(VillageModel(
          id: villageId,
          name: v['name'] as String,
          blockId: v['block_id'] as String,
          stationIds: stationIds,
        ));
      }

      // 4. Fetch Today's Submissions to determine station status
      final todayStr = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      final rainfallTodayData = await client
          .from('rainfall_entries')
          .select()
          .gte('timestamp', '${todayStr}T00:00:00Z');

      final Map<String, Map<String, dynamic>> todayReportedMap = {};
      for (var entry in rainfallTodayData) {
        todayReportedMap[entry['station_id']] = {
          'rainfall': (entry['rainfall'] as num).toDouble(),
          'timestamp': entry['timestamp'],
        };
      }

      // 5. Fetch Stations
      final stationsData = await client.from('stations').select();
      final List<StationModel> fetchedStations = [];
      
      for (var s in stationsData) {
        final stationId = s['id'] as String;
        final villageId = s['village_id'] as String;
        
        // Find matching administrative levels
        final village = fetchedVillages.firstWhere((v) => v.id == villageId, orElse: () => VillageModel(id: villageId, name: 'Unknown', blockId: '', stationIds: []));
        final block = fetchedBlocks.firstWhere((b) => b.id == village.blockId, orElse: () => BlockModel(id: '', name: 'Unknown', districtId: '', villageIds: [], centerLat: 0, centerLng: 0));
        
        final isReportedToday = todayReportedMap.containsKey(stationId);
        double? todayRainfall;
        String? lastSubmission;
        StationStatus status = StationStatus.missing;

        if (isReportedToday) {
          todayRainfall = todayReportedMap[stationId]!['rainfall'];
          status = StationStatus.reported;
          lastSubmission = 'Today • $todayRainfall mm';
        } else {
          // Find last submission from history
          final lastEntryData = await client
              .from('rainfall_entries')
              .select('rainfall, timestamp')
              .eq('station_id', stationId)
              .lt('timestamp', '${todayStr}T00:00:00Z')
              .order('timestamp', ascending: false)
              .limit(1)
              .maybeSingle();

          if (lastEntryData != null) {
            final lastRainfall = (lastEntryData['rainfall'] as num).toDouble();
            final lastTime = DateTime.parse(lastEntryData['timestamp'] as String).toLocal();
            lastSubmission = 'Last: ${lastTime.day}/${lastTime.month} • $lastRainfall mm';
          } else {
            lastSubmission = 'No submissions yet';
          }
        }

        fetchedStations.add(StationModel(
          id: stationId,
          name: s['name'] as String,
          villageId: villageId,
          villageName: village.name,
          blockId: block.id,
          blockName: block.name,
          districtId: block.districtId.isNotEmpty ? block.districtId : 'dist_raipur',
          lat: (s['lat'] as num).toDouble(),
          lng: (s['lng'] as num).toDouble(),
          status: status,
          todayRainfall: todayRainfall,
          lastSubmission: lastSubmission,
        ));
      }

      // Update in-memory MockData with live values
      MockData.updateMetadata(
        districts: fetchedDistricts,
        blocks: fetchedBlocks,
        villages: fetchedVillages,
        stations: fetchedStations,
      );

      // Load rainfall entries list for current user
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        final submissionsResponse = await client
            .from('rainfall_entries')
            .select()
            .order('timestamp', ascending: false)
            .limit(50);
            
        final List<RainfallEntry> fetchedEntries = (submissionsResponse as List).map((entry) {
          return RainfallEntry(
            id: entry['id'] as String,
            stationId: entry['station_id'] as String,
            rainfall: (entry['rainfall'] as num).toDouble(),
            timestamp: DateTime.parse(entry['timestamp'] as String).toLocal(),
            lat: (entry['lat'] as num).toDouble(),
            lng: (entry['lng'] as num).toDouble(),
            remarks: entry['remarks'] as String?,
            syncStatus: SyncStatus.synced,
          );
        }).toList();
        
        MockData.rainfallEntries = fetchedEntries;
      }
    } catch (e) {
      print('Error syncing metadata from database: $e');
    }
  }

  /// Submits a rainfall report to Supabase.
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
      // Attempt upload to Supabase (omit ID so Postgres auto-generates a UUID v4)
      final response = await client.from('rainfall_entries').insert({
        'station_id': stationId,
        'rainfall': rainfall,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'lat': lat,
        'lng': lng,
        'remarks': remarks,
        'created_by': client.auth.currentUser?.id,
      }).select().maybeSingle();

      if (response != null) {
        // Success! Remove local temporary entry and insert the synced one
        final idx = MockData.rainfallEntries.indexWhere((e) => e.id == entryId);
        if (idx != -1) {
          MockData.rainfallEntries[idx] = RainfallEntry(
            id: response['id'] as String,
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
  Future<int> syncOfflineSubmissions() async {
    int syncCount = 0;
    // Iterate over a copy of the list because we will modify items in-place
    final pending = MockData.rainfallEntries.where((e) => e.syncStatus == SyncStatus.pending).toList();

    for (var entry in pending) {
      try {
        final response = await client.from('rainfall_entries').insert({
          'station_id': entry.stationId,
          'rainfall': entry.rainfall,
          'timestamp': entry.timestamp.toUtc().toIso8601String(),
          'lat': entry.lat,
          'lng': entry.lng,
          'remarks': entry.remarks,
          'created_by': client.auth.currentUser?.id,
        }).select().maybeSingle();

        if (response != null) {
          // Update local status to Synced
          final idx = MockData.rainfallEntries.indexWhere((e) => e.id == entry.id);
          if (idx != -1) {
            MockData.rainfallEntries[idx] = RainfallEntry(
              id: response['id'] as String,
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
