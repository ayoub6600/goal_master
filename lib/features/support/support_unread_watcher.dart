import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goal_master/features/support/support_repo.dart';

/// Keeps [SupportRepo.unread] fresh while the app is in front: at once,
/// on every return to the app, and once a minute — so the red count on
/// «حسابك» and «خدمة العملاء» is right even when no push arrived.
class SupportUnreadWatcher extends StatefulWidget {
  const SupportUnreadWatcher({super.key, required this.child, this.repo});

  final Widget child;
  final SupportRepo? repo;

  @override
  State<SupportUnreadWatcher> createState() => _SupportUnreadWatcherState();
}

class _SupportUnreadWatcherState extends State<SupportUnreadWatcher>
    with WidgetsBindingObserver {
  late final SupportRepo _repo = widget.repo ?? SupportRepo();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repo.refreshUnread();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _repo.refreshUnread());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _repo.refreshUnread();
      _timer ??= Timer.periodic(const Duration(seconds: 60), (_) => _repo.refreshUnread());
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
