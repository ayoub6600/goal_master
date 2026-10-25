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
  final VenueMarketingPreview? marketingOffer;

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
    this.marketingOffer,
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
      marketingOffer: json['marketing_offer'] is Map
          ? VenueMarketingPreview.fromJson(
              Map<String, dynamic>.from(json['marketing_offer'] as Map))
          : null,
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

class VenueMarketingPreview {
  const VenueMarketingPreview({
    required this.headline,
    required this.fundedBy,
    this.serviceName,
    this.scheduleLimited = false,
    this.discountType,
    this.discountValue,
    this.schedules = const [],
  });

  final String headline;
  final String fundedBy;
  final String? serviceName;
  final bool scheduleLimited;
  final String? discountType;
  final double? discountValue;
  final List<Map<String, dynamic>> schedules;

  bool appliesOnDate(DateTime date, {int? categoryId}) {
    return schedules.any((schedule) => _scheduleAppliesOnDate(
          schedule,
          date,
          categoryId: categoryId,
        ));
  }

  bool _scheduleAppliesOnDate(
    Map<String, dynamic> schedule,
    DateTime date, {
    int? categoryId,
  }) {
    final starts =
        DateTime.tryParse(schedule['starts_at']?.toString() ?? '')?.toLocal();
    final ends =
        DateTime.tryParse(schedule['ends_at']?.toString() ?? '')?.toLocal();
    final localDate = DateTime(date.year, date.month, date.day);
    if (starts != null &&
        localDate.isBefore(DateTime(starts.year, starts.month, starts.day))) {
      return false;
    }
    if (ends != null &&
        localDate.isAfter(DateTime(ends.year, ends.month, ends.day))) {
      return false;
    }
    final days = (schedule['weekdays'] as List? ?? const [])
        .map((value) => int.tryParse('$value') ?? -1)
        .toList();
    if (days.isNotEmpty && !days.contains(date.weekday % 7)) {
      return false;
    }
    if (categoryId != null &&
        schedule['category_id'] != null &&
        int.tryParse('${schedule['category_id']}') != categoryId) {
      return false;
    }
    if (categoryId != null &&
        schedule['category_id'] == null &&
        schedule['service_id'] != null) {
      return false;
    }
    return true;
  }

  bool appliesAt(String date, String time, {int? categoryId}) {
    final day = DateTime.tryParse(date);
    if (day == null) return false;
    return schedules.any((schedule) {
      if (!_scheduleAppliesOnDate(schedule, day, categoryId: categoryId)) {
        return false;
      }
      final start = schedule['daily_start_time']?.toString();
      final end = schedule['daily_end_time']?.toString();
      final slotTime = time.length >= 5 ? time.substring(0, 5) : time;
      final ranges = (schedule['daily_time_ranges'] as List? ?? const [])
          .whereType<Map>()
          .map((range) => Map<String, dynamic>.from(range))
          .toList();
      if (ranges.isNotEmpty) {
        final inRange = ranges.any((range) {
          final rangeStart = range['start']?.toString();
          final rangeEnd = range['end']?.toString();
          return rangeStart != null &&
              rangeEnd != null &&
              slotTime.compareTo(rangeStart) >= 0 &&
              slotTime.compareTo(rangeEnd) < 0;
        });
        if (!inRange) return false;
      } else if ((start != null && slotTime.compareTo(start) < 0) ||
          (end != null && slotTime.compareTo(end) >= 0)) {
        return false;
      }
      final occurrence = DateTime.tryParse(
          '${day.toIso8601String().substring(0, 10)}T$slotTime:00');
      final startsAt =
          DateTime.tryParse(schedule['starts_at']?.toString() ?? '')?.toLocal();
      final endsAt =
          DateTime.tryParse(schedule['ends_at']?.toString() ?? '')?.toLocal();
      return occurrence != null &&
          (startsAt == null || !occurrence.isBefore(startsAt)) &&
          (endsAt == null || !occurrence.isAfter(endsAt));
    });
  }

  factory VenueMarketingPreview.fromJson(Map<String, dynamic> json) =>
      VenueMarketingPreview(
        headline: json['headline']?.toString() ?? 'عروض وخصومات',
        fundedBy: json['funded_by']?.toString() ?? 'venue',
        serviceName: json['service_name']?.toString(),
        scheduleLimited: json['schedule_limited'] == true,
        discountType: json['discount_type']?.toString(),
        discountValue: (json['discount_value'] as num?)?.toDouble(),
        schedules: (json['schedules'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'funded_by': fundedBy,
        'service_name': serviceName,
        'schedule_limited': scheduleLimited,
        'discount_type': discountType,
        'discount_value': discountValue,
        'schedules': schedules,
      };
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
