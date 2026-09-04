import 'package:collection/collection.dart';

class User {
  int? id;
  String? name;
  String? username;
  String? phoneNumber;
  int? isSysAdm;
  int? userType;
  dynamic photo;
  dynamic schEmployeeId;
  int? status;
  dynamic email;
  dynamic emailVerifiedAt;

  User({
    this.id,
    this.name,
    this.username,
    this.phoneNumber,
    this.isSysAdm,
    this.userType,
    this.photo,
    this.schEmployeeId,
    this.status,
    this.email,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        name: json['name'] as String?,
        username: json['username'] as String?,
        phoneNumber: json['phone_number'] as String?,
        isSysAdm: json['is_sys_adm'] as int?,
        userType: json['user_type'] as int?,
        photo: json['photo'] as dynamic,
        schEmployeeId: json['sch_employee_id'] as dynamic,
        status: json['status'] as int?,
        email: json['email'] as dynamic,
        emailVerifiedAt: json['email_verified_at'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'phone_number': phoneNumber,
        'is_sys_adm': isSysAdm,
        'user_type': userType,
        'photo': photo,
        'sch_employee_id': schEmployeeId,
        'status': status,
        'email': email,
        'email_verified_at': emailVerifiedAt,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      phoneNumber.hashCode ^
      isSysAdm.hashCode ^
      userType.hashCode ^
      photo.hashCode ^
      schEmployeeId.hashCode ^
      status.hashCode ^
      email.hashCode ^
      emailVerifiedAt.hashCode;
}
