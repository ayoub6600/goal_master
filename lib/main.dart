import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/splach/presentation/view/splash_view.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const GoalMaster());
}

class GoalMaster extends StatelessWidget {
  const GoalMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: MaterialApp.router(
          title: 'Goal Master',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
            textTheme: GoogleFonts.tajawalTextTheme(),
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          //supportedLocales: const [Locale('ar')],
          routerConfig: AppRouter.router,
          //  home: SplashView(),
        ),
      ),
    );
  }
}
