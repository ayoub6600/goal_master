import UIKit
import Flutter
import GoogleMaps                   // لتفعيل خرائط جوجل
import UserNotifications            // لتمرير إشعارات الـ foreground
import flutter_local_notifications  // لتهيئة البلجن إذا احتجت
import WebKit
import webview_flutter_wkwebview

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var generatedPluginsRegistered = false

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

    let usesSceneLifecycle = Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") != nil
    if !usesSceneLifecycle {
      GeneratedPluginRegistrant.register(with: self)
      generatedPluginsRegistered = true
    }
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
#if DEBUG
    if let flutterController = window?.rootViewController as? FlutterViewController {
      CardFillBridge.register(
        messenger: flutterController.binaryMessenger,
        registry: flutterController.pluginRegistry
      )
    }
#endif
    return launched
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
#if DEBUG
    let windows = ([window].compactMap { $0 } +
      UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows))
    for candidate in windows {
      if let flutterController = candidate.rootViewController as? FlutterViewController {
        CardFillBridge.register(
          messenger: flutterController.binaryMessenger,
          registry: flutterController.pluginRegistry
        )
        break
      }
    }
#endif
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let registry = engineBridge.pluginRegistry
    if !generatedPluginsRegistered {
      GeneratedPluginRegistrant.register(with: registry)
      generatedPluginsRegistered = true
    }
#if DEBUG
    CardFillBridge.register(
      messenger: engineBridge.applicationRegistrar.messenger(),
      registry: registry
    )
#endif
  }
}

private final class CardFillBridge: NSObject {
  static let shared = CardFillBridge()
  private var channel: FlutterMethodChannel?
  private weak var registry: FlutterPluginRegistry?
  private let allowed = Origin("https://npg.moamalat.net:6006")!
  @available(iOS 14.0, *) private static let world = WKContentWorld.world(name: "goal-master-card-fill")

  private struct Origin: Equatable {
    let scheme: String
    let host: String
    let port: Int
    init?(_ raw: String) {
      guard let url = URL(string: raw), let scheme = url.scheme, let host = url.host,
            url.path.isEmpty || url.path == "/", url.query == nil, url.fragment == nil else { return nil }
      self.scheme = scheme.lowercased(); self.host = host.lowercased()
      self.port = url.port ?? (scheme.lowercased() == "https" ? 443 : 80)
    }
    init(_ origin: WKSecurityOrigin) {
      scheme = origin.protocol.lowercased(); host = origin.host.lowercased()
      port = origin.port == 0 ? (scheme == "https" ? 443 : 80) : origin.port
    }
  }

