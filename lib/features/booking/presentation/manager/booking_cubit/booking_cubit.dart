import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo bookingRepo;
  late final PagingController<int, Booking> _pagingController;
  bool _now = true; // <--- add this

  BookingCubit({
    required this.bookingRepo,
  }) : super(BookingInitial()) {
    _pagingController = PagingController<int, Booking>(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    emit(BookingSuccess(pagingController: _pagingController));
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final result = await bookingRepo.getBooking(pageKey, _now);

      result.fold(
        (failure) {
          _pagingController.error = failure.errMessage;
          emit(BookingFailure(message: failure.errMessage));
        },
        (response) {
          final booking = response.data ?? [];
          final isLastPage = pageKey >= (response.lastPage ?? 1);

          if (isLastPage) {
            _pagingController.appendLastPage(booking);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(booking, nextPageKey);
          }
        },
      );
    } catch (error) {
      _pagingController.error = error.toString();
      emit(BookingFailure(message: error.toString()));
    }
  }

  void setNow(bool value) {
    _now = value;
    print("-------->now: $value    ${_now}");
    _pagingController.refresh();
  }

  void refresh() {
    _pagingController.refresh();
  }

  @override
  Future<void> close() {
    _pagingController.dispose();
    return super.close();
  }
}
