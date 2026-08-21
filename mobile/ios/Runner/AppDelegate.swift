import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    /// 推送通道：Dart 侧通过 MethodChannel "lumotrip/push" 获取/设置 device token
    static let pushChannelName = "lumotrip/push"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // 注册推送通道
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: AppDelegate.pushChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            channel.setMethodCallHandler { [weak self] (call, result) in
                switch call.method {
                case "register":
                    self?.registerForPush()
                    result(nil)
                case "getToken":
                    result(self?.cachedDeviceToken ?? "")
                case "setBadge":
                    let count = (call.arguments as? Int) ?? 0
                    UIApplication.shared.applicationIconBadgeNumber = count
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 已缓存的 APNs device token（Dart 侧随时可读）
    private var cachedDeviceToken: String? {
        get { UserDefaults.standard.string(forKey: "apns_device_token") }
        set { UserDefaults.standard.set(newValue, forKey: "apns_device_token") }
    }

    /// 申请推送授权并注册 APNs
    private func registerForPush() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - APNs token

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        cachedDeviceToken = token
        // 通知 Dart 侧上传
        DispatchQueue.main.async {
            if let controller = self.window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: AppDelegate.pushChannelName,
                    binaryMessenger: controller.binaryMessenger
                )
                channel.invokeMethod("onTokenReceived", arguments: token)
            }
        }
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[APNs] register failed: \(error.localizedDescription)")
    }

    // MARK: - 前台通知展示（alert + badge）

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 前台也展示横幅 + 声音 + 角标
        completionHandler([.alert, .badge, .sound])
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 点击通知 → 通知 Dart 侧处理跳转
        let userInfo = response.notification.request.content.userInfo
        DispatchQueue.main.async {
            if let controller = self.window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: AppDelegate.pushChannelName,
                    binaryMessenger: controller.binaryMessenger
                )
                channel.invokeMethod("onNotificationTap", arguments: userInfo)
            }
        }
        completionHandler()
    }
}
