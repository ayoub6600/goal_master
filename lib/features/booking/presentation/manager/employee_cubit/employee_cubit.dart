import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/employe/employe.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  EmployeeCubit(this.bookingRepo) : super(EmployeeInitial());
  final BookingRepo bookingRepo;

  Future<void> listEmployee(int branchId) async {
    emit(EmployeeLoading());
    final result = await bookingRepo.listEmployee(branchId: branchId);
    result.fold((failure) => emit(EmployeeFailure(message: failure.errMessage)),
        (employee) {
      emit(EmployeeSuccess(employees: employee));
    });
  }
}
