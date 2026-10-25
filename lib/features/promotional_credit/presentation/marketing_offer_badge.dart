import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';

/// A compact, consistent offer marker used in venue and booking lists.
class MarketingOfferBadge extends StatelessWidget {
  const MarketingOfferBadge({super.key, required this.offer});

  final VenueMarketingPreview offer;

  @override
  Widget build(BuildContext context) {
    final funder = offer.fundedBy == 'platform' ? 'جول ماستر' : 'الملعب';
    final detail = [
      if (offer.serviceName != null) offer.serviceName!,
      funder,
      if (offer.fundedBy == 'platform') 'الدفع بالمحفظة',
      if (offer.scheduleLimited) 'حسب الموعد',
    ].join(' · ');

    return Tooltip(
      message: 'الخصم النهائي يتحدد عند اختيار الموعد · $detail',
      child: Container(
        constraints: BoxConstraints(maxWidth: 240.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xffeaf5e9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_offer_outlined,
              size: 14.sp, color: const Color(0xff2f7b3b)),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              offer.fundedBy == 'platform'
                  ? '${offer.headline} · للمحفظة'
                  : offer.headline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.font12Bold
                  .copyWith(color: const Color(0xff286b33)),
            ),
          ),
        ]),
      ),
    );
  }
}
