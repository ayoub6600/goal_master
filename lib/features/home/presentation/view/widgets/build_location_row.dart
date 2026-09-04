import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/view/required_location_view.dart';

/// The Home location chip.
///
/// Reads the Active Location and nothing else. It used to show whatever
/// address LayoutCubit had reverse-geocoded, which was a different fact from
/// the one Home's venue list was scoped by — so the chip could name one place
/// while the pitches below came from another.
///
/// Tapping it opens the same centralized chooser as the required-location
/// screen. One widget for both, so "change location" and "choose location"
/// cannot drift into writing location two different ways.
class BuildLocationRow extends StatelessWidget {
  const BuildLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveLocationCubit, ActiveLocationState>(
      builder: (context, state) {
        final location = state.location;

        final label = location == null
            ? 'اختر موقعك'
            : (location.isServiceable
                ? location.displayName
                : 'خارج نطاق الخدمة');

        return Row(
          children: [
            Image.asset(Assets.imagesPngImageLocation, color: AppColors.primary),
            const SizedBox(width: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * .4,
              child: Text(
                label,
                key: const Key('home_location_label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font16Medium.copyWith(
                  color: location?.isServiceable == false
                      ? Colors.red
                      : AppColors.grey,
                ),
              ),
            ),
            IconButton(
              key: const Key('home_change_location'),
              icon: Image.asset(Assets.imagesPngImageArrowDown),
              onPressed: () => _openChooser(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openChooser(BuildContext context) async {
    final servicesCubit = context.read<GetServicesInfoCubit>();
    final locationCubit = context.read<ActiveLocationCubit>();

    final before = locationCubit.state.location;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: locationCubit,
          child: RequiredLocationView(
            isBlocking: false,
            // Closes itself as soon as a usable location is set, so the
            // customer is not left looking at the chooser wondering whether it
            // worked.
            onResolved: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );

    if (!context.mounted) return;

    final after = locationCubit.state.location;

    // Only refetch when the answer actually changed. Re-requesting on every
    // dismissal would flash the venue list for a customer who backed out.
    if (after != null && after != before) {
      // No coordinates passed: the repository reads the Active Location, which
      // is the same source everything else uses. Passing them here would be a
      // second path to the same fact.
      await servicesCubit.getServicesInfo();
    }
  }
}
