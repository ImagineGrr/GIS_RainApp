import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/models/station_model.dart';
import 'package:rainfall_app/models/rainfall_model.dart';
import 'package:rainfall_app/models/location_models.dart';

/// Centralized mock data layer for the rainfall monitoring MVP.
/// Designed to be easily replaced with API calls in the future.
class MockData {

  // ─── MOCK CREDENTIALS ─────────────────────────────────────────
  static const Map<String, Map<String, String>> credentials = {
    'operator_rp001': {'password': '123456', 'userId': 'user_field'},
    'block_abhanpur': {'password': '123456', 'userId': 'user_block'},
    'district_raipur': {'password': '123456', 'userId': 'user_district'},
    'state_admin': {'password': '123456', 'userId': 'user_state'},
  };

  // ─── USERS ─────────────────────────────────────────────────────
  static const Map<String, UserModel> users = {
    'user_field': UserModel(
      id: 'user_field',
      name: 'Ramesh Kumar',
      role: UserRole.field,
      phone: '9876543210',
      assignedAreaId: 'RP001',
      assignedAreaName: 'Khora Village',
    ),
    'user_block': UserModel(
      id: 'user_block',
      name: 'Suresh Verma',
      role: UserRole.block,
      phone: '9876543211',
      assignedAreaId: 'block_abhanpur',
      assignedAreaName: 'Abhanpur Block',
    ),
    'user_district': UserModel(
      id: 'user_district',
      name: 'Anjali Sharma',
      role: UserRole.district,
      phone: '9876543212',
      assignedAreaId: 'dist_raipur',
      assignedAreaName: 'Raipur District',
    ),
    'user_state': UserModel(
      id: 'user_state',
      name: 'Sandeep',
      role: UserRole.state,
      phone: '9876543213',
      assignedAreaId: 'state_cg',
      assignedAreaName: 'Chhattisgarh',
    ),
  };

  // ─── DISTRICTS ─────────────────────────────────────────────────
  static List<DistrictModel> districts = [
    DistrictModel(
      id: 'dist_raipur',
      name: 'Raipur',
      stateId: 'state_cg',
      blockIds: ['block_abhanpur', 'block_arang', 'block_tilda'],
      centerLat: 21.2514,
      centerLng: 81.6296,
    ),
  ];

  // ─── BLOCKS ────────────────────────────────────────────────────
  static List<BlockModel> blocks = [
    BlockModel(
      id: 'block_abhanpur',
      name: 'Abhanpur',
      districtId: 'dist_raipur',
      villageIds: ['v01', 'v02', 'v03', 'v04'],
      centerLat: 21.2200,
      centerLng: 81.7000,
    ),
    BlockModel(
      id: 'block_arang',
      name: 'Arang',
      districtId: 'dist_raipur',
      villageIds: ['v05', 'v06', 'v07'],
      centerLat: 21.1960,
      centerLng: 81.9700,
    ),
    BlockModel(
      id: 'block_tilda',
      name: 'Tilda',
      districtId: 'dist_raipur',
      villageIds: ['v08', 'v09', 'v10'],
      centerLat: 21.3600,
      centerLng: 81.6600,
    ),
  ];

  // ─── VILLAGES ──────────────────────────────────────────────────
  static List<VillageModel> villages = [
    // Abhanpur Block
    VillageModel(id: 'v01', name: 'Khora', blockId: 'block_abhanpur', stationIds: ['RP001']),
    VillageModel(id: 'v02', name: 'Bhanpuri', blockId: 'block_abhanpur', stationIds: ['RP002']),
    VillageModel(id: 'v03', name: 'Mandir Hasaud', blockId: 'block_abhanpur', stationIds: ['RP003']),
    VillageModel(id: 'v04', name: 'Nardaha', blockId: 'block_abhanpur', stationIds: ['RP004']),
    // Arang Block
    VillageModel(id: 'v05', name: 'Arang Town', blockId: 'block_arang', stationIds: ['RP005']),
    VillageModel(id: 'v06', name: 'Chhura', blockId: 'block_arang', stationIds: ['RP006']),
    VillageModel(id: 'v07', name: 'Kota', blockId: 'block_arang', stationIds: ['RP007']),
    // Tilda Block
    VillageModel(id: 'v08', name: 'Tilda Town', blockId: 'block_tilda', stationIds: ['RP008']),
    VillageModel(id: 'v09', name: 'Bemetara Road', blockId: 'block_tilda', stationIds: ['RP009']),
    VillageModel(id: 'v10', name: 'Simga', blockId: 'block_tilda', stationIds: ['RP010']),
  ];

