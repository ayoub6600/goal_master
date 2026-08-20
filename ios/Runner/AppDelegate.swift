import UIKit
import Flutter
import GoogleMaps                   // لتفعيل خرائط جوجل
import UserNotifications            // لتمرير إشعارات الـ foreground
import flutter_local_notifications  // لتهيئة البلجن إذا احتجت

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // نفس مفتاح Google Maps المستخدم في Android (android/app/src/main/AndroidManifest.xml)
    // — إن كان هذا المفتاح مقيداً بمنصة Android فقط في Google Cloud Console، سيحتاج تفعيل iOS له أو مفتاح منفصل.
    GMSServices.provideAPIKey("AIzaSyCLVX-Jnqqo89cZ2xQ6CJflSueG-laba7g")

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
