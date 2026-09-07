// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';

/// A single wallet-paid booking is marked Done (status 4) the instant it's
/// paid — saveBooking() confirms it immediately, with no manager-approval
/// step — so it can be far in the future and still carry that status. The
/// cancel button used to only render for status 0 (Pending) or 1
/// (Processing), which hid it for exactly this case, and for any
/// manager-approved (status 2) pay-on-arrival booking. Whether cancelling
/// is actually allowed is the backend's call, made when the confirmation
/// sheet asks — this button only needs to exist for anything not already
/// cancelled.
class _FakeBookingRepo implements BookingRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Booking _booking({required int status}) {
  return Booking(
    id: 100030,
    branch: 'ملاعب الجدار',
    address: 'مصراتة',
    latitude: '0',
    longitude: '0',
    date: '2026-12-06',
    startTime: '22:00:00',
    endTime: '23:00:00',
    service: 'سداسي 1',
    serviceAmount: '66',
    paidAmount: '66',
    paymentStatus: '2',
    paymentType: 'محفظة',
    status: status,
    statusName: 'status',
    remarks: '',
    category: 'كرة قدم',
  );
}

Widget _host(Booking booking) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider(
              create: (_) => CancelBookingCubit(_FakeBookingRepo()),
              child: BookingItems(booking: booking),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a Done (wallet-paid, far in the future) booking still shows a cancel button',
      (tester) async {
    await tester.pumpWidget(_host(_booking(status: 4)));
    await tester.pumpAndSettle();

    expect(find.text('الغاء الحجز'), findsOneWidget);
  });

  testWidgets('a manager-approved pay-on-arrival booking still shows a cancel button',
      (tester) async {
    await tester.pumpWidget(_host(_booking(status: 2)));
    await tester.pumpAndSettle();

    expect(find.text('الغاء الحجز'), findsOneWidget);
  });

  testWidgets('an already-cancelled booking shows no cancel button',
      (tester) async {
    await tester.pumpWidget(_host(_booking(status: 3)));
    await tester.pumpAndSettle();

    expect(find.text('الغاء الحجز'), findsNothing);
  });
}