  private final class Session: NSObject, WKScriptMessageHandler {
    let id: Int64
    weak var owner: CardFillBridge?
    weak var webView: WKWebView?
    var ready: WKFrameInfo?
    var navigationObservation: NSKeyValueObservation?
    init(id: Int64, owner: CardFillBridge, webView: WKWebView) { self.id = id; self.owner = owner; self.webView = webView }
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
      guard let body = message.body as? [String: Any], let type = body["type"] as? String,
            let owner, Origin(message.frameInfo.securityOrigin) == owner.allowed else { return }
      if type == "ready" { ready = message.frameInfo; owner.emit(id, "ready") }
      if type == "gone" { ready = nil; owner.emit(id, "gone") }
    }
    func observeNavigation() {
      navigationObservation = webView?.observe(\.url, options: [.new]) { [weak self] _, _ in
        guard let self else { return }
        self.ready = nil
        self.owner?.emit(self.id, "gone")
      }
    }
  }

  private var sessions: [Int64: Session] = [:]
  static func register(messenger: FlutterBinaryMessenger, registry: FlutterPluginRegistry) {
    let bridge = shared
    bridge.registry = registry
    let channel = FlutterMethodChannel(name: "goal_master/card_fill", binaryMessenger: messenger)
    bridge.channel = channel
    channel.setMethodCallHandler { call, result in bridge.handle(call, result) }
  }
  private func emit(_ id: Int64, _ state: String) {
    DispatchQueue.main.async { self.channel?.invokeMethod("state", arguments: ["webViewId": Int(id), "state": state]) }
  }
  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      result(call.method == "install"
        ? ["ok": false, "status": "ios_version_unsupported", "operation": "availability"]
        : ["ok": false, "reason": "ios_version_unsupported"])
      return
    }
    guard let args = call.arguments as? [String: Any],
          let id = (args["webViewId"] as? NSNumber)?.int64Value else {
      result(call.method == "install"
        ? ["ok": false, "status": "missing_webview_id", "operation": "request_validation"]
        : ["ok": false, "reason": "missing_webview_id"])
      return
    }
    switch call.method {
    case "install": result(install(id, args))
    case "fill": fill(id, args, result)
    case "dispose": dispose(id); result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }
  @available(iOS 14.0, *) private func install(_ id: Int64, _ args: [String: Any]) -> [String: Any] {
    guard args["origins"] as? [String] == ["https://npg.moamalat.net:6006"] else {
      return ["ok": false, "status": "invalid_origin_rules", "operation": "origin_validation"]
    }
    guard let script = args["script"] as? String, !script.isEmpty else {
      return ["ok": false, "status": "empty_script", "operation": "script_validation"]
    }
    guard let registry else {
      return ["ok": false, "status": "wrong_plugin_registry", "operation": "registry_lookup"]
    }
    guard let publishedPlugin = registry.valuePublished(byPlugin: "WebViewFlutterPlugin") else {
      return ["ok": false, "status": "plugin_not_registered", "operation": "plugin_lookup"]
    }
    guard publishedPlugin is WebViewFlutterPlugin else {
      return ["ok": false, "status": "wrong_plugin_registry", "operation": "plugin_type_validation"]
    }
    guard let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(
      forIdentifier: id, withPluginRegistry: registry
    ) else {
      return ["ok": false, "status": "native_webview_not_found", "operation": "native_webview_lookup"]
    }
    dispose(id)
    let session = Session(id: id, owner: self, webView: webView)
    session.observeNavigation()
    let content = webView.configuration.userContentController
    content.add(session, contentWorld: Self.world, name: "goalMasterCardFill")
    content.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false, in: Self.world))
    sessions[id] = session
    return ["ok": true, "status": "installed", "operation": "script_and_handler_install"]
  }
  @available(iOS 14.0, *) private func fill(_ id: Int64, _ args: [String: Any], _ result: @escaping FlutterResult) {
    guard let session = sessions[id], let webView = session.webView, let frame = session.ready,
          Origin(frame.securityOrigin) == allowed else { result(["ok": false, "reason": "no_ready_frame"]); return }
    var values: [String: Any] = ["pan": args["pan"] as? String ?? "", "exp": args["exp"] as? String ?? "",
      "name": args["name"] as? String ?? "", "acceptTerms": args["acceptTerms"] as? Bool ?? false]
    webView.callAsyncJavaScript("return window.__goalMasterFill({pan: pan, exp: exp, name: name, acceptTerms: acceptTerms});",
      arguments: values, in: frame, in: Self.world) { outcome in
        values.removeAll()
      guard case .success(let raw) = outcome, let map = raw as? [String: Any] else { result(["ok": false, "reason": "frame_failed"]); return }
        var safe: [String: Any] = ["ok": map["ok"] as? Bool ?? false]
        for key in ["pan", "exp", "name", "terms", "cvv", "reason"] { if let value = map[key] as? String { safe[key] = value } }
        result(safe)
      }
  }
  private func dispose(_ id: Int64) {
    guard let session = sessions.removeValue(forKey: id), #available(iOS 14.0, *), let webView = session.webView else { return }
    webView.configuration.userContentController.removeScriptMessageHandler(forName: "goalMasterCardFill", contentWorld: Self.world)
  }
}
