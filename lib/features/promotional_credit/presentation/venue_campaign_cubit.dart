import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/promotional_credit/data/promotional_credit_repo.dart';

class VenueCampaignState extends Equatable {
  const VenueCampaignState({
    this.offers = const [],
    this.selectedOfferId,
    this.baseAmount = 0,
    this.walletSelected = true,
  });
  final List<VenueMarketingOffer> offers;
  final int? selectedOfferId;
  final double baseAmount;
  final bool walletSelected;

  VenueMarketingOffer? get selectedOffer {
    for (final offer in offers) {
      if (offer.id == selectedOfferId &&
          (walletSelected || offer.fundedBy != 'platform')) {
        return offer;
      }
    }
    if (!walletSelected) {
      for (final offer in offers) {
        if (offer.fundedBy != 'platform') {
          return offer;
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [offers, selectedOfferId, baseAmount, walletSelected];
}

class VenueCampaignCubit extends Cubit<VenueCampaignState> {
  VenueCampaignCubit(this.repo) : super(const VenueCampaignState());
  final PromotionalCreditRepo repo;

  Future<void> load({
    required int branchId,
    required int serviceId,
    required double amount,
    required String bookingAt,
  }) async {
    final result = await repo.getVenueOffers(
      branchId: branchId,
      serviceId: serviceId,
      amount: amount,
      bookingAt: bookingAt,
    );
    result.fold(
      (_) => emit(const VenueCampaignState()),
      (offers) {
        // Offers returned for this exact field and occurrence are eligible.
        // Apply the customer's best available deal without asking them to
        // understand campaign rules or choose between overlapping offers.
        final best = offers.fold<VenueMarketingOffer?>(
          null,
          (current, offer) =>
              current == null || offer.discount > current.discount
                  ? offer
                  : current,
        );
        emit(VenueCampaignState(
          offers: offers,
          selectedOfferId: best?.id,
          baseAmount: amount,
        ));
      },
    );
  }

  void select(int? offerId) => emit(state.copyWith(selectedOfferId: offerId));
  void setWalletSelected(bool selected) {
    final eligibleOffers = state.offers.where(
      (offer) => selected || offer.fundedBy != 'platform',
    );
    final bestOffer = eligibleOffers.fold<VenueMarketingOffer?>(
      null,
      (best, offer) =>
          best == null || offer.discount > best.discount ? offer : best,
    );
    emit(state.copyWith(
      walletSelected: selected,
      selectedOfferId: bestOffer?.id,
    ));
  }

  void clear() => emit(const VenueCampaignState());
}

extension on VenueCampaignState {
  VenueCampaignState copyWith({int? selectedOfferId, bool? walletSelected}) =>
      VenueCampaignState(
        offers: offers,
        selectedOfferId: selectedOfferId,
        baseAmount: baseAmount,
        walletSelected: walletSelected ?? this.walletSelected,
      );
}
