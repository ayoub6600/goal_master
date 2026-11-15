import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/coupons/data/coupon_repo.dart';
import 'package:goal_master/features/coupons/presentation/checkout_coupon_cubit.dart';

class _Repo implements CouponRepo {
  _Repo(this.coupons);
  final List<CustomerCoupon> coupons;
  final checked = <Map<String, Object>>[];

  @override
  Future<Either<Failure, List<CustomerCoupon>>> myCoupons() async => right(coupons);

  @override
  Future<Either<Failure, CouponPreview>> check(
      {required String code, required int branchId, required double amount}) async {
    checked.add({'code': code, 'branchId': branchId, 'amount': amount});
    if (code != 'GOOD10') return left(Failure(errMessage: 'كود الخصم غير صحيح أو منتهي الصلاحية.'));
    final c = coupons.firstWhere((c) => c.code == code);
    return right(CouponPreview(coupon: c, discount: amount * 0.1, payable: amount * 0.9));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const everywhere = CustomerCoupon(
      code: 'GOOD10', isFixed: false, value: 10, maxDiscount: 20, minOrder: 0, source: 'game');
  const otherField = CustomerCoupon(
      code: 'THERE', isFixed: true, value: 15, maxDiscount: 0, minOrder: 0, branchId: 9, branchName: 'ملعب آخر');

  test('parses the server shape, including fixed amounts and a field lock', () {
    final c = CustomerCoupon.fromJson({
      'code': 'FIX15', 'is_fixed': true, 'percent': 15, 'max_discount': 0, 'min_order': 40,
      'expires_at': '2026-12-01', 'branch_id': 3, 'branch_name': 'ملعب النصر', 'source': 'admin',
    });
    expect(c.headline, '15 د.ل');
    expect(c.validAt(3), isTrue);
    expect(c.validAt(4), isFalse);
    expect(everywhere.headline, '10%');
    expect(everywhere.validAt(123), isTrue);
  });

  test('a new checkout starts clean and only offers coupons valid at this field', () async {
    final cubit = CheckoutCouponCubit(_Repo([everywhere, otherField]));
    await cubit.begin(branchId: 4, amount: 120);

    expect(cubit.state.appliedCode, isNull);
    expect(cubit.state.usableHere.map((c) => c.code), ['GOOD10']);
  });

  test('applying checks the code against this booking and keeps the preview', () async {
    final repo = _Repo([everywhere]);
    final cubit = CheckoutCouponCubit(repo);
    await cubit.begin(branchId: 4, amount: 120);

    expect(await cubit.apply('  GOOD10 '), isTrue);
    expect(repo.checked.single, {'code': 'GOOD10', 'branchId': 4, 'amount': 120.0});
    expect(cubit.state.appliedCode, 'GOOD10');
    expect(cubit.state.discount, closeTo(12, 1e-9));

    cubit.remove();
    expect(cubit.state.appliedCode, isNull);
    expect(cubit.state.discount, 0);
  });

  test('a refused code shows the server reason and applies nothing', () async {
    final cubit = CheckoutCouponCubit(_Repo([everywhere]));
    await cubit.begin(branchId: 4, amount: 120);

    expect(await cubit.apply('NOPE'), isFalse);
    expect(cubit.state.appliedCode, isNull);
    expect(cubit.state.error, contains('غير صحيح'));
  });
}
