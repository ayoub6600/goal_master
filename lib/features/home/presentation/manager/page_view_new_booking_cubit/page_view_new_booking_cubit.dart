import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';

part 'page_view_new_booking_cubitstate.dart';

class PageViewNewBookingCubit extends Cubit<PageViewNewBookingState> {
  PageViewNewBookingCubit()
      : super(const PageViewNewBookingState(currentPage: 0));

  void nextPage() {
    if (state.currentPage < 2) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void setClubId(int id) {
    emit(state.copyWith(clubId: id));
  }

  void setZoneId(int id) {
    emit(state.copyWith(zoneId: id));
  }

  void setCategoryId(int id) {
    emit(state.copyWith(categoryId: id));
  }

  void setEmployeeId(int id) {
    emit(state.copyWith(employeeId: id));
  }

  void setServiceId(int id) {
    emit(state.copyWith(serviceId: id));
  }

  void setDate(String date) {
    emit(state.copyWith(selectedDate: date));
  }

  void reset() {
    emit(const PageViewNewBookingState(currentPage: 0));
  }
}
