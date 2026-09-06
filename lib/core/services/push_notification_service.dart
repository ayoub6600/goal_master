import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/services/service_locator.dart';

// Required by firebase_messaging: must be a top-level (or static) function
// so it can run in its own isolate when the app is backgrounded/terminated.
// It's intentionally a no-op — the OS already renders the notification from
// the message's `notification` payload without any app code running.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  /// Call once, right after Firebase.initializeApp().
  ///
  /// Wrapped end to end: this runs unconditionally in main(), before
  /// runApp(), with nothing above it to catch a throw. requestPermission()
  /// is not expected to throw on a normally-configured device, but an
  /// unusual permission/entitlement state turning into an uncaught
  /// exception here would crash app startup entirely — never rendering a
  /// single frame — which is a strictly worse failure than the one
  /// registerTokenIfLoggedIn() already guards against below. The
  /// onTokenRefresh subscription still has to be reached even when
  /// requestPermission() itself fails, since that subscription is what
  /// later registers a token if APNS only becomes available afterwards.
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // In the foreground, the authenticated socket flow renders the correct
      // Captain persona. FCM remains responsible for background/terminated UI.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    } catch (_) {
      // Best-effort — the app must still start, and a token can still
      // arrive later via onTokenRefresh below.
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  }

  /// Call after login (or on app start if already logged in) — the backend
  /// route this hits requires an authenticated user.
  static Future<void> registerTokenIfLoggedIn() async {
    final loggedIn = SharedPreferenceUtil.getString(PrefKey.login) == 'true';
    if (!loggedIn) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerToken(token);
      }
    } catch (_) {
      // iOS simulators can fail here until APNS provides a token. FCM is
      // best-effort and must not block the app from rendering.
    }
  }

  static Future<void> _registerToken(String token) async {
    try {
      await getIt<DioConsumer>().post(
        EndPoints.saveFcmToken,
        data: {
          'fcm_token': token,
          // Lets the backend keep this device's token in its own row,
          // separate from whatever the Manager App registered for the same
          // person — see user_device_tokens / SendPushNotification().
          'app_domain': 'customer',
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
    } catch (_) {
      // Best-effort — retried on next app open or token refresh.
    }
  }

  /// Call right before clearing the local session on logout — removes only
  /// THIS device's Customer-app registration, not every token this person
  /// has (e.g. their Manager App on another device keeps working).
  static Future<void> unregisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await getIt<DioConsumer>().post(
        EndPoints.logout,
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Best-effort — a missed removal just means one stale token to be
      // cleaned up server-side the next time Firebase reports it invalid.
    }
  }
}
