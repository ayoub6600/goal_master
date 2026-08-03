class Service {
  final int id;
  final String title;
  final String image;
  final int schServiceCategoryId;
  final int visibility;
  final String price;
  final String? cmnCouponId; // Nullable field
  final String? cmnCouponAmount; // Nullable field
  final int durationInDays;
  final String durationInTime;
  final String timeSlotInTime;
  final String paddingTimeBefore;
  final String paddingTimeAfter;
  final int appointmentLimitType;
  final int appointmentLimit;
  final int minimumTimeRequiredToBookingInDays;
  final String minimumTimeRequiredToBookingInTime;
  final int minimumTimeRequiredToCancelInDays;
  final String minimumTimeRequiredToCancelInTime;
  final String remarks;
  final String? createdBy; // Nullable field
  final String? updatedBy; // Nullable field
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.title,
    required this.image,
    required this.schServiceCategoryId,
    required this.visibility,
    required this.price,
    this.cmnCouponId,
    this.cmnCouponAmount,
    required this.durationInDays,
    required this.durationInTime,
    required this.timeSlotInTime,
    required this.paddingTimeBefore,
    required this.paddingTimeAfter,
    required this.appointmentLimitType,
    required this.appointmentLimit,
    required this.minimumTimeRequiredToBookingInDays,
    required this.minimumTimeRequiredToBookingInTime,
    required this.minimumTimeRequiredToCancelInDays,
    required this.minimumTimeRequiredToCancelInTime,
    required this.remarks,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for converting JSON to Dart object
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      schServiceCategoryId: json['sch_service_category_id'],
      visibility: json['visibility'],
      price: json['price']?.toString() ?? '0',
      cmnCouponId: json['cmn_coupon_id']?.toString(),
      cmnCouponAmount: json['cmn_coupon_amount']?.toString(),
      durationInDays: json['duration_in_days'],
      durationInTime: json['duration_in_time']?.toString() ?? '00:00:00',
      timeSlotInTime: json['time_slot_in_time']?.toString() ?? '00:00:00',
      paddingTimeBefore:
          json['padding_time_before']?.toString() ?? '00:00:00',
      paddingTimeAfter: json['padding_time_after']?.toString() ?? '00:00:00',
      appointmentLimitType: json['appoinntment_limit_type'],
      appointmentLimit: json['appoinntment_limit'],
      minimumTimeRequiredToBookingInDays:
          json['minimum_time_required_to_booking_in_days'],
      minimumTimeRequiredToBookingInTime:
          json['minimum_time_required_to_booking_in_time']?.toString() ??
              '00:00:00',
      minimumTimeRequiredToCancelInDays:
          json['minimum_time_required_to_cancel_in_days'],
      minimumTimeRequiredToCancelInTime:
          json['minimum_time_required_to_cancel_in_time']?.toString() ??
              '00:00:00',
      remarks: json['remarks']?.toString() ?? '',
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  // Method to convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'sch_service_category_id': schServiceCategoryId,
      'visibility': visibility,
      'price': price,
      'cmn_coupon_id': cmnCouponId,
      'cmn_coupon_amount': cmnCouponAmount,
      'duration_in_days': durationInDays,
      'duration_in_time': durationInTime,
      'time_slot_in_time': timeSlotInTime,
      'padding_time_before': paddingTimeBefore,
      'padding_time_after': paddingTimeAfter,
      'appoinntment_limit_type': appointmentLimitType,
      'appoinntment_limit': appointmentLimit,
      'minimum_time_required_to_booking_in_days':
          minimumTimeRequiredToBookingInDays,
      'minimum_time_required_to_booking_in_time':
          minimumTimeRequiredToBookingInTime,
      'minimum_time_required_to_cancel_in_days':
          minimumTimeRequiredToCancelInDays,
      'minimum_time_required_to_cancel_in_time':
          minimumTimeRequiredToCancelInTime,
      'remarks': remarks,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
