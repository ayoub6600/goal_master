import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/home/presentation/view/widgets/change_location_view.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

/// The one place a customer chooses where they are shopping from.
///
/// Used both as the blocking screen when nothing is set and as the chooser
/// behind the Home location chip. Deliberately the same widget for both: a
/// second "change location" sheet would drift from this one, and the two would
/// eventually write location differently.
///
/// It never resolves a zone itself. It hands coordinates to the cubit, which
/// hands them to the server. A device that decides which zone a point is in
/// will disagree with the backend the first time a boundary moves.
class RequiredLocationView extends StatefulWidget {
  const RequiredLocationView({
    super.key,
    this.isBlocking = true,
    this.onResolved,
  });

  /// Blocking mode has no back button — there is nowhere useful to go until a
  /// location exists. Opened from the Home chip it is dismissible.
  final bool isBlocking;

  /// Called once a serviceable location is set. This is what lets an
  /// interrupted booking carry on by itself instead of dumping the customer
  /// back on Home to press احجز الآن again.
  final VoidCallback? onResolved;

  @override
  State<RequiredLocationView> createState() => _RequiredLocationViewState();
}

class _RequiredLocationViewState extends State<RequiredLocationView> {
  /// True from the tap until the location is committed or has failed.
  ///
  /// Covers the GPS acquisition too, not just the server call. Getting a fix
  /// walks a chain of guarded calls that can take many seconds, and with no
  /// indicator the screen looked inert — so the customer taps again, and the
  /// second tap is the one that gets confusing.
  bool _locating = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveLocationCubit, ActiveLocationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: widget.isBlocking
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: Colors.black,
                  title: const Text('تغيير الموقع'),
                ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.location_on, size: 64, color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    'حدد موقعك',
                    key: const Key('required_location_title'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font24Bold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لنُظهر لك الملاعب المناسبة لموقعك',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font16Medium
                        .copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: 32),

                  _Option(
                    key: const Key('option_current_location'),
                    icon: Icons.my_location,
                    title: 'موقعي الحالي',
                    subtitle: _locating
                        ? 'جاري تحديد موقعك...'
                        : 'استخدم الـ GPS لتحديد موقعك',
                    // Disabled for the whole operation, GPS included — a
                    // second tap while a fix is on its way starts nothing and
                    // only makes the screen feel broken.
                    enabled: !state.isSubmitting && !_locating,
                    busy: _locating,
                    onTap: () => _useCurrentLocation(context),
                  ),
                  const SizedBox(height: 12),
                  _Option(
                    key: const Key('option_map'),
                    icon: Icons.map_outlined,
                    title: 'تحديد على الخريطة',
                    subtitle: 'اختر موقعك يدويًا على الخريطة',
                    enabled: !state.isSubmitting && !_locating,
                    onTap: () => _pickOnMap(context),
                  ),

                  // Hidden entirely when there is nothing saved. An option that
                  // opens an empty list is a dead end dressed as a choice, and
                  // a first-time customer meets it before they can possibly
                  // have saved anything.
                  if (state.saved.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Option(
                      key: const Key('option_saved'),
                      icon: Icons.bookmark_outline,
                      title: 'المواقع المحفوظة',
                      subtitle: '${state.saved.length} موقع محفوظ',
                      enabled: !state.isSubmitting && !_locating,
                      onTap: () => _pickSaved(context, state.saved),
                    ),
                  ],

                  if (state.status == ActiveLocationStatus.unserviceable) ...[
                    const SizedBox(height: 20),
                    _Notice(
                      key: const Key('unserviceable_notice'),
                      // Said plainly. Widening the search to every city would
                      // hide the real answer behind pitches nobody can reach.
                      message:
                          'لا توجد ملاعب متاحة في هذا الموقع حاليًا. جرّب موقعًا آخر.',
                    ),
                  ],

                  if (state.error != null) ...[
                    const SizedBox(height: 20),
                    _Notice(
                      key: const Key('location_error_notice'),
                      message: state.error!,
                    ),
                  ],

