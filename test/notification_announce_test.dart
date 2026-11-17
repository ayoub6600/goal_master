import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_announce.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_fetch_state.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_logic_cubit.dart';

NotificationItem item(String id, DateTime createdAt,
        {String type = '', String? readAt}) =>
    NotificationItem.fromJson({
      'id': id,
      'type': 'x',
      'notifiable_type': 'User',
      'notifiable_id': 1,
      'data': {'message': 'm $id', 'id': 1, 'type': type},
      'read_at': readAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': createdAt.toIso8601String(),
    });

class _FakeRepo implements NotificationRepo {
  _FakeRepo(this.items);
  final List<NotificationItem> items;
  int markAllCalls = 0;
  bool failMarkAll = false;

  @override
  Future<Either<Failure, NotificationResponse>> getNotifications(int page) async =>
      right(NotificationResponse.fromJson({
        'status': true,
        'data': {
          'current_page': page,
          'last_page': 1,
          'data': items.map((e) => e.toJson()).toList(),
          'path': '',
          'per_page': 15,
          'total': items.length,
          'links': [],
        },
      }));

  @override
  Future<Either<Failure, String>> markAllNotificationsAsRead() async {
    markAllCalls++;
    return failMarkAll ? left(Failure(errMessage: 'x')) : right('تم');
  }

  @override
  Future<Either<Failure, String>> markNotificationAsRead(String id) async =>
      right('ok');
}

void main() {
  final now = DateTime(2026, 11, 17, 12);

  group('notificationsToAnnounce — no burst of old banners', () {
    test('a backlog from before the app came to the foreground is silent', () {
      final unseen = [
        item('d', now.subtract(const Duration(minutes: 5))),
        item('c', now.subtract(const Duration(minutes: 20))),
        item('b', now.subtract(const Duration(hours: 3))),
        item('a', now.subtract(const Duration(days: 1))),
      ];
      expect(notificationsToAnnounce(unseen, visibleSince: now), isEmpty);
    });

    test('several new ones at once: only the newest gets a banner', () {
      final unseen = [
        item('n2', now.add(const Duration(seconds: 10))),
        item('n1', now.add(const Duration(seconds: 5))),
        item('old', now.subtract(const Duration(hours: 1))),
      ];
      final shown = notificationsToAnnounce(unseen, visibleSince: now);
      expect(shown.map((e) => e.id), ['n2']);
    });

    test('Captain Ayoub\'s offer wins over the cancellation notice', () {
      final unseen = [
        item('cancel', now.add(const Duration(seconds: 2))),
        item('offer', now.add(const Duration(seconds: 1)),
            type: 'captain_rejection_offer'),
      ];
      expect(notificationsToAnnounce(unseen, visibleSince: now).single.id,
          'offer');
    });

    test('a small clock difference with the server is tolerated', () {
      final unseen = [item('x', now.subtract(const Duration(seconds: 30)))];
      expect(notificationsToAnnounce(unseen, visibleSince: now), hasLength(1));
    });
  });

  group('NotificationFetchCubit — the notifications screen', () {
    test('opening does not mark anything read; the button does', () async {
      final repo = _FakeRepo([
        item('1', now),
        item('2', now, readAt: now.toIso8601String()),
        item('3', now),
      ]);
      final cubit = NotificationFetchCubit(notificationRepo: repo);
      cubit.pagingController.notifyPageRequestListeners(1);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.unreadCount, 2);
      expect(repo.markAllCalls, 0);

      await cubit.markAllAsRead();
      expect(repo.markAllCalls, 1);
      expect(cubit.unreadCount, 0);
      expect(cubit.state, isA<NotificationLoadSuccessState>(),
          reason: 'the list stays on screen after marking');
      await cubit.close();
    });

    test('refresh keeps the list mounted (no endless loading)', () async {
      final repo = _FakeRepo([item('1', now)]);
      final cubit = NotificationFetchCubit(notificationRepo: repo);
      cubit.pagingController.notifyPageRequestListeners(1);
      await Future<void>.delayed(Duration.zero);

      await cubit.refresh();
      expect(cubit.state, isA<NotificationLoadSuccessState>());
      await cubit.close();
    });

    test('opening one notification marks only that one', () async {
      final repo = _FakeRepo([item('1', now), item('2', now)]);
      final cubit = NotificationFetchCubit(notificationRepo: repo);
      cubit.pagingController.notifyPageRequestListeners(1);
      await Future<void>.delayed(Duration.zero);

      cubit.markReadLocally('2');
      expect(cubit.unreadCount, 1);
      await cubit.close();
    });

    test('a failed mark-all puts the unread ones back', () async {
      final repo = _FakeRepo([item('1', now)])..failMarkAll = true;
      final cubit = NotificationFetchCubit(notificationRepo: repo);
      cubit.pagingController.notifyPageRequestListeners(1);
      await Future<void>.delayed(Duration.zero);

      await cubit.markAllAsRead();
      expect(cubit.unreadCount, 1);
      await cubit.close();
    });
  });
}
