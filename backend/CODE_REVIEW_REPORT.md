# Code Review Report

审查时间：
2026-07-20

项目：
LUMOGUIDE (LuMo Guide) — Laravel + Vue 3 SPA 旅游向导平台

审查范围：
- `app/Http/Controllers/Api/` — 11 个 API 控制器
- `app/Http/Middleware/` — 认证中间件
- `app/Http/Requests/` — 请求验证
- `app/Exceptions/Handler.php` — 异常处理
- `app/helpers.php` — 全局辅助函数
- `app/Models/` — Eloquent 模型
- `routes/api.php` — API 路由
- `frontend/js/` — 前端 SPA（Vue 3 CDN 构建）
- `resources/views/` — Blade 模板

未审查范围：
- `app/Services/*` — **10 个核心业务逻辑文件使用 Swoole Loader 加密**，无法进行源代码审查
- `app/Admin/*` — 管理后台（基于 Dcat Admin）
- `storage/` — 运行时文件
- `vendor/` — 第三方依赖

---

# Summary

发现问题数量：**18**

Critical: **1**
High: **5**
Medium: **8**
Low: **4**

---

# Issues

## Issue 001

Severity:
**Critical**

Category:
Security — Core business logic encrypted / unverifiable

Location:
文件路径:
- `app/Services/AuthService.php`
- `app/Services/UserService.php`
- `app/Services/CityService.php`
- `app/Services/GuideService.php`
- `app/Services/VipService.php`
- `app/Services/IntegralService.php`
- `app/Services/CommonService.php`
- `app/Services/CompanyService.php`
- `app/Services/InformationService.php`
- `app/Services/MessageService.php`

Description:
以上 10 个 Service 文件全部使用 Swoole Loader 加密。文件开头为 `<?php extension_loaded('swoole_loader') or die(...);?>`，随后是二进制加密数据。源代码完全不可读。

这些文件包含项目的核心业务逻辑（认证、用户管理、城市内容、导游、VIP、积分等）。由于无法审计，无法确认是否存在 SQL 注入、授权绕过、数据校验缺失等安全漏洞。

此外，加密代码依赖 Swoole Loader 扩展——如果该扩展未来不再维护或不兼容新 PHP 版本，整个项目将无法运行。

Impact:
1. 无法对核心业务逻辑进行安全审查
2. PHP 版本升级可能导致项目完全不可用
3. 任何 bug 修复必须依赖原始源代码重新加密部署
4. Swoole Loader 扩展本身若有漏洞，所有使用相同加密的项目都受影响

Evidence:
```
// AuthService.php (hex dump)
00000000: 3c3f 7068 7020 6578 7465 6e73 696f 6e5f  <?php extension_
00000010: 6c6f 6164 6564 2827 7377 6f6f 6c65 5f6c  loaded('swoole_l
// ... 之后均为二进制密文
```

---

## Issue 002

Severity:
**High**

Category:
Security — Password stored in plaintext in localStorage

Location:
文件路径: `frontend/js/stores/user.js`
函数: `saveCredentials`
行号: 147-157

Description:
`UserStore.saveCredentials` 在用户勾选"记住我"时，将密码明文存入 `localStorage`：

```javascript
saveCredentials(email, password, remember) {
    Storage.account = email;
    if (remember) {
        Storage.rememberMe = true;
        Storage.password = password;  // ← 明文密码
    }
}
```

任何同源 XSS 或恶意浏览器扩展都可读取密码。`localStorage` 数据会持久保留在磁盘上，不会随 session 结束清除。

Impact:
1. XSS 漏洞可导致用户密码批量泄露
2. 共享计算机上后续用户可读取前一个用户的密码
3. 违反 OWASP 安全规范（禁止在客户端存储敏感凭据）

Evidence:
```javascript
Storage.password = password;  // 明文存储密码
```

触发条件：用户登录时勾选"记住密码"。

---

## Issue 003

Severity:
**High**

