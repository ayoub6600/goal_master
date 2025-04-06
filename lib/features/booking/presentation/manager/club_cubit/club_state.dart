part of 'club_cubit.dart';

sealed class ClubState extends Equatable {
  const ClubState();

  @override
  List<Object> get props => [];
}

final class ClubInitial extends ClubState {}

final class ClubLoading extends ClubState {}

final class ClubSuccess extends ClubState {
  final List<ClubResponce> clubs;

  const ClubSuccess({required this.clubs});
  @override
  List<Object> get props => [clubs];
}

final class ClubError extends ClubState {
  final String message;
  const ClubError({required this.message});
  @override
  List<Object> get props => [message];
}
