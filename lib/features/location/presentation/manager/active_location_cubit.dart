import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';
import 'package:goal_master/features/location/data/repo/location_repo.dart';

enum ActiveLocationStatus {
  /// Nothing has been asked yet — the app has not decided anything.
  initial,

  /// Reading the account. The cached value may already be showing.
  loading,

  /// A usable location is set. The marketplace is scoped.
  ready,

  /// No location on the account. The required-location screen must open.
  missing,

  /// A real place, resolved to no Goal Master zone. Not an error, and not
  /// "everywhere" — the customer is told we are not in their area.
  unserviceable,

  /// The account could not be read and there is no cache to fall back on.
  failed,
}

class ActiveLocationState {
  final ActiveLocationStatus status;
  final ActiveLocation? location;
  final List<ActiveLocation> saved;
  final String? error;

  /// True while a selection is being written, so screens can disable buttons
  /// without inventing their own flags.
  final bool isSubmitting;

  const ActiveLocationState({
    this.status = ActiveLocationStatus.initial,
    this.location,
    this.saved = const [],
    this.error,
    this.isSubmitting = false,
  });

  /// The one question the marketplace asks. Null scopes nothing.
  int? get zoneId => location?.isServiceable == true ? location!.zoneId : null;

  String? get zoneName => location?.zoneName;

  /// Whether discovery can proceed. Deliberately false for an unserviceable
  /// point: showing every city would be worse than showing nothing.
  bool get hasUsableLocation =>
      status == ActiveLocationStatus.ready && location?.isServiceable == true;

  ActiveLocationState copyWith({
    ActiveLocationStatus? status,
    ActiveLocation? location,
    List<ActiveLocation>? saved,
    String? error,
    bool? isSubmitting,
    bool clearLocation = false,
    bool clearError = false,
  }) {
    return ActiveLocationState(
      status: status ?? this.status,
      location: clearLocation ? null : (location ?? this.location),
      saved: saved ?? this.saved,
      error: clearError ? null : (error ?? this.error),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// The customer's location, and the only thing that decides it.
///
/// Registered as a singleton and provided once, above the router. That
/// placement is the fix for the original bug: the location used to be derived
/// per screen, so Home → Account → Home rebuilt Home with nothing and it fell
/// back to un-scoped results. A cubit that outlives every route cannot lose an
/// answer to navigation.
///
/// Truth model, stated once so it cannot drift:
///
///   SERVER is the truth.  The account owns the location. It survives reinstall,
///                         follows the customer to another device, and is what
///                         stops one customer inheriting another's.
///   LOCAL is a cache.     Read at startup so the first frame is not empty. It
///                         is never written by anything except a successful
///                         server response, and never outranks the server.
///   RECONCILE on bootstrap. The cache paints immediately, the account is read,
///                         and the account wins. A cache belonging to a
///                         different user id is discarded unread.
class ActiveLocationCubit extends Cubit<ActiveLocationState> {
  ActiveLocationCubit(this._repo) : super(const ActiveLocationState());

  final LocationRepo _repo;

  /// The single place the context-free projection is written.
  ///
  /// Overriding emit rather than calling publish() at each site: there are a
  /// dozen emits in this class and the one somebody forgets is the one that
  /// leaves a repository sending the previous city's coordinates.
  @override
  void emit(ActiveLocationState state) {
    ActiveLocationSnapshot.publish(state.location);
    super.emit(state);
  }

  /// Whose cache is on this device.
  ///
  /// Without the owner stamp the cache is exactly the leak the old
  /// savedLat/savedLng pair had: it outlives sign-out, and the next person to
  /// log in on the handset starts in the previous customer's city.
  static const _cacheKey = PrefKey.activeLocationCache;
  static const _cacheOwnerKey = PrefKey.activeLocationOwner;

  /// Paint from cache, then reconcile with the account.
  ///
  /// The cache never decides anything on its own — it only avoids an empty
  /// first frame while the real answer is fetched.
  Future<void> bootstrap({int? userId}) async {
    emit(state.copyWith(status: ActiveLocationStatus.loading, clearError: true));

    final cached = _readCache(userId ?? _currentUserId);
    if (cached != null) {
      emit(state.copyWith(location: cached, status: ActiveLocationStatus.loading));
    }

    final result = await _repo.bootstrap();

    // Set by the branch below when the account has no location yet. Awaited
    // after the fold rather than fired and forgotten: bootstrap() must not
    // report "no location" while a migration that supplies one is still in
    // flight, or the gate flashes the location screen at a customer who is
    // about to be given theirs.
    var shouldAdoptLegacy = false;

    result.fold(
      (failure) {
        // Offline with a cache: keep working from it rather than sending the
        // customer to a location screen they have already answered. Offline
        // with no cache: say so, do not guess.
        if (cached != null) {
          emit(state.copyWith(
            status: cached.isServiceable
                ? ActiveLocationStatus.ready
                : ActiveLocationStatus.unserviceable,
            location: cached,
          ));
          return;
        }

        emit(state.copyWith(
          status: ActiveLocationStatus.failed,
          error: failure.errMessage,
        ));
      },
      (bootstrap) {
        final active = bootstrap.active;

        if (active == null) {
          // The account has no location. Anything cached is stale or belongs
          // to a previous session — drop it rather than serve it.
          _clearCache();
          emit(state.copyWith(
            status: ActiveLocationStatus.missing,
            saved: bootstrap.saved,
            clearLocation: true,
          ));
          shouldAdoptLegacy = true;
          return;
        }

        _writeCache(active, userId ?? _currentUserId);

        emit(state.copyWith(
          status: active.isServiceable
              ? ActiveLocationStatus.ready
              : ActiveLocationStatus.unserviceable,
          location: active,
          saved: bootstrap.saved,
        ));
      },
    );

    if (shouldAdoptLegacy) {
      await _adoptLegacyCoordinates();
    }
  }

  /// Set the location from a coordinate, whatever produced it.
  ///
  /// One method for both «موقعي الحالي» and «تحديد على الخريطة»: they differ
  /// only in `source`. Two methods would have become two slightly different
  /// paths, and one of them would eventually forget to persist.
  Future<bool> setFromCoordinates({
    required double latitude,
    required double longitude,
    required String source,
    String? label,
    String? formattedAddress,
    String? city,
    bool save = false,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _repo.setFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      source: source,
      label: label,
      formattedAddress: formattedAddress,
      city: city,
      save: save,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, error: failure.errMessage));
        return false;
      },
      (location) {
        _writeCache(location, _currentUserId);

        emit(state.copyWith(
          isSubmitting: false,
          location: location,
          status: location.isServiceable
              ? ActiveLocationStatus.ready
              : ActiveLocationStatus.unserviceable,
        ));

        // Only a serviceable location lets the customer through. An
        // unserviceable one is recorded and reported, never treated as done.
        return location.isServiceable;
      },
    );
  }

