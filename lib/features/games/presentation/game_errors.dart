/// Server errors as a player should read them: Arabic, and saying what to
/// do next, never a raw framework message.
String friendlyGameError(String? raw) {
  final m = (raw ?? '').toLowerCase();
  if (m.contains('too many')) return 'محاولات كثيرة في وقت قصير. استنى دقيقة وحاول مرة ثانية.';
  if (m.contains('game_locked') || m.contains('locked')) return 'هذا المستوى مقفول حاليًا.';
  if (m.contains('unavailable')) return 'اللعبة غير متاحة الآن. حاول لاحقًا.';
  if (m.contains('unauthenticated') || m.contains('token')) return 'انتهت جلستك. سجّل الدخول مرة ثانية.';
  if (m.contains('socket') || m.contains('connection') || m.contains('timeout') || m.contains('network')) {
    return 'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة ثانية.';
  }
  final hasArabic = RegExp(r'[؀-ۿ]').hasMatch(raw ?? '');
  return hasArabic ? raw! : 'حدث خطأ غير متوقع. حاول مرة ثانية.';
}
