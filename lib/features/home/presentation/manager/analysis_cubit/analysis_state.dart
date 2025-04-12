part of 'analysis_cubit.dart';

sealed class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object> get props => [];
}

final class AnalysisInitial extends AnalysisState {}

final class AnalysisLoading extends AnalysisState {}

final class AnalysisLoaded extends AnalysisState {
  final Analysis analysis;
  const AnalysisLoaded(this.analysis);
  @override
  List<Object> get props => [analysis];
}

final class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object> get props => [message];
}
