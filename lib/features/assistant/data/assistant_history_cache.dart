/// Session-only freshness marker for Captain Ayoub's in-memory history.
///
/// The notification flow can invalidate it without reaching into the Cubit,
/// so opening the chat after a live offer always fetches that new message.
class AssistantHistoryCache {
  static bool _stale = false;

  static bool get isStale => _stale;

  static void invalidate() => _stale = true;

  static void markFresh() => _stale = false;
}
