import 'package:flutter/material.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/attendance/data/mandatory_action.dart';
import 'package:goal_master/features/attendance/data/mandatory_action_repo.dart';

/// Holds the app until the customer answers what they have been asked.
///
/// Wraps whatever the router is showing, so it covers every route and survives
/// navigation, tab switches and Android back. One gate rather than a check on
/// each screen: a per-screen check is a list nobody finishes, and the one that
/// gets forgotten is the way through.
///
/// The backend is the authority. This widget never decides a question exists or
/// has gone away — it asks on start, asks again when the app returns to the
/// foreground, and asks again after every answer. Nothing is remembered
/// locally, so force-quitting, reinstalling or signing in on another device
/// all lead back to the same question.
class MandatoryActionGate extends StatefulWidget {
  const MandatoryActionGate({
    super.key,
    required this.child,
    this.repo,
    this.isLoggedIn,
  });

  final Widget child;

  /// Injected in tests; resolved from the locator in the app.
  final MandatoryActionRepo? repo;
  final bool Function()? isLoggedIn;

  @override
  State<MandatoryActionGate> createState() => _MandatoryActionGateState();
}

class _MandatoryActionGateState extends State<MandatoryActionGate>
    with WidgetsBindingObserver {
  List<MandatoryAction> _pending = const [];
  bool _submitting = false;
  String? _error;
  bool _loaded = false;

  MandatoryActionRepo get _repo => widget.repo ?? getIt<MandatoryActionRepo>();

  bool get _loggedIn =>
      widget.isLoggedIn?.call() ??
      (SharedPreferenceUtil.getString(PrefKey.login) == 'true');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-asked on every return to the foreground: a venue may have reported a
    // no-show while the app sat in the background, and the customer should
    // meet the question on the way back in rather than after another booking.
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (!_loggedIn) {
      if (mounted) setState(() => _pending = const []);
      return;
    }

    final result = await _repo.pending();
    if (!mounted) return;

    result.fold(
      // A failed check must not open the gate. If we cannot confirm the
      // customer is clear, the safe reading is "unchanged", not "free to go".
      (_) => setState(() => _loaded = true),
      (actions) => setState(() {
        _pending = actions;
        _loaded = true;
      }),
    );
  }

  Future<void> _answer(bool attended) async {
    if (_submitting || _pending.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await _repo.answer(
      confirmationId: _pending.first.id,
      attended: attended,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _submitting = false;
        // The answer is not lost and the gate stays shut — dismissing here on
        // a failed write would let somebody through on a question the server
        // still has open.
        _error = failure.errMessage.isEmpty
            ? 'تعذّر إرسال ردك. تحقق من الاتصال وحاول مرة أخرى.'
            : failure.errMessage;
      }),
      (remaining) => setState(() {
        _submitting = false;
        _pending = remaining;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocking = _loaded && _loggedIn && _pending.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (blocking)
          // canPop: false is what makes Android back a no-op here. Combined
          // with covering the whole surface, there is no gesture out of it —
          // except signing out, which stays reachable below.
          PopScope(
            canPop: false,
            child: _Prompt(
              action: _pending.first,
              remaining: _pending.length,
              submitting: _submitting,
              error: _error,
              onAnswer: _answer,
              onLogout: _logout,
            ),
          ),
      ],
    );
  }

  Future<void> _logout() async {
    // The one way out, deliberately kept. A question the customer cannot
    // answer must never become an account they cannot leave.
    await SharedPreferenceUtil.putString(PrefKey.login, 'false');
    await SharedPreferenceUtil.putString(PrefKey.fcmToken, '');
    await SharedPreferenceUtil.putString(PrefKey.refreshToken, '');
    if (mounted) setState(() => _pending = const []);
  }
}

/// The question itself. States what the venue reported; accuses nobody.
class _Prompt extends StatelessWidget {
  const _Prompt({
    required this.action,
    required this.remaining,
    required this.submitting,
    required this.error,
    required this.onAnswer,
    required this.onLogout,
  });

  final MandatoryAction action;
  final int remaining;
  final bool submitting;
  final String? error;
  final Future<void> Function(bool attended) onAnswer;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                key: const Key('mandatory_action_prompt'),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      action.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    // The venue's stated reason, shown with the question so
                    // the customer knows what they are being asked to confirm.
                    if (action.reason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'السبب المسجل: ${action.reason}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (action.context.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          action.context,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                    if (remaining > 1) ...[
                      const SizedBox(height: 10),
                      Text(
                        'لديك $remaining حجوزات بحاجة إلى تأكيد.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        key: const Key('mandatory_action_error'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      key: const Key('mandatory_action_attended'),
                      onPressed: submitting ? null : () => onAnswer(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: submitting
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                            )
                          : Text(action.confirmLabel ?? 'نعم، حضرت'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      key: const Key('mandatory_action_absent'),
                      onPressed: submitting ? null : () => onAnswer(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(action.denyLabel ?? 'لا، لم أحضر'),
                    ),
                    if (action.note != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        action.note!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ],
                    const SizedBox(height: 6),
                    TextButton(
                      key: const Key('mandatory_action_logout'),
                      onPressed: submitting ? null : () => onLogout(),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
