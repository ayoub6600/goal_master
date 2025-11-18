import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

part 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit(this.analysisRepo) : super(AnalysisInitial());
  final AnalysisRepo analysisRepo;

  Future<void> getAnalysis() async {
    emit(AnalysisLoading());

    final loginState = SharedPreferenceUtil.getString(PrefKey.login);

    // 🔥 لو المستخدم مش عامل Login → رجّع Static Data مباشرة
    if (loginState != "true") {
      emit(AnalysisLoaded(Analysis.staticData()));
      return;
    }

    // 🔥 لو عامل Login → نفّذ الـ API
    final result = await analysisRepo.getAnalysis();
    result.fold(
      (failure) => emit(AnalysisError(failure.errMessage)),
      (analysis) => emit(AnalysisLoaded(analysis)),
    );
  }
}
