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
  final String branchName;
  final int branchZoneId;
  final bool branchAllowLocalPayment;

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
    required this.branchName,
    required this.branchZoneId,
    required this.branchAllowLocalPayment,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: _asInt(json['id']),
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      schServiceCategoryId: _asInt(json['sch_service_category_id']),
      visibility: _asInt(json['visibility']),
      price: json['price']?.toString() ?? '0',
      durationInDays: _asInt(json['duration_in_days']),
      durationInTime: json['duration_in_time']?.toString() ?? '00:00:00',
      timeSlotInTime: json['time_slot_in_time']?.toString() ?? '00:00:00',
      paddingTimeBefore: json['padding_time_before']?.toString() ?? '00:00:00',
      paddingTimeAfter: json['padding_time_after']?.toString() ?? '00:00:00',
      appointmentLimitType: _asInt(json['appoinntment_limit_type']),
      appointmentLimit: _asInt(json['appoinntment_limit']),
      minBookingDays: _asInt(json['minimum_time_required_to_booking_in_days']),
      minBookingTime:
          json['minimum_time_required_to_booking_in_time']?.toString() ??
              '00:00:00',
      minCancelDays: _asInt(json['minimum_time_required_to_cancel_in_days']),
      minCancelTime:
          json['minimum_time_required_to_cancel_in_time']?.toString() ??
              '00:00:00',
      remarks: json['remarks']?.toString() ?? '',
      branchId: _asInt(json['branch_id']),
      branchName: json['branch_name']?.toString() ?? '',
      branchZoneId: _asInt(json['branch_zone_id']),
      branchAllowLocalPayment: json['branch_allow_local_payment'] == true,
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
      'branch_name': branchName,
      'branch_zone_id': branchZoneId,
      'branch_allow_local_payment': branchAllowLocalPayment,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ZoneModel {
  final int id;
  final String name;

  ZoneModel({required this.id, required this.name});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: ServiceModel._asInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class ServiceResponse {
  final String status;
  final List<ServiceModel> data;
  final ZoneModel? zone;

  ServiceResponse({
    required this.status,
    required this.data,
    this.zone,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      status: json['status'],
      data: List<ServiceModel>.from(
          json['data'].map((x) => ServiceModel.fromJson(x))),
      zone: json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}
