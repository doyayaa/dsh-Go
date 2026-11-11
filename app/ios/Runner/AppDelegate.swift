import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 通知点击代理要在任何通知出现之前挂上。
    UNUserNotificationCenter.current().delegate = DshNotifyPlugin.shared.makeCenterDelegate()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // iOS 移植版的自定义插件（docs/ios-port-notes.md）。
    DshAppPlugin.register(with: engineBridge.pluginRegistry)
    DshNotifyPlugin.register(with: engineBridge.pluginRegistry)
    DshMediaPlugin.register(with: engineBridge.pluginRegistry)
    DshDiagnosticsPlugin.register(with: engineBridge.pluginRegistry)
  }
}
