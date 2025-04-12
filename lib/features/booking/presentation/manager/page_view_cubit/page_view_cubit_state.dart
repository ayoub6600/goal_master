part of 'page_view_cubit_cubit.dart';

class PageViewState extends Equatable {
  final int currentPage;
  final int? clubId;
  final int? employeeId;
  final int? categoryId;
  final int? serviceId;
  final int? zoneId;
  final String? selectedDate;

  const PageViewState({
    required this.currentPage,
    this.clubId,
    this.categoryId,
    this.employeeId,
    this.serviceId,
    this.zoneId,
    this.selectedDate,
  });

  PageViewState copyWith({
    int? currentPage,
    int? clubId,
    int? employeeId,
    int? categoryId,
    int? serviceId,
    int? zoneId,
    String? selectedDate,
  }) {
    return PageViewState(
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
