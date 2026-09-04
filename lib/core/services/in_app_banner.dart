import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goal_master/core/routing/app_router.dart';

/// A heads-up that slides down over whatever the customer is looking at.
///
/// Exists because a push notification is invisible while the app is in the
/// foreground — which is exactly when the venue's answer tends to arrive, so
/// the offer that follows a refusal was landing in a chat nobody had a reason
/// to open.
///
/// Deliberately not styled like a system notification: it carries the
/// assistant's own face and name, because the message is from that character
/// and tapping it goes to the conversation, not to a booking.
class InAppBanner {
  static OverlayEntry? _current;
  static Timer? _timer;

  /// Shows the banner, replacing any that is still on screen.
  ///
  /// Silently does nothing when no overlay is mounted yet (very early
  /// startup) — a missed banner is not worth a crash, and the notification
  /// itself is still in the chat.
  static void show({
    required String title,
    required String body,
    String? avatarUrl,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 6),
  }) {
    final overlay =
        AppRouter.router.routerDelegate.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    dismiss();

    final entry = OverlayEntry(
      builder: (context) => _BannerBody(
        title: title,
        body: body,
        avatarUrl: avatarUrl,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _BannerBody extends StatefulWidget {
  const _BannerBody({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
    this.avatarUrl,
  });

  final String title;
  final String body;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_BannerBody> createState() => _BannerBodyState();
}

class _BannerBodyState extends State<_BannerBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, topInset + 8, 12, 0),
              child: Dismissible(
                key: const ValueKey('in_app_banner'),
                direction: DismissDirection.up,
                onDismissed: (_) => widget.onDismiss(),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 84),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _avatar(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_left,
                            size: 24, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The assistant's own face. Falls back to a generic icon rather than
  /// leaving a hole — the message still stands without the picture.
  Widget _avatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1F5234),
      ),
      child: ClipOval(
        child: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
            ? Image.network(
                widget.avatarUrl!,
                fit: BoxFit.cover,
                // The artwork is a tall character illustration; a centred
                // crop cuts off the face at this size.
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 28,
                ),
              )
            : const Icon(Icons.support_agent, color: Colors.white, size: 28),
      ),
    );
  }
}
