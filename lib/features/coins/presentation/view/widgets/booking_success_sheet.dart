import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';

const _gold = Color(0xFFFFB300);
const _goldDark = Color(0xFFE59400);
const _goldBg = Color(0xFFFFF8E1);

/// Booking-confirmed screen: Captain Ayoub congratulating the customer, plus
/// what the booking did for their coins.
///
/// Shows what was *spent* (known immediately) and that a reward is on its way
/// once the booking completes — deliberately not a number, because the backend
/// only awards it on completion and inventing one here would be a promise the
/// app can't keep.
Future<void> showBookingSuccessSheet(
  BuildContext context, {
  required int coinsRedeemed,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<AssistantChatCubit>(),
      child: _BookingSuccessContent(coinsRedeemed: coinsRedeemed),
    ),
  );
}

class _BookingSuccessContent extends StatelessWidget {
  const _BookingSuccessContent({required this.coinsRedeemed});

  final int coinsRedeemed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          _captainAvatar(context),
          const SizedBox(height: 14),
          Text(
            'يعطيك الصحة 🔥',
            style: AppTextStyles.font20Bold.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'حجزك تم بنجاح',
            style: AppTextStyles.font16Medium
                .copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          _coinsSummary(),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'تمام',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reuses the admin-uploaded booking_success avatar so the captain's mood
  /// here matches the same state the chat would show.
  Widget _captainAvatar(BuildContext context) {
    return BlocBuilder<AssistantChatCubit, AssistantChatState>(
      buildWhen: (previous, current) =>
          previous.avatarStates != current.avatarStates,
      builder: (context, state) {
        final url = state.avatarFor('booking_success');
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: ClipOval(
            child: url != null
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
          ),
        );
      },
    );
  }

  Widget _fallbackIcon() => Icon(
        Icons.sports_soccer,
        color: AppColors.primary,
        size: 44,
      );

  Widget _coinsSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _goldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          if (coinsRedeemed > 0) ...[
            Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'استخدمت $coinsRedeemed كوينز في هذا الحجز',
                    style: AppTextStyles.font14Medium,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
          ],
          Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'كوينز المكافأة تنضاف لرصيدك بعد ما يكتمل الحجز',
                  style: AppTextStyles.font14Medium
                      .copyWith(color: _goldDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
