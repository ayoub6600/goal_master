class ClubResponce {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final int order;
  final int status;
  final int createdBy;
  final int? updatedBy;
  final String createdAt;
  final String updatedAt;
  final String lat;
  final String long;
  final String? imageUrl;
  final int zoneId;

  ClubResponce({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.order,
    required this.status,
    required this.createdBy,
    this.updatedBy, // nullable
    required this.createdAt,
    required this.updatedAt,
    required this.lat,
    this.imageUrl,
    required this.long,
    required this.zoneId,
  });

  // Factory constructor لتحويل JSON إلى كائن Dart
  factory ClubResponce.fromJson(Map<String, dynamic> json) {
    return ClubResponce(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      order: json['order'],
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'], // handle nullable updatedBy
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imageUrl: json['image'],
      lat: json['lat'],
      long: json['long'],
      zoneId: json['zone_id'] ?? 0, // Default to 0 if zoneId is null
    );
  }

  // لتحويل الكائن إلى JSON (اختياري)
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
    };
  }
}
