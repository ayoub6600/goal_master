import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

part 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit(this.analysisRepo) : super(AnalysisInitial());
  final AnalysisRepo analysisRepo;

  Future<void> getAnalysis() async {
    emit(AnalysisLoading());
    final result = await analysisRepo.getAnalysis();
    result.fold(
      (failure) => emit(AnalysisError(failure.errMessage)),
      (analysis) => emit(AnalysisLoaded(analysis)),
    );
  }
}
