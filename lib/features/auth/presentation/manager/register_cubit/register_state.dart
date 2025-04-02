part of 'register_cubit.dart';

sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  RegisterSuccess();
}

final class RegisterError extends RegisterState {
  final String errMessage;

  RegisterError(this.errMessage);
}
