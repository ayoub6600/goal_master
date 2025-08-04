import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/utils/storage_service.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo_imp.dart';
import 'package:goal_master/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo_imp.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_cubit.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo_imp.dart';
import 'package:goal_master/features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceUtil.getInstance();

  await StorageService.init();
  setupServiceLocator();

  await _initializeNotifications();
  await requestNotificationPermission();
  runApp(const GoalMaster());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings iosInitSettings =
      const DarwinInitializationSettings(
    // دي لو عايز تطلب الصلاحيات مع الـ init مباشرة (اختياري)
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    // مهم لـ iOS عشان لما يضغط على الإشعار نعرف نوجّه
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload == RoutesKeys.kNotification) {
        // افتح صفحة الإشعارات
        AppRouter.router.go(RoutesKeys.kNotification); // حسب الراوتر عندك
      }
    },
  );
}

// Future<void> _initializeNotifications() async {
//   const AndroidInitializationSettings androidInitSettings =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const InitializationSettings initSettings = InitializationSettings(
//     android: androidInitSettings,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initSettings);
// }
Future<void> requestNotificationPermission() async {
  // أندرويد 13+ (الإذن الجديد على أندرويد)
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }

  // iOS: لازم تطلب من خلال المكتبة نفسها
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

// Future<void> requestNotificationPermission() async {
//   final status = await Permission.notification.status;
//   if (!status.isGranted) {
//     await Permission.notification.request();
//   }
// }

class GoalMaster extends StatelessWidget {
  const GoalMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = NotificationCubit(
              notificationRepo: getIt<NotificationRepo>(),
              userId: SharedPreferenceUtil.getInt(PrefKey.userId) ?? 0,
              onVisualNotification: (notification) async {
                const androidDetails = AndroidNotificationDetails(
                  'goal_channel_id',
                  'Goal Notifications',
                  channelDescription: 'Notifications from Goal Master Admin',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  icon: '@mipmap/ic_launcher',
                  styleInformation: BigPictureStyleInformation(
                    DrawableResourceAndroidBitmap('app_notifiction'),
                    largeIcon: DrawableResourceAndroidBitmap('app_notifiction'),
                    contentTitle: '📣 مدير الملعب',
                    summaryText: null, // ممكن تمرّر الرسالة هنا لو حابب
                  ),
                );

                const iosDetails = DarwinNotificationDetails(
                  presentAlert:
                      true, // يظهر تنبيه حتى لو الآب في الـ foreground
                  presentBadge: true,
                  presentSound: true,
                  threadIdentifier: 'goal_notifications',
                );

                await flutterLocalNotificationsPlugin.show(
                  0,
                  '📣 مدير الملعب',
                  notification.data.message,
                  const NotificationDetails(
                    android: androidDetails,
                    iOS: iosDetails,
                  ),
                  payload: RoutesKeys.kNotification,
                );
              },

              // onVisualNotification: (notification) async {
              //   await flutterLocalNotificationsPlugin.show(
              //     0,
              //     '📣 مدير الملعب',
              //     notification.data.message,
              //     NotificationDetails(
              //       android: AndroidNotificationDetails(
              //         'goal_channel_id',
              //         'Goal Notifications',
              //         channelDescription:
              //             'Notifications from Goal Master Admin',
              //         importance: Importance.max,
              //         priority: Priority.high,
              //         playSound: true,
              //         icon: '@mipmap/ic_launcher',
              //         styleInformation: BigPictureStyleInformation(
              //           DrawableResourceAndroidBitmap('app_notifiction'),
              //           largeIcon:
              //               DrawableResourceAndroidBitmap('app_notifiction'),
              //           contentTitle: '📣 مدير الملعب',
              //           summaryText: notification.data.message,
              //         ),
              //       ),
              //     ),
              //     payload: RoutesKeys.kNotification,
              //   );
              // },
            );
            cubit.startSocket();
            return cubit;
          },
        ),

        BlocProvider(
          create: (context) => LayoutCubit(),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(
            getIt<AuthRepoImpl>(),
          ),
        ),
        BlocProvider(
          create: (context) => AnalysisCubit(
            getIt<AnalysisRepoImp>(),
          )..getAnalysis(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(
            getIt<ProfileRepoImp>(),
          )..getProfile(),
        ),
        //BalanceCubit
        BlocProvider(
          create: (context) => BalanceCubit(
            getIt<BalanceRepoImp>(),
          )..getBalance(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: OKToast(
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
              supportedLocales: const [
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.router,
            ),
          ),
        ),
      ),
    );
  }
}
