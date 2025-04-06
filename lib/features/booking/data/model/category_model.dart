class CategoryModel {
  final int id;
  final String name;
  final int createdBy;
  final int? modifiedBy; // Nullable because it can be null
  final String createdAt;
  final String updatedAt;
  final int cmnBranchId;
  final CmnBranch cmnBranch;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.modifiedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.cmnBranchId,
    required this.cmnBranch,
  });

  // Factory constructor to convert JSON to Dart object
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
      modifiedBy: json['modified_by'], // Nullable
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      cmnBranchId: json['cmn_branch_id'],
      cmnBranch: CmnBranch.fromJson(json['cmn_branch']), // Parse nested object
    );
  }

  // To convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'modified_by': modifiedBy, // Nullable
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cmn_branch_id': cmnBranchId,
      'cmn_branch': cmnBranch.toJson(), // Convert nested object to JSON
    };
  }
}

class CmnBranch {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final int order;
  final int status;
  final int createdBy;
  final int? updatedBy; // Nullable because it can be null
  final String createdAt;
  final String updatedAt;
  final String lat;
  final String long;
  final int zoneId;

  CmnBranch({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.order,
    required this.status,
    required this.createdBy,
    this.updatedBy, // Nullable
    required this.createdAt,
    required this.updatedAt,
    required this.lat,
    required this.long,
    required this.zoneId,
  });

  // Factory constructor to convert JSON to Dart object
  factory CmnBranch.fromJson(Map<String, dynamic> json) {
    return CmnBranch(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      order: json['order'],
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'], // Nullable
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lat: json['lat'],
      long: json['long'],
      zoneId: json['zone_id'] ?? 0, // Default to 0 if zoneId is null
    );
  }

  // To convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'order': order,
      'status': status,
      'created_by': createdBy,
      'updated_by': updatedBy, // Nullable
      'created_at': createdAt,
      'updated_at': updatedAt,
      'lat': lat,
      'long': long,
      'zone_id': zoneId,
    };
  }
}
