import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';

/// Two endpoints describe payment status two different ways for the exact
/// same booking. `myBookings` already translates it — `getPaymentStatus()`
/// returns 'paid' / 'pending' / 'partially_paid', the words every screen's
/// `_getPaymentStatusText` switch already expects. `get-info` — reused for
/// one occurrence's own details when a monthly date is tapped — sends the
/// raw `ServicePaymentStatus` column value instead: 1 Paid, 2 Unpaid,
/// 3 PartialPaid.
///
/// Parsed the old way (`_asString`), the raw code became the STRING "2",
/// matched none of the switch's cases, and showed the customer a bare digit
/// where a word belonged. Both shapes are read the same way now, so this
/// stays correct regardless of which endpoint answered.
void main() {
  Map<String, dynamic> bookingJson({required dynamic paymentStatus}) => {
        'id': 100024,
        'branch': 'ملاعب الجدار',
        'address': 'مصراتة',
        'latitude': '0',
        'longitude': '0',
        'date': '2026-09-06',
        'start_time': '20:00:00',
        'end_time': '21:00:00',
        'service': 'سداسي 1',
        'service_amount': '66',
        'paid_amount': '0',
        'payment_status': paymentStatus,
        'payment_type': 'محفظة',
        'status': 2,
        'status_name': 'موافق عليه',
        'remarks': '',
        'category': 'كرة قدم',
      };

  group('already-translated words pass through unchanged', () {
    test('paid / pending / partially_paid', () {
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 'paid')).paymentStatus,
        'paid',
      );
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 'pending')).paymentStatus,
        'pending',
      );
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 'partially_paid'))
            .paymentStatus,
        'partially_paid',
      );
    });
  });

  group('a raw ServicePaymentStatus code is translated the same way', () {
    test('1 Paid, 2 Unpaid, 3 PartialPaid — as an int', () {
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 1)).paymentStatus,
        'paid',
      );
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 2)).paymentStatus,
        'pending',
      );
      expect(
        Booking.fromJson(bookingJson(paymentStatus: 3)).paymentStatus,
        'partially_paid',
      );
    });

    test('the same codes as numeric strings, in case JSON sends them that '
        'way', () {
      expect(
        Booking.fromJson(bookingJson(paymentStatus: '1')).paymentStatus,
        'paid',
      );
      expect(
        Booking.fromJson(bookingJson(paymentStatus: '2')).paymentStatus,
        'pending',
      );
    });

    test('this is the exact failure this fixes: "2" is never shown raw', () {
      final booking = Booking.fromJson(bookingJson(paymentStatus: 2));

      expect(booking.paymentStatus, isNot('2'));
      expect(booking.paymentStatus, 'pending');
    });
  });

  test('an unrecognised value is passed through rather than guessed at', () {
    expect(
      Booking.fromJson(bookingJson(paymentStatus: 'refunded')).paymentStatus,
      'refunded',
    );
  });
}
