# Lumotrip macOS 开发环境配置

本文档供 Claude Code 在新 MacBook 上自动配置开发环境。

## 配置流程

按顺序执行每一步。每步先检查是否已满足，满足则跳过，不满足则安装配置。

---

### 1. Shell 环境

检查 `~/.zshrc` 中是否已有 Flutter 相关配置：

```bash
grep -q "PUB_HOSTED_URL.*pub.flutter-io.cn" ~/.zshrc && echo "OK: 镜像已配置" || echo "MISS: 需要配置镜像"
grep -q "flutter/bin" ~/.zshrc && echo "OK: Flutter PATH 已配置" || echo "MISS: 需要配置 PATH"
```

如果缺少，追加到 `~/.zshrc`：

```bash
cat >> ~/.zshrc << 'EOF'

# Flutter
export PATH="$HOME/flutter/bin:$PATH"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
EOF
source ~/.zshrc
```

---

### 2. Homebrew

```bash
which brew && echo "OK: Homebrew $(brew --version | head -1)" || echo "MISS: 需要安装 Homebrew"
```

安装命令：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

### 3. Flutter SDK

```bash
ls ~/flutter/bin/flutter && echo "OK: Flutter $(flutter --version | head -1)" || echo "MISS: 需要安装 Flutter"
```

安装命令：
```bash
# 从 https://docs.flutter.dev/get-started/install/macos 下载最新 stable zip
# 解压到 ~/flutter
cd ~
curl -o flutter.zip https://storage.flutter-io.cn/flutter_infra_release/releases/stable/macos/flutter_macos_latest_stable.zip
unzip -q flutter.zip
rm flutter.zip

# 如果遇到 macOS 安全限制导致 dart 无法运行：
xattr -r -d com.apple.quarantine ~/flutter/
```

---

### 4. Xcode + Command Line Tools

```bash
# 检查 Xcode.app 是否存在
ls /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild && echo "OK: Xcode 已安装" || echo "MISS: 需要安装 Xcode"

# 检查 xcode-select 是否指向 Xcode（而非 Command Line Tools）
xcode-select -p | grep -q "Xcode.app" && echo "OK: xcode-select 正确" || echo "MISS: xcode-select 需要切换"
```

安装 Xcode：
1. 从 App Store 搜索安装 Xcode
2. 首次打开 Xcode 接受 license 并完成组件安装

```bash
# 切换 xcode-select 到 Xcode（而非独立 Command Line Tools）
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 接受 Xcode license
sudo xcodebuild -license accept
```

#### 4.1 常见问题

**Simulator runtime 不可用：** `flutter doctor` 报 "Unable to get list of installed Simulator runtimes"。

```bash
# 列出已安装的 Simulator runtime
xcrun simctl list runtimes

# 如果为空，下载 iOS Simulator runtime
# Xcode → Settings → Platforms → 下载 iOS Simulator
# 或用命令行：
xcodebuild -downloadPlatform iOS

# 如果 macOS 桌面构建已可用，iOS Simulator 不是必须的
flutter devices  # macOS (desktop) 出现即为可用
```

---

### 5. CocoaPods

```bash
which pod && echo "OK: CocoaPods $(pod --version)" || echo "MISS: 需要安装 CocoaPods"
```

安装命令：
```bash
brew install cocoapods
```

---

### 6. VS Code

```bash
ls /Applications/Visual\ Studio\ Code.app && echo "OK: VS Code 已安装" || echo "MISS: 需要安装 VS Code"
```

安装命令：
```bash
brew install --cask visual-studio-code
```

#### 6.1 安装 Flutter 扩展

```bash
# 如果 code 命令不可用，先创建 symlink
sudo ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code

# 安装 Dart + Flutter 扩展（依赖会自动安装）
code --install-extension Dart-Code.flutter
```

**验证扩展已激活：** 安装后必须在 VS Code 中执行 **Cmd+Shift+P → "Developer: Reload Window"**，否则扩展不会加载。重载后底部状态栏应显示 "macOS (desktop)" 设备选择器。

#### 6.2 终端 `code` 命令

```bash
# 检查
which code && echo "OK: code 命令已配置" || echo "MISS: 需要配置"

# 如果 VS Code 从 Desktop 移动到 Applications，旧 symlink 会失效
ls -l $(which code)  # 确认指向 /Applications/... 而非 ~/Desktop/...
# 如指向错误路径：
sudo rm /usr/local/bin/code && sudo ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
```

#### 6.3 项目 VS Code 配置

在项目根目录下已有 `.vscode/settings.json` 和 `.vscode/launch.json`：

- **settings.json** — Flutter SDK 路径、保存时格式化、排除 build/Pods 目录
- **launch.json** — 4 个调试配置：macOS、Android、iOS Simulator、自动检测

如需重新生成或缺失，让 Claude Code 创建：

```
帮我在 VS Code 中配置 Flutter 项目
```

---

### 7. 项目依赖

进入项目目录后：

```bash
cd /path/to/lumotrip
flutter pub get
```

运行验证：
```bash
flutter analyze          # 静态分析，检查代码是否有错误
flutter devices           # 确认目标设备可用
flutter run -d macos     # 在 macOS 上启动运行
```

#### 从 VS Code 一键运行

1. 确保 VS Code 窗口已打开项目根目录
2. 确认 Flutter 扩展已激活（状态栏显示设备）
3. 点击底部状态栏设备名，选择目标设备（如 "macOS (desktop)"）
4. 点击右上角 ▶ 箭头或按 **F5** 开始调试
5. 首次启动会编译，耐心等待（macOS 约 1-2 分钟）

---

## 验证清单

全部通过即表示配置完成：

| # | 检查项 | 命令 |
|---|--------|------|
| 1 | Homebrew | `which brew` |
| 2 | Flutter SDK | `flutter --version` |
| 3 | Xcode | `xcodebuild -version` |
| 4 | xcode-select | `xcode-select -p`（输出应含 Xcode.app） |
| 5 | CocoaPods | `pod --version` |
| 6 | 中国镜像 | `echo $PUB_HOSTED_URL`（输出 pub.flutter-io.cn） |
| 7 | VS Code | `ls /Applications/Visual\ Studio\ Code.app` |
| 8 | Flutter 扩展 | `code --list-extensions \| grep flutter` |
| 9 | `code` 命令 | `which code`（symlink 指向 /Applications/...） |
| 10 | 可用设备 | `flutter devices`（应列出 macOS） |
| 11 | 项目依赖 | `flutter pub get`（No issues found） |
| 12 | 静态分析 | `flutter analyze`（No issues found） |
| 13 | macOS 构建 | `flutter run -d macos`（成功启动） |

## 已知项目补丁

以下补丁已在项目中，复制项目即可，无需重新修补：

- `patched_packages/extended_text_field/` — 修复 Flutter 3.44 移除 `ExtendSelectionByPageIntent` 导致的编译错误
- `pubspec.yaml` 中 `dependency_overrides` 已指向本地补丁
