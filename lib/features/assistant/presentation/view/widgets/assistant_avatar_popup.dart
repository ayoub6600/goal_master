import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';

/// A brief center-screen celebration/notice for meaningful moments
/// (booking success, an error, an empty search...) — shows the matching
/// avatar image big and centered, fades itself out on its own after a
/// couple of seconds, and can be skipped early by tapping anywhere.
class AssistantAvatarPopup extends StatefulWidget {
  const AssistantAvatarPopup({
    super.key,
    required this.imageUrl,
    required this.onDismissed,
  });

  final String imageUrl;
  final VoidCallback onDismissed;

  @override
  State<AssistantAvatarPopup> createState() => _AssistantAvatarPopupState();
}

class _AssistantAvatarPopupState extends State<AssistantAvatarPopup> {
  bool _visible = false;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    // Kick off the fade-in on the next frame, then auto-dismiss shortly after.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _autoHideTimer = Timer(const Duration(milliseconds: 1800), _dismiss);
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _autoHideTimer?.cancel();
    if (!mounted) return;
    setState(() => _visible = false);
    // Let the fade-out play before actually removing the widget from the tree.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        // Tapping anywhere skips it early — for anyone in a hurry.
        onTap: _dismiss,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: _visible ? 1 : 0.85,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.support_agent,
                      size: 64,
                      color: AppColors.primary,
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
}