Category:
Data — Payment success + DB failure = money lost, no retry

Location:
文件路径: `app/Http/Controllers/Api/PaymentController.php`
函数: `webhook` — `payment_intent.succeeded`
行号: 约 46-95

Description:
Stripe webhook 收到支付成功事件后，整个 VIP 开通流程包裹在 `try/catch` 中：

```php
DB::beginTransaction();
try {
    // 更新订单、VIP、用户状态 ...
    DB::commit();
} catch (\Throwable $th) {
    DB::rollBack();
    Log::debug('SystemError' . $th->getMessage());
    // ← 异常被吞掉
}
// ← 始终返回 200
return response()->json(['received' => true]);
```

**关键问题**：catch 块只记录日志，没有返回错误响应。Stripe 收到 HTTP 200 后认为 webhook 成功，不会重试。用户已被扣款但未获得 VIP 状态——钱付了，服务没到。

Impact:
1. 用户扣款但未获得 VIP — 需要人工退款
2. 财务对账不一致
3. 客户投诉和信任损失

Evidence:
```php
} catch (\Throwable $th) {
    DB::rollBack();
    Log::debug('SystemError' . $th->getMessage());
    // 没有返回非 2xx 状态码给 Stripe
}
return response()->json(['received' => true]);  // Stripe 认为成功
```

触发条件：支付 webhook 到达时数据库操作失败（死锁、连接中断、磁盘满等）。

---

## Issue 004

Severity:
**High**

Category:
Logic Bug — `reserveCompanyEdit` bypasses request validation

Location:
文件路径: `app/Http/Controllers/Api/UserController.php`
函数: `reserveCompanyEdit`

Description:
`reserveCompanyEdit` 直接将 `$request->all()` 传给 Service 层，未经任何验证：

```php
public function reserveCompanyEdit(UserService $service, Request $request)
{
    $id = $request->post('id', 0) ?? 0;
    if ($id <= 0) { /* error */ }
    $service->reserveCompanyEdit($id, $request->all());  // ← 无验证
}
```

对比同控制器中的 `reserveGuideEdit` 使用了 `ReserveGuideRequest` Form Request 校验：

```php
public function reserveGuideEdit(UserService $service, ReserveGuideRequest $request)
{
    $service->reserveGuideEdit($id, $request->validated());  // ✅
}
```

由于 Service 层被加密无法审计，无法确认其内部是否有二次校验。

Impact:
1. 攻击者可注入额外/恶意参数
2. 缺少类型/格式校验可能导致数据库错误
3. 与 `reserveGuideEdit` 安全级别不一致

Evidence:
```php
$service->reserveCompanyEdit($id, $request->all());  // ⚠️ 无验证
// vs
$service->reserveGuideEdit($id, $request->validated());  // ✅ 已验证
```

触发条件：向 `/api/user/reserveCompanyEdit` 发送包含额外参数的 POST 请求。

---

## Issue 005

Severity:
**High**

Category:
Logic Bug — `addContentReserve` bypasses request validation

Location:
文件路径: `app/Http/Controllers/Api/CityController.php`
函数: `addContentReserve`

Description:
与 Issue 004 相同模式。该方法仅验证 `content_id`，其余参数直接传入 Service 层：

```php
public function addContentReserve(CityService $service, Request $request)
{
    $content_id = $request->post('content_id', 0) ?? 0;
    if ($content_id <= 0) { /* error */ }
    $service->addContentReserve($request->all());  // ← 无 FormRequest
}
```

其他类似端点（`reserveGuide`, `addContentEvaluate` 等）都使用了专用 Form Request。

Impact:
与 Issue 004 相同：未验证的用户输入直接进入加密的 Service 层。

Evidence:
```php
$service->addContentReserve($request->all());  // 无验证
```

触发条件：向 `/api/city/addContentReserve` 发送未验证的参数。

---

## Issue 006

Severity:
**High**

Category:
Security — XSS via unescaped user nickname in message helpers

