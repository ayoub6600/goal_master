import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this.analysisRepo) : super(FilterInitial()) {
    _pagingController = PagingController<int, BookingSlot>(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  late final PagingController<int, BookingSlot> _pagingController;

  final AnalysisRepo analysisRepo;

  String? bookingStart;
  String? bookingEnd;
  String? startTime;
  String? endTime;
  String? branchId;
  String? categoryId;

  void updateBookingStart(String date) => bookingStart = date;
  void updateBookingEnd(String date) => bookingEnd = date;
  void updateStartTime(String time) => startTime = time;
  void updateEndTime(String time) => endTime = time;
  void updateBranchId(String id) => branchId = id;
  void updateCategoryId(String id) => categoryId = id;

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat("HH:mm:ss").format(dateTime);
  }

  Future<void> filterBooking() async {
    if ([bookingStart, bookingEnd].any((e) => e == null || e!.isEmpty)) {
      emit(FilterError("يرجى اختيار التاريخ"));
      return;
    }

    // Formatting dates
    String formattedBookingStart =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingStart!));
    String formattedBookingEnd =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingEnd!));

    emit(FilterLoading());

    final result = await analysisRepo.filterBooking(
      formattedBookingStart,
      formattedBookingEnd,
      branchId ?? "",
      startTime ?? "",
      endTime ?? "",
      categoryId ?? "",
      1, // Page number for initial request
    );

    result.fold((failure) => emit(FilterError(failure.errMessage)),
        (bookingSlotsResponse) {
      emit(FilterLoaded(bookingSlotsResponse, _pagingController));
      _pagingController.refresh();
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    String formattedBookingStart =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingStart!));
    String formattedBookingEnd =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingEnd!));
    try {
      final result = await analysisRepo.filterBooking(
        formattedBookingStart,
        formattedBookingEnd,
        branchId ?? "",
        startTime ?? "",
        endTime ?? "",
        categoryId ?? "",
        pageKey,
      );

      result.fold(
        (failure) {
          _pagingController.error = failure.errMessage;
          emit(FilterError(failure.errMessage));
        },
        (bookingSlotsResponse) {
          final bookings = bookingSlotsResponse.data;
          final isLastPage = pageKey >= (bookingSlotsResponse.lastPage);

          if (isLastPage) {
            _pagingController.appendLastPage(bookings);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(bookings, nextPageKey);
          }
        },
      );
    } catch (error) {
      _pagingController.error = error.toString();
      emit(FilterError(error.toString()));
    }
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
