# Code Review Report

审查时间：
2026-07-21

项目：
LUMOGUIDE-Front (LuMo Trip) — Flutter 跨平台移动应用（Android / iOS）

技术栈：
- Flutter 3.x / Dart 3.8+
- GetX 状态管理
- Provider + SharedPreferences
- Dio HTTP 客户端
- flutter_stripe 支付集成
- Tencent Cloud Chat IM

审查范围：
- `lib/main.dart` — 应用入口
- `lib/global.dart` — 全局初始化
- `lib/common/apis/` — API 层（Dio 封装、拦截器、URL 常量）
- `lib/common/stores/` — 状态管理（UserStore, StorageStone）
- `lib/common/services/` — 服务层（StorageService, ConfigService, StripeService）
- `lib/common/values/` — 常量定义（storage keys, enums）
- `lib/pages/login/` — 登录页
- `lib/pages/register/` — 注册页
- 其他相关配置文件

未审查范围：
- `patched_packages/` — 第三方补丁包
- `plugins/` — 第三方插件修改
- `lib/pages/*/page.dart` — 纯 UI 布局文件（约 60+ 页面）
- `android/`, `ios/` — 平台原生代码
- `.dart_tool/` — 构建工具缓存

---

# Summary

发现问题数量：**11**

Critical: **2**
High: **4**
Medium: **4**
Low: **1**

---

# Issues

## Issue 001

Severity:
**Critical**

Category:
Security — Stripe live publishable key hardcoded in source code

Location:
文件路径: `lib/common/services/stripe.dart`
行号: 32

Description:
Stripe **生产环境** publishable key 被硬编码在源代码中：

```dart
const String stripePublishableKey = 'pk_live_51RkgWL058lDhaDhlmzyCTYR6DGnbTDCQhyAU5OKqDZtvwuFmq7MizQ0xUR1f4jo6ssfSWrx3ngPV2VDOwf4E28KS00GTJNHInk';
```

代码虽有从 `ConfigService.to.systemConfig.stripeKey` 动态读取的逻辑，但硬编码的 `pk_live_xxx` 作为 fallback 被编译进应用包。这意味着：

1. 任何反编译 APK/IPA 的人都能获取该 key
2. 该 key 被提交到了版本控制系统
3. Stripe publishable key 虽非 secret（按 Stripe 文档），但暴露在源码中结合其他信息可能被滥用

Impact:
1. 生产环境 Stripe key 泄露
2. 如果代码仓库是公开的，任何人可以获取该 key
3. 一旦该 key 需要轮换，必须重新发布应用

Evidence:
```dart
const String stripePublishableKey = 'pk_live_51RkgWL...00GTJNHInk';
```

触发条件：任何人获取源代码或反编译 APK。

---

## Issue 002

Severity:
**Critical**

Category:
Security — User password stored in plaintext in SharedPreferences

Location:
文件路径:
- `lib/common/values/storage.dart` 行号: 17 — `STORAGE_PASSWORD_KEY`
- `lib/common/stores/storage.dart` 行号: 41-45 — `StorageStone.password` / `setPassword`
- `lib/pages/login/controller.dart` 行号: 69-78 — 登录时存储密码

Description:
Flutter 应用将用户密码**明文**存储到 `SharedPreferences`（Android 上的 XML 文件，iOS 上的 plist）：

```dart
// storage.dart — 存储密码
static setPassword(String value) async {
    await StorageService.to.setString(STORAGE_PASSWORD_KEY, value);
}
```

```dart
// login/controller.dart — 登录时写入
if (rememberPassword.value) {
    StorageStone.setPassword(password.value);  // ← 明文密码
}
```

SharedPreferences 在 Android 上存储为明文 XML，在有 root 权限的设备或通过 ADB backup 可直接读取。iOS 上虽在应用沙箱内，但越狱设备同样可读取。

此外，登录页在 `onInit` 中自动加载密码：

```dart
password.value = StorageStone.password;  // 明文密码加载到内存
```

Impact:
1. root/越狱设备上密码可被直接读取
2. ADB backup 可导出包含明文密码的 SharedPreferences
3. 违反 OWASP Mobile Top 10: M2 (Insecure Data Storage)

