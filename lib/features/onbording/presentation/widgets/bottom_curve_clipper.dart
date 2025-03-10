import 'package:flutter/material.dart';

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80); // Start the curve lower

    // Creating a smoother curve with more control points
    path.quadraticBezierTo(
        size.width / 4,
        size.height + 30, // First control point
        size.width / 2,
        size.height - 40); // End point of the first curve

    path.quadraticBezierTo(
        3 * size.width / 4,
        size.height - 100, // Second control point
        size.width,
        size.height - 60); // End point of the second curve

    path.lineTo(size.width, 0); // Close the path at the top right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
