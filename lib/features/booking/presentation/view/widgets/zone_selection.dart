import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/zone_cubit/zone_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/location_items_booking.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class ZoneSelection extends StatelessWidget {
  final PageController controller;

  const ZoneSelection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZoneCubitCubit, ZoneCubitState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepTitle(
              title: "اختر المنطقة",
              description: "اختر المنطقة المناسبة للحجز الذي تريده",
            ),
            if (state is ZoneCubitSuccess)
              Expanded(
                child: ListView.builder(
                  itemCount: state.location.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      context
                          .read<PageViewCubit>()
                          .setZoneId(state.location[index].id);
                      context
                          .read<ClubCubit>()
                          .listClub(state.location[index].id);
                      context.read<PageViewCubit>().nextPage();
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: LocationItemsBooking(
                      title: state.location[index].name,
                    ),
                  ),
                ),
              ),
            if (state is ZoneCubitError) Text('خطأ: ${state.message}'),
            if (state is ZoneCubitLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {},
                    child: LocationItemsBooking(
                      title: '.......',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
