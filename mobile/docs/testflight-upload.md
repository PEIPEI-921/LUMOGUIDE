# LUMOTRIP TestFlight 上传指南

## 前置条件

| 条件 | 说明 |
|------|------|
| Apple Developer Program | $99/年，账号需加入开发团队 `FLVV24Q9HH` |
| App Store Connect 已创建 App | Bundle ID: `com.app.lumotrip`，SKU: `lumotrip` |
| Xcode 已安装 + 命令行工具 | `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` |
| CocoaPods 已安装 | `brew install cocoapods`（本项目版本 ≥1.16.2） |

## 一、构建前检查

### 1.1 更新版本号

在 `pubspec.yaml` 中递增 build number（`version: x.y.z+N`），App Store Connect 不允许重复版本号。

```yaml
# 例：1.0.6+19 → 1.0.6+20
version: 1.0.6+20
```

### 1.2 确认 push 环境

`ios/Runner/Runner.entitlements` 中 `aps-environment` 必须为 `production`（非 `development`），否则 TestFlight 中推送通知不工作。

### 1.3 确认签名配置

项目已配置自动签名（`CODE_SIGN_STYLE = Automatic`），开发团队 `FLVV24Q9HH`。
```bash
# 验证证书是否有效
security find-identity -v -p codesigning
```

### 1.4 修复 CocoaPods 冲突（重要）

**每次 `flutter pub get` 后**需修复两个 podspec 文件，否则 pod install 失败：

```bash
# 1. 修改 tencent_cloud_chat_push 的 TXIMSDK 版本约束
sed -i '' "s/'TXIMSDK_Plus_iOS_XCFramework'/'TXIMSDK_Plus_iOS_XCFramework', '>= 8.9.7537'/g" \
  ios/.symlinks/plugins/tencent_cloud_chat_push/ios/tencent_cloud_chat_push.podspec

# 2. 修改 tencent_cloud_chat_sdk 的 TXIMSDK 版本约束
sed -i '' 's/"~> 8.8.7373"/">= 8.8.7373"/g' \
  ios/.symlinks/plugins/tencent_cloud_chat_sdk/ios/tencent_cloud_chat_sdk.podspec

# 3. 重新安装 Pod
cd ios && rm -f Podfile.lock && pod install --repo-update && cd ..
```

### 1.5 安装依赖

```bash
flutter pub get
flutter analyze  # 确保 0 errors
```

## 二、构建 Archive

```bash
flutter build ipa
```

构建产物位置：
- Archive: `build/ios/archive/Runner.xcarchive`
- IPA: `build/ios/ipa/Runner.ipa`

## 三、上传至 App Store Connect

### 方式 A：Xcode Organizer（推荐）

```bash
open build/ios/archive/Runner.xcarchive
```

Xcode Organizer 打开后：
1. 选中该 Archive → **Distribute App**
2. 选择 **TestFlight & App Store** → Next
3. 选择 **Upload** → Next
4. 全部默认 → 等待上传完成

### 方式 B：Transporter 命令行

```bash
xcrun altool --upload-app \
  -f build/ios/ipa/Runner.ipa \
  -t ios \
  -u "你的Apple ID邮箱" \
  -p "App专用密码"
```

App 专用密码在 https://appleid.apple.com → 登录与安全 → App 专用密码 中创建。

### 方式 C：Transporter App

从 Mac App Store 下载 **Transporter**，拖入 IPA 文件即可。

## 四、TestFlight 分发

上传成功后登录 https://appstoreconnect.apple.com：

### 4.1 等待处理

上传后 Apple 自动处理（通常 15-30 分钟），期间会检查：
- 缺少合规说明（加密出口）
- 缺少隐私清单
- 私有 API 使用

### 4.2 处理出口合规

在 App Store Connect → TestFlight → 构建版本 → 点击黄色警告图标：
- 如果 App 只用了 HTTPS（本项目情况）：选择 **"不需要提供出口合规证明"**
- 本项目使用 `dio` 进行标准 HTTPS 通信，通常不需要出口合规

### 4.3 添加测试员

| 类型 | 人数上限 | 是否需要审核 |
|------|---------|-------------|
| 内部测试员 | 100 人 | 不需要 |
| 外部测试员（公开链接） | 10,000 人 | 首次需要 Beta 审核 |

**添加内部测试员：**
1. App Store Connect → 用户和访问 → 添加具有 "开发者" 或 "App 管理" 角色的用户
2. TestFlight → 内部测试 → 添加测试员
3. 测试员收到邮件邀请，通过 TestFlight App 安装

**创建公开测试链接：**
1. TestFlight → 外部测试 → 创建 Beta 版群组
2. 启用公开链接，将链接分享给测试员

## 五、常见问题

### 5.1 `ITMS-90683: Missing Purpose String in Info.plist`

检查 `ios/Runner/Info.plist` 中是否包含必需的隐私描述（本项目已有 `NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription` 等）。

### 5.2 `ITMS-90809: UIWebView deprecated`

本项目 Flutter 版本使用 WKWebView，不应出现此警告。如出现，检查是否有依赖仍使用 UIWebView。

### 5.3 签名错误 `No signing certificate "iOS Distribution"`

```bash
# 在 Xcode 中：Preferences → Accounts → 选择 Apple ID → Manage Certificates
# 点击 "+" → iOS Distribution → 创建新的分发证书
```

### 5.4 上传后构建状态一直 "处理中"

等待即可，正常 15-30 分钟。超过 1 小时联系 Apple 支持。

### 5.5 测试员收不到邀请

- 确认测试员使用的 Apple ID 与邀请邮件一致
- 测试员设备需安装 TestFlight App
- iOS 版本需 ≥13.0（本项目最低支持版本）

## 快速命令速查

```bash
# 完整构建发布流程（一键）
flutter pub get && flutter analyze && flutter build ipa && open build/ios/archive/Runner.xcarchive

# 修复 CocoaPods + 构建（pub get 后执行）
cd ios && rm -f Podfile.lock && pod install --repo-update && cd .. && flutter build ipa
```
