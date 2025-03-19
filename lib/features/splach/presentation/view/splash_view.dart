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
  void initState() {
    //  if (SharedPreferenceUtil.getString(PrefKey.currentLanguageCode) == '') {
    //   SharedPreferenceUtil.putString(PrefKey.currentLanguageCode, 'ar');
    // }
    Future.delayed(Duration(seconds: 1)).then(
      (value) {
        var result = SharedPreferenceUtil.getString(PrefKey.login);
        if (result.isEmpty) {
          print("----->$result");
          pushReplacement(RoutesKeys.kOnboarding, context);
        } else if (result == 'true') {
          print("----->$result");
          pushReplacement(RoutesKeys.kLogin, context);
        } else {
          print("----->$result");
          pushReplacement(RoutesKeys.kHome, context);
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          Assets.imagesSvgImageSplash,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
