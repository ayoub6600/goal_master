import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/custom_error_widget.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/section_play.dart';
import 'package:shimmer/shimmer.dart';

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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: List.generate(1, (index) {
                  return SectionPlay(
                    analysis: Analysis(
                      approved: 0,
                      cancel: 0,
                      pending: 0,
                      processing: 0,
                      done: 0,
                    ),
                  );
                }),
              ),
            ),
          );
        } else if (state is AnalysisError) {
          return CustomErrorWidget(
            message: state.message,
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
