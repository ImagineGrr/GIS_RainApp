/// Defines the hierarchical roles in the rainfall monitoring system.
enum UserRole {
  field,    // Village-level field operator
  block,    // Block-level officer
  district, // District-level officer
  state,    // State-level admin
}

/// Extension to get display-friendly role information.
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.field:
        return 'Field Operator';
      case UserRole.block:
        return 'Block Officer';
      case UserRole.district:
        return 'District Officer';
      case UserRole.state:
        return 'State Admin';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.field:
        return 'FO';
      case UserRole.block:
        return 'BO';
      case UserRole.district:
        return 'DO';
      case UserRole.state:
        return 'SA';
    }
  }
}

/// Represents a user in the rainfall monitoring system.
class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final String phone;
  final String assignedAreaId; // stationId for field, blockId for block, etc.
  final String assignedAreaName;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.assignedAreaId,
    required this.assignedAreaName,
  });
}
