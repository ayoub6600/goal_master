import 'package:goal_master/features/notification/data/model/notification_response.dart';

/// Which of the newly fetched notifications deserve a banner + sound.
///
/// Only something that genuinely arrived while the app was on screen. What
/// piled up while the app was in the background (or closed) was already
/// delivered by the system as push notifications; replaying it on return
/// produced a burst of old banners («مبروك كسبت 7 كوينز…», «تم تأكيد
/// حجزك»…) each with its sound. Those go into the list and the badge
/// silently.
///
/// Rules:
///  - nothing created before the app came to the foreground ([visibleSince]),
///    with [slack] for clock difference between phone and server;
///  - at most one banner per check: Captain Ayoub's offer if present (it
///    is the one that needs attention), otherwise the newest.
///
/// [unseen] is newest first, as the API returns it.
List<NotificationItem> notificationsToAnnounce(
  List<NotificationItem> unseen, {
  required DateTime visibleSince,
  Duration slack = const Duration(seconds: 90),
}) {
  final threshold = visibleSince.subtract(slack);
  final fresh =
      unseen.where((n) => !n.createdAt.isBefore(threshold)).toList();
  if (fresh.isEmpty) return const [];

  for (final n in fresh) {
    if (n.data.type == 'captain_rejection_offer') return [n];
  }
  return [fresh.first];
}
