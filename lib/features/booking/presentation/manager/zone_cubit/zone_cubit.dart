import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'zone_state.dart';

class ZoneCubitCubit extends Cubit<ZoneCubitState> {
  ZoneCubitCubit(this.bookingRepo) : super(ZoneCubitInitial());
  final BookingRepo bookingRepo;

  Future<void> listZone() async {
    emit(ZoneCubitLoading());
    final result = await bookingRepo.listZone();
    result.fold((failure) => emit(ZoneCubitError(message: failure.errMessage)),
        (location) {
      emit(ZoneCubitSuccess(location: location));
    });
  }
}