  Future<bool> selectSaved(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _repo.activate(id);

    return result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, error: failure.errMessage));
        return false;
      },
      (location) {
        _writeCache(location, _currentUserId);
        emit(state.copyWith(
          isSubmitting: false,
          location: location,
          status: location.isServiceable
              ? ActiveLocationStatus.ready
              : ActiveLocationStatus.unserviceable,
        ));
        return location.isServiceable;
      },
    );
  }

  Future<void> saveCurrent(String label) async {
    final current = state.location;
    if (current == null) return;

    final result = await _repo.save(current.id, label);

    result.fold(
      (_) {},
      (_) => refreshSaved(),
    );
  }

  Future<void> deleteSaved(int id) async {
    await _repo.delete(id);
    await refreshSaved();
  }

  /// Re-read the saved list without disturbing the active choice.
  Future<void> refreshSaved() async {
    final result = await _repo.bootstrap();

    result.fold(
      (_) {},
      (bootstrap) {
        final active = bootstrap.active;

        emit(state.copyWith(
          saved: bootstrap.saved,
          location: active,
          clearLocation: active == null,
          status: active == null
              ? ActiveLocationStatus.missing
              : (active.isServiceable
                  ? ActiveLocationStatus.ready
                  : ActiveLocationStatus.unserviceable),
        ));

        if (active != null) {
          _writeCache(active, _currentUserId);
        } else {
          _clearCache();
        }
      },
    );
  }

  /// Wipe everything on sign-out.
  ///
  /// Called from the logout path so the handset carries nothing into the next
  /// session. The server copy stays untouched — it is this account's, and it is
  /// what restores their city when they sign back in.
  void clearForSignOut() {
    _clearCache();
    ActiveLocationSnapshot.clear();
    emit(const ActiveLocationState(status: ActiveLocationStatus.missing));
  }

  /// Carry the old loose coordinates into the account, once.
  ///
  /// Before this feature, location was two SharedPreferences doubles written by
  /// LayoutCubit. A customer updating the app has those, and sending them
  /// straight to a "where are you?" screen would be asking a question they
  /// already answered — for a value we are holding.
  ///
  /// Runs only when the ACCOUNT has nothing, so it can never overwrite a real
  /// choice, and only once, so a customer who deliberately clears their
  /// location is not dragged back to it on the next launch. The legacy keys are
  /// left in place: something else may still be mid-migration, and deleting
  /// them buys nothing.
  Future<void> _adoptLegacyCoordinates() async {
    if (SharedPreferenceUtil.getBool(PrefKey.legacyLocationMigrated)) return;

    final hasLat = SharedPreferenceUtil.haveKey(PrefKey.savedLat) == true;
    final hasLng = SharedPreferenceUtil.haveKey(PrefKey.savedLng) == true;

    // Mark it done either way. A device with nothing to migrate must not
    // re-check on every launch forever.
    await SharedPreferenceUtil.putBool(PrefKey.legacyLocationMigrated, true);

    if (!hasLat || !hasLng) return;

    final lat = SharedPreferenceUtil.getDouble(PrefKey.savedLat);
    final lng = SharedPreferenceUtil.getDouble(PrefKey.savedLng);
    if (lat == 0 && lng == 0) return;

    // The server resolves the zone, exactly as it would for a fresh pick. If
    // those old coordinates fall outside every zone the customer lands on the
    // location screen anyway — which is correct, because they were never in a
    // serviceable area to begin with.
    await setFromCoordinates(
      latitude: lat,
      longitude: lng,
      source: 'map',
    );
  }

  // ---- cache ----

  int get _currentUserId => SharedPreferenceUtil.getInt(PrefKey.userId);

  ActiveLocation? _readCache(int userId) {
    // A cache with no owner, or another account's owner, is not ours to read.
    final owner = SharedPreferenceUtil.getInt(_cacheOwnerKey);
    if (owner == 0 || owner != userId) return null;

    final raw = SharedPreferenceUtil.getString(_cacheKey);
    if (raw.isEmpty) return null;

    try {
      return ActiveLocation.maybeFrom(jsonDecode(raw));
    } catch (_) {
      // A corrupt cache is simply no cache. The account still has the answer.
      return null;
    }
  }

  void _writeCache(ActiveLocation location, int userId) {
    SharedPreferenceUtil.putString(_cacheKey, jsonEncode(location.toJson()));
    SharedPreferenceUtil.putInt(_cacheOwnerKey, userId);
  }

  void _clearCache() {
    SharedPreferenceUtil.putString(_cacheKey, '');
    SharedPreferenceUtil.putInt(_cacheOwnerKey, 0);
  }
}