Location:
文件路径: `app/helpers.php`
函数: `reserveMessage`, `reserveUserMessage`

Description:
两个函数将 `$user_nickname` 直接拼接到消息字符串中：

```php
function reserveMessage(string $user_nickname, int $status) {
    $text = "[$user_nickname] 提交了预约消息";  // ← 直接拼接
}
function reserveUserMessage(string $str, int $status) {
    $text = "您的预约被拒绝:[$str]";  // ← 直接拼接
}
```

如果用户昵称包含 HTML/JavaScript（如 `<img src=x onerror=alert(1)>`），这些内容会进入消息系统。如果消息在 Web 页面中以非转义方式渲染，则触发存储型 XSS。

需要更多上下文确认消息的最终渲染方式（Blade `{{ }}` 会自动转义，但 `v-html`/`innerHTML` 不会）。

Impact:
如果消息以非转义 HTML 渲染，可导致存储型 XSS 攻击。

Evidence:
```php
$text = "[$user_nickname] 提交了预约消息";  // 无转义
```

触发条件：用户设置包含 HTML 标签的昵称后提交预约，管理员在未转义渲染的页面查看消息。

---

## Issue 007

Severity:
**Medium**

Category:
Logic Bug — `Authenticate` middleware has dead / confusing code

Location:
文件路径: `app/Http/Middleware/Authenticate.php`
函数: `redirectTo`

Description:
```php
protected function redirectTo($request)
{
    if (! $request->expectsJson()) {
        return null;          // ← 先 return null
        return route('login'); // ← 永远不会执行
    }
}
```

`return null;` 之后的 `return route('login');` 是死代码。此外，`$request->expectsJson()` 返回 `true` 时函数无显式返回值。

虽然全局异常处理器 (`Handler::unauthenticated`) 会统一返回 JSON 401，这里的逻辑正确性依赖隐式行为而非显式代码，是维护隐患。

Impact:
低直接影响，但代码意图不清晰，未来修改可能导致认证行为异常。

Evidence:
```php
return null;
return route('login');  // unreachable
```

---

## Issue 008

Severity:
**Medium**

Category:
Data — `generateUniqueInviteCode` has no uniqueness verification against database

Location:
文件路径: `app/helpers.php`
函数: `generateUniqueInviteCode`

Description:
```php
function generateUniqueInviteCode(): string
{
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $code = '';
    for ($i = 0; $i < 7; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;  // ← 未检查数据库唯一性
}
```

7 位邀请码，32 字符字母表，共 32^7 ≈ 340 亿种组合。概率极低但仍可能碰撞。如果发生碰撞，数据库唯一约束会导致写入失败。调用方（加密 Service）的错误处理未知。

Impact:
极端情况下两个用户获得相同邀请码，邀请关系混乱或注册失败。

Evidence:
```php
return $code;  // 生成后未检查数据库已存在
```

触发条件：极低概率的随机碰撞。

---

## Issue 009

Severity:
**Medium**

Category:
Security — `compressImage` disables SSL certificate verification

Location:
文件路径: `app/helpers.php`
函数: `compressImage`

Description:
```php
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_TIMEOUT => 15,
    CURLOPT_SSL_VERIFYPEER => false,  // ← 禁用 SSL 验证
]);
```

`CURLOPT_SSL_VERIFYPEER = false` 使得 cURL 接受任何 SSL 证书，包括伪造证书。中间人攻击者可伪造远程图片服务器，注入恶意内容。虽然仅用于下载图片，但恶意图片可能利用 GD 库漏洞进行 RCE。

Impact:
MITM 攻击者可替换远程图片内容，可能导致恶意文件被处理和存储。

Evidence:
```php
CURLOPT_SSL_VERIFYPEER => false,  // SSL 验证被禁用
```

触发条件：通过 HTTPS 下载远程图片时存在中间人攻击。

---

## Issue 010

Severity:
**Medium**

Category:
Data — `PaymentController` calls `saveData` with potentially invalid inviter_id

