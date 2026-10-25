import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';
import 'package:goal_master/features/promotional_credit/data/promotional_credit_repo.dart';
import 'package:goal_master/features/promotional_credit/presentation/venue_campaign_cubit.dart';

void main() {
  test('marketing preview marks only configured weekdays and hours', () {
    final preview = VenueMarketingPreview.fromJson({
      'headline': 'خصم 40 د.ل',
      'funded_by': 'platform',
      'schedules': [
        {
          'category_id': 8,
          'starts_at': '2026-10-25T00:00:00+02:00',
          'ends_at': '2026-10-27T23:59:59+02:00',
          'weekdays': [0, 1, 2],
          'daily_start_time': '17:00',
          'daily_end_time': '21:00',
        },
      ],
    });

    expect(
        preview.appliesOnDate(DateTime(2026, 10, 25), categoryId: 8), isTrue);
    expect(
        preview.appliesOnDate(DateTime(2026, 10, 28), categoryId: 8), isFalse);
    expect(
        preview.appliesOnDate(DateTime(2026, 10, 25), categoryId: 9), isFalse);
    expect(preview.appliesAt('2026-10-25', '18:00', categoryId: 8), isTrue);
    expect(preview.appliesAt('2026-10-25', '21:00', categoryId: 8), isFalse);
  });

  test('switching back to wallet reapplies the best eligible offer', () async {
    final cubit = VenueCampaignCubit(_StubPromotionalCreditRepo());
    addTearDown(cubit.close);

    await cubit.load(
      branchId: 1,
      serviceId: 2,
      amount: 140,
      bookingAt: '2026-10-25T18:00:00',
    );
    expect(cubit.state.selectedOffer?.id, 12);

    cubit.setWalletSelected(false);
    expect(cubit.state.selectedOffer?.id, 13);

    cubit.setWalletSelected(true);
    expect(cubit.state.selectedOffer?.id, 12);
  });
}

class _StubPromotionalCreditRepo extends PromotionalCreditRepo {
  _StubPromotionalCreditRepo() : super(_NoopApiConsumer());

  @override
  Future<Either<Failure, List<VenueMarketingOffer>>> getVenueOffers({
    required int branchId,
    required int serviceId,
    required double amount,
    required String bookingAt,
  }) async =>
      const Right([
        VenueMarketingOffer(
          id: 12,
          name: 'خصم جول ماستر',
          discount: 40,
          fundedBy: 'platform',
        ),
        VenueMarketingOffer(
          id: 13,
          name: 'خصم الملعب',
          discount: 10,
          fundedBy: 'venue',
        ),
      ]);
}

class _NoopApiConsumer implements ApiConsumer {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