Evidence:
```dart
StorageStone.setPassword(password.value);   // 明文写入 SharedPreferences
password.value = StorageStone.password;      // 明文读回
```

触发条件：用户登录时勾选"记住密码"。

---

## Issue 003

Severity:
**High**

Category:
Security — Test credentials hardcoded in debug mode

Location:
文件路径: `lib/pages/login/controller.dart`
行号: 31-39

Description:
登录控制器在 `kDebugMode` 下自动填充测试账号密码：

```dart
if (kDebugMode) {
    email.value = 'zhouguanpei@hotmail.com';
    password.value = 'zhou123';
    emailController.text = email.value;
    passwordController.text = password.value;
    rememberPassword.value = true;
}
```

**关键风险**：`kDebugMode` 在 Flutter 中通过 `assert` 实现，但在某些构建配置或第三方 SDK 中可能不会完全剥离。如果 debug 构建被意外发布到应用商店，所有用户都会看到预填充的真实邮箱和密码。

此外，注释中暴露了多个邮箱地址（`2096037421@qq.com`, `arilks@qq.com`, `zhouguanpei@gmail.com` 等），这些都是真实的个人信息。

Impact:
1. 如果 debug 版本被发布，用户可直接使用预填充的凭证登录
2. 源代码中暴露了真实邮箱地址
3. 测试密码 `zhou123` 仅 7 位且包含常见模式

Evidence:
```dart
email.value = 'zhouguanpei@hotmail.com';
password.value = 'zhou123';
```

触发条件：任何获取源代码的人；debug 构建被意外发布。

---

## Issue 004

Severity:
**High**

Category:
Logic Bug — AuthInterceptor breaks Dio response chain on 401

Location:
文件路径: `lib/common/apis/interceptors/auth_interceptor.dart`
行号: 17-25

Description:
`AuthInterceptor.onResponse` 在检测到 401 后执行 `Get.offAllNamed` 然后 **`return`**，跳过 `super.onResponse(response, handler)`：

```dart
void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
        if (response.statusCode == 401 || response.data['code'] == 401) {
            if (ConfigService.to.isEnterApp) {
                Loading.dismiss();
                getx.Get.offAllNamed(AppRoutes.LOGIN);
                return;  // ← 跳过了 super.onResponse(handler)
            }
        }
    } catch (e) { ... }
    super.onResponse(response, handler);  // ← 正常情况下才到达这里
}
```

这导致：
1. 触发 401 响应的 API 调用方永远收不到 response 或 error 回调
2. 如果页面在 `await` API 调用后执行清理逻辑，这些逻辑不会被执行
3. 可能导致内存泄漏（回调未释放）

更安全的方式是：调用 `handler.next(response)` 或 `handler.reject(error)` 正常结束拦截链，然后在调用方处理跳转。

Impact:
1. 页面等待 API 响应的代码永远不会完成（Promise/Future 悬挂）
2. 可能导致 UI 一直显示 loading 状态
3. 资源未正确释放

Evidence:
```dart
getx.Get.offAllNamed(AppRoutes.LOGIN);
return;  // ← 跳过 handler 回调
```

触发条件：用户 token 过期后发起任何需要认证的 API 请求。

---

## Issue 005

Severity:
**High**

Category:
Security — Hardcoded production backend URL

Location:
文件路径: `lib/common/apis/urls.dart`
行号: 3-4

Description:
```dart
static const _isDev = false;
static const baseUrl = _isDev
    ? 'https://dev.lumoguide.com/'
    : 'https://api.lumoguide.com/';
```

后端 API 地址硬编码在源代码中。虽然切换环境通过 `_isDev` 常量控制，但：
1. 生产环境 URL 始终编译进应用
2. 没有从配置文件/环境变量读取的机制
3. 无法在不重新构建应用的情况下切换后端环境

Impact:
1. 如果后端域名变更，必须发布新版本
2. 攻击者可以通过反编译获取 API 端点信息

Evidence:
```dart
static const baseUrl = ... 'https://api.lumoguide.com/';
```

---

## Issue 006

Severity:
**High**

Category:
Logic Bug — `ApiResult.success` does not handle non-200 successful responses

Location:
文件路径: `lib/common/apis/result.dart`
函数: `ApiResult.success`

