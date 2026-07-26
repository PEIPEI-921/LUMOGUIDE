# LUMOTRIP (LUMOGUIDE)

Flutter 旅行指南 App，支持 iOS / Android / macOS。

- 版本：1.0.6+19
- 后端 API：`https://api.lumoguide.com/api/`
- 后端代码：`../LUMO_GUIDE_BackendCode/`（Laravel PHP）

## 环境

- Flutter 3.44.4 (Dart 3.12.2)，安装路径 `~/flutter/`
- 中国镜像必需（`PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL`）
- 详见 [SETUP.md](SETUP.md) 和 [CLAUDE.md](CLAUDE.md)

## 快速开始

```bash
flutter pub get
flutter run -d macos   # macOS 桌面
flutter run             # 自动检测设备
flutter build apk       # Android APK
flutter build ios       # iOS
```

## 文档

| 文档 | 说明 |
|------|------|
| [CLAUDE.md](CLAUDE.md) | 架构、模式、已知问题 |
| [SETUP.md](SETUP.md) | 新机器环境配置 |
| [flutter-share-deeplink.md](flutter-share-deeplink.md) | 分享二维码 + 深链接设计文档 |
| [docs/testflight-upload.md](docs/testflight-upload.md) | TestFlight 上传指南 |
| [docs/testflight-deploy-with-claude.md](docs/testflight-deploy-with-claude.md) | TestFlight 上传教程（配合 Claude Code） |
| [docs/backend-requirements.md](docs/backend-requirements.md) | 后端修改需求清单 |
