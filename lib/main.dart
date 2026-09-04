import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:goal_master/core/app_update/app_update_gate.dart';
import 'package:goal_master/features/attendance/presentation/mandatory_action_gate.dart';
import 'package:goal_master/core/services/notification_navigation_service.dart';
import 'package:goal_master/core/services/in_app_banner.dart';
import 'package:goal_master/core/services/push_notification_service.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/location/data/repo/location_repo.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/required_location_gate.dart';
import 'package:goal_master/firebase_options.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/utils/storage_service.dart';
import 'package:goal_master/core/view/connection_cubit.dart';
import 'package:goal_master/core/view/no_internet_view.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo_imp.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/assistant/data/assistant_history_cache.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/captain_ayoub_bubble.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo_imp.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo_imp.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo_imp.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_cubit.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo_imp.dart';
import 'package:goal_master/features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A real, unconditional check — not `assert`, which release builds strip.
  // A release build made without a valid production --dart-define=API_BASE
  // must crash here, loudly, at first launch, instead of silently shipping
  // an app that talks to localhost or a LAN address.
  if (kReleaseMode) {
    final violation = EndPoints.releaseSafetyViolation;
    if (violation != null) {
      throw StateError('Release build refused: $violation');
    }
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferenceUtil.getInstance();

  await StorageService.init();
  setupServiceLocator();

  await _initializeNotifications();
  await requestNotificationPermission();
  await PushNotificationService.initialize();
  await PushNotificationService.registerTokenIfLoggedIn();

  // App opened by tapping a notification while backgrounded (not terminated).
  FirebaseMessaging.onMessageOpenedApp
      .listen(NotificationNavigationService.handleMessageTap);

  runApp(const GoalMaster());

  // App launched fresh by tapping a notification (was fully terminated) —
  // handled after runApp so the router/navigator exists to push onto.
  NotificationNavigationService.handleInitialMessage();
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

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

class GoalMaster extends StatelessWidget {
  const GoalMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectionCubit(),
      child: BlocBuilder<ConnectionCubit, bool>(
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) {
                  final cubit = NotificationCubit(
                    notificationRepo: getIt<NotificationRepo>(),
                    userId: SharedPreferenceUtil.getInt(PrefKey.userId),
                    onVisualNotification: (notification) async {
                      if (notification.data.type ==
                          NotificationNavigationService.captainOffer) {
                        AssistantHistoryCache.invalidate();
                        InAppBanner.show(
                          title: notification.data.assistantName.isNotEmpty
                              ? notification.data.assistantName
                              : 'كابتن أيوب',
                          body:
                              'للأسف الملعب ما وافقش على حجزك 😔 بس عندي حل، افتح المحادثة.',
                          avatarUrl: notification.data.assistantAvatar,
                          onTap: () =>
                              AppRouter.router.push(RoutesKeys.kAssistantChat),
                        );
                        return;
                      }

                      const androidDetails = AndroidNotificationDetails(
                        'goal_channel_id',
                        'Goal Notifications',
                        channelDescription:
                            'Notifications from Goal Master Admin',
                        importance: Importance.max,
                        priority: Priority.high,
                        playSound: true,
                        icon: '@mipmap/ic_launcher',
                        styleInformation: BigPictureStyleInformation(
                          DrawableResourceAndroidBitmap('app_notifiction'),
                          largeIcon:
                              DrawableResourceAndroidBitmap('app_notifiction'),
                          contentTitle: '📣 Goal Master',
                        ),
                      );

                      const iosDetails = DarwinNotificationDetails(
                        presentAlert: true,
                        presentBadge: true,
                        presentSound: true,
                        threadIdentifier: 'goal_notifications',
                      );

                      await flutterLocalNotificationsPlugin.show(
                        0,
                        '📣 Goal Master',
                        notification.data.message,
                        const NotificationDetails(
                          android: androidDetails,
                          iOS: iosDetails,
                        ),
                        payload: RoutesKeys.kNotification,
                      );
                    },
                  );
                  cubit.startSocket();
                  cubit.listenForForegroundFcm();
                  return cubit;
                },
              ),
              BlocProvider(create: (_) => LayoutCubit()),
              // Provided ABOVE the router, so it outlives every route.
              //
              // This placement is the fix for the original bug: location used
              // to be derived per screen, so Home → Account → Home rebuilt
              // Home with nothing and it fell back to un-scoped results. A
              // cubit that survives navigation cannot lose the answer.
              BlocProvider(
                create: (_) => ActiveLocationCubit(getIt<LocationRepo>()),
              ),
              BlocProvider(create: (_) => UserInfoCubit(getIt<AuthRepoImpl>())),
              BlocProvider(
                  create: (_) =>
                      AnalysisCubit(getIt<AnalysisRepoImp>())..getAnalysis()),
              BlocProvider(
                  create: (_) =>
                      ProfileCubit(getIt<ProfileRepoImp>())..getProfile()),
              BlocProvider(
                  create: (_) =>
                      BalanceCubit(getIt<BalanceRepoImp>())..getBalance()),
              BlocProvider(
                  create: (_) => AssistantChatCubit(getIt<AssistantRepoImp>())),
              BlocProvider(create: (_) => CoinsCubit(getIt<CoinsRepoImp>())),
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
                  child: AppUpdateGate(
                    appKey: 'customer',
                    child: MaterialApp.router(
                      title: 'Goal Master',
                      theme: ThemeData(
                        colorScheme:
                            ColorScheme.fromSeed(seedColor: AppColors.primary),
                        useMaterial3: true,
                        textTheme: const TextTheme(),
                        scaffoldBackgroundColor: Colors.white,
                      ),
                      debugShowCheckedModeBanner: false,
                      locale: const Locale('ar'),
                      supportedLocales: const [Locale('ar')],
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      builder: (context, child) {
                        // The mandatory-action gate wraps the ROUTED content
                        // and everything drawn over it — Captain Ayoub's
                        // bubble included. Sitting here rather than on
                        // individual screens is what makes it survive tab
                        // switches, route changes and Android back, and is why
                        // there is no second entrance to find later.
                        // Gate order, deliberately: the attendance question
                        // is an obligation the customer already owes, so it
                        // comes first. Letting "where are you?" jump ahead
                        // would let somebody dodge attendance by never
                        // choosing a location.
                        return MandatoryActionGate(
                          child: RequiredLocationGate(
                            child: Stack(
                            children: [
                              if (child != null) child,
                              if (!state)
                                const Positioned.fill(child: NoInternetView()),
                              if (state) const CaptainAyoubBubble(),
                            ],
                            ),
                          ),
                        );
                      },
                      routerConfig: AppRouter.router,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
