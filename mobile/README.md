# LUMOTRIP (LUMOGUIDE)

Flutter 旅行指南 App，支持 iOS / Android / macOS。

- 版本：1.0.6+21
- 后端 API：`https://api.lumoguide.com/api/`
- 后端代码：`../LUMO_GUIDE_BackendCode/`（Laravel PHP）

## 环境

- Flutter 3.44.4 (Dart 3.12.2)，安装路径 `~/flutter/`
- 中国镜像必需（`PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL`）
- Android: Gradle 8.13, AGP 8.11.1, Kotlin 2.2.20, compileSdk 36, targetSdk 36
- 详见 [SETUP.md](SETUP.md) 和 [CLAUDE.md](CLAUDE.md)

## 快速开始

```bash
flutter pub get
flutter run -d macos   # macOS 桌面
flutter run             # 自动检测设备
flutter build apk --debug  # Android Debug APK（无需签名）
flutter build apk          # Android Release APK（需 key.jks）
flutter build ios       # iOS
```

## Android 构建注意事项

国内网络需要配置阿里云 Maven 镜像（已配置在 `android/build.gradle` + `android/settings.gradle`），以及全局 Gradle init script（`~/.gradle/init.d/aliyun-mirrors.gradle`）。详见 [CLAUDE.md](CLAUDE.md) 已知问题 #12。

## 文档

| 文档 | 说明 |
|------|------|
| [CLAUDE.md](CLAUDE.md) | 架构、模式、已知问题 |
| [SETUP.md](SETUP.md) | 新机器环境配置 |
| [docs/backend-deep-link-share.md](docs/backend-deep-link-share.md) | 分享二维码 + 深链接后端设计 |
| [docs/share.html](docs/share.html) | 分享落地页 |
| [docs/testflight-deploy-with-claude.md](docs/testflight-deploy-with-claude.md) | TestFlight 上传教程（配合 Claude Code） |
| [docs/backend-requirements.md](docs/backend-requirements.md) | 后端修改需求清单 |
| [docs/backend-member-expiry-reminder.md](docs/backend-member-expiry-reminder.md) | 会员到期提醒后端设计 |
