import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/auth/data/model/onboarding/onboarding_screen_model.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';

/// Holds the admin-configured signup screens for the length of the session.
///
/// Signing up walks through four screens in a row; fetching the same handful
/// of image URLs four times would put a network round trip between the
/// customer and every button they press. So the first screen asks, and the
/// rest read what it got.
///
/// Nothing here can fail loudly: if the request does not come back, the app
/// keeps the look it ships with and signup carries on. Artwork is decoration,
/// and decoration must never stand between a customer and an account.
class OnboardingScreensService {
  OnboardingScreensService._();

  static final OnboardingScreensService instance = OnboardingScreensService._();

  final Map<String, OnboardingScreenModel> _bySlug = {};
  Future<void>? _inFlight;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Fetches once per session. Concurrent callers share the same request
  /// rather than each firing their own.
  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _inFlight ??= _load();
  }

  Future<void> _load() async {
    final result = await getIt<AuthRepoImpl>().onboardingScreens();

    result.fold(
      (_) {
        // Left deliberately silent — see the class note.
      },
      (screens) {
        _bySlug
          ..clear()
          ..addEntries(screens.map((s) => MapEntry(s.slug, s)));
      },
    );

    _loaded = true;
    _inFlight = null;
  }

  OnboardingScreenModel? of(String slug) => _bySlug[slug];

  String? imageFor(String slug) => _bySlug[slug]?.imageUrl;

  /// The admin's wording where they set one, the app's own otherwise.
  String titleFor(String slug, String fallback) =>
      _bySlug[slug]?.title ?? fallback;

  String? subtitleFor(String slug, String? fallback) =>
      _bySlug[slug]?.subtitle ?? fallback;

  /// Test seam.
  void resetForTest() {
    _bySlug.clear();
    _loaded = false;
    _inFlight = null;
  }
}
