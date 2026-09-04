class PrefKey {
  /// Newest notification the customer has already been shown.
  ///
  /// Persisted because the watermark used to live only in memory: every
  /// fresh login started from null, so the whole first page counted as
  /// unseen and was replayed — sound, banner and all — on every sign-in.
  static const String lastSeenNotificationId = 'last_seen_notification_id';

  static const String baseUrl = "baseUrl";
  static const String login = "LOGIN";
  static const String fcmToken = "FCMTOKEN";
  static const String userId = "USERID";
  static const String isLoggedIn = "IsLoggedIn";
  static const String profileImage = "PROFILE_IMAGE";
  static const String fullName = 'fullName';
  static const String email = "EMAIL";
  static const String country = "COUNTRY";
  static const String mobile = "MOBILE";
  static const String gender = "gender";
  static const String phone = "phone";

  static const String currentLanguageCode = "currentLanguageCode";
  static const String chucker = "chucker";
  static const String homeDialog = "homeDialog";
  static const String refreshToken = "refreshToken";

  /// Legacy loose coordinates.
  ///
  /// Superseded by the account-owned Active Location. Kept only so a customer
  /// upgrading the app carries their last position into the new system once,
  /// instead of being sent to a location screen they already answered.
  /// Nothing reads these to make a decision any more.
  static const String savedLat = "savedLat";
  static const String savedLng = "savedLng";

  /// Whether the one-time migration of the pair above has already run.
  static const String legacyLocationMigrated = "legacy_location_migrated";

  /// Last known Active Location, cached for a fast first frame only.
  ///
  /// Never the truth — the account is. Stamped with the user id it belongs to,
  /// because an unstamped cache is exactly how the previous customer's city
  /// followed the handset into the next person's session.
  static const String activeLocationCache = "active_location_cache";
  static const String activeLocationOwner = "active_location_owner";
}
