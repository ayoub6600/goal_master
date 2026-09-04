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
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Best-effort — retried on next app open or token refresh.
    }
  }
}
