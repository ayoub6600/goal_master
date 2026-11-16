import 'data.dart';

class LoginModel {
  String? status;
  Data? data;

  /// Set when the account was created but the code could not be sent —
  /// shown on the code screen so the customer knows to press resend.
  String? notice;

  LoginModel({this.status, this.data});

  @override
  String toString() => 'LoginModel(status: $status, data: $data)';

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json['status'] as String?,
        data: json['data'] == null
            ? null
            : Data.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}
