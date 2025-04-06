import 'package:flutter_bloc/flutter_bloc.dart';

import 'booking_toggle_state.dart';

class ToggleCubit extends Cubit<BookingToggleState> {
  ToggleCubit() : super(BookingDoctors());

  Future<void> toggle({required bool isDoc}) async {
    if (isDoc) {
      emit(BookingDoctors());
    } else {
      emit(BookingArticles());
    }
  }
}
