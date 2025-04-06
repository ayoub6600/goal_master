import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'club_state.dart';

class ClubCubit extends Cubit<ClubState> {
  ClubCubit(this.bookingRepo) : super(ClubInitial());
  final BookingRepo bookingRepo;
  Future<void> listClub(int zoneId) async {
    emit(ClubLoading());
    final result = await bookingRepo.listClub(zoneId);
    result.fold((failure) => emit(ClubError(message: failure.errMessage)),
        (club) {
      emit(ClubSuccess(clubs: club));
    });
  }
}
