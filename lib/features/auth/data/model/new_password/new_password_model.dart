class ResetTokenResponse {
  final bool status;
  final ResetTokenData data;
  final String message;

  ResetTokenResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ResetTokenResponse.fromJson(Map<String, dynamic> json) {
    return ResetTokenResponse(
      status: json['status'].toString().toLowerCase() == 'true',
      data: ResetTokenData.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString(),
      'data': data.toJson(),
      'message': message,
    };
  }
}

class ResetTokenData {
  final String resetToken;

  ResetTokenData({required this.resetToken});

  factory ResetTokenData.fromJson(Map<String, dynamic> json) {
    return ResetTokenData(
      resetToken: json['reset_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
    };
  }
}
