/// Pure validation for whether an API base URL is safe to ship in a release
/// build.
///
/// Deliberately separate from [EndPoints.baserUrl] (a `String.fromEnvironment`
/// compile-time constant, fixed for the lifetime of a given build/test run)
/// so the actual rule can be exercised against arbitrary URLs in tests —
/// the constant itself can't be varied at test-run time.
class ApiBaseSafety {
  ApiBaseSafety._();

  static final RegExp _privateLan =
      RegExp(r'//(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)');

  static bool isLocalOrLan(String url) =>
      url.contains('127.0.0.1') ||
      url.contains('localhost') ||
      url.contains('10.0.2.2') ||
      _privateLan.hasMatch(url);

  /// Null when [url] is safe to ship in a release build; otherwise a
  /// human-readable reason it isn't.
  static String? releaseViolation(String url) {
    if (isLocalOrLan(url)) {
      return 'API_BASE resolves to a local/LAN address ($url) — a release '
          'build must never ship pointed at a developer machine.';
    }
    if (!url.startsWith('https://')) {
      return 'API_BASE is not HTTPS ($url) — release builds must use HTTPS.';
    }
    return null;
  }
}
