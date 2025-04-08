import 'package:flutter/material.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_view_body.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        allowBack: false, title: 'حجوزاتي', child: BookingViewBody());
  }
}
