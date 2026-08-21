import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    /// 推送通道：Dart 侧通过 MethodChannel "lumotrip/push" 获取/设置 device token
    static let pushChannelName = "lumotrip/push"

    /// 冷启动（App 被杀后点击推送横幅）时缓存的通知数据，待 Dart 通道就绪后补发
    private var pendingLaunchNotification: [AnyHashable: Any]?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // 冷启动：点击推送横幅拉起 App → 缓存通知，Flutter 引擎就绪后补发
        if let launchNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pendingLaunchNotification = launchNotification
            NSLog("[PushDebug] cold-start notification cached: \(launchNotification.keys)")
        }

        // FlutterViewController 在引擎初始化完成后才存在（冷启动早期可能为 nil），
        // 轮询等待就绪后设置推送通道 + 补发冷启动通知。
        setupPushChannelWhenReady()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 轮询等待 FlutterViewController 就绪，再注册推送通道
    private func setupPushChannelWhenReady() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            NSLog("[PushDebug] waiting for FlutterViewController... (window=\(String(describing: window)))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.setupPushChannelWhenReady()
            }
            return
        }
        NSLog("[PushDebug] FlutterViewController ready, setting push channel")
        let channel = FlutterMethodChannel(
            name: AppDelegate.pushChannelName,
            binaryMessenger: controller.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "register":
                self?.registerForPush()
                self?.flushPendingLaunchNotification()
                result(nil)
            case "getToken":
                result(self?.cachedDeviceToken ?? "")
            case "setBadge":
                let count = (call.arguments as? Int) ?? 0
                UIApplication.shared.applicationIconBadgeNumber = count
                result(nil)
            case "getPendingNotification":
                // Dart 主动拉取冷启动通知（若原生补发早于 Dart 就绪而丢失，这里兜底）
                let pending = self?.pendingLaunchNotification
                self?.pendingLaunchNotification = nil
                NSLog("[PushDebug] getPendingNotification -> \(String(describing: pending?.keys))")
                result(pending)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        // 通道就绪后立即补发冷启动通知（Dart 侧订阅在 register 之前完成，不丢失）
        flushPendingLaunchNotification()
    }

    /// Dart 侧调用 register（即初始化完成）后，补发冷启动期间点击的通知
    private func flushPendingLaunchNotification() {
        guard let notification = pendingLaunchNotification else { return }
        pendingLaunchNotification = nil
        invokeNotificationTap(userInfo: notification)
    }

    /// 通过 MethodChannel 通知 Dart 侧处理通知点击
    private func invokeNotificationTap(userInfo: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            guard let controller = self.window?.rootViewController as? FlutterViewController else { return }
            let channel = FlutterMethodChannel(
                name: AppDelegate.pushChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            channel.invokeMethod("onNotificationTap", arguments: userInfo)
        }
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
        invokeNotificationTap(userInfo: userInfo)
        completionHandler()
    }
}
