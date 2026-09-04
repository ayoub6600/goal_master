import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/captain_slot.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/onboarding_artwork.dart';

/// The shape every signup step shares: one question, one field, one button.
///
/// Kept as a single scaffold so the three steps cannot drift apart in
/// spacing, wording weight or button placement — the whole point of splitting
/// the form up is that each screen feels like the same conversation
/// continuing, not like three separate forms.
class SignupStepScaffold extends StatelessWidget {
  const SignupStepScaffold({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.emoji,
    required this.question,
    required this.field,
    required this.ctaText,
    required this.onCta,
    this.subtitle,
    this.error,
    this.isBusy = false,
    this.onBack,
    this.artworkUrl,
  });

  final int stepIndex;
  final int totalSteps;
  final String emoji;
  final String question;
  final String? subtitle;
  final Widget field;
  final String ctaText;
  final VoidCallback? onCta;
  final String? error;
  final bool isBusy;
  final VoidCallback? onBack;

  /// Artwork the admin panel uploaded for this step, if any.
  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    final hasArtwork = artworkUrl != null && artworkUrl!.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        // Laid out against the space actually available, so the keyboard
        // rising over half the screen scrolls the step rather than
        // overflowing it.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        if (onBack != null)
                          IconButton(
                            onPressed: isBusy ? null : onBack,
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            color: AppColors.mainGrey,
                          )
                        else
                          SizedBox(width: 40.w),
                        const Spacer(),
                        _progress(),
                        const Spacer(),
                        SizedBox(width: 40.w),
                      ],
                    ),

                    // The badge and the artwork are two answers to the same
                    // question — showing both stacks two focal points on one
                    // screen, so the uploaded drawing replaces the badge.
                    SizedBox(height: hasArtwork ? 12.h : 24.h),
                    if (!hasArtwork) ...[
                      Center(child: CaptainSlot(emoji: emoji)),
                      SizedBox(height: 22.h),
                    ],

                    Text(
                      question,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font20Bold
                          .copyWith(color: AppColors.darkBlue),
                    ),

                    if (subtitle != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Regular
                            .copyWith(color: AppColors.mainGrey, height: 1.45),
                      ),
                    ],

                    SizedBox(height: 26.h),
                    field,

                    // Reserved space, so the layout does not jump the moment an
                    // error appears — a shifting screen reads as a glitch.
                    SizedBox(
                      height: 34.h,
                      child: error == null
                          ? null
                          : Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 15.sp, color: AppColors.errorRed),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      error!,
                                      style: AppTextStyles.font12Bold
                                          .copyWith(color: AppColors.errorRed),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // The lower half: the drawing takes the room left over
                    // between the field and the button, exactly as the empty
                    // space did before there was one.
                    Expanded(
                      child: hasArtwork
                          ? Center(child: OnboardingArtwork(imageUrl: artworkUrl))
                          : const SizedBox.shrink(),
                    ),

                    ButtonApp(
                      text: ctaText,
                      textColor: Colors.white,
                      backGround: AppColors.primary,
                      isLoading: isBusy,
                      onTap: isBusy ? null : onCta,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Three dots, so the customer can see the end from the first screen.
  Widget _progress() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final done = i <= stepIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: (i == stepIndex ? 22 : 8).w,
          height: 8.h,
          decoration: BoxDecoration(
            color: done
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }
}
