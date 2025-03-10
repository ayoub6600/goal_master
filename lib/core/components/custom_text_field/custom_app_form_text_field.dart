// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_text_field/custom_text_field_actual_field.dart';
import 'package:goal_master/core/components/custom_text_field/custom_text_field_container.dart';
import 'package:goal_master/core/components/custom_text_field/custom_text_field_leading.dart';
import 'package:goal_master/core/components/custom_text_field/custom_text_field_trailing.dart';
import 'package:goal_master/core/components/custom_text_field/phone_number_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final bool password;
  final TextEditingController? controller;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final bool allowUpperHint;
  final String? leadingIconPath;
  final String? trailingIconPath;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool isPhone;

  const CustomTextField({
    super.key,
    this.hint,
    this.password = false,
    this.controller,
    this.leading,
    this.trailing,
    this.style,
    this.hintStyle,
    this.allowUpperHint = true,
    this.leadingIconPath,
    this.enabled = true,
    this.trailingIconPath,
    this.maxLines,
    this.minLines,
    this.inputFormatters,
    this.inputType,
    this.inputAction,
    this.isPhone = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  final _hintKey = GlobalKey();
  final _containerKey = GlobalKey();
  double hintHeight = 0;
  double containerHeight = 0;
  String content = '';
  bool passwordShown = false;

  void togglePasswordShown() {
    setState(() {
      passwordShown = !passwordShown;
    });
  }

  bool hintDown = true;

  void _initSize() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      hintHeight = _hintKey.currentContext?.size?.height ?? 0;
      containerHeight = _containerKey.currentContext?.size?.height ?? 0;
      topSpace = (containerHeight - hintHeight) / 2;
      hintDown = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _initSize();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      topSpace = 7.h;
      hintDown = false;
    } else if (content.isEmpty) {
      _initSize();
    }
    setState(() {});
  }

  double topSpace = 0;

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  TextInputType? get inputType {
    if (widget.inputType != null) {
      return widget.inputType;
    }
    if (widget.isPhone) {
      return TextInputType.phone;
    }
    if (widget.password && passwordShown) {
      return TextInputType.visiblePassword;
    }
    return null;
  }

  List<TextInputFormatter>? get inputFormatters {
    var formatters = widget.inputFormatters ?? [];

    if (widget.isPhone) {
      formatters.add(PhoneNumberInputFormatter());
    }

    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    var animationDuration = Duration(milliseconds: 100);
    return AbsorbPointer(
      absorbing: !widget.enabled,
      child: GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.nextFocus();
          } else {
            _focusNode.requestFocus();
          }
        },
        child: CustomTextFieldContainer(
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          animationDuration: animationDuration,
          containerKey: _containerKey,
          focusNode: _focusNode,
          child: Row(
            children: [
              CustomTextFieldLeading(
                leading: widget.leading,
                leadingIconPath: widget.leadingIconPath,
              ),
              Expanded(
                child: CustomTextFieldActualField(
                  inputType: inputType,
                  inputAction: widget.inputAction,
                  inputFormatters: inputFormatters,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  containerHeight: containerHeight,
                  allowUpperHint: widget.allowUpperHint,
                  enabled: widget.enabled,
                  focusNode: _focusNode,
                  password: widget.password,
                  passwordShown: passwordShown,
                  animationDuration: animationDuration,
                  topSpace: topSpace,
                  hintDown: hintDown,
                  hintKey: _hintKey,
                  onChanged: (v) {
                    setState(() {
                      content = v;
                    });
                  },
                  style: widget.style,
                  hintStyle: widget.hintStyle,
                  hint: widget.hint,
                  controller: widget.controller,
                ),
              ),
              CustomTextFieldTrailing(
                password: widget.password,
                trailingIconPath: widget.trailingIconPath,
                trailing: widget.trailing,
                passwordShown: passwordShown,
                togglePasswordShown: togglePasswordShown,
              )
            ],
          ),
        ),
      ),
    );
  }
}
