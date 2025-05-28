import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/model/banner_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

part 'banner_cubit_state.dart';

class BannerCubitCubit extends Cubit<BannerCubitState> {
  BannerCubitCubit(this.analysisRepo) : super(BannerCubitInitial());
  final AnalysisRepo analysisRepo;

  Future<void> getBanner() async {
    emit(BannerCubitLoading());
    final result = await analysisRepo.getBanner();
    result.fold(
      (failure) => emit(BannerCubitError(failure.errMessage)),
      (slider) => emit(BannerCubitLoaded(slider)),
    );
  }
}
