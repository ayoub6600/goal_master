class TimeslotModel {
  String? startTime;
  String? endTime;
  int? isAvailable;

  TimeslotModel({this.startTime, this.endTime, this.isAvailable});

  factory TimeslotModel.fromJson(Map<String, dynamic> json) => TimeslotModel(
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        isAvailable: json['is_available'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
      };
}
