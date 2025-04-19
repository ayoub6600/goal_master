import 'package:flutter/material.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:intl/intl.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String? formatPattern;
  final Function(TimeOfDay? time)? onTimePicked;
  final TextEditingController? controller;
  final String? hint;

  const CustomTimePicker({
    super.key,
    this.initialTime,
    this.formatPattern,
    this.onTimePicked,
    this.controller,
    this.hint,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? picked;
  TextEditingController staticController = TextEditingController();
  TextEditingController get controller => widget.controller ?? staticController;

  @override
  void initState() {
    controller.addListener(() {
      var time = _parseTime(controller.text);
      if (time == null) return;
      _afterPick(time, updateText: false);
    });
    super.initState();
  }

  // Custom function to parse time in format "hh:mm a"
  TimeOfDay? _parseTime(String timeString) {
    try {
      final format = DateFormat(widget.formatPattern ?? 'hh:mm a');
      final dateTime = format.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return null;
    }
  }

  void _afterPick(
    TimeOfDay? time, {
    bool updateText = true,
  }) {
    if (widget.onTimePicked != null) widget.onTimePicked!(time);
    if (time == null) return;
    picked = time;
    if (updateText) {
      controller.text = DateFormat(widget.formatPattern ?? 'hh:mm a').format(
        DateTime(2020, 1, 1, time.hour, time.minute),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var time = await showTimePicker(
          context: context,
          initialTime: widget.initialTime ?? picked ?? TimeOfDay.now(),
        );
        _afterPick(time);
      },
      child: CustomTextField(
        hint: widget.hint ?? " اختر الوقت",
        controller: controller,
        enabled: false,

        trailingIconPath: Assets
            .imagesPngImageArrowDown, // You can replace this with an icon for time
        allowUpperHint: false,
        style: TextStyle(color: AppColors.uiBlack),
      ),
    );
  }
}
