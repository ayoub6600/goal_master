import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';

/// Navigates to a booking's details screen from a push notification's tap
/// (opened from background) or launch (opened from terminated), using the
/// `booking_id` the backend already attaches to the notification's data
/// payload (see `SendPushNotification()` in goal-master-web).
class NotificationNavigationService {
  /// The assistant's offer after a venue refuses. Opens the CHAT, not the
  /// booking — the point of the notification is the solution waiting there.
  static const captainOffer = 'captain_rejection_offer';

  static Future<void> handleMessageTap(RemoteMessage message) async {
    // Routed by type first: a booking id is attached to the assistant's
    // offer too, and opening the booking would bury the very message the
    // notification exists to surface.
    if (message.data['type']?.toString() == captainOffer) {
      AppRouter.router.push(RoutesKeys.kAssistantChat);
      return;
    }

    final bookingIdStr = message.data['booking_id'];
    if (bookingIdStr == null) return;

    final bookingId = int.tryParse(bookingIdStr.toString());
    if (bookingId == null) return;

    final result = await getIt<BookingRepoImp>().getBookingInfo(bookingId);
    result.fold(
      (_) {}, // booking no longer available/accessible — nothing to open
      (booking) {
        AppRouter.router.push(
          RoutesKeys.kBookingItemsDetails,
          extra: booking,
        );
      },
    );
  }

  /// Call once at startup, after the app's first frame, to handle a
  /// notification tap that launched the app from a fully terminated state.
  static Future<void> handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await handleMessageTap(initialMessage);
    }
  }
}
