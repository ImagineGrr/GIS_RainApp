/// Represents a village in the administrative hierarchy.
class VillageModel {
  final String id;
  final String name;
  final String blockId;
  final List<String> stationIds;

  const VillageModel({
    required this.id,
    required this.name,
    required this.blockId,
    required this.stationIds,
  });
}

/// Represents a block (tehsil) in the administrative hierarchy.
class BlockModel {
  final String id;
  final String name;
  final String districtId;
  final List<String> villageIds;
  final double centerLat;
  final double centerLng;

  const BlockModel({
    required this.id,
    required this.name,
    required this.districtId,
    required this.villageIds,
    required this.centerLat,
    required this.centerLng,
  });
}

/// Represents a district in the administrative hierarchy.
class DistrictModel {
  final String id;
  final String name;
  final String stateId;
  final List<String> blockIds;
  final double centerLat;
  final double centerLng;

  const DistrictModel({
    required this.id,
    required this.name,
    required this.stateId,
    required this.blockIds,
    required this.centerLat,
    required this.centerLng,
  });
}