Location:
文件路径: `app/Http/Controllers/Api/PaymentController.php`
函数: `webhook` — `payment_intent.succeeded`
行号: 约 84

Description:
```php
SystemIntegralConfig::saveData($user->inviter_id, $mark);
```

未检查：
1. `$user->inviter_id` 是否 > 0（无邀请人时为 0）
2. 邀请人是否存在
3. 幂等性——Stripe 重发 webhook 时是否重复发放积分

由于 `SystemIntegralConfig::saveData` 的实现未知（可能在加密的 Service 中），无法确认内部保护。

Impact:
1. Stripe 重发 webhook 时可能重复发放积分
2. `inviter_id = 0` 时可能导致异常数据

Evidence:
```php
SystemIntegralConfig::saveData($user->inviter_id, $mark);
// inviter_id 可能为 0
```

触发条件：无邀请人的用户支付成功，或 Stripe 重发 webhook。

---

## Issue 011

Severity:
**Medium**

Category:
Logic Bug — VIP expiration accumulation uses old timestamp instead of current time

Location:
文件路径: `app/Http/Controllers/Api/PaymentController.php`
函数: `webhook`
行号: 约 68

Description:
```php
if ($user->vip_expiration_time == 0) {
    $user->vip_expiration_time = time() + Vip::TimeTypeDay[$vip->time_type];
} else {
    $user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
    // ⚠️ 基于旧过期时间累加，而非当前时间
}
```

如果用户 VIP 已过期（`$user->vip_expiration_time < time()` 但 `!= 0`），代码基于**已过期的旧时间**累加。例如用户 30 天前过期，现在订阅月卡：过期时间 = 30天前 + 30天 = 今天，而非今天 + 30 天。

Impact:
已过期用户重新订阅时 VIP 立即再次过期，需人工处理。

Evidence:
```php
// 基于旧过期时间累加而非当前时间
$user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
```

触发条件：VIP 已过期的用户重新订阅。

---

## Issue 012

Severity:
**Medium**

Category:
Logic Bug — VIP expiration Job dispatched with incorrect day count for unknown time types

Location:
文件路径: `app/Http/Controllers/Api/PaymentController.php`
函数: `webhook`
行号: 约 76-90

Description:
```php
$day = 1;
if ($vip->time_type == Vip::TimeTypeMonth) {
    $day = 30;
}
if ($vip->time_type == Vip::TimeTypeYear) {
    $day = 365;
}
// 如果 time_type 既不是月也不是年，$day 保持为 1
VipExpiredJob::dispatch($user->id)->delay(now()->addDays($day));
```

如果未来新增 VIP 类型（如季度卡、周卡），`$day` 会错误地保持为 1，导致 VIP 在 1 天后被标记为过期。

需要更多上下文确认 `Vip::TimeType` 的完整枚举值。

Impact:
新增 VIP 时长类型时到期 Job 错误触发。

Evidence:
```php
$day = 1;  // 仅在非月/非年时使用，可能不正确
```

触发条件：存在月/年以外的 VIP 时间类型。

---

## Issue 013

Severity:
**Medium**

Category:
Performance — `handleIsRead` N+1 UPDATE pattern

Location:
文件路径: `app/helpers.php`
函数: `handleIsRead`

Description:
```php
function handleIsRead($model)
{
    if ($model->is_read == 0) {
        $model->is_read = 1;
        $model->save();  // ← 每条记录一个 UPDATE
    }
}
```

在消息列表循环中调用时，每条未读消息触发一次独立 UPDATE。项目中虽已有 `handleIsReadBatch` 批量版本，但调用方可能仍使用单条版本。

Impact:
消息列表页加载时产生大量不必要的 UPDATE 查询，影响响应速度。

Evidence:
```php
$model->save();  // 循环中导致 N+1
```

触发条件：在 foreach 中为多条消息调用 `handleIsRead()`。

---

## Issue 014

Severity:
**Medium**

