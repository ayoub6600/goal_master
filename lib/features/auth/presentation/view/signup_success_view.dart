import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/auth/data/model/onboarding/onboarding_screen_model.dart';
import 'package:goal_master/features/auth/data/services/onboarding_screens_service.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/captain_slot.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/onboarding_artwork.dart';

/// The end of signing up.
///
/// Deliberately says nothing about the account handle. The customer signs in
/// with their phone number and nothing in the system looks an account up by
/// handle — putting it here would hand them a question to carry («and what do
/// I do with this?») at the one moment they should simply be getting on with
/// booking a pitch.
class SignupSuccessView extends StatelessWidget {
  const SignupSuccessView({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final screens = OnboardingScreensService.instance;
    final artwork = screens.imageFor(OnboardingSlugs.success);
    final hasArtwork = artwork != null && artwork.isNotEmpty;

    final greeting = (name == null || name!.trim().isEmpty)
        ? 'هلا بيك في Goal Master'
        : 'هلا بيك في Goal Master يا ${name!.trim()}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (!hasArtwork) ...[
                Center(
                  child: CaptainSlot(emoji: '🎉', size: 148, celebrate: true),
                ),
                SizedBox(height: 26.h),
              ],
              Text(
                screens.titleFor(
                    OnboardingSlugs.success, 'تم إنشاء حسابك بنجاح 🎉'),
                textAlign: TextAlign.center,
                style: AppTextStyles.font24Bold
                    .copyWith(color: AppColors.darkBlue),
              ),
              SizedBox(height: 10.h),
              Text(
                screens.subtitleFor(OnboardingSlugs.success, greeting) ??
                    greeting,
                textAlign: TextAlign.center,
                style: AppTextStyles.font16Medium
                    .copyWith(color: AppColors.mainGrey, height: 1.5),
              ),
              if (hasArtwork)
                Expanded(child: Center(child: OnboardingArtwork(imageUrl: artwork)))
              else
                const Spacer(),
              ButtonApp(
                text: 'ابدأ الآن',
                textColor: Colors.white,
                backGround: AppColors.primary,
                // Verifying the number signed the customer in — sending them
                // to a login form here would ask for credentials the app is
                // already holding.
                onTap: () => pushReplacement(RoutesKeys.kHome, context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
