import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The admin-uploaded picture for a signup screen, drawn in the lower half.
///
/// It occupies whatever vertical room is left between the field and the
/// button, so a tall drawing and a short one both sit correctly without the
/// admin having to match a fixed size.
///
/// It disappears while the keyboard is up: the space it would take is the
/// space the keyboard has taken, and a picture squeezed to a sliver above a
/// text field reads as a rendering fault rather than as decoration.
///
/// Every failure path ends in empty space. A picture that will not load must
/// never be the reason someone cannot finish creating an account.
class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    // Read from the view, not from MediaQuery: a Scaffold with
    // resizeToAvoidBottomInset strips the bottom inset out of the MediaQuery
    // it hands its body, so asking there reports no keyboard even with one
    // covering half the screen.
    final keyboardUp = View.of(context).viewInsets.bottom > 0;

    if (url == null || url.isEmpty || keyboardUp) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        // No spinner: this is decoration arriving late, and a spinner in the
        // middle of a signup step looks like the step itself is stuck.
        frameBuilder: (_, child, frame, wasSynchronous) {
          if (wasSynchronous || frame != null) return child;
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
