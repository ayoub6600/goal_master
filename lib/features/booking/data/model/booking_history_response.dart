class BookingHistoryResponse {
  final int currentPage;
  final List<Booking> bookings;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final int to;
  final int total;

  BookingHistoryResponse({
    required this.currentPage,
    required this.bookings,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    var bookingList = (json['data'] as List?) ?? const [];
    List<Booking> bookings =
        bookingList.map((i) => Booking.fromJson(i)).toList();

    return BookingHistoryResponse(
      currentPage: _asInt(json['current_page']),
      bookings: bookings,
      firstPageUrl: _asString(json['first_page_url']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      lastPageUrl: _asString(json['last_page_url']),
      links: ((json['links'] as List?) ?? const [])
          .map((i) => PageLink.fromJson(i as Map<String, dynamic>))
          .toList(),
      nextPageUrl: _asString(json['next_page_url']),
      path: _asString(json['path']),
      perPage: _asInt(json['per_page']),
      to: _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }
}

class Booking {
  final int id;
  final String branch;
  final String address;
  final String latitude;
  final String longitude;
  final String date;
  final String startTime;
  final String endTime;
  final String service;
  final String serviceAmount;
  final String paidAmount;
  final String paymentStatus;
  final String paymentType;
  final int status;
  final String statusName;
  final String remarks;
  final String category;

  /// Set only when this booking is one occurrence of a recurring booking,
  /// so the list can badge it and open the series. Null for ordinary bookings.
  final BookingSeriesRef? series;

  /// Set only for a cancelled booking that actually moved platform money —
  /// null for one still active, or one paid on arrival.
  final BookingCancellation? cancellation;

  Booking({
    required this.id,
    required this.branch,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.service,
    required this.serviceAmount,
    required this.paidAmount,
    required this.paymentStatus,
    required this.paymentType,
    required this.status,
    required this.statusName,
    required this.remarks,
    required this.category,
    this.series,
    this.cancellation,
  });

  bool get isPartOfSeries => series != null;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _asInt(json['id']),
      branch: _asString(json['branch']),
      address: _asString(json['address']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      service: _asString(json['service']),
      serviceAmount: _asString(json['service_amount']),
      paidAmount: _asString(json['paid_amount']),
      paymentStatus: _paymentStatus(json['payment_status']),
      paymentType: _asString(json['payment_type']),
      status: _asInt(json['status']),
      statusName: _asString(json['status_name']),
      remarks: _asString(json['remarks']),
      category: _asString(json['category']),
      series: json['series'] is Map<String, dynamic>
          ? BookingSeriesRef.fromJson(json['series'] as Map<String, dynamic>)
          : null,
      cancellation: json['cancellation'] is Map<String, dynamic>
          ? BookingCancellation.fromJson(
              json['cancellation'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// What actually happened to the money on a cancelled booking — how much
/// came back, and how much the venue kept as a fee.
class BookingCancellation {
  final double paidAmount;
  final double refundAmount;
  final double retainedAmount;

  const BookingCancellation({
    required this.paidAmount,
    required this.refundAmount,
    required this.retainedAmount,
  });

  /// A real fee was retained — the case worth calling out visually.
  bool get hasPenalty => retainedAmount > 0.001;

  factory BookingCancellation.fromJson(Map<String, dynamic> json) {
    return BookingCancellation(
      paidAmount: _asDouble(json['paid_amount']),
      refundAmount: _asDouble(json['refund_amount']),
      retainedAmount: _asDouble(json['retained_amount']),
    );
  }
}

/// Just enough of the parent series to badge a booking in a list —
/// "حجز شهري · الموعد 2 من 4" — without loading the whole series.
class BookingSeriesRef {
  final int seriesId;
  final int sequence;
  final int occurrenceCount;
  final String seriesStatus;

  const BookingSeriesRef({
    required this.seriesId,
    required this.sequence,
    required this.occurrenceCount,
    required this.seriesStatus,
  });

  String get positionLabel => 'الموعد $sequence من $occurrenceCount';

  factory BookingSeriesRef.fromJson(Map<String, dynamic> json) {
    return BookingSeriesRef(
      seriesId: _asInt(json['series_id']),
      sequence: _asInt(json['sequence']),
      occurrenceCount: _asInt(json['occurrence_count']),
      seriesStatus: _asString(json['series_status']),
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: _asString(json['label']),
      active: json['active'] == true,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// Reads `payment_status` whichever way the endpoint that sent it spells it.
///
/// `myBookings` already sends the translated word this app reads everywhere
/// — 'paid' / 'pending' / 'partially_paid'. `get-info` (behind
/// `getBookingInfo`, reused here for one occurrence's own details) sends the
/// raw `ServicePaymentStatus` code the column stores: 1 Paid, 2 Unpaid,
/// 3 PartialPaid. Both are read the same way client-side rather than fixed on
/// the server, so this stays correct even if a future endpoint sends either
/// shape.
///
/// Without this, a numeric code fell through `_getPaymentStatusText`'s switch
/// to its `default` branch and showed the customer a bare digit — "2" — where
/// a word belonged.
String _paymentStatus(dynamic value) {
  const known = {'paid', 'pending', 'partially_paid'};
  final asString = _asString(value);
  if (known.contains(asString)) return asString;

  return switch (_asInt(value)) {
    1 => 'paid',
    2 => 'pending',
    3 => 'partially_paid',
    _ => asString,
  };
}

String _asString(dynamic value) {
  final stringValue = value?.toString();
  if (stringValue == null || stringValue == 'null') {
    return '';
  }
  return stringValue;
}
