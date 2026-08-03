import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/assets.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (!mounted) return;

      final result = SharedPreferenceUtil.getString(PrefKey.login);
      if (result.isEmpty) {
        pushReplacement(RoutesKeys.kOnboarding, context);
      } else if (result == 'true') {
        pushReplacement(RoutesKeys.kHome, context);
      } else {
        pushReplacement(RoutesKeys.kLogin, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      Assets.imagesSvgImageSplash,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
    );
  }
}
