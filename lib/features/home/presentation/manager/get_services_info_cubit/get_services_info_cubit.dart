import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

part 'get_services_info_state.dart';

class GetServicesInfoCubit extends Cubit<GetServicesInfoState> {
  GetServicesInfoCubit(this.analysisRepo) : super(GetServicesInfoInitial());
  final AnalysisRepo analysisRepo;

  Future<void> getServicesInfo() async {
    emit(GetServicesInfoLoading());
    final result = await analysisRepo.getService();
    result.fold((l) => emit(GetServicesInfoError(errMessage: l.errMessage)),
        (r) => emit(GetServicesInfoSuccess(services: r)));
  }
}
