import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'page_view_cubit_state.dart';

class PageViewCubit extends Cubit<PageViewState> {
  PageViewCubit() : super(const PageViewState(currentPage: 0));

  /// The booking wizard's steps, by name.
  ///
  /// These were bare numbers scattered across the screen, and the last time
  /// they drifted the customer got a blank checkout — the state said one page
  /// and the PageController showed another. Removing «اختر المنطقة» shifted
  /// every index down by one, which is exactly the change that would have
  /// reintroduced that bug. Named once, here, so the next change to the step
  /// list moves one line.
  static const int club = 0;
  static const int category = 1;
  static const int service = 2;
  // The time-band step is gone from the customer flow; the server decides
  // which band a slot belongs to. `employeeId` remains on the state because
  // booking still needs it — it now arrives with the chosen slot.
  static const int calendar = 3;
  static const int timeSlot = 4;
  static const int checkout = 5;

  static const int lastPage = checkout;

  void nextPage() {
    if (state.currentPage < lastPage) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  /// Jump straight to a step. Callers must move the PageController to the
  /// same index — the two together are what "which page are we on" means,
  /// and letting them disagree renders a half-empty screen.
  void goToPage(int page) {
    if (page < 0) return;
    emit(state.copyWith(currentPage: page));
  }

  void previousPage() {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void setClubId(int id, String title, {required bool allowLocalPayment}) {
    emit(
      state.copyWith(
        clubId: id,
        clubTitle: title,
        allowLocalPayment: allowLocalPayment,
      ),
    );
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
