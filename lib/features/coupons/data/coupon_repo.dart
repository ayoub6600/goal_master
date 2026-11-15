import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';

double _double(Object? v) => (v as num?)?.toDouble() ?? 0;

/// A discount code as the server describes it. Every term — percent or fixed
/// amount, cap, minimum booking, expiry, the one field it is limited to — is
/// set by the admin (or by the game reward rule that issued it).
class CustomerCoupon extends Equatable {
  const CustomerCoupon({
    required this.code,
    required this.isFixed,
    required this.value,
    required this.maxDiscount,
    required this.minOrder,
    this.expiresAt,
    this.branchId,
    this.branchName,
    this.source = 'admin',
  });

  factory CustomerCoupon.fromJson(Map<String, dynamic> j) => CustomerCoupon(
        code: j['code']?.toString() ?? '',
        isFixed: j['is_fixed'] == true,
        value: _double(j['percent']),
        maxDiscount: _double(j['max_discount']),
        minOrder: _double(j['min_order']),
        expiresAt: j['expires_at']?.toString(),
        branchId: (j['branch_id'] as num?)?.toInt(),
        branchName: j['branch_name']?.toString(),
        source: j['source']?.toString() ?? 'admin',
      );

  final String code, source;
  final bool isFixed;
  final double value, maxDiscount, minOrder;
  final String? expiresAt, branchName;
  final int? branchId;

  bool get fromGame => source == 'game';

  /// "10%" or "15 د.ل" — the headline of the coupon.
  String get headline => isFixed ? '${_trim(value)} د.ل' : '${_trim(value)}%';

  bool validAt(int branchId) =>
      this.branchId == null || this.branchId == branchId;

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  List<Object?> get props => [
        code,
        isFixed,
        value,
        maxDiscount,
        minOrder,
        expiresAt,
        branchId,
        branchName,
        source
      ];
}

/// A code checked against one booking: what it takes off and what is left.
class CouponPreview extends Equatable {
  const CouponPreview({
    required this.coupon,
    required this.discount,
    required this.payable,
  });

  final CustomerCoupon coupon;
  final double discount, payable;

  @override
  List<Object?> get props => [coupon, discount, payable];
}

class CouponRepo {
  CouponRepo(this.api);
  final ApiConsumer api;

  Future<Either<Failure, List<CustomerCoupon>>> myCoupons() =>
      api.handleRequest(
        () => api.get('user/coupons'),
        (response) => ((response['data'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CustomerCoupon.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  /// Dry run only: the booking endpoint validates the code again and nothing
  /// is reserved here.
  Future<Either<Failure, CouponPreview>> check({
    required String code,
    required int branchId,
    required double amount,
  }) =>
      api.handleRequest(
        () => api.post('user/coupons/check', isFormData: false, data: {
          'code': code.trim(),
          'branch_id': branchId,
          'amount': double.parse(amount.toStringAsFixed(2)),
        }),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return CouponPreview(
            coupon: CustomerCoupon.fromJson(data),
            discount: _double(data['discount']),
            payable: _double(data['payable']),
          );
        },
      );
}
