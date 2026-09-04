import 'package:dartz/dartz.dart';
import 'package:goal_master/features/booking/data/model/cancellation_quote.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/operational_night_context.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/model/cancel_booking_response.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/model/employe/employe.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/model/service_model.dart';
import 'package:goal_master/features/booking/data/model/timeslot.dart';

abstract class BookingRepo {
  Future<Either<Failure, PaginatedResponse<Booking>>> getBooking(
    int page,
    bool now,
  );
  Future<Either<Failure, Booking>> getBookingInfo(
    int id,
  );
  Future<Either<Failure, CancelBookingResponse>> cancelBooking(
    int id,
  );

  Future<Either<Failure, List<Location>>> listZone();
  Future<Either<Failure, List<ClubResponce>>> listClub(
    int zoneId,
  );
  //category
  Future<Either<Failure, List<CategoryModel>>> listCategory(
      {required int branchId});
  //service
  Future<Either<Failure, List<Service>>> listService(
    int categoryId,
    int branchId,
  );

  //employee
  Future<Either<Failure, List<Employee>>> listEmployee({required int branchId});
  //timeslot
  /// Whether the night already in progress is still bookable.
  Future<Either<Failure, OperationalNightContext>> nightContext({
    required int branchId,
    required int serviceId,
  });

  /// One operational night's slots, evening and after-midnight merged.
  Future<Either<Failure, List<TimeslotModel>>> listNightSlots({
    required int branchId,
    required int serviceId,
    required String operationalDate,
  });

  Future<Either<Failure, List<TimeslotModel>>> listTimeslot({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required String date,
  });
  Future<Either<Failure, String>> addBooking({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required int paymentType,
    required String date,
    required String startTime,
    required String endTime,
    // Authoritative occurrence datetimes from the server's slot. Optional so
    // older clients keep working; when present the backend cross-checks them
    // against service_date/start_time/end_time.
    String? startAt,
    String? endAt,
    required String fullName,
    required String phone,
    required String state,
    int coinsToRedeem,
    String? checkoutReference,
  });

  // ---- Recurring bookings ("حجز شهري") ----

  /// Whether this branch may offer monthly booking at all.
  ///
  /// A subscription feature of the venue, decided entirely by the backend.
  /// Used only to decide whether to show the option — the server enforces it
  /// again when a series is actually created.
  Future<Either<Failure, bool>> monthlyBookingAvailable(int branchId);

  /// The four dates a series would take, and whether each is free.
  /// Availability is always the backend's answer — never computed in the app.
  Future<Either<Failure, SeriesPreview>> previewSeries({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required String date,
    required String startTime,
    required String endTime,
    String? startAt,
    String? endAt,
    List<Map<String, dynamic>> replacements,
  });

  /// Creates all four bookings at once. All-or-nothing: on a clash this fails
  /// with a [SeriesConflictFailure] listing every week, and nothing is booked.
  Future<Either<Failure, BookingSeries>> addMonthlyBooking({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required int paymentType,
    required String date,
    required String startTime,
    required String endTime,
    // Authoritative occurrence datetimes from the server's slot. Optional so
    // older clients keep working; when present the backend cross-checks them
    // against service_date/start_time/end_time.
    String? startAt,
    String? endAt,
    required String fullName,
    required String phone,
    String? checkoutReference,
    /// The customer's explicit approval of a plan that skips a taken week.
    /// Without the matching signature the backend refuses to skip anything.
    String? approvedPlanSignature,

    /// Blocked weeks the customer moved to a nearby slot instead of losing.
    /// Re-validated server-side; the app's view is never authoritative.
    List<Map<String, dynamic>> replacements,
  });

  /// Tells the backend the customer was offered a skip-and-extend plan and
  /// turned it down. Fire-and-forget: it records an analytics row and nothing
  /// else, so a failure must never be shown to the customer.
  Future<void> declineSkipOffer({
    required String planSignature,
    int? branchId,
    int? serviceId,
  });

  // ---- Renewal ----

  /// What renewing would cost and occupy. Quoted only — nothing is charged.
  Future<Either<Failure, RenewalOffer>> getRenewalOffer(int seriesId);

  /// Renews the series, charging once for the next cycle. Both signatures are
  /// required so neither the dates nor the price can move silently.
  Future<Either<Failure, BookingSeries>> renewSeries({
    required int seriesId,
    required String priceSignature,
    String? approvedPlanSignature,
  });

  /// "No thanks" — the held slots go back on sale immediately.
  Future<Either<Failure, bool>> declineRenewal(int seriesId);

  Future<Either<Failure, BookingSeries>> getSeries(int seriesId);

  Future<Either<Failure, List<BookingSeries>>> listSeries();

  /// Cancels one date; the rest of the series is untouched.
  Future<Either<Failure, BookingSeries>> cancelSeriesOccurrence(int bookingId);

  /// Cancels every date that has not happened yet. Past sessions are kept.
  Future<Either<Failure, BookingSeries>> cancelSeriesFuture(int seriesId);
}
