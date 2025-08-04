import UIKit
import Flutter
import UserNotifications            // لتمرير إشعارات الـ foreground
import flutter_local_notifications  // لتهيئة البلجن إذا احتجت

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // خليه يمرّر الإشعارات للتطبيق وهو مفتوح (foreground)
    UNUserNotificationCenter.current().delegate = self

    // (اختياري) لو هتستخدم scheduling/isolates
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