  // ─── STATIONS ──────────────────────────────────────────────────
  static List<StationModel> stations = [
    // Abhanpur Block — 3 reported, 1 missing
    StationModel(
      id: 'RP001', name: 'Khora Station', villageId: 'v01', villageName: 'Khora',
      blockId: 'block_abhanpur', blockName: 'Abhanpur', districtId: 'dist_raipur',
      lat: 21.2514, lng: 81.6296, status: StationStatus.reported,
      todayRainfall: 22.0, lastSubmission: 'Today • 22 mm',
    ),
    StationModel(
      id: 'RP002', name: 'Bhanpuri Station', villageId: 'v02', villageName: 'Bhanpuri',
      blockId: 'block_abhanpur', blockName: 'Abhanpur', districtId: 'dist_raipur',
      lat: 21.2350, lng: 81.6500, status: StationStatus.reported,
      todayRainfall: 18.5, lastSubmission: 'Today • 18.5 mm',
    ),
    StationModel(
      id: 'RP003', name: 'Mandir Hasaud Station', villageId: 'v03', villageName: 'Mandir Hasaud',
      blockId: 'block_abhanpur', blockName: 'Abhanpur', districtId: 'dist_raipur',
      lat: 21.2100, lng: 81.7200, status: StationStatus.missing,
      lastSubmission: 'Yesterday • 15 mm',
    ),
    StationModel(
      id: 'RP004', name: 'Nardaha Station', villageId: 'v04', villageName: 'Nardaha',
      blockId: 'block_abhanpur', blockName: 'Abhanpur', districtId: 'dist_raipur',
      lat: 21.2000, lng: 81.6800, status: StationStatus.reported,
      todayRainfall: 30.0, lastSubmission: 'Today • 30 mm',
    ),

    // Arang Block — 1 reported, 1 missing, 1 pending
    StationModel(
      id: 'RP005', name: 'Arang Town Station', villageId: 'v05', villageName: 'Arang Town',
      blockId: 'block_arang', blockName: 'Arang', districtId: 'dist_raipur',
      lat: 21.1960, lng: 81.9700, status: StationStatus.reported,
      todayRainfall: 12.0, lastSubmission: 'Today • 12 mm',
    ),
    StationModel(
      id: 'RP006', name: 'Chhura Station', villageId: 'v06', villageName: 'Chhura',
      blockId: 'block_arang', blockName: 'Arang', districtId: 'dist_raipur',
      lat: 21.1800, lng: 81.9500, status: StationStatus.missing,
      lastSubmission: 'Yesterday • 8 mm',
    ),
    StationModel(
      id: 'RP007', name: 'Kota Station', villageId: 'v07', villageName: 'Kota',
      blockId: 'block_arang', blockName: 'Arang', districtId: 'dist_raipur',
      lat: 21.2100, lng: 81.9900, status: StationStatus.pendingSync,
      todayRainfall: 14.0, lastSubmission: 'Today • 14 mm (pending)',
    ),

    // Tilda Block — 2 reported, 1 pending
    StationModel(
      id: 'RP008', name: 'Tilda Town Station', villageId: 'v08', villageName: 'Tilda Town',
      blockId: 'block_tilda', blockName: 'Tilda', districtId: 'dist_raipur',
      lat: 21.3600, lng: 81.6600, status: StationStatus.reported,
      todayRainfall: 25.0, lastSubmission: 'Today • 25 mm',
    ),
    StationModel(
      id: 'RP009', name: 'Bemetara Road Station', villageId: 'v09', villageName: 'Bemetara Road',
      blockId: 'block_tilda', blockName: 'Tilda', districtId: 'dist_raipur',
      lat: 21.3800, lng: 81.6400, status: StationStatus.reported,
      todayRainfall: 19.0, lastSubmission: 'Today • 19 mm',
    ),
    StationModel(
      id: 'RP010', name: 'Simga Station', villageId: 'v10', villageName: 'Simga',
      blockId: 'block_tilda', blockName: 'Tilda', districtId: 'dist_raipur',
      lat: 21.3700, lng: 81.6200, status: StationStatus.pendingSync,
      todayRainfall: 11.0, lastSubmission: 'Today • 11 mm (pending)',
    ),
  ];

  /// Updates the cached metadata lists from the database
  static void updateMetadata({
    required List<DistrictModel> districts,
    required List<BlockModel> blocks,
    required List<VillageModel> villages,
    required List<StationModel> stations,
  }) {
    MockData.districts = districts;
    MockData.blocks = blocks;
    MockData.villages = villages;
    MockData.stations = stations;
  }

