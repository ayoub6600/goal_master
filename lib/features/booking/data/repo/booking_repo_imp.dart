import 'package:dartz/dartz.dart';
import 'package:goal_master/features/booking/data/model/cancellation_quote.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/exceptions.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/model/cancel_booking_response.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/model/employe/employe.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/model/service_model.dart';
import 'package:goal_master/features/booking/data/model/timeslot.dart';
import 'package:goal_master/features/booking/data/model/operational_night_context.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

class BookingRepoImp extends BookingRepo {
  final ApiConsumer apiConsumer;

  BookingRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, PaginatedResponse<Booking>>> getBooking(
      int page, bool now) async {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(
        EndPoints.bookingHistory(page),
        queryParameters: {
          'pageSize': 10,
          'page': page,
          'now': now,
        },
      ),
      (data) => PaginatedResponse<Booking>.fromJson(
        data['data'],
        (json) => Booking.fromJson(json),
      ),
    );
  }

  @override
  Future<Either<Failure, Booking>> getBookingInfo(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.getBookingInfo(id),
      ),
      (data) {
        return Booking.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<Either<Failure, CancelBookingResponse>> cancelBooking(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancelBooking,
        data: {
          'id': id,
        },
      ),
      (data) => CancelBookingResponse.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, CancellationQuote>> cancellationPreview(int bookingId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancellationPreview,
        isFormData: false,
        data: {'id': bookingId},
      ),
      (data) => CancellationQuote.fromJson(
          Map<String, dynamic>.from(data['data'] as Map)),
    );
  }

  @override
  Future<Either<Failure, BookingCaseStatus>> caseStatus(int bookingId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.bookingCaseStatus,
        isFormData: false,
        data: {'booking_id': bookingId},
      ),
      (data) => BookingCaseStatus.fromJson(
          Map<String, dynamic>.from(data['data'] as Map)),
    );
  }

  @override
  Future<Either<Failure, String>> requestException(
    int bookingId,
    String reasonCode,
    String? reasonText,
  ) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancellationException,
        isFormData: false,
        data: {
          'booking_id': bookingId,
          'reason_code': reasonCode,
          if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText,
        },
      ),
      (data) => data['message']?.toString() ?? 'تم إرسال طلبك.',
    );
  }

  @override
  Future<Either<Failure, String>> escalateToPlatform(int bookingId, String? reason) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancellationEscalate,
        isFormData: false,
        data: {
          'booking_id': bookingId,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      (data) => data['message']?.toString() ?? 'رفعنا طلبك.',
    );
  }

  @override
  Future<Either<Failure, String>> disputeNoShow(int bookingId, String? reason) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.disputeNoShow,
        isFormData: false,
        data: {
          'booking_id': bookingId,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      (data) => data['message']?.toString() ?? 'سجّلنا اعتراضك.',
    );
  }

  @override
  Future<Either<Failure, PayOnArrivalRestriction>> payOnArrivalRestriction(int? branchId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(
        EndPoints.myPaymentRestrictions,
        queryParameters: {if (branchId != null) 'branch_id': branchId},
      ),
      (data) => PayOnArrivalRestriction.fromJson(
          Map<String, dynamic>.from(data['data'] as Map)),
    );
  }

  @override
  Future<Either<Failure, List<Location>>> listZone() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.listZone),
      (data) {
        // تأكد من أن data['data'] هو عبارة عن List
        List<Location> locations = (data['data'] as List<dynamic>)
            .map((item) => Location.fromJson(item as Map<String, dynamic>))
            .toList();
        return locations;
      },
    );
  }

  @override
  Future<Either<Failure, List<ClubResponce>>> listClub(int zoneId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listClub,
        data: {
          'zone': zoneId,
        },
      ),
      (data) {
        print("data: ${data["id"]}");
        List<ClubResponce> clubs = (data['data'] as List<dynamic>)
            .map((item) => ClubResponce.fromJson(item as Map<String, dynamic>))
            .toList();
        return clubs;
      },
    );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> listCategory(
      {required int branchId}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listCategory,
        data: {
          'branch': branchId,
        },
      ),
      (data) {
        List<CategoryModel> categories = (data['data'] as List<dynamic>)
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return categories;
      },
    );
  }

  @override
  Future<Either<Failure, List<Service>>> listService(
      int categoryId, int branchId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listService,
        data: {
          'category': categoryId,
          'branch': branchId,
        },
      ),
      (data) {
        List<Service> services = (data['data'] as List<dynamic>)
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
        return services;
      },
    );
  }

  @override
  Future<Either<Failure, List<Employee>>> listEmployee(
      {required int branchId}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listEmployee,
        data: {
          'branch': branchId,
        },
      ),
      (data) {
        List<Employee> employees = (data['data'] as List<dynamic>)
            .map((item) => Employee.fromJson(item as Map<String, dynamic>))
            .toList();
        return employees;
      },
    );
  }

  @override
  Future<Either<Failure, List<TimeslotModel>>> listTimeslot(
      {required int branchId,
      required int employeeId,
      required int serviceId,
      required String date}) {
    return apiConsumer.handleRequest(
        () => apiConsumer.post(
              EndPoints.listTimeslot,
              data: {
                'branch_id': branchId,
                'employee_id': employeeId,
                'service_id': serviceId,
                'date': date,
              },
            ), (data) {
      List<TimeslotModel> timeslots = (data['data'] as List<dynamic>)
          .map((item) => TimeslotModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return timeslots;
    });
  }

  @override
  Future<Either<Failure, OperationalNightContext>> nightContext({
    required int branchId,
    required int serviceId,
  }) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.operationalNightContext,
        data: {'branch_id': branchId, 'service_id': serviceId},
      ),
      (data) => OperationalNightContext.fromJson(
        Map<String, dynamic>.from(
          data['data']?['previous_operational_night'] as Map? ?? const {},
        ),
      ),
    );
  }

  /// One operational night's slots, bands already merged by the server.
  ///
  /// No `employee_id`: which time band a slot belongs to is the server's
  /// business now, and it comes back attached to each slot. The customer is
  /// no longer asked a scheduling question they should never have seen.
  @override
  Future<Either<Failure, List<TimeslotModel>>> listNightSlots({
    required int branchId,
    required int serviceId,
    required String operationalDate,
  }) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.operationalAvailability,
        data: {
          'branch_id': branchId,
          'service_id': serviceId,
          'operational_date': operationalDate,
        },
      ),
      (data) => ((data['data']?['slots'] as List<dynamic>?) ?? const [])
          .map((item) => TimeslotModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Either<Failure, String>> addBooking(
      {required int branchId,
      required int employeeId,
      required int serviceId,
      required int paymentType,
      required String date,
      required String startTime,
      required String endTime,
      String? startAt,
      String? endAt,
      required String fullName,
      required String phone,
      required String state,
      int coinsToRedeem = 0,
      String? checkoutReference}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.addBooking,
        data: {
          'branch_id': branchId,
          'employee_id': employeeId,
          'service_id': serviceId,
          'payment_type': paymentType,
          'service_date': date,
          'start_time': startTime,
          'end_time': endTime,
          if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
          if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
          'full_name': fullName,
          'phone_no': phone,
          'state': "1",
          'paid_amount': "0",
          if (coinsToRedeem > 0) 'coins_to_redeem': coinsToRedeem,
          // Sent whenever coins are involved so a retried submit can't spend
          // them twice — the backend rejects a repeat of the same reference.
          if (coinsToRedeem > 0 && checkoutReference != null)
            'checkout_reference': checkoutReference,
        },
      ),
      (data) {
        if (paymentType == 1) {
          return data['data'];
        }

        // Extract returnUrl if available
        final returnUrl = data['data']?['returnUrl'];
        if (returnUrl != null && returnUrl is String) {
          return returnUrl;
        }

        // fallback: return something useful (e.g., success message or booking ID)
        return data['data'].toString();
      },
    );
  }

  // ---- Recurring bookings ("حجز شهري") ----

  @override
  Future<Either<Failure, bool>> monthlyBookingAvailable(int branchId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.seriesCapability(branchId)),
      (data) => data['data']?['monthly_booking_available'] == true,
    );
  }

  @override
  Future<Either<Failure, SeriesPreview>> previewSeries({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required String date,
    required String startTime,
    required String endTime,
    String? startAt,
    String? endAt,
    List<Map<String, dynamic>> replacements = const [],
  }) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.seriesPreview,
        data: {
          'branch_id': branchId,
          'employee_id': employeeId,
          'service_id': serviceId,
          'service_date': date,
          'start_time': startTime,
          'end_time': endTime,
          if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
          if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
          // Sent so the preview returns the FINAL schedule — with the moved
          // week in place and the compensating extension week gone. The app
          // renders what comes back rather than working it out locally.
          if (replacements.isNotEmpty) 'replacements': replacements,
        },
        isFormData: false,
      ),
      (data) => SeriesPreview.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  /// Creation reuses the ordinary booking endpoint with `is_monthly: 1`, so a
  /// recurring booking is priced and validated by exactly the same backend
  /// code as a normal one.
  ///
  /// Handled here rather than through [handleRequest] because a
  /// `series_conflict` refusal carries a list the generic handler would
  /// flatten into a single string.
  @override
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
    String? approvedPlanSignature,
    List<Map<String, dynamic>> replacements = const [],
  }) async {
    try {
      final response = await apiConsumer.post(
        EndPoints.addBooking,
        data: {
          'branch_id': branchId,
          'employee_id': employeeId,
          'service_id': serviceId,
          'payment_type': paymentType,
          'service_date': date,
          'start_time': startTime,
          'end_time': endTime,
          if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
          if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
          'full_name': fullName,
          'phone_no': phone,
          'state': '1',
          'paid_amount': '0',
          'is_monthly': 1,
          // Lets a retried submit return the series that was already created
          // instead of building a second one.
          if (checkoutReference != null) 'checkout_reference': checkoutReference,
          // Only sent once the customer has actually approved the plan. The
          // signature pins it to the exact dates they saw.
          if (approvedPlanSignature != null && approvedPlanSignature.isNotEmpty) ...{
            'allow_skip': 1,
            'approved_plan_signature': approvedPlanSignature,
          },
          // Weeks the customer moved rather than lost. Every one is
          // re-validated server-side under lock — a slot free when the sheet
          // was drawn may be gone by now, and only the server can say.
          if (replacements.isNotEmpty) 'replacements': replacements,
        },
      );

      return right(
        BookingSeries.fromJson(response['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic> && data['reason'] == 'series_conflict') {
        final parsed = SeriesConflict.fromJson(data);
        return left(SeriesConflictFailure(
          errMessage: parsed.message,
          conflicts: _toConflictedDates(parsed),
          canSkipAndExtend: parsed.canSkipAndExtend,
          planSignature: parsed.planSignature,
          proposedDates: _proposedDates(parsed),
        ));
      }

      // The plan moved between approval and commit. Nothing was booked.
      if (data is Map<String, dynamic> && data['reason'] == 'plan_changed') {
        final parsed = SeriesConflict.fromJson(data);
        return left(SeriesPlanChangedFailure(
          errMessage: parsed.message,
          conflicts: _toConflictedDates(parsed),
          planSignature: parsed.planSignature,
          proposedDates: _proposedDates(parsed),
        ));
      }

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['data'];
        if (message is String && message.isNotEmpty) {
          return left(Failure(errMessage: message));
        }
      }

      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<void> declineSkipOffer({
    required String planSignature,
    int? branchId,
    int? serviceId,
  }) async {
    try {
      await apiConsumer.post(
        EndPoints.seriesSkipDeclined,
        data: {
          'plan_signature': planSignature,
          if (branchId != null) 'branch_id': branchId,
          if (serviceId != null) 'service_id': serviceId,
        },
      );
    } catch (_) {
      // Analytics only. The customer already made their decision, and telling
      // them a metric failed to record would be noise.
    }
  }

  @override
  Future<Either<Failure, RenewalOffer>> getRenewalOffer(int seriesId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.seriesRenewalOffer(seriesId)),
      (data) => RenewalOffer.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  /// Handled outside handleRequest so a moved price or a moved plan comes
  /// back as its own type — the generic handler would flatten both into a
  /// sentence, and the customer needs to re-approve, not just be told.
  @override
  Future<Either<Failure, BookingSeries>> renewSeries({
    required int seriesId,
    required String priceSignature,
    String? approvedPlanSignature,
  }) async {
    try {
      final response = await apiConsumer.post(
        EndPoints.seriesRenew(seriesId),
        data: {
          'price_signature': priceSignature,
          if (approvedPlanSignature != null && approvedPlanSignature.isNotEmpty)
            'approved_plan_signature': approvedPlanSignature,
        },
      );

      return right(
        BookingSeries.fromJson(response['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['reason'] == 'price_changed') {
          final payload = (data['data'] as Map<String, dynamic>?) ?? const {};
          return left(RenewalPriceChangedFailure(
            errMessage: (data['message'] ?? '').toString(),
            pricePerOccurrence:
                double.tryParse('${payload['price_per_occurrence']}') ?? 0,
            totalAmount: double.tryParse('${payload['total_amount']}') ?? 0,
            priceSignature: (payload['price_signature'] ?? '').toString(),
          ));
        }

        if (data['reason'] == 'series_conflict' || data['reason'] == 'plan_changed') {
          final parsed = SeriesConflict.fromJson(data);
          return left(SeriesConflictFailure(
            errMessage: parsed.message,
            conflicts: _toConflictedDates(parsed),
            canSkipAndExtend: parsed.canSkipAndExtend,
            planSignature: parsed.planSignature,
            proposedDates: _proposedDates(parsed),
          ));
        }

        final message = data['message'] ?? data['data'];
        if (message is String && message.isNotEmpty) {
          return left(Failure(errMessage: message));
        }
      }

      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> declineRenewal(int seriesId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.seriesDeclineRenewal(seriesId)),
      (data) => true,
    );
  }

  @override
  Future<Either<Failure, BookingSeries>> getSeries(int seriesId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.seriesDetails(seriesId)),
      (data) => BookingSeries.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<BookingSeries>>> listSeries() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.seriesList),
      (data) {
        final page = data['data'];
        final rows = (page is Map<String, dynamic> ? page['data'] : page) as List?;
        return (rows ?? const [])
            .map((e) => BookingSeries.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, BookingSeries>> cancelSeriesOccurrence(int bookingId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancelSeriesOccurrence,
        data: {'booking_id': bookingId},
      ),
      (data) => BookingSeries.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, BookingSeries>> cancelSeriesFuture(int seriesId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancelSeriesFuture,
        data: {'series_id': seriesId},
      ),
      (data) => BookingSeries.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  List<ConflictedDate> _toConflictedDates(SeriesConflict parsed) {
    return parsed.conflicts
        .map((c) => ConflictedDate(
              date: c.date,
              startTime: c.startTime,
              message: c.message,
            ))
        .toList();
  }

  /// The dates the offered plan would actually book, so the popup can show
  /// the customer what they end up with, not only what went wrong.
  List<String> _proposedDates(SeriesConflict parsed) {
    final plan = parsed.plan;
    if (plan == null) return const [];

    return plan.dates
        .where((d) => d.action == 'book')
        .map((d) => d.date)
        .toList(growable: false);
  }
}
