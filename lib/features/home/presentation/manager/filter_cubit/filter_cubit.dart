import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';
import 'package:intl/intl.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this.analysisRepo) : super(FilterInitial());

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
    if ([
      bookingStart,
      bookingEnd,
    ].any((e) => e == null || e!.isEmpty)) {
      emit(FilterError("يرجى إدخال جميع البيانات"));
      return;
    }
    // تنسيق التواريخ باستخدام DateFormat
    String formattedBookingStart =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingStart!));
    String formattedBookingEnd =
        DateFormat("yyyy-MM-dd").format(DateTime.parse(bookingEnd!));
    // تنسيق startTime و endTime
    // String formattedStartTime =
    //     startTime != null ? formatTimeOfDay(startTime! as TimeOfDay) : "";
    // String formattedEndTime =
    //     endTime != null ? formatTimeOfDay(endTime! as TimeOfDay) : "";

    emit(FilterLoading());
    final result = await analysisRepo.filterBooking(
      formattedBookingStart,
      formattedBookingEnd,
      branchId ?? "",
      startTime ?? "",
      endTime ?? "",
      categoryId ?? "",
    );

    result.fold(
      (failure) => emit(FilterError(failure.errMessage)),
      (bookingSlotsResponse) => emit(FilterLoaded(bookingSlotsResponse)),
    );
  }
}
