import 'package:flutter/material.dart';

/// The assistant composing a reply.
///
/// Shaped like one of its own message bubbles — same avatar, same side, same
/// corner radius — so the wait reads as the character thinking rather than as
/// the app stalling. A bare spinner under the thread said "something is
/// loading"; this says "he is answering you", which is the thing the customer
/// actually wants to know.
///
/// The three dots rise in sequence on one controller, so they stay in step
/// however long the wait runs.
class AssistantTypingIndicator extends StatefulWidget {
  const AssistantTypingIndicator({super.key, this.avatarUrl});

  final String? avatarUrl;

  @override
  State<AssistantTypingIndicator> createState() =>
      _AssistantTypingIndicatorState();
}

class _AssistantTypingIndicatorState extends State<AssistantTypingIndicator>
    with SingleTickerProviderStateMixin {
  /// The only ticker this State owns.
  ///
  /// SingleTickerProviderStateMixin permits exactly one — a second controller
  /// vsynced to `this` crashes the widget on first build. The fade-in below
  /// therefore uses TweenAnimationBuilder, which brings its own.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _avatar(),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  // Squared off toward the avatar, matching the assistant's
                  // own bubbles.
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => _dot(i)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One dot, offset a third of a cycle behind the previous one.
  Widget _dot(int index) {
    // Each dot owns a third of the cycle, then rests — so the group reads as
    // a wave rather than three things blinking at once.
    final progress = (_controller.value - (index * 0.18)) % 1.0;
    final lift = progress < 0.5
        ? Curves.easeOut.transform(progress * 2)
        : Curves.easeIn.transform((1 - progress) * 2);

    return Padding(
      padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
      child: Transform.translate(
        offset: Offset(0, -3 * lift),
        child: Opacity(
          opacity: 0.45 + (0.55 * lift),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1F5234),
      ),
      child: ClipOval(
        child: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
            ? Image.network(
                widget.avatarUrl!,
                fit: BoxFit.cover,
                // Tall character artwork — a centred crop cuts off the face
                // at this size.
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : const Icon(Icons.support_agent, color: Colors.white, size: 16),
      ),
    );
  }
}
