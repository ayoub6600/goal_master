part of 'change_password_cubit.dart';

@immutable
sealed class ChangePasswordState {}

final class ChangePasswordInitial extends ChangePasswordState {}

final class ChangePasswordLoading extends ChangePasswordState {}

final class ChangePasswordError extends ChangePasswordState {
  final String message;
  ChangePasswordError({required this.message});
}

final class ChangePasswordSuccess extends ChangePasswordState {
  final String message;
  ChangePasswordSuccess({required this.message});
}
