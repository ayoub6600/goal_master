import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/assistant/data/assistant_history_cache.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';

part 'assistant_chat_state.dart';

class AssistantChatCubit extends Cubit<AssistantChatState> {
  AssistantChatCubit(this.assistantRepo) : super(const AssistantChatState());

  final AssistantRepo assistantRepo;
  bool _historyLoaded = false;

  /// The zone whose captain is currently on screen.
  ///
  /// The persona is scoped by zone on the backend — Misurata has كابتن أيوب,
  /// and anything the server cannot place falls back to the DEFAULT profile,
  /// which today is كابتن طرابلس. So "no zone yet" does not render a neutral
  /// captain; it renders the wrong city's captain, and it looks completely
  /// normal. Tracking which zone the current persona belongs to is what lets
  /// us notice.
  int? _loadedForZoneId;

  /// The zone the in-flight request was made for, so a slow answer for the
  /// city the customer has already left can be thrown away instead of
  /// overwriting the right one.
  int? _requestedZoneId;

  bool get hasCachedHistory => _historyLoaded;

  /// [markRead] is passed only by the chat screen. The floating bubble calls
  /// this too — for the avatar — and must leave the badge alone.
  Future<void> loadHistory({
    bool markRead = false,
    bool forceRefresh = false,
  }) async {
    final zoneId = ActiveLocationSnapshot.current?.zoneId;

    // The chat cubit is app-wide, so returning to the conversation can reuse
    // the history already in memory. We still refresh if an unread message
    // exists, because that is the signal the cached conversation is stale.
    //
    // A zone change is also that signal: the captain on screen belongs to a
    // city the customer is no longer in, and keeping it would leave the venue
    // list and the persona disagreeing about where they are.
    final needsRefresh = forceRefresh ||
        !_historyLoaded ||
        _loadedForZoneId != zoneId ||
        AssistantHistoryCache.isStale ||
        (markRead && state.unreadCount > 0);
    if (!needsRefresh || state.loading) {
      if (markRead && state.unreadCount > 0 && !state.loading) {
        emit(state.copyWith(unreadCount: 0));
      }
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    _requestedZoneId = zoneId;
    final result = await assistantRepo.getHistory(markRead: markRead);

    // The customer moved while this was in the air. Applying it now would put
    // the previous city's captain back on screen and leave it there, because
    // as far as this cubit is concerned the load succeeded.
    if (_requestedZoneId != ActiveLocationSnapshot.current?.zoneId) {
      emit(state.copyWith(loading: false));
      return;
    }

    result.fold(
      (failure) =>
          emit(state.copyWith(loading: false, error: failure.errMessage)),
      (conversation) {
        _historyLoaded = true;
        _loadedForZoneId = zoneId;
        AssistantHistoryCache.markFresh();
        emit(state.copyWith(
          loading: false,
          // Reading the chat is what clears it; a background fetch is not.
          unreadCount: markRead ? 0 : null,
          messages: conversation.messages,
          avatarUrl: conversation.avatarUrl,
          avatarStates: conversation.avatarStates,
          assistantName: conversation.assistantName,
          assistantShortName: conversation.assistantShortName,
        ));
      },
    );
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(sending: true, error: null));
    final result = await assistantRepo.sendText(text.trim());
    result.fold(
      (failure) =>
          emit(state.copyWith(sending: false, error: failure.errMessage)),
      (conversation) {
        AssistantHistoryCache.markFresh();
        emit(state.copyWith(
          sending: false,
          // The customer is looking at the chat right now.
          unreadCount: 0,
          messages: conversation.messages,
          avatarUrl: conversation.avatarUrl,
          avatarStates: conversation.avatarStates,
          assistantName: conversation.assistantName,
          assistantShortName: conversation.assistantShortName,
        ));
      },
    );
  }

  Future<void> sendAction(String action, Map<String, dynamic> payload) async {
    emit(state.copyWith(sending: true, error: null));
    final result = await assistantRepo.sendAction(action, payload);
    result.fold(
      (failure) =>
          emit(state.copyWith(sending: false, error: failure.errMessage)),
      (conversation) {
        AssistantHistoryCache.markFresh();
        emit(state.copyWith(
          sending: false,
          unreadCount: 0,
          messages: conversation.messages,
          avatarUrl: conversation.avatarUrl,
          avatarStates: conversation.avatarStates,
          assistantName: conversation.assistantName,
          assistantShortName: conversation.assistantShortName,
        ));
      },
    );
  }

  /// Refreshes the badge. Cheap enough to call whenever the app comes back to
  /// the foreground, which is when an offer sent while the app was closed
  /// would otherwise go unnoticed.
  Future<void> refreshUnread() async {
    final result = await assistantRepo.getUnreadCount();
    result.fold(
      (_) {}, // A badge that fails to load is not worth an error state.
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }
}