  /// Updates status for a single station in-memory
  static void updateStationStatus({
    required String stationId,
    required StationStatus status,
    required double todayRainfall,
    required String lastSubmission,
  }) {
    final idx = stations.indexWhere((s) => s.id == stationId);
    if (idx != -1) {
      final old = stations[idx];
      stations[idx] = StationModel(
        id: old.id,
        name: old.name,
        villageId: old.villageId,
        villageName: old.villageName,
        blockId: old.blockId,
        blockName: old.blockName,
        districtId: old.districtId,
        lat: old.lat,
        lng: old.lng,
        status: status,
        todayRainfall: todayRainfall,
        lastSubmission: lastSubmission,
      );
    }
  }

  // ─── RAINFALL ENTRIES (for queue/history) ──────────────────────
  static List<RainfallEntry> rainfallEntries = [
    RainfallEntry(
      id: 'entry_001', stationId: 'RP001', rainfall: 22.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      lat: 21.2514, lng: 81.6296, syncStatus: SyncStatus.synced,
    ),
    RainfallEntry(
      id: 'entry_002', stationId: 'RP007', rainfall: 14.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      lat: 21.2100, lng: 81.9900, remarks: 'Heavy drizzle in the morning',
      syncStatus: SyncStatus.pending,
    ),
    RainfallEntry(
      id: 'entry_003', stationId: 'RP010', rainfall: 11.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      lat: 21.3700, lng: 81.6200, syncStatus: SyncStatus.pending,
    ),
  ];

  // ─── AGGREGATION HELPERS ───────────────────────────────────────

  /// Get all stations belonging to a specific block.
  static List<StationModel> getStationsForBlock(String blockId) {
    return stations.where((s) => s.blockId == blockId).toList();
  }

  /// Get all stations belonging to a specific district.
  static List<StationModel> getStationsForDistrict(String districtId) {
    return stations.where((s) => s.districtId == districtId).toList();
  }

  /// Get all villages belonging to a specific block.
  static List<VillageModel> getVillagesForBlock(String blockId) {
    return villages.where((v) => v.blockId == blockId).toList();
  }

  /// Get all blocks belonging to a specific district.
  static List<BlockModel> getBlocksForDistrict(String districtId) {
    return blocks.where((b) => b.districtId == districtId).toList();
  }

  /// Count reported stations from a list.
  static int countReported(List<StationModel> stationList) {
    return stationList.where((s) => s.status == StationStatus.reported).length;
  }

  /// Count missing stations from a list.
  static int countMissing(List<StationModel> stationList) {
    return stationList.where((s) => s.status == StationStatus.missing).length;
  }

  /// Count pending sync stations from a list.
  static int countPending(List<StationModel> stationList) {
    return stationList.where((s) => s.status == StationStatus.pendingSync).length;
  }

  /// Get missing stations from a list.
  static List<StationModel> getMissingStations(List<StationModel> stationList) {
    return stationList.where((s) => s.status == StationStatus.missing).toList();
  }

  /// Calculate average rainfall from stations that have reported.
  static double getAverageRainfall(List<StationModel> stationList) {
    final reported = stationList.where((s) => s.todayRainfall != null).toList();
    if (reported.isEmpty) return 0;
    final total = reported.fold<double>(0, (sum, s) => sum + s.todayRainfall!);
    return total / reported.length;
  }

  /// Get the station with highest rainfall today.
  static StationModel? getHighestRainfallStation(List<StationModel> stationList) {
    final reported = stationList.where((s) => s.todayRainfall != null).toList();
    if (reported.isEmpty) return null;
    reported.sort((a, b) => b.todayRainfall!.compareTo(a.todayRainfall!));
    return reported.first;
  }

  /// Calculate compliance percentage for a list of stations.
  static double getComplianceRate(List<StationModel> stationList) {
    if (stationList.isEmpty) return 0;
    final reported = stationList.where(
      (s) => s.status == StationStatus.reported || s.status == StationStatus.pendingSync,
    ).length;
    return (reported / stationList.length) * 100;
  }

  /// Get the assigned station for the field operator.
  static StationModel getAssignedStation(String stationId) {
    return stations.firstWhere((s) => s.id == stationId);
  }

  /// Get a block by ID.
  static BlockModel getBlock(String blockId) {
    return blocks.firstWhere((b) => b.id == blockId);
  }

  /// Get a district by ID.
  static DistrictModel getDistrict(String districtId) {
    return districts.firstWhere((d) => d.id == districtId);
  }

  /// Authenticate user and return UserModel if valid.
  static UserModel? authenticate(String username, String password) {
    final cred = credentials[username];
    if (cred != null && cred['password'] == password) {
      return users[cred['userId']];
    }
    return null;
  }
}