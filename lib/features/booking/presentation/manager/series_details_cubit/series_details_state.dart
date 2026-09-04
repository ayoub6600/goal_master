part of 'series_details_cubit.dart';

// ConflictedDate comes from core/errors/failure.dart via the cubit import.

sealed class SeriesDetailsState extends Equatable {
  const SeriesDetailsState();

  @override
  List<Object?> get props => [];
}

final class SeriesDetailsInitial extends SeriesDetailsState {}

final class SeriesDetailsLoading extends SeriesDetailsState {}

final class SeriesDetailsLoaded extends SeriesDetailsState {
  final BookingSeries series;

  /// Present only while the series is in its renewal window and has not been
  /// answered. Null the rest of the time, which is most of the time.
  final RenewalOffer? renewalOffer;

  final bool isBusy;

  /// Set once, right after a cancel, so the screen can say what happened
  /// without a separate state that would lose the series.
  final String? actionMessage;
  final String? actionError;

  const SeriesDetailsLoaded({
    required this.series,
    this.renewalOffer,
    this.isBusy = false,
    this.actionMessage,
    this.actionError,
  });

  @override
  List<Object?> get props => [
        series.seriesId,
        series.status,
        series.occurrences.map((o) => '${o.bookingId}:${o.status}').join(','),
        renewalOffer?.holdsExpireAt,
        renewalOffer?.priceSignature,
        isBusy,
        actionMessage,
        actionError,
      ];
}

/// Renewed. A new series exists and has been paid for.
final class SeriesRenewed extends SeriesDetailsState {
  final BookingSeries series;

  const SeriesRenewed({required this.series});

  @override
  List<Object?> get props => [series.seriesId];
}

/// The price moved before the charge. Nothing was taken.
final class SeriesRenewalPriceChanged extends SeriesDetailsState {
  final BookingSeries series;
  final RenewalOffer offer;
  final double newPricePerOccurrence;
  final double newTotal;
  final String newPriceSignature;

  const SeriesRenewalPriceChanged({
    required this.series,
    required this.offer,
    required this.newPricePerOccurrence,
    required this.newTotal,
    required this.newPriceSignature,
  });

  @override
  List<Object?> get props => [newPriceSignature, newTotal];
}

/// The available dates moved before the charge. Nothing was taken.
final class SeriesRenewalPlanChanged extends SeriesDetailsState {
  final BookingSeries series;
  final RenewalOffer offer;
  final String message;
  final List<ConflictedDate> conflicts;
  final List<String> proposedDates;
  final String planSignature;

  const SeriesRenewalPlanChanged({
    required this.series,
    required this.offer,
    required this.message,
    required this.conflicts,
    required this.proposedDates,
    required this.planSignature,
  });

  @override
  List<Object?> get props => [planSignature, message];
}

final class SeriesDetailsFailure extends SeriesDetailsState {
  final String message;

  const SeriesDetailsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
