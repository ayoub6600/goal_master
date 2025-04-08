import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/service_model.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit(this.bookingRepo) : super(ServiceInitial());
  final BookingRepo bookingRepo;

  Future<void> listService(int categoryId, int branchId) async {
    emit(ServiceLoading());
    final result = await bookingRepo.listService(categoryId, branchId);
    result.fold((failure) => emit(ServiceError(failure.errMessage)), (service) {
      emit(ServiceSuccess(service));
    });
  }
}
