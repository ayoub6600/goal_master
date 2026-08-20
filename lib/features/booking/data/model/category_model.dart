class CategoryModel {
  final int id;
  final String name;
  final int? createdBy;
  final int? modifiedBy;
  final String? createdAt;
  final String? updatedAt;
  final int cmnBranchId;
  final CmnBranch cmnBranch;

  CategoryModel({
    required this.id,
    required this.name,
    this.createdBy,
    this.modifiedBy,
    this.createdAt,
    this.updatedAt,
    required this.cmnBranchId,
    required this.cmnBranch,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      createdBy: _asNullableInt(json['created_by']),
      modifiedBy: _asNullableInt(json['modified_by']),
      createdAt: _asNullableString(json['created_at']),
      updatedAt: _asNullableString(json['updated_at']),
      cmnBranchId: _asInt(json['cmn_branch_id']),
      cmnBranch: CmnBranch.fromJson(
        (json['cmn_branch'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

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
  final String? phone;
  final String? email;
  final String? address;
  final int order;
  final int status;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? lat;
  final String? long;
  final int zoneId;

  CmnBranch({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.order,
    required this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.lat,
    this.long,
    required this.zoneId,
  });

  factory CmnBranch.fromJson(Map<String, dynamic> json) {
    return CmnBranch(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: _asNullableString(json['phone']),
      email: _asNullableString(json['email']),
      address: _asNullableString(json['address']),
      order: _asInt(json['order']),
      status: _asInt(json['status']),
      createdBy: _asNullableInt(json['created_by']),
      updatedBy: _asNullableInt(json['updated_by']),
      createdAt: _asNullableString(json['created_at']),
      updatedAt: _asNullableString(json['updated_at']),
      lat: _asNullableString(json['lat']),
      long: _asNullableString(json['long']),
      zoneId: _asInt(json['zone_id']),
    );
  }

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

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}
