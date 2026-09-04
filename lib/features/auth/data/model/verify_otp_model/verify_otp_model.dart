import 'package:collection/collection.dart';
import 'package:goal_master/features/auth/data/model/verify_otp_model/data.dart';


class VerifyOtpModel {
  String? status;
  Data? data;
  String? message;

  VerifyOtpModel({this.status, this.data, this.message});

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      status: json['status'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
        'message': message,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! VerifyOtpModel) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => status.hashCode ^ data.hashCode ^ message.hashCode;
}
