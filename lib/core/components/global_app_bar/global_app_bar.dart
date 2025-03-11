// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:goal_master/core/components/global_app_bar/app_bar_content.dart';
import 'package:goal_master/core/components/global_app_bar/pattern_image_colorizer.dart';
import 'package:goal_master/core/styles/app_colors.dart';

class GlobalAppBar extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final bool backAlwaysVisible;
  final bool allowBack;
  final Color? bgColor;
  final Gradient? gradient;
  final bool allowBgColors;
  final List<Color>? shaderColors;
  final Widget? content;
  final int? bgPatternCount;
  final BlendMode? patternBlendMode;

  const GlobalAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.backAlwaysVisible = false,
    this.allowBack = true,
    this.bgColor,
    this.gradient,
    this.allowBgColors = true,
    this.shaderColors,
    this.content,
    this.bgPatternCount,
    this.patternBlendMode,
  });

  @override
  State<GlobalAppBar> createState() => _GlobalAppBarState();
}

class _GlobalAppBarState extends State<GlobalAppBar> {
  var contentKey = GlobalKey();
  double contentHeight = 75;
  bool stopRendering = false;

  void _initSizes() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      contentHeight = contentKey.currentContext?.size?.height ?? 0;
      if (stopRendering) return;
      if (contentHeight != 0) stopRendering = true;

      setState(() {});
    });
  }

  @override
  void initState() {
    _initSizes();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              height: topPadding + contentHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                //  color: const Color(0xFFFDFDFD),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40000000), // #00000040 (Opacity 25%)
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
                color: widget.allowBgColors ? widget.bgColor : null,
                gradient: widget.bgColor != null || !widget.allowBgColors
                    ? null
                    : (widget.gradient ??
                        LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [.8, 1],
                          colors: [
                            AppColors.inactive3,
                            Colors.white,
                          ],
                        )),
              ),
            ),
            Column(
              children: [
                LayoutBuilder(builder: (context, constrains) {
                  _initSizes();

                  return PatternImageColorizer(
                    bgPatternCount: widget.bgPatternCount,
                    shaderColors: widget.shaderColors,
                    topPadding: topPadding,
                    contentHeight: contentHeight,
                    blendMode: widget.patternBlendMode,
                  );
                }),
              ],
            ),
            SafeArea(
              bottom: false,
              child: Container(
                key: contentKey,
                child: widget.content ??
                    AppBarContent(
                      trailing: widget.trailing,
                      titleWidget: widget.titleWidget,
                      title: widget.title,
                      leading: widget.leading,
                      backAlwaysVisible: widget.backAlwaysVisible,
                      allowBack: widget.allowBack,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
