part of 'page_view_new_booking_cubit.dart';

class PageViewNewBookingState extends Equatable {
  final int currentPage;
  final int? clubId;
  final int? employeeId;
  final int? categoryId;
  final int? serviceId;
  final int? zoneId;
  final String? selectedDate;

  const PageViewNewBookingState({
    required this.currentPage,
    this.clubId,
    this.categoryId,
    this.employeeId,
    this.serviceId,
    this.zoneId,
    this.selectedDate,
  });

  PageViewNewBookingState copyWith({
    int? currentPage,
    int? clubId,
    int? employeeId,
    int? categoryId,
    int? serviceId,
    int? zoneId,
    String? selectedDate,
  }) {
    return PageViewNewBookingState(
        currentPage: currentPage ?? this.currentPage,
        clubId: clubId ?? this.clubId,
        employeeId: employeeId ?? this.employeeId,
        serviceId: serviceId ?? this.serviceId,
        categoryId: categoryId ?? this.categoryId,
        selectedDate: selectedDate ?? this.selectedDate,
        zoneId: zoneId ?? this.zoneId);
  }

  @override
  List<Object?> get props => [
        currentPage,
        clubId,
        employeeId,
        serviceId,
        selectedDate,
        zoneId,
        categoryId
      ];
}
