import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'series_details_state.dart';

/// One recurring booking: its four dates, and the two ways to cancel them.
///
/// Every cancel returns the updated series from the backend, so the screen
/// re-renders from the server's view rather than guessing what changed.
class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  SeriesDetailsCubit(this.bookingRepo) : super(SeriesDetailsInitial());

  final BookingRepo bookingRepo;

  Future<void> load(int seriesId) async {
    emit(SeriesDetailsLoading());

    final result = await bookingRepo.getSeries(seriesId);

    await result.fold(
      (failure) async => emit(SeriesDetailsFailure(message: failure.errMessage)),
      (series) async {
        emit(SeriesDetailsLoaded(series: series));
        // Fetched after the series is on screen: the renewal offer is extra
        // information, and waiting for it would delay the page for every
        // customer including the ones with nothing to renew.
        await _loadRenewalOffer(seriesId);
      },
    );
  }

  Future<void> _loadRenewalOffer(int seriesId) async {
    final current = state;
    if (current is! SeriesDetailsLoaded) return;

    final result = await bookingRepo.getRenewalOffer(seriesId);

    result.fold(
      // Silent: a missing renewal offer is not an error the customer needs
      // to see on a page that already rendered.
      (_) {},
      (offer) {
        if (state is SeriesDetailsLoaded) {
          emit(SeriesDetailsLoaded(
            series: (state as SeriesDetailsLoaded).series,
            renewalOffer: offer,
          ));
        }
      },
    );
  }

  /// Renews, charging once for the next cycle.
  ///
  /// The signatures pin the renewal to the dates and price the customer saw.
  /// If either moved, nothing is charged and they are asked again.
  Future<void> renew({String? approvedPlanSignature}) async {
    final current = state;
    if (current is! SeriesDetailsLoaded || current.renewalOffer == null) return;

    final offer = current.renewalOffer!;
    emit(SeriesDetailsLoaded(
      series: current.series,
      renewalOffer: offer,
      isBusy: true,
    ));

    final result = await bookingRepo.renewSeries(
      seriesId: offer.seriesId,
      priceSignature: offer.priceSignature,
      approvedPlanSignature: approvedPlanSignature ?? offer.planSignature,
    );

    result.fold(
      (failure) {
        if (failure is RenewalPriceChangedFailure) {
          emit(SeriesRenewalPriceChanged(
            series: current.series,
            offer: offer,
            newPricePerOccurrence: failure.pricePerOccurrence,
            newTotal: failure.totalAmount,
            newPriceSignature: failure.priceSignature,
          ));
        } else if (failure is SeriesConflictFailure) {
          emit(SeriesRenewalPlanChanged(
            series: current.series,
            offer: offer,
            message: failure.errMessage,
            conflicts: failure.conflicts,
            proposedDates: failure.proposedDates,
            planSignature: failure.planSignature,
          ));
        } else {
          emit(SeriesDetailsLoaded(
            series: current.series,
            renewalOffer: offer,
            actionError: failure.errMessage,
          ));
        }
      },
      (renewed) => emit(SeriesRenewed(series: renewed)),
    );
  }

  /// Retries with a price the customer has just seen and accepted.
  Future<void> renewAtNewPrice(String priceSignature) async {
    final current = state;
    if (current is! SeriesRenewalPriceChanged) return;

    emit(SeriesDetailsLoaded(series: current.series, isBusy: true));

    final result = await bookingRepo.renewSeries(
      seriesId: current.offer.seriesId,
      priceSignature: priceSignature,
      approvedPlanSignature: current.offer.planSignature,
    );

    result.fold(
      (failure) => emit(SeriesDetailsLoaded(
        series: current.series,
        renewalOffer: current.offer,
        actionError: failure.errMessage,
      )),
      (renewed) => emit(SeriesRenewed(series: renewed)),
    );
  }

  /// "No thanks" — the held slots go back on sale straight away.
  Future<void> declineRenewal() async {
    final current = state;
    if (current is! SeriesDetailsLoaded || current.renewalOffer == null) return;

    final seriesId = current.renewalOffer!.seriesId;
    emit(SeriesDetailsLoaded(series: current.series, isBusy: true));

    await bookingRepo.declineRenewal(seriesId);
    await load(seriesId);
  }

  /// Cancels one date. The other three stay booked.
  Future<void> cancelOccurrence(int bookingId) async {
    final current = state;
    if (current is! SeriesDetailsLoaded) return;

    emit(SeriesDetailsLoaded(series: current.series, isBusy: true));

    final result = await bookingRepo.cancelSeriesOccurrence(bookingId);

    result.fold(
      (failure) => emit(SeriesDetailsLoaded(
        series: current.series,
        actionError: failure.errMessage,
      )),
      (series) => emit(SeriesDetailsLoaded(
        series: series,
        actionMessage: 'تم إلغاء هذا الموعد فقط.',
      )),
    );
  }

  /// Cancels the dates that have not happened yet. Sessions already played
  /// are never touched — the backend refuses to rewrite them.
  Future<void> cancelFuture(int seriesId) async {
    final current = state;
    if (current is! SeriesDetailsLoaded) return;

    emit(SeriesDetailsLoaded(series: current.series, isBusy: true));

    final result = await bookingRepo.cancelSeriesFuture(seriesId);

    result.fold(
      (failure) => emit(SeriesDetailsLoaded(
        series: current.series,
        actionError: failure.errMessage,
      )),
      (series) => emit(SeriesDetailsLoaded(
        series: series,
        actionMessage: 'تم إلغاء المواعيد القادمة.',
      )),
    );
  }
}
