// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';

class PatternImage extends StatelessWidget {
  final double height;
  final int? patternCount;
  final Axis direction;
  const PatternImage({
    super.key,
    required this.height,
    this.patternCount,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(),
      height: height,
      child: Transform.rotate(
        angle: direction == Axis.horizontal ? 0 : pi / 2,
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: List.generate(patternCount ?? 6, (index) {
            return Row(
              children: [
                // Expanded(
                //   child: Image.asset(
                //     AppAssets.appbarBG,
                //   ),
                // ),
                // Expanded(
                //   child: Image.asset(
                //     AppAssets.appbarBG,
                //   ),
                // ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
