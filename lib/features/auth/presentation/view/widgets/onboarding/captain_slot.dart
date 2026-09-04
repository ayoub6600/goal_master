import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';

/// The friendly face at the top of each signup step.
///
/// Captain Ayoub's artwork lives on the server and every endpoint that serves
/// it needs a session — which a person signing up does not have yet. So this
/// draws the app's own mark instead, and takes an optional [imagePath] so a
/// bundled Captain asset can be dropped in later without touching any of the
/// step screens.
///
/// The pose changes between steps through [emoji], which costs nothing and
/// still makes the four screens feel like a sequence rather than one form
/// split in three.
class CaptainSlot extends StatelessWidget {
  const CaptainSlot({
    super.key,
    required this.emoji,
    this.imagePath,
    this.size = 132,
    this.celebrate = false,
  });

  /// Bundled artwork, when there is any. Falls back to the mark below.
  final String? imagePath;

  /// The pose, in the absence of a drawn one.
  final String emoji;

  final double size;

  /// The success step earns a warmer ring.
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final ring = celebrate ? AppColors.successGreen : AppColors.primary;

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ring.withValues(alpha: 0.08),
        border: Border.all(color: ring.withValues(alpha: 0.22), width: 2),
      ),
      alignment: Alignment.center,
      child: imagePath != null
          ? ClipOval(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                  // A missing asset must never take the signup screen down.
                  errorBuilder: (_, __, ___) => _fallback(),
                ),
              ),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Text(emoji, style: TextStyle(fontSize: (size * 0.42).sp));
  }
}
