class ClubResponce {
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
  final String? imageUrl;
  final int zoneId;
  final bool allowLocalPayment;

  ClubResponce({
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
    this.imageUrl,
    this.long,
    required this.zoneId,
    required this.allowLocalPayment,
  });

  factory ClubResponce.fromJson(Map<String, dynamic> json) {
    return ClubResponce(
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
      imageUrl: _asNullableString(json['image'] ?? json['image_url']),
      lat: _asNullableString(json['lat']),
      long: _asNullableString(json['long']),
      zoneId: _asInt(json['zone_id']),
      allowLocalPayment: _asBool(json['allow_local_payment']),
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
      'updated_by': updatedBy, // it can be null
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_url': imageUrl,
      'lat': lat,
      'long': long,
      'zone_id': zoneId,
      'allow_local_payment': allowLocalPayment,
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

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}
