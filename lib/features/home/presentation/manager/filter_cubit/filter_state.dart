part of 'filter_cubit.dart';

sealed class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object> get props => [];
}

final class FilterInitial extends FilterState {}

final class FilterLoading extends FilterState {}

final class FilterLoaded extends FilterState {
  final BookingSlotsResponse filter;
  const FilterLoaded(this.filter);

  @override
  List<Object> get props => [filter];
}

final class FilterError extends FilterState {
  final String message;
  const FilterError(this.message);

  @override
  List<Object> get props => [message];
}
