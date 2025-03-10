// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:goal_master/core/components/global_app_bar/pattern_image.dart';

class PatternImageColorizer extends StatelessWidget {
  const PatternImageColorizer({
    super.key,
    required this.shaderColors,
    required this.topPadding,
    required this.contentHeight,
    this.blendMode,
    this.bgPatternCount,
  });

  final List<Color>? shaderColors;
  final double topPadding;
  final double contentHeight;
  final BlendMode? blendMode;

  final int? bgPatternCount;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: shaderColors ??
              [Colors.black.withOpacity(1), Colors.black.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      blendMode: blendMode ?? BlendMode.dstIn, // Makes the widget fade out
      child: PatternImage(
        height: topPadding + contentHeight,
        patternCount: bgPatternCount,
      ),
    );
  }
}
