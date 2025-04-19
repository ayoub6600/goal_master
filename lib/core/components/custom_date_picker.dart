// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? formatPattern;
  final Function(DateTime? date)? onDatePicked;
  final TextEditingController? controller;
  final String? hint;
  const CustomDatePicker(
      {super.key,
      this.firstDate,
      this.lastDate,
      this.initialDate,
      this.formatPattern,
      this.onDatePicked,
      this.controller,
      this.hint});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? picked;
  TextEditingController staticController = TextEditingController();
  TextEditingController get controller => widget.controller ?? staticController;

  @override
  void initState() {
    controller.addListener(() {
      var date = DateTime.tryParse(controller.text);
      if (date == null) return;
      _afterPick(
        date,
        updateText: false,
      );
    });
    super.initState();
  }

  void _afterPick(
    DateTime? date, {
    bool updateText = true,
  }) {
    if (widget.onDatePicked != null) widget.onDatePicked!(date);
    if (date == null) return;
    picked = date;
    if (updateText) {
      controller.text =
          DateFormat(widget.formatPattern ?? 'yyy-MM-dd').format(date);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var date = await showDatePicker(
          context: context,
          firstDate:
              widget.firstDate ?? DateTime.now().subtract(Duration(days: 1000)),
          lastDate: widget.lastDate ?? DateTime.now().add(Duration(days: 1000)),
          initialDate: widget.initialDate ?? picked,
        );
        _afterPick(date);
      },
      child: CustomTextField(
        //  hint: DateTime.now().toString(),
        hint: " اختر التاريخ",
        controller: controller,
        enabled: false,
        trailingIconPath: Assets.imagesPngImageCalendar,
        allowUpperHint: false,
        style: TextStyle(color: AppColors.uiBlack),
      ),
    );
  }
}
