import 'package:flutter/material.dart';
import 'package:goal_master/core/components/skeletons.dart';

/// Generic loading for a region whose content shape is unknown: a few
/// skeleton lines (when the region has a height) or a small, thin spinner.
/// Screens with a known shape use the skeletons in skeletons.dart directly.
class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SizedBox(
        height: height,
        child: const SkeletonList(count: 3, shrinkWrap: true),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: SoftSpinner()),
    );
  }
}
