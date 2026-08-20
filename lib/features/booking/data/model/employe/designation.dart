class Designation {
  int? id;
  String? name;
  int? order;
  int? createdBy;
  int? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  Designation({
    this.id,
    this.name,
    this.order,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Designation.fromJson(Map<String, dynamic> json) => Designation(
        id: _asNullableInt(json['id']),
        name: _asNullableString(json['name']),
        order: _asNullableInt(json['order']),
        createdBy: _asNullableInt(json['created_by']),
        updatedBy: _asNullableInt(json['updated_by']),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.tryParse(json['updated_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
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
