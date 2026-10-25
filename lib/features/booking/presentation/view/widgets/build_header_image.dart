import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/onboarding/presentation/view/onboarding_view.dart';

class BuildHeaderImage extends StatelessWidget {
  const BuildHeaderImage({super.key, this.booking});
  final Booking? booking;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        SizedBox(
          height: 270.h,
          child: ClipPath(
            clipper: ShapePainter(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (booking?.serviceImage.isNotEmpty != true)
                  Image.asset(Assets.imagesPngImageBackgroundLogin,
                      width: double.infinity, fit: BoxFit.cover)
                else
                  Image.network(
                    booking!.serviceImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      Assets.imagesPngImageBackgroundLogin,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xAA000000)],
                    ),
                  ),
                ),
                Positioned(
                  right: 20.w,
                  bottom: 38.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (booking != null)
                        Text(booking!.service,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold)),
                      if (booking != null)
                        Text(booking!.branch,
                            style: TextStyle(
                                color: Colors.white, fontSize: 16.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              Assets.imagesPngImageArrowSquareRight,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
