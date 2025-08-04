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
    var bookingList = json['data'] as List;
    List<Booking> bookings =
        bookingList.map((i) => Booking.fromJson(i)).toList();

    return BookingHistoryResponse(
      currentPage: json['current_page'],
      bookings: bookings,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List).map((i) => PageLink.fromJson(i)).toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
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
      id: json['id'] ?? 0,
      branch: json['branch'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      service: json['service'] ?? '',
      serviceAmount: json['service_amount'].toString(),
      paidAmount: json['paid_amount'].toString(),
      paymentStatus: json['payment_status'].toString(),
      paymentType: json['payment_type'] ?? '',
      status: json['status'] ?? 0,
      statusName: json['status_name'] ?? '',
      remarks: json['remarks'] ?? '',
      category: json['category'] ?? '',
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
      label: json['label'],
      active: json['active'],
    );
  }
}
