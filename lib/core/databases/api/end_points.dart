import 'package:goal_master/core/databases/api/api_base_safety.dart';

class EndPoints {
  //********  base url
  //
  /// Where the API lives, chosen at BUILD time.
  ///
  /// `127.0.0.1` means different things on different devices, which is why
  /// login worked in the Simulator and failed on a real iPhone: the Simulator
  /// borrows the Mac's network stack, so loopback reaches `artisan serve`,
  /// while on a phone loopback is the phone itself and the connection is
  /// refused outright.
  ///
  /// The default keeps the Simulator working untouched. A real device passes
  /// the Mac's LAN address instead:
  ///
  ///   flutter run --dart-define=API_BASE=http://192.168.1.x:8000/api/
  ///
  /// Deliberately `String.fromEnvironment`, so this stays a compile-time
  /// constant baked into the binary — a machine-specific address cannot be
  /// injected into an already-built app, and there is no runtime lookup on
  /// every request.
  ///
  /// Nothing else in the app decides this. All three consumers
  /// (DioConsumer, AppUpdateService, ConnectionCubit) read it from here.
  static const String baserUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:8000/api/',
  );

  /// True when the app is pointing at a developer machine rather than a
  /// server anybody else can reach.
  ///
  /// Worth having as a value rather than a comment: the default above is a
  /// LOCAL address, so a release build made without --dart-define ships an
  /// API endpoint that resolves to the customer's own phone. See the assert
  /// in DioConsumer, which turns that into a loud failure during development
  /// instead of a silent "Connection Error" after release.
  static bool get isLocalApi => ApiBaseSafety.isLocalOrLan(baserUrl);

  /// Null when this build's [baserUrl] is safe to ship in a release build;
  /// otherwise the reason it isn't. Checked for real (not via `assert`,
  /// which release builds strip) at app startup — see `main()`.
  static String? get releaseSafetyViolation =>
      ApiBaseSafety.releaseViolation(baserUrl);

  //******* routes
  static const String id = 'id'; //! example route, remove this

  //# parent
  static String login = 'login';
  // transaction-store
  static String transactionStore = 'user/wallet/transaction-store';
  static String getServices = 'get-service-info';
  static String sendOTP = 'resend-otp';

  static String getBookingInfo(int id) => 'user/booking/get-info/?id=$id';

  static String verifyOTP = 'verify';

  static String update = 'user/update';

  static String banner = "list/slider";
  //sendMoney

  static String sendMoney = 'user/wallet/send-money';
  //transaction

  static String transaction(int id) => 'user/wallet/transaction?page=$id';

  static String register = 'register';

  /// Public: read before the customer has an account to authenticate with.
  static String onboardingScreens = 'onboarding-screens';

  static String deleteAccount = 'user/delete';

  static String changePassword = 'change-password';

  static String changePasswordUser = 'user/change-password-user';

  static String refresh = 'user/refresh';
  static String appVersionCheck = 'app-version/check';
  static String saveFcmToken = 'user/save-fcm-token';

  /// Questions the customer must answer before ordinary use continues.
  /// Both stay reachable while the gate is closed — they are the way out.
  static String mandatoryActions = 'user/mandatory-actions';
  static String attendanceConfirmation = 'user/attendance-confirmation';

  static String profile = 'user/profile';
  static String analysis = 'user/analysis';
  static String bookingHistory(int id) => 'user/booking/history?page=$id';

  static String cancelBooking = 'user/booking/cancel-booking';
  static String cancellationPreview = 'user/booking/cancellation-preview';
  static String cancellationException = 'user/booking/cancellation-exception';
  static String cancellationEscalate = 'user/booking/cancellation-escalate';
  static String disputeNoShow = 'user/booking/dispute-no-show';
  static String bookingCaseStatus = 'user/booking/case-status';
  static String myPaymentRestrictions = 'user/booking/my-payment-restrictions';

  static String listZone = 'list/zone';
  static String listClub = 'list/club';

  static String listCategory = 'list/category';

  static String listService = 'list/service';

  static String listEmployee = 'list/booking';

  static String listTimeslot = 'list/timeslot';

  /// One operational night's slots, evening and after-midnight already merged
  /// by the server. The app never works out which calendar day a slot is on.
  static String operationalAvailability = 'list/operational-availability';

  /// Whether the previous operational night is still bookable. Asked by the
  /// date step; the server decides, never the device clock.
  static String operationalNightContext = 'list/operational-night-context';

  static String addBooking = 'user/booking/store-booking';

  // Recurring bookings ("حجز شهري"). Creation goes through addBooking with
  // is_monthly=1 — a series is priced and validated by the same code as a
  // normal booking, so it needs no endpoint of its own.
  /// Whether this branch's subscription includes monthly booking. The app
  /// gets a boolean and never learns which plan the venue holds.
  static String seriesCapability(int branchId) =>
      'user/booking/series/capability?branch_id=$branchId';
  static String seriesPreview = 'user/booking/series/preview';
  static String seriesList = 'user/booking/series';
  static String seriesDetails(int id) => 'user/booking/series/$id';
  static String cancelSeriesOccurrence =
      'user/booking/series/cancel-occurrence';
  static String cancelSeriesFuture = 'user/booking/series/cancel-future';
  // Records a declined skip offer. Only the app knows the difference between
  // "no thanks" and abandoning checkout, and those are different answers.
  static String seriesSkipDeclined = 'user/booking/series/skip-declined';

  // Renewal. Quoting is separate from renewing: the price and the dates are
  // both pinned by signature, so neither can move between the two.
  static String seriesRenewalOffer(int id) =>
      'user/booking/series/$id/renewal-offer';
  static String seriesRenew(int id) => 'user/booking/series/$id/renew';
  static String seriesDeclineRenewal(int id) =>
      'user/booking/series/$id/decline-renewal';

  static String charge = 'user/card/charge';
  //user/card/balance

  static String balance = 'user/card/balance';

  ///user/booking/fillter-new-booking?page=5

  static String fillterNewBooking(int id) =>
      'user/booking/fillter-new-booking?page=$id';
  static String markNotificationAsRead(String notificationId) =>
      'user/notifications/read-notification/$notificationId';

  static String markAllNotificationsAsRead =
      'user/notifications/read-all-notification';
  static String notification = 'user/notifications/get-notification';

  static String assistantHistory = 'user/assistant/history';
  static String assistantMessage = 'user/assistant/message';
  static String assistantUnread = 'user/assistant/unread';

  static String coinsBalance = 'user/coins/balance';
  static String coinsHistory(int page) => 'user/coins/history?per_page=20&page=$page';
  static String coinsRedeem = 'user/coins/redeem';
  static String coinsQuote = 'user/coins/quote';

  /// Where the customer is shopping from. Account-scoped, server-resolved.
  static String locationBootstrap = 'user/location/bootstrap';
  static String locationSet = 'user/location/set';
  static String locationResolveZone = 'user/location/resolve-zone';
  static String locationActivate = 'user/location/activate';
  static String locationSave = 'user/location/save';
  static String locationDelete = 'user/location/delete';
}

//doctors/top-ratings
