import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/section_play.dart';

class ListSectionPlay extends StatelessWidget {
  const ListSectionPlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnalysisCubit, AnalysisState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is AnalysisLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AnalysisError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is AnalysisLoaded) {
          return SectionPlay(
            analysis: state.analysis,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
