import 'package:flutter/material.dart';
import 'package:goal_master/core/components/custom_drop_down.dart';

class CustomDropDownShimmer extends StatelessWidget {
  const CustomDropDownShimmer(
      {super.key, required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      items: const [],
      //label: label,
      hint: hint,
      onChanged: (v) {},
    );
  }
}
