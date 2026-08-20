class BookingHistoryResponse {
  final int currentPage;
  final List<Booking> bookings;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final int to;
  final int total;

  BookingHistoryResponse({
    required this.currentPage,
    required this.bookings,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    var bookingList = (json['data'] as List?) ?? const [];
    List<Booking> bookings =
        bookingList.map((i) => Booking.fromJson(i)).toList();

    return BookingHistoryResponse(
      currentPage: _asInt(json['current_page']),
      bookings: bookings,
      firstPageUrl: _asString(json['first_page_url']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      lastPageUrl: _asString(json['last_page_url']),
      links: ((json['links'] as List?) ?? const [])
          .map((i) => PageLink.fromJson(i as Map<String, dynamic>))
          .toList(),
      nextPageUrl: _asString(json['next_page_url']),
      path: _asString(json['path']),
      perPage: _asInt(json['per_page']),
      to: _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }
}

class Booking {
  final int id;
  final String branch;
  final String address;
  final String latitude;
  final String longitude;
  final String date;
  final String startTime;
  final String endTime;
  final String service;
  final String serviceAmount;
  final String paidAmount;
  final String paymentStatus;
  final String paymentType;
  final int status;
  final String statusName;
  final String remarks;
  final String category;

  Booking({
    required this.id,
    required this.branch,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.service,
    required this.serviceAmount,
    required this.paidAmount,
    required this.paymentStatus,
    required this.paymentType,
    required this.status,
    required this.statusName,
    required this.remarks,
    required this.category,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _asInt(json['id']),
      branch: _asString(json['branch']),
      address: _asString(json['address']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      service: _asString(json['service']),
      serviceAmount: _asString(json['service_amount']),
      paidAmount: _asString(json['paid_amount']),
      paymentStatus: _asString(json['payment_status']),
      paymentType: _asString(json['payment_type']),
      status: _asInt(json['status']),
      statusName: _asString(json['status_name']),
      remarks: _asString(json['remarks']),
      category: _asString(json['category']),
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: _asString(json['label']),
      active: json['active'] == true,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  final stringValue = value?.toString();
  if (stringValue == null || stringValue == 'null') {
    return '';
  }
  return stringValue;
}