Description:
```dart
ApiResult.success(Response response) {
    try {
        if (response.statusCode != 200) {
            message = response.statusMessage;
            code = response.statusCode ?? -1;
            return;
        }
        // ...
    }
}
```

这里只接受 HTTP 200，但 Dio 的 `validateStatus` 配置接受 `200 <= status < 300`（见 `provider.dart` 第 17-18 行）。这意味着：
- 后端返回 HTTP 201 (Created) 时，Dio 认为请求成功并返回 Response
- 但 `ApiResult.success` 将其标记为失败（`code = 201, isSuccess = false`）

调用方使用 `res.isSuccess` (即 `code == 200`) 判断结果，所以 HTTP 201 会被误判为失败。

Impact:
后端返回 201 Created 的端点（如某些创建资源的 API）会被前端误判为请求失败。

Evidence:
```dart
if (response.statusCode != 200) {  // 只接受 200
    // ...
    return;
}
// 但 Dio 接受 200-299
```

触发条件：后端返回 201、202、204 等非 200 的成功状态码。

---

## Issue 007

Severity:
**Medium**

Category:
Logic Bug — `_verifyPaymentResult` swallows exceptions silently

Location:
文件路径: `lib/common/services/stripe.dart`
函数: `_verifyPaymentResult`

Description:
```dart
Future<PaymentResult> _verifyPaymentResult(String clientSecret) async {
    try {
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
        // ...
    } catch (e) {
        log(e.toString());
        return PaymentResult(
            status: PaymentStatus.failed,
            message: _getErrorMessage(e),
            errorType: _getErrorType(e),
        );
    }
}
```

catch 块捕获所有异常但仅记录到 `log`（debug 级别），用户收到的错误消息是通过字符串匹配推断的：

```dart
String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
        return '網絡錯誤...';
    } else if (error.toString().contains('cancelled')) {
        return '支付被取消'.tr;
    } else {
        return error.toString().isNotEmpty ? error.toString() : '支付系統錯誤'.tr;
    }
}
```

如果 Stripe SDK 抛出的异常消息不包含 `network`/`cancel`/`timeout` 关键字，直接把异常消息返回给用户（`error.toString()`），这可能包含技术细节（如 JSON 解析错误、API 错误码等），不适合展示给终端用户。

Impact:
用户可能看到包含技术细节的错误消息，体验不佳且可能暴露系统信息。

Evidence:
```dart
return error.toString().isNotEmpty ? error.toString() : '支付系統錯誤'.tr;
```

触发条件：Stripe 支付过程中发生未被预期的异常类型。

---

## Issue 008

Severity:
**Medium**

Category:
Logic Bug — `_verifyOrderSn` checks `pay_status` but webhook may not have completed

Location:
文件路径: `lib/common/services/stripe.dart`
函数: `_verifyOrderSn`

Description:
支付成功后轮询订单状态：

```dart
Future<PaymentResult> _verifyOrderSn(String orderSn) async {
    final res = await get(ApiUrl.vipPayStatus, parameters: {'order_sn': orderSn});
    // ...
    final status = res.dataJson['pay_status'] as int? ?? 0;
    if (status == 1) {
        return PaymentResult(status: PaymentStatus.success, message: '訂閱成功');
    } else {
        return PaymentResult(status: PaymentStatus.failed, message: '訂閱失敗');
    }
}
```

这里只检查一次，如果 Stripe webhook 尚未处理完成（后端异步处理支付确认），`pay_status` 可能仍为 0，前端会立即返回"訂閱失敗"给用户——但实际支付可能再过几秒就成功了。

应与 `_handleProcessingPayment` 一样使用轮询重试机制。

Impact:
网络延迟或后端处理较慢时，用户看到"支付失败"但钱已扣，造成困惑和客服咨询。

Evidence:
```dart
if (status == 1) { ... } else { return PaymentResult(status: PaymentStatus.failed); }
// 没有重试机制
```

触发条件：Stripe webhook 延迟到达（网络慢、后端繁忙）。

---

## Issue 009

Severity:
**Medium**

Category:
Data — `_isFirstOpen` inverted logic

Location:
文件路径: `lib/common/services/config.dart`
函数: `_loadConfig` / `enterApp`

