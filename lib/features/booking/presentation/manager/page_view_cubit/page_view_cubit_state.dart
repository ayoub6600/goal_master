part of 'page_view_cubit_cubit.dart';

class PageViewState extends Equatable {
  final int currentPage;
  final int? clubId;
  final int? employeeId;
  final int? categoryId;
  final int? serviceId;
  final int? zoneId;
  final String? zoneTitle;
  final String? serviceTitle;
  final String? categoryTitle;
  final String? employeeTitle;
  final String? clubTitle;
  final String? selectedDate;

  const PageViewState({
    required this.currentPage,
    this.clubId,
    this.employeeId,
    this.categoryId,
    this.serviceId,
    this.zoneId,
    this.zoneTitle,
    this.serviceTitle,
    this.categoryTitle,
    this.employeeTitle,
    this.clubTitle,
    this.selectedDate,
  });

  PageViewState copyWith({
    int? currentPage,
    int? clubId,
    int? employeeId,
    int? categoryId,
    int? serviceId,
    int? zoneId,
    String? zoneTitle,
    String? serviceTitle,
    String? categoryTitle,
    String? employeeTitle,
    String? clubTitle,
    String? selectedDate,
  }) {
    return PageViewState(
      currentPage: currentPage ?? this.currentPage,
      clubId: clubId ?? this.clubId,
      employeeId: employeeId ?? this.employeeId,
      serviceId: serviceId ?? this.serviceId,
      categoryId: categoryId ?? this.categoryId,
      zoneId: zoneId ?? this.zoneId,
      zoneTitle: zoneTitle ?? this.zoneTitle,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      employeeTitle: employeeTitle ?? this.employeeTitle,
      clubTitle: clubTitle ?? this.clubTitle,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        clubId,
        employeeId,
        serviceId,
        zoneId,
        categoryId,
        zoneTitle,
        serviceTitle,
        categoryTitle,
        employeeTitle,
        clubTitle,
        selectedDate,
      ];
}
