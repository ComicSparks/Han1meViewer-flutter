import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let icons: [String: String?] = [
    "default": nil,
    "calc": "AppIcon-Calc",
    "cornhub": "AppIcon-Cornhub",
    "xxt": "AppIcon-Xxt",
  ]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "hvf/native", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handle(call, result: result)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "excludeFromBackup":
      guard let path = args?["path"] as? String else {
        result(false)
        return
      }
      result(excludeFromBackup(path))
    case "setLauncherIcon":
      let name = args?["name"] as? String ?? "default"
      guard let entry = icons[name], UIApplication.shared.supportsAlternateIcons else {
        result(false)
        return
      }
      UIApplication.shared.setAlternateIconName(entry) { error in
        result(error == nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Application Support 下的数据库、缓存与下载都不进 iCloud 备份
  private func excludeFromBackup(_ path: String) -> Bool {
    var url = URL(fileURLWithPath: path, isDirectory: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    do {
      try url.setResourceValues(values)
      return true
    } catch {
      return false
    }
  }
}
