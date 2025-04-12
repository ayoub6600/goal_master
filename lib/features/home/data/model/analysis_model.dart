class Analysis {
  final int pending;
  final int processing;
  final int approved;
  final int cancel;
  final int done;

  Analysis({
    required this.pending,
    required this.processing,
    required this.approved,
    required this.cancel,
    required this.done,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      pending: json['Pending'] ?? 0,
      processing: json['Processing'] ?? 0,
      approved: json['Approved'] ?? 0,
      cancel: json['Cancel'] ?? 0,
      done: json['Done'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pending': pending,
      'Processing': processing,
      'Approved': approved,
      'Cancel': cancel,
      'Done': done,
    };
  }
}

class ResponseModel {
  final bool status;
  final Analysis data;

  ResponseModel({
    required this.status,
    required this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      status: json['status'] ?? false,
      data: Analysis.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}
