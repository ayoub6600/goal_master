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
        id: json['id'] as int?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        order: json['order'] as int?,
        status: json['status'] as int?,
        createdBy: json['created_by'] as int?,
        updatedBy: json['updated_by'] as dynamic,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
        lat: json['lat'] as String?,
        long: json['long'] as String?,
        zoneId: json['zone_id'] as int?,
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
