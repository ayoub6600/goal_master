class CancelBookingResponse {
  final bool status;
  final BookingData? data;

  CancelBookingResponse({required this.status, this.data});

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) {
    return CancelBookingResponse(
      status: json['status'].toString() == 'true',
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
    );
  }
}

class BookingData {
  final String? status;
  final List<BookingItem>? data;
  final ServiceTimeSlot? serviceTimeSlot;
  final StatusDetails? statusDetails;

  BookingData({
    this.status,
    this.data,
    this.serviceTimeSlot,
    this.statusDetails,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      status: json['status'],
      data:
          (json['data'] as List?)?.map((e) => BookingItem.fromJson(e)).toList(),
      serviceTimeSlot: json['serviceTimeSlot'] != null
          ? ServiceTimeSlot.fromJson(json['serviceTimeSlot'])
          : null,
      statusDetails: json['status_details'] != null
          ? StatusDetails.fromJson(json['status_details'])
          : null,
    );
  }
}

class BookingItem {
  final int? id;
  final String? branch;
  final String? employee;
  final String? designation;
  final String? imageUrl;
  final List<BookingService>? bookingService;

  BookingItem({
    this.id,
    this.branch,
    this.employee,
    this.designation,
    this.imageUrl,
    this.bookingService,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'],
      branch: json['branch'],
      employee: json['employee'],
      designation: json['designation'],
      imageUrl: json['image_url'],
      bookingService: (json['booking_service'] as List?)
          ?.map((e) => BookingService.fromJson(e))
          .toList(),
    );
  }
}

class BookingService {
  final int? id;
  final int? schEmployeeId;
  final String? customer;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? service;
  final int? status;

  BookingService({
    this.id,
    this.schEmployeeId,
    this.customer,
    this.date,
    this.startTime,
    this.endTime,
    this.service,
    this.status,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id'],
      schEmployeeId: json['sch_employee_id'],
      customer: json['customer'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      service: json['service'],
      status: json['status'],
    );
  }
}

class ServiceTimeSlot {
  final DateTime? startTime;
  final DateTime? endTime;

  ServiceTimeSlot({this.startTime, this.endTime});

  factory ServiceTimeSlot.fromJson(Map<String, dynamic> json) {
    return ServiceTimeSlot(
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'])
          : null,
      endTime:
          json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
    );
  }
}

class StatusDetails {
  final int? statusCode;
  final String? statusDescription;

  StatusDetails({
    this.statusCode,
    this.statusDescription,
  });

  factory StatusDetails.fromJson(Map<String, dynamic> json) {
    return StatusDetails(
      statusCode: json['status_code'],
      statusDescription: json['status_description'],
    );
  }
}
