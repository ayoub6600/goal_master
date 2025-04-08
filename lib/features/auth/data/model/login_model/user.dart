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

  @override
  String toString() {
    return 'User(id: $id, name: $name, username: $username, phoneNumber: $phoneNumber, isSysAdm: $isSysAdm, userType: $userType, photo: $photo, schEmployeeId: $schEmployeeId, status: $status, email: $email, emailVerifiedAt: $emailVerifiedAt)';
  }

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
}

class UserData {
  final User? user;
  final String? token;

  UserData({this.user, this.token});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      token: json['token'] as String?,
    );
  }
}

class UpdateProfileResponse {
  final String? status;
  final UserData? data;
  final String? message;

  UpdateProfileResponse({this.status, this.data, this.message});

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