Description:
```dart
_loadConfig() {
    _isFirstOpen = StorageService.to.getBool(
        STORAGE_IS_FIRST_OPEN_KEY,
        defaultValue: true,
    );
}

enterApp() {
    _isEnterApp = true;
    _isFirstOpen = true;  // ← 进入应用后将 isFirstOpen 设为 true
    StorageService.to.setBool(STORAGE_IS_FIRST_OPEN_KEY, false);  // ← 但存储值设为 false
}
```

`_loadConfig` 读取存储值，默认 `true`（首次打开）。`enterApp` 方法中：
- `_isFirstOpen = true` — 内存中标记为"首次打开"
- `StorageService.to.setBool(..., false)` — 但写入存储的是 `false`（表示"非首次"）

下次启动时 `_loadConfig` 读取到 `false`，`_isFirstOpen` 为 `false`。逻辑上能正常工作（首次=true → 进入后存 false → 下次读 false），但 `enterApp` 中 `_isFirstOpen = true` 这行让代码阅读者困惑——"进入应用后反而标记为首次打开？"

需要更多上下文确认 `_isFirstOpen` 的实际用途。

Impact:
代码意图不清晰，维护时可能引入 bug。

Evidence:
```dart
_isFirstOpen = true;                            // 内存中 = 首次打开
StorageService.to.setBool(..., false);          // 存储中 = 非首次
```

---

## Issue 010

Severity:
**Medium**

Category:
Logic Bug — `AuthInterceptor` `onError` handler is a no-op

Location:
文件路径: `lib/common/apis/interceptors/auth_interceptor.dart`
行号: 29-32

Description:
```dart
void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.data is Map) {}
    super.onError(err, handler);
}
```

`onError` 中的 `if (err.response?.data is Map) {}` 是一个空操作——它检查了条件但什么都不做。如果原本意图是处理包含特定错误格式的响应（如 401），那这个处理逻辑缺失了。

而且如果**网络层面的** 401（HTTP 401）在 Dio 中可能被 `validateStatus` 拒绝而进入 `onError`（而非 `onResponse`），此时 `onError` 不会触发登录跳转——`onResponse` 中的 401 处理逻辑不会被调用。

需要更多上下文确认：Dio 的 `validateStatus` 设置只接受 200-299，所以 HTTP 401 **会**进入 `onError`，不会进入 `onResponse`。这意味着 `onResponse` 中的 401 处理**永远不会被触发**。

Impact:
如果 Dio 因 HTTP 401 进入 `onError` 而非 `onResponse`，token 过期不会自动跳转登录页——用户看到"网络错误"但不知道为什么。

Evidence:
```dart
void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.data is Map) {}  // 空操作
    super.onError(err, handler);
}
```

触发条件：需要更多上下文确认 Dio 的 `validateStatus` 行为。

---

## Issue 011

Severity:
**Low**

Category:
Data — Email stored unconditionally in SharedPreferences

Location:
文件路径: `lib/pages/login/controller.dart`
行号: 69-76

Description:
```dart
if (rememberPassword.value) {
    StorageStone.setPassword(password.value);
    StorageStone.setAccount(email.value);
    StorageStone.setRememberMe(true);
} else {
    StorageStone.setPassword('');
    StorageStone.setAccount('');       // ← 清空
    StorageStone.setRememberMe(false);
}
```

即使用户不勾选"记住密码"，邮箱也曾被写入 SharedPreferences（在 `onInit` 中如果之前记住过会读取，但在本次登录后的 else 分支会清空）。这个行为本身是正确的。

但注册页（`register/controller.dart`）没有类似逻辑——它不存储任何凭证。这不是 bug，只是一致性问题。

**真正的问题**：`logout()` 方法（在 `StorageStone` 中）仅清除 token 和 userInfo，**不清除 account 和 password**：

```dart
static logout() async {
    await setToken('');
    await setUserInfo('');
    await setExpireTime('');
    // ❌ 不清除 account / password / rememberMe
}
```

用户退出登录后，下次打开登录页仍会看到之前保存的邮箱和密码。

Impact:
用户退出登录后，敏感信息仍保留在设备上。

Evidence:
```dart
static logout() async {
    await setToken('');
    await setUserInfo('');
    // account / password / rememberMe 未清除
}
```

触发条件：用户点击退出登录。

---

# End of Report
