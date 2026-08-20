class Branch {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? address;
  int? order;
  int? status;
  int? createdBy;
  dynamic updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? lat;
  String? long;
  int? zoneId;

  Branch({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.order,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.lat,
    this.long,
    this.zoneId,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: _asNullableInt(json['id']),
        name: _asNullableString(json['name']),
        phone: _asNullableString(json['phone']),
        email: _asNullableString(json['email']),
        address: _asNullableString(json['address']),
        order: _asNullableInt(json['order']),
        status: _asNullableInt(json['status']),
        createdBy: _asNullableInt(json['created_by']),
        updatedBy: json['updated_by'] as dynamic,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.tryParse(json['updated_at'].toString()),
        lat: _asNullableString(json['lat']),
        long: _asNullableString(json['long']),
        zoneId: _asNullableInt(json['zone_id']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'order': order,
        'status': status,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'lat': lat,
        'long': long,
        'zone_id': zoneId,
      };
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
  return stringValue.isEmpty || stringValue == 'null' ? null : stringValue;
}
