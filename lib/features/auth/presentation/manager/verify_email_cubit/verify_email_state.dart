part of 'verify_email_cubit.dart';

sealed class VerifyEmailState {
  const VerifyEmailState();
}

final class VerifyEmailInitial extends VerifyEmailState {}

final class VerifyEmailLoading extends VerifyEmailState {}

final class VerifyEmailSuccess extends VerifyEmailState {
  final ResetTokenResponse model;

  final bool nextPage;
  const VerifyEmailSuccess(
    this.model, {
    this.nextPage = false,
  });
}

final class VerifyEmailError extends VerifyEmailState {
  final String errMessage;

  const VerifyEmailError(this.errMessage);
}

final class VerifyResend extends VerifyEmailState {
  final String massage;

  const VerifyResend(this.massage);
}
