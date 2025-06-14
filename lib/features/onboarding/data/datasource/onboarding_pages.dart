import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/onboarding/data/model/onboarding_model.dart';

class OnboardingPages {
  static List<OnboardingModel> getPages(BuildContext context) {
    return [
      OnboardingModel(
        title: "أفضل الملاعب بأفضل الأسعار",
        subtitle:
            "نوفر لك أفضل العروض والتخفيضات على حجز الملاعب، عروض خاصة للمباريات الجماعية مع خيارات دفع مريحة وسهلة.",
        imageIndex: 0,
        images: Assets.imagesPngImageOn2,
      ),
      OnboardingModel(
        title: "احجز ملعبك بكل سهولة ",
        subtitle:
            "سواء كنت تبي تلعب كرة قدم، تنس، أو أي رياضة ثانية، احجز ملعبك بأسرع وقت وبضغطة زر.",
        imageIndex: 1,
        images: Assets.imagesPngImage1,
      ),
      OnboardingModel(
        title: "جهّز فريقك وتحدى الأصدقاء",
        subtitle: "شارك في بطولات، كوّن فريقك، ونافس أقوى اللاعبين في منطقتك",
        imageIndex: 2,
        images: Assets.imagesPngImageOn3,
      ),
    ];
  }
}
