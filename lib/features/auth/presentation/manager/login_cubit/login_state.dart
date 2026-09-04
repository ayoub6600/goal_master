part of 'login_cubit.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginError extends LoginState {
  final String errMessage;

  const LoginError(this.errMessage);
}

/// The account exists and the password is right, but the phone code was never
/// confirmed. A fresh code is already on its way, so this state is a
/// destination — the code screen — not an error to show and stop at.
final class LoginNeedsVerification extends LoginState {
  final String phone;
  final String message;

  const LoginNeedsVerification(this.phone, this.message);
}
