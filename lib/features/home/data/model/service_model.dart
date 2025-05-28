class ServiceModel {
  final int id;
  final String category;
  final String title;
  final String? imageUrl;
  final int schServiceCategoryId;
  final int visibility;
  final String price;
  final int durationInDays;
  final String durationInTime;
  final String timeSlotInTime;
  final String paddingTimeBefore;
  final String paddingTimeAfter;
  final int appointmentLimitType;
  final int appointmentLimit;
  final int minBookingDays;
  final String minBookingTime;
  final int minCancelDays;
  final String minCancelTime;
  final String remarks;
  final int branchId;

  ServiceModel({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.schServiceCategoryId,
    required this.visibility,
    required this.price,
    required this.durationInDays,
    required this.durationInTime,
    required this.timeSlotInTime,
    required this.paddingTimeBefore,
    required this.paddingTimeAfter,
    required this.appointmentLimitType,
    required this.appointmentLimit,
    required this.minBookingDays,
    required this.minBookingTime,
    required this.minCancelDays,
    required this.minCancelTime,
    required this.remarks,
    required this.branchId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      imageUrl: json['image_url'],
      schServiceCategoryId: json['sch_service_category_id'],
      visibility: json['visibility'],
      price: json['price'],
      durationInDays: json['duration_in_days'],
      durationInTime: json['duration_in_time'],
      timeSlotInTime: json['time_slot_in_time'],
      paddingTimeBefore: json['padding_time_before'],
      paddingTimeAfter: json['padding_time_after'],
      appointmentLimitType: json['appoinntment_limit_type'],
      appointmentLimit: json['appoinntment_limit'],
      minBookingDays: json['minimum_time_required_to_booking_in_days'],
      minBookingTime: json['minimum_time_required_to_booking_in_time'],
      minCancelDays: json['minimum_time_required_to_cancel_in_days'],
      minCancelTime: json['minimum_time_required_to_cancel_in_time'],
      remarks: json['remarks'],
      branchId: json['branch_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'image_url': imageUrl,
      'sch_service_category_id': schServiceCategoryId,
      'visibility': visibility,
      'price': price,
      'duration_in_days': durationInDays,
      'duration_in_time': durationInTime,
      'time_slot_in_time': timeSlotInTime,
      'padding_time_before': paddingTimeBefore,
      'padding_time_after': paddingTimeAfter,
      'appoinntment_limit_type': appointmentLimitType,
      'appoinntment_limit': appointmentLimit,
      'minimum_time_required_to_booking_in_days': minBookingDays,
      'minimum_time_required_to_booking_in_time': minBookingTime,
      'minimum_time_required_to_cancel_in_days': minCancelDays,
      'minimum_time_required_to_cancel_in_time': minCancelTime,
      'remarks': remarks,
      'branch_id': branchId,
    };
  }
}

class ServiceResponse {
  final String status;
  final List<ServiceModel> data;

  ServiceResponse({
    required this.status,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      status: json['status'],
      data: List<ServiceModel>.from(
          json['data'].map((x) => ServiceModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}
