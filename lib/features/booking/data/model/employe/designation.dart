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
        id: json['id'] as int?,
        name: json['name'] as String?,
        order: json['order'] as int?,
        createdBy: json['created_by'] as int?,
        updatedBy: json['updated_by'] as int?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
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
