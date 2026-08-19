# LUMOGUIDE TestFlight 上传教程（配合 Claude Code 使用）

## 给 Claude Code 的说明

这是一份教程文档。当你的用户（以下简称"同事"）说要做 TestFlight 上传时，请按以下步骤逐一引导他操作。每一步只做一件事，确认完成后再继续下一步。如果某一步失败，停下来排查原因，不要跳过。

同事可能不熟悉命令行或 iOS 开发，请用通俗的语言解释每一步在做什么。

---

## 前置条件检查

在开始之前，先让同事确认以下条件：

1. **Apple Developer 账号**：同事需要有一个加入了 `FLVV24Q9HH` 团队的 Apple ID。如果不确定，让同事问团队管理员确认。
2. **Xcode 已安装**：Mac 上需要有 Xcode（App Store 下载）。
3. **项目代码已拉取**：同事的 Mac 上已经有 LUMOGUIDE 项目代码。

让同事确认这三点，都满足再继续。

---

## 第 1 步：在 Xcode 中登录 Apple ID 并创建证书

这是最关键的一步。没有证书无法构建发布版本。

让同事执行以下操作：

1. 打开 Xcode（在 Applications 中找到或 Spotlight 搜索 "Xcode"）
2. 菜单栏 → **Xcode** → **Settings...**（或快捷键 `Cmd + ,`）
3. 点击顶部的 **Accounts** 标签页
4. 点击左下角的 **+** 按钮 → 选择 **Apple ID**
5. 输入同事的 Apple ID 和密码（就是加入了 `FLVV24Q9HH` 团队的那个账号）
6. 登录后，右侧列表会显示团队信息。点击 **FLVV24Q9HH** 团队
7. 点击右侧的 **Manage Certificates...** 按钮
8. 在弹出的窗口中，点击左下角 **+** 按钮 → 选择 **iOS Distribution**
9. 等待几秒，证书创建完成。关闭弹窗。

**验证证书是否创建成功**：在终端运行：

```bash
security find-identity -v -p codesigning
```

告诉同事：如果看到一行包含 "iPhone Distribution" 的输出，说明证书创建成功。如果输出为空，回到第 7-8 步重新创建。

---

## 第 2 步：递增版本号

App Store Connect 不允许重复的 build number，每次上传必须递增。

让同事确认：当前版本号是多少？在 `pubspec.yaml` 文件中找到 `version:` 这一行。

例如当前是 `version: 1.0.6+19`，每次上传需要把 `+` 后面的数字加 1。如果是 `+19`，改成 `+20`。

帮同事修改 `pubspec.yaml` 中的版本号（用 Edit 工具）。

---

## 第 3 步：构建 & 上传

让同事在终端中逐条执行以下命令（在项目根目录下）。

### 3.1 安装依赖

```bash
flutter pub get
```

### 3.2 修复 CocoaPods 兼容性问题

```bash
# 修复 tencent_cloud_chat_push
sed -i '' "s/'TXIMSDK_Plus_iOS_XCFramework'/'TXIMSDK_Plus_iOS_XCFramework', '>= 8.9.7537'/g" \
  ios/.symlinks/plugins/tencent_cloud_chat_push/ios/tencent_cloud_chat_push.podspec

# 修复 tencent_cloud_chat_sdk
sed -i '' 's/"~> 8.8.7373"/">= 8.8.7373"/g' \
  ios/.symlinks/plugins/tencent_cloud_chat_sdk/ios/tencent_cloud_chat_sdk.podspec
```

### 3.3 安装 iOS 原生依赖

```bash
cd ios && rm -f Podfile.lock && pod install --repo-update && cd ..
```

这一步需要几分钟，耐心等待。

### 3.4 代码检查

```bash
flutter analyze
```

确保 0 errors。如果有 warning 可以忽略（warning 是预先存在的，不影响构建）。

### 3.5 构建 IPA

```bash
flutter build ipa
```

这一步会编译整个 App，需要 5-15 分钟（取决于 Mac 性能）。期间会弹出钥匙串访问权限请求，点"始终允许"。

### 3.6 上传到 App Store Connect

```bash
open build/ios/archive/Runner.xcarchive
```

这会打开 Xcode Organizer。引导同事：

1. 在 Organizer 左侧列表中，选中刚刚构建的 Archive（应该是列表中最新的）
2. 点击右侧的 **Distribute App** 按钮（蓝色大按钮）
3. 选择 **TestFlight & App Store** → 点 Next
4. 选择 **Upload** → 点 Next
5. 后续全部保持默认，一路点 Next
6. 最后点 **Upload**，等待上传完成（几分钟）
7. 上传成功后，窗口会自动关闭

---

## 第 4 步：App Store Connect 配置

上传成功后，引导同事登录 [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)：

### 4.1 等待处理

上传后 Apple 需要 15-30 分钟自动处理。这期间构建状态显示为"正在处理"。让同事稍等一会儿。

### 4.2 处理出口合规警告

处理完成后，构建旁边可能有一个黄色三角警告。点击它：

如果 App 只使用了标准 HTTPS 通信（本项目的情况），选择 **"不需要提供出口合规证明"**。

### 4.3 添加内部测试员

1. 进入 **TestFlight** → 左侧 **内部测试**
2. 如果还没有测试员，先到 **"用户和访问"** 添加（需要输入对方的 Apple ID 邮箱）
3. 添加后，在内部测试中点击 **"+"** 添加测试员
4. 测试员会收到邮件邀请，通过 iPhone 上的 TestFlight App 安装测试

---

## 常见问题处理

### 问题：`flutter build ipa` 报签名错误

让同事确认在 Xcode 中已登录正确的 Apple ID 并创建了 iOS Distribution 证书。如果证书正确但仍报错：

检查项目签名配置：
```bash
grep -A5 "CODE_SIGN" ios/Runner.xcodeproj/project.pbxproj | head -20
```

### 问题：上传后一直"正在处理"超过 1 小时

常见原因：
- 缺少隐私权限描述
- 使用了被废弃的 API

让同事检查 Apple 发送的邮件（注册 Apple ID 的邮箱），通常会有具体错误说明。

### 问题：测试员收不到 TestFlight 邀请

- 确认测试员使用的 Apple ID 与邀请邮箱一致
- 测试员设备需安装 TestFlight App（App Store 免费下载）
- 测试员设备 iOS 版本需 ≥13.0

---

## 快速命令参考（一键执行）

证书已就绪后，以下是完整的构建上传命令序列：

```bash
flutter pub get && \
sed -i '' "s/'TXIMSDK_Plus_iOS_XCFramework'/'TXIMSDK_Plus_iOS_XCFramework', '>= 8.9.7537'/g" ios/.symlinks/plugins/tencent_cloud_chat_push/ios/tencent_cloud_chat_push.podspec && \
sed -i '' 's/"~> 8.8.7373"/">= 8.8.7373"/g' ios/.symlinks/plugins/tencent_cloud_chat_sdk/ios/tencent_cloud_chat_sdk.podspec && \
cd ios && rm -f Podfile.lock && pod install --repo-update && cd .. && \
flutter analyze && \
flutter build ipa && \
open build/ios/archive/Runner.xcarchive
```
