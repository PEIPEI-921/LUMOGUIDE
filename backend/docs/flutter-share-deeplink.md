# Flutter 端修改文档 — 动态分享二维码 + 深链接

## 概述

服务端已完成动态分享二维码系统和深链接落地页。Flutter APP 需要进行以下修改以配合整套分享/深链接流程。

## 架构流程

```
用户点击分享
  → APP 调用 GET /api/common/shareQrcode?type=guide&id=123
  → 后端返回 PNG 二维码（编码: https://www.lumoguide.com/share.html?c=INVCODE&t=guide&i=123）
  → 展示二维码给用户分享

他人扫码
  → 浏览器打开 share.html 落地页
  → 尝试唤起 APP: lumoguide://share?c=INVCODE&t=guide&i=123
  ├─ APP 已安装 → 收到 deep link → 跳转到对应内容页
  └─ APP 未安装 → share.html 写参数到剪贴板 → 跳转应用商店
                    → 用户安装后首次打开 → APP 读取剪贴板 → 跳转到对应内容页
```

---

## 1. URL Scheme 注册

### iOS（Info.plist）

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>lumoguide</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.app.lumotrip</string>
    </dict>
</array>
```

**文件位置**: `ios/Runner/Info.plist`

### Android（AndroidManifest.xml）

在 `<activity>` 中加入 intent-filter：

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="lumoguide" android:host="share" />
</intent-filter>
```

**文件位置**: `android/app/src/main/AndroidManifest.xml`

---

## 2. Deep Link 处理

### 2.1 添加依赖

```yaml
# pubspec.yaml
dependencies:
  uni_links: ^0.5.1  # 或 app_links
```

### 2.2 初始化 Deep Link 监听

创建一个 `DeepLinkService` 或在已有的 router/navigation 服务中添加：

```dart
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  static void init() {
    // 监听 deep link（APP 已在后台时收到）
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleDeepLink(uri);
    }, onError: (err) {});

    // 检查冷启动时的 deep link
    getInitialUri().then((Uri? uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  static void _handleDeepLink(Uri uri) {
    if (uri.host != 'share') return;

    final code = uri.queryParameters['c'] ?? ''; // 邀请码
    final type = uri.queryParameters['t'] ?? ''; // guide/city/content/trip
    final id = uri.queryParameters['i'] ?? '';   // 内容 ID

    if (type.isEmpty || id.isEmpty) return;

    // 如果已登录，记录邀请关系
    if (isLoggedIn && code.isNotEmpty) {
      _bindInviter(code);
    }

    // 跳转到对应内容页
    _navigateToContent(type, int.parse(id));
  }

  static void _navigateToContent(String type, int id) {
    switch (type) {
      case 'guide':
        // 跳转到导游详情页
        navigator.pushNamed('/guide/detail', arguments: {'id': id});
        break;
      case 'city':
        // 跳转到城市详情页
        navigator.pushNamed('/city/detail', arguments: {'id': id});
        break;
      case 'content':
        // 跳转到内容详情页
        navigator.pushNamed('/city/content/detail', arguments: {'id': id});
        break;
      case 'trip':
        // 跳转到行程详情页
        navigator.pushNamed('/trip/detail', arguments: {'id': id});
        break;
    }
  }

  static void _bindInviter(String code) {
    // 调用绑定邀请人接口（需后端配合）
    // api.post('/user/bindInviter', {'inviter_code': code});
  }
}
```

### 2.3 在 main.dart 中初始化

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DeepLinkService.init();
  runApp(MyApp());
}
```

---

## 3. 延迟深链接 — 剪贴板读取

用户扫码时未安装 APP → share.html 将分享参数写入剪贴板 → 安装 APP 后首次打开时读取。

share.html 写入剪贴板的格式是 JSON 字符串：
```json
{"code":"ABC1234","type":"guide","id":"123"}
```

```dart
import 'package:flutter/services.dart';