                  const Spacer(),
                  if (state.isSubmitting)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// «موقعي الحالي» — one reading, not a subscription.
  ///
  /// This is a marketplace choice, not live tracking. Nothing here starts a
  /// location stream, and the customer's position is not watched afterwards.
  Future<void> _useCurrentLocation(BuildContext context) async {
    // The in-flight guard. The enabled: flag above hides the button, but the
    // state is the thing that actually prevents a second GPS request.
    if (_locating) return;
    setState(() => _locating = true);

    try {
      await _resolveCurrentLocation(context);
    } finally {
      // Cleared only once the location is COMMITTED or has failed — never at
      // the point coordinates arrive. "We have a fix" is not "the app agrees
      // where you are".
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _resolveCurrentLocation(BuildContext context) async {
    final locationCubit = context.read<ActiveLocationCubit>();
    final layoutCubit = context.read<LayoutCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await layoutCubit.initUserLocation();
    final position = layoutCubit.state.currentPosition;

    if (position == null) {
      if (!context.mounted) return;

      // Permission refused, or the device could not produce a fix. The
      // customer is not trapped: the map is right there and needs no
      // permission at all.
      final permanentlyDenied =
          await Permission.location.status.then((s) => s.isPermanentlyDenied);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'تعذّر تحديد موقعك. يمكنك اختيار موقعك على الخريطة.',
          ),
          action: permanentlyDenied
              ? SnackBarAction(
                  label: 'الإعدادات',
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
      return;
    }

    final address = layoutCubit.state.currentFullAddress;

    final ok = await locationCubit.setFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      source: 'current_location',
      formattedAddress: address.isEmpty ? null : address,
      // Kept in the list: a customer who shops from where they live will want
      // it again, and asking them to name it first would be friction for
      // nothing.
      //
      // Deliberately UNNAMED. It used to be labelled «موقعي», which then won
      // the display and told a customer standing in Misurata that they were
      // in "my location" — a word that names nothing. How the point was
      // obtained (source: current_location) and what the place is called are
      // two different facts; with no label the display falls through to the
      // zone the SERVER resolved, so the chip reads «مصراتة».
      save: true,
    );

    if (ok) widget.onResolved?.call();
  }

  /// «تحديد على الخريطة» — the existing picker, used as a picker.
  ///
  /// ChangeLocationView already does the map well. What it must NOT do any more
  /// is decide anything: it returns a point, and the cubit turns that into the
  /// active location. Before this it wrote raw coordinates to SharedPreferences
  /// itself, which is precisely how the app ended up with two location systems.
  Future<void> _pickOnMap(BuildContext context) async {
    final locationCubit = context.read<ActiveLocationCubit>();
    final layoutCubit = context.read<LayoutCubit>();

    final confirmed = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeLocationView(
          zoneId: locationCubit.state.zoneId,
        ),
      ),
    );

    if (confirmed != true) return;

    final position = layoutCubit.state.currentPosition;
    if (position == null) return;

    final address = layoutCubit.state.currentFullAddress;

    final ok = await locationCubit.setFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      source: 'map',
      formattedAddress: address.isEmpty ? null : address,
      save: true,
    );

    if (ok) widget.onResolved?.call();
  }

  Future<void> _pickSaved(
    BuildContext context,
    List<ActiveLocation> saved,
  ) async {
    final locationCubit = context.read<ActiveLocationCubit>();

    final chosen = await showModalBottomSheet<ActiveLocation>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('المواقع المحفوظة', style: AppTextStyles.font16Medium),
            ),
            for (final location in saved)
              ListTile(
                key: Key('saved_location_${location.id}'),
                leading: Icon(Icons.place, color: AppColors.primary),
                title: Text(location.displayName),
                subtitle: location.isServiceable
                    ? Text(location.zoneName ?? '')
                    : const Text(
                        'خارج نطاق الخدمة حاليًا',
                        style: TextStyle(color: Colors.red),
                      ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await locationCubit.deleteSaved(location.id);
                  },
                ),
                onTap: () => Navigator.pop(sheetContext, location),
              ),
          ],
        ),
      ),
    );

    if (chosen == null) return;

    final ok = await locationCubit.selectSaved(chosen.id);
    if (ok) widget.onResolved?.call();
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  /// Swaps the leading icon for a spinner, so the row itself shows that the
  /// tap landed rather than leaving the customer to guess.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (busy)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.font16Medium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.font12Medium
                        .copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.font12Medium.copyWith(color: Colors.orange[900]),
      ),
    );
  }
}
