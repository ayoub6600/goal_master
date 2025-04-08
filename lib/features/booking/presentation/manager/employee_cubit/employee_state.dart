part of 'employee_cubit.dart';

sealed class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

final class EmployeeSuccess extends EmployeeState {
  final List<Employee> employees;

  const EmployeeSuccess({required this.employees});

  @override
  List<Object> get props => [employees];
}

final class EmployeeFailure extends EmployeeState {
  final String message;

  const EmployeeFailure({required this.message});

  @override
  List<Object> get props => [message];
}
