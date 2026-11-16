import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/auth/data/services/onboarding_screens_service.dart';
import 'package:goal_master/features/onboarding/data/model/onboarding_model.dart';

/// The welcome slides. Picture, title and text come from the admin panel's
/// «شاشات الترحيب» when set there; the wording and small pictures below are
/// what the app shows otherwise.
class OnboardingPages {
  static List<OnboardingModel> getPages(BuildContext context) {
    final screens = OnboardingScreensService.instance;

    OnboardingModel page(
      int index,
      String slug,
      String title,
      String subtitle,
      String asset,
    ) =>
        OnboardingModel(
          imageIndex: index,
          slug: slug,
          title: screens.titleFor(slug, title),
          subtitle: screens.subtitleFor(slug, subtitle) ?? subtitle,
          images: asset,
          imageUrl: screens.imageFor(slug),
        );

    return [
      page(
        0,
        'intro_1',
        "أفضل الملاعب بأفضل الأسعار",
        "نوفر لك أفضل العروض والتخفيضات على حجز الملاعب، عروض خاصة للمباريات الجماعية مع خيارات دفع مريحة وسهلة.",
        Assets.imagesPngImageOn2,
      ),
      page(
        1,
        'intro_2',
        "احجز ملعبك بكل سهولة",
        "اختر الملعب والوقت اللي يناسبك، واحجز ملعب كرة القدم بضغطة زر.",
        Assets.imagesPngImage1,
      ),
      page(
        2,
        'intro_3',
        "جهّز فريقك وتحدى الأصدقاء",
        "شارك في بطولات، كوّن فريقك، ونافس أقوى اللاعبين في منطقتك",
        Assets.imagesPngImageOn3,
      ),
    ];
  }
}
