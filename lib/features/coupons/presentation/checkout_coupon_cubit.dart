import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/coupons/data/coupon_repo.dart';

class CheckoutCouponState extends Equatable {
  const CheckoutCouponState({
    this.branchId = 0,
    this.amount = 0,
    this.myCoupons = const [],
    this.applied,
    this.checking = false,
    this.error,
  });

  final int branchId;

  /// The booking price before any discount; the code is checked against it.
  final double amount;
  final List<CustomerCoupon> myCoupons;
  final CouponPreview? applied;
  final bool checking;
  final String? error;

  double get discount => applied?.discount ?? 0;
  String? get appliedCode => applied?.coupon.code;

  /// The customer's own coupons that can work on this booking's field.
  List<CustomerCoupon> get usableHere =>
      myCoupons.where((c) => c.validAt(branchId)).toList();

  CheckoutCouponState copyWith({
    int? branchId,
    double? amount,
    List<CustomerCoupon>? myCoupons,
    CouponPreview? applied,
    bool clearApplied = false,
    bool? checking,
    String? error,
    bool clearError = false,
  }) =>
      CheckoutCouponState(
        branchId: branchId ?? this.branchId,
        amount: amount ?? this.amount,
        myCoupons: myCoupons ?? this.myCoupons,
        applied: clearApplied ? null : (applied ?? this.applied),
        checking: checking ?? this.checking,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [branchId, amount, myCoupons, applied, checking, error];
}

class CheckoutCouponCubit extends Cubit<CheckoutCouponState> {
  CheckoutCouponCubit(this.repo) : super(const CheckoutCouponState());
  final CouponRepo repo;

  /// A fresh checkout: no code carried over from a previous booking.
  Future<void> begin({required int branchId, required double amount}) async {
    emit(CheckoutCouponState(branchId: branchId, amount: amount));
    final result = await repo.myCoupons();
    if (isClosed) return;
    result.fold((_) {}, (coupons) => emit(state.copyWith(myCoupons: coupons)));
  }

  Future<bool> apply(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || state.checking) return false;
    emit(state.copyWith(checking: true, clearError: true));
    final result = await repo.check(
      code: trimmed,
      branchId: state.branchId,
      amount: state.amount,
    );
    if (isClosed) return false;
    return result.fold(
      (failure) {
        emit(state.copyWith(
            checking: false, clearApplied: true, error: failure.errMessage));
        return false;
      },
      (preview) {
        emit(state.copyWith(
            checking: false, applied: preview, clearError: true));
        return true;
      },
    );
  }

  void remove() => emit(state.copyWith(clearApplied: true, clearError: true));

  void clear() => emit(const CheckoutCouponState());
}