class ClipboardService {
  static Future<void> checkShareParams() async {
    // 只在首次启动时检查（用 SharedPreferences 标记）
    final prefs = await SharedPreferences.getInstance();
    final checked = prefs.getBool('deep_link_clipboard_checked') ?? false;
    if (checked) return;

    await prefs.setBool('deep_link_clipboard_checked', true);

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';

      if (!text.startsWith('{') || !text.contains('"code"')) return;

      final json = jsonDecode(text) as Map<String, dynamic>;
      final code = json['code'] as String? ?? '';
      final type = json['type'] as String? ?? '';
      final id = json['id'] as String? ?? '';

      if (type.isNotEmpty && id.isNotEmpty) {
        // 延迟执行，等 APP 完全初始化 + 用户登录后再跳转
        Future.delayed(Duration(seconds: 2), () {
          if (code.isNotEmpty) _bindInviter(code);
          _navigateToContent(type, int.parse(id));
        });
        // 清除剪贴板
        Clipboard.setData(ClipboardData(text: ''));
      }
    } catch (_) {}
  }
}
```

在合适位置调用（如登录成功后或首页加载时）：
```dart
ClipboardService.checkShareParams();
```

---

## 4. 分享二维码 API 集成

### 4.1 新增 API 调用

```dart
// 在 api_service.dart 或 network_service.dart 中
Future<Uint8List> getShareQrcode(String type, int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/common/shareQrcode?type=$type&id=$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    return response.bodyBytes; // 直接返回 PNG 二进制数据
  }
  throw Exception('Failed to load QR code');
}
```

### 4.2 展示二维码的分享组件

```dart
class ShareQrcodeDialog extends StatefulWidget {
  final String type; // guide, city, content, trip
  final int id;

  const ShareQrcodeDialog({required this.type, required this.id});

  @override
  _ShareQrcodeDialogState createState() => _ShareQrcodeDialogState();
}

class _ShareQrcodeDialogState extends State<ShareQrcodeDialog> {
  Uint8List? _qrcodeBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQrcode();
  }

  Future<void> _loadQrcode() async {
    try {
      final bytes = await ApiService.getShareQrcode(widget.type, widget.id);
      setState(() {
        _qrcodeBytes = bytes;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('分享', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (_loading)
              CircularProgressIndicator()
            else if (_qrcodeBytes != null)
              Image.memory(_qrcodeBytes!, width: 250, height: 250)
            else
              Text('加載失敗', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('掃碼查看內容', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. 在各详情页添加分享入口

在导游详情、城市详情、内容详情、行程详情页的 AppBar 或底部操作栏添加分享按钮：

```dart
IconButton(
  icon: Icon(Icons.qr_code),
  onPressed: () {
    showDialog(
      context: context,
      builder: (_) => ShareQrcodeDialog(
        type: 'guide',  // 或 'city' / 'content' / 'trip'
        id: guideId,
      ),
    );
  },
)
```

各页面对应的 type 参数：

| 页面 | type 值 | id 来源 |
|---|---|---|
| 导游详情 | `guide` | 导游 ID |
| 城市详情 | `city` | 城市 ID |
| 景点/餐厅等详情 | `content` | 城市内容 ID |
| 行程详情 | `trip` | 行程 ID |

---

## 6. API 接口参考

### 获取分享二维码

```
GET /api/common/shareQrcode?type={type}&id={id}
Authorization: Bearer {token}
```

**参数**:

| 参数 | 类型 | 必填 | 说明 |
|---|---|---|---|
| type | string | 是 | guide / city / content / trip |
| id | int | 是 | 对应内容 ID |

**返回**: PNG 图片二进制流 (`Content-Type: image/png`)

### 获取系统配置（含下载链接和 URL Scheme）

```
GET /api/common/config
```

**返回新增字段**:

| 字段 | 说明 |
|---|---|
| `ios_download_url` | iOS App Store 链接 |
| `android_download_url` | Android 应用商店链接 |
| `app_url_scheme` | APP URL Scheme（默认 `lumoguide`） |

---

## 7. 修改清单汇总

| # | 修改内容 | 文件/位置 | 优先级 |
|---|---|---|---|
| 1 | 注册 URL Scheme `lumoguide://` | `ios/Runner/Info.plist` + `AndroidManifest.xml` | **高** |
| 2 | 实现 Deep Link 解析 | 新建 `DeepLinkService` + `main.dart` 初始化 | **高** |
| 3 | 各详情页跳转逻辑 | Router/Navigation 层 | **高** |
| 4 | 剪贴板读取 + 首次启动恢复 | 新建 `ClipboardService` | 中 |
| 5 | 分享二维码 API 调用 | API Service 新增方法 | **高** |
| 6 | 分享二维码弹窗组件 | 新建 `ShareQrcodeDialog` Widget | **高** |
| 7 | 各详情页添加分享按钮 | 导游/城市/内容/行程详情页 | **高** |
| 8 | 注册邀请人绑定接口（可选） | 新建 `/user/bindInviter` API + Flutter 调用 | 低 |