Category:
Concurrency — No Stripe webhook idempotency handling

Location:
文件路径: `app/Http/Controllers/Api/PaymentController.php`
函数: `webhook`

Description:
Stripe 可能在网络超时后重发同一个 webhook。代码没有基于 webhook event ID 的幂等性检查。虽然 `$order->pay_status` 可防止重复更新订单状态，但积分发放和 Job 派发可能重复执行：

```php
// 没有 event ID 去重检查
$orderId = $pi->metadata->order_id ?? null;
```

Impact:
Stripe 重发 webhook 时可能：
1. 重复发放积分给邀请人
2. 重复发送邮件通知
3. 重复派发延迟 Job

Evidence:
```php
// 缺少基于 Stripe event ID 的幂等性保护
$orderId = $pi->metadata->order_id ?? null;
```

触发条件：Stripe 因网络问题重发 webhook 事件。

---

## Issue 015

Severity:
**Low**

Category:
Logic Bug — `ApiProvider` uses Vue internal/private API `__vue_app__`

Location:
文件路径: `frontend/js/api/provider.js`
行号: 约 82

Description:
```javascript
const app = document.querySelector('#app').__vue_app__;
if (app) {
    const router = app.config.globalProperties.$router;
    if (router) router.push('/login');
}
```

`__vue_app__` 是 Vue 3 的内部私有属性。Vue 小版本升级可能重命名或删除此属性，导致 401 自动跳转登录功能静默失效。

Impact:
Vue 3.x 更新后 401 自动跳转可能失效，用户看到空白页面或错误提示而非登录页。

Evidence:
```javascript
document.querySelector('#app').__vue_app__  // Vue 内部 API
```

触发条件：Vue 3 小版本升级。

---

## Issue 016

Severity:
**Low**

Category:
Data — Email stored in localStorage unconditionally

Location:
文件路径: `frontend/js/stores/user.js`
函数: `saveCredentials`
行号: 147-150

Description:
```javascript
saveCredentials(email, password, remember) {
    Storage.account = email;  // ← 总是存储
    if (remember) {
        Storage.rememberMe = true;
        Storage.password = password;
    }
}
```

即使用户不勾选"记住我"，邮箱也被存入 localStorage，下次自动填充。在公共/共享电脑上，用户可能期望不留下任何痕迹。

Impact:
公共计算机上用户隐私泄露风险。

Evidence:
```javascript
Storage.account = email;  // 无条件存储
```

触发条件：在公共设备上登录且不勾选"记住我"。

---

## Issue 017

Severity:
**Low**

Category:
Logic Bug — `$request->expectsJson()` has implicit null return

Location:
文件路径: `app/Http/Middleware/Authenticate.php`
函数: `redirectTo`

Description:
```php
protected function redirectTo($request)
{
    if (! $request->expectsJson()) {
        return null;
        return route('login');  // dead code
    }
    // expectJson() 为 true 时无显式 return，隐式返回 null
}
```

函数在所有分支都应显式返回值。当前隐式依赖全局异常处理器兜底，代码意图不清晰。

Impact:
维护性风险，当前功能正常但不健壮。

---

## Issue 018

Severity:
**Low**

Category:
Data — `handleIsRead` called directly instead of batch version

Location:
文件路径: `app/helpers.php`
函数: `handleIsRead` vs `handleIsReadBatch`

Description:
项目同时存在单条版 `handleIsRead` 和批量版 `handleIsReadBatch`：

```php
function handleIsRead($model) { $model->save(); }
function handleIsReadBatch(string $modelClass, array $ids) { /* 批量 UPDATE */ }
```

如果调用方在循环中使用单条版本，会产生 N+1 问题。无法确认加密的 Service 层中调用的是哪个版本。批量版本已实现但可能未被使用。

Impact:
取决于 Service 层如何调用——如果使用单条版本则有 N+1 性能问题。

Evidence:
存在两个版本但无法确认 Service 层使用哪个。

---

# End of Report
