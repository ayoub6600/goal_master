import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'page_view_cubit_state.dart';

class PageViewCubit extends Cubit<PageViewState> {
  PageViewCubit() : super(const PageViewState(currentPage: 0));

  void nextPage() {
    if (state.currentPage < 7) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void setClubId(int id, String title) {
    emit(state.copyWith(clubId: id, clubTitle: title));
  }

  void setZoneId(int id, String title) {
    emit(state.copyWith(zoneId: id, zoneTitle: title));
  }

  void setCategoryId(int id, String title) {
    emit(state.copyWith(categoryId: id, categoryTitle: title));
  }

  void setEmployeeId(
    int id,
  ) {
    emit(state.copyWith(employeeId: id));
  }

  void setServiceId(int id, String title) {
    emit(state.copyWith(serviceId: id, serviceTitle: title));
  }

  void setDate(String date) {
    emit(state.copyWith(selectedDate: date));
  }

  void reset() {
    emit(const PageViewState(currentPage: 0));
  }
}
