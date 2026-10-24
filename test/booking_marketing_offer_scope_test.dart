import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';

void main() {
  group('booking marketing offer scope', () {
    late PageViewCubit cubit;

    setUp(() => cubit = PageViewCubit());
    tearDown(() => cubit.close());

    test('a service-specific offer is cleared for another service', () {
      cubit.setClubId(
        2,
        'الجدار الرياضي',
        allowLocalPayment: true,
        marketingOffer: const {
          'headline': 'خصومات حتى 30%',
          'service_name': 'ملعب رقم 1',
          'funded_by': 'platform',
        },
      );

      cubit.setServiceId(4, 'ملعب رقم 2');

      expect(cubit.state.marketingOffer, isNull);
      expect(cubit.state.serviceId, 4);
    });

    test('the offer remains for the service it targets', () {
      cubit.setClubId(
        2,
        'الجدار الرياضي',
        allowLocalPayment: true,
        marketingOffer: const {
          'headline': 'خصومات حتى 30%',
          'service_name': 'ملعب رقم 1',
          'funded_by': 'platform',
        },
      );

      cubit.setServiceId(3, 'ملعب رقم 1');

      expect(cubit.state.marketingOffer?['headline'], 'خصومات حتى 30%');
    });

    test('changing to a club without a discovery offer clears the old one', () {
      cubit.setClubId(
        2,
        'الجدار الرياضي',
        allowLocalPayment: true,
        marketingOffer: const {'headline': 'خصومات حتى 30%'},
      );

      cubit.setClubId(9, 'ملعب آخر', allowLocalPayment: false);

      expect(cubit.state.marketingOffer, isNull);
    });
  });
}
