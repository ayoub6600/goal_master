class BookingSlotsResponse {
  final List<BookingSlot> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  BookingSlotsResponse({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory BookingSlotsResponse.fromJson(Map<String, dynamic> json) {
    return BookingSlotsResponse(
      data: List<BookingSlot>.from(
          json['data'].map((x) => BookingSlot.fromJson(x))),
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
    );
  }
}

class BookingSlot {
  final String date;
  final String startTime;
  final String endTime;
  final int clubId;
  final String club;
  final int categoryId;
  final String categoryName;
  final int serviceId;
  final String serviceTitle;
  final String address;
  final String latitude;
  final String longitude;
  final List<int> employees;
  final List<String> employeesName;

  BookingSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.clubId,
    required this.club,
    required this.categoryId,
    required this.categoryName,
    required this.serviceId,
    required this.serviceTitle,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.employees,
    required this.employeesName,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      clubId: json['club_id'],
      club: json['club'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      serviceId: json['service_id'],
      serviceTitle: json['service_title'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      employees: List<int>.from(json['employees'] ?? []),
      employeesName: List<String>.from(json['employees_name'] ?? []),
    );
  }
}
