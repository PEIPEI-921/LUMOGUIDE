# Code Fix Guide — LUMOGUIDE

> 生成时间：2026-07-20
> 对应报告：CODE_REVIEW_REPORT.md
> 说明：本文档为每个问题提供**具体修复代码**。严格按照编号顺序修复。

---

## Issue 001 · 核心 Service 文件加密，无法审计

**无法直接修复**。需要：

1. 联系原始开发者获取未加密的源代码
2. 将源代码部署到服务器替换加密文件
3. 如果 Swoole Loader 是商业加密方案，考虑迁移到无加密部署

**临时缓解措施**：无。加密文件无法被任何人（包括你）审查或修改。

---

## Issue 002 · 密码明文存储在 localStorage

**文件**: `frontend/js/stores/user.js`

**当前代码** (第 147-157 行):
```javascript
saveCredentials(email, password, remember) {
    Storage.account = email;
    if (remember) {
        Storage.rememberMe = true;
        Storage.password = password;   // ❌ 明文密码
    } else {
        Storage.rememberMe = false;
        Storage.password = '';
    }
},
```

**修复方案**：完全移除密码存储。JWT Token 已足够维持登录态。

```javascript
saveCredentials(email, remember) {
    Storage.account = email;
    Storage.rememberMe = !!remember;
    // ❌ 删除：Storage.password = password;
},
```

同步修改 `getCredentials()`（同文件）:
```javascript
// 修改前
getCredentials() {
    if (Storage.rememberMe) {
        return {
            email: Storage.account,
            password: Storage.password,   // ❌ 删除
            remember: true
        };
    }
    return { email: '', password: '', remember: false };
}

// 修改后
getCredentials() {
    return {
        email: Storage.rememberMe ? Storage.account : '',
        remember: !!Storage.rememberMe
    };
}
```

同步修改 `login.js`（`frontend/js/pages/auth/login.js`）:
```javascript
// 修改前
UserStore.saveCredentials(this.email, this.password, this.remember);

// 修改后
UserStore.saveCredentials(this.email, this.remember);
```

---

## Issue 003 · 支付成功但 DB 失败导致资金损失

**文件**: `app/Http/Controllers/Api/PaymentController.php`

**当前代码** (约第 46-95 行):
```php
DB::beginTransaction();
try {
    $order->pay_time = time();
    $order->pay_status = Vip::PayStatusPay;
    $order->save();
    // ... VIP 处理 ...
    DB::commit();
} catch (\Throwable $th) {
    DB::rollBack();
    Log::debug('SystemError' . $th->getMessage());
    // ❌ 没有返回错误给 Stripe
}
return response()->json(['received' => true]);
```

**修复方案**：catch 块返回 HTTP 非 2xx 状态码，让 Stripe 重试 webhook。

```php
DB::beginTransaction();
try {
    // --- 1. 先检查订单是否已处理（幂等性）---
    $order = VipOrder::query()->where('order_sn', $orderId)->first();
    if (!$order) {
        Log::error('Stripe webhook: order not found', ['order_sn' => $orderId]);
        return response()->json(['error' => 'Order not found'], 404);
    }
    if ($order->pay_status == Vip::PayStatusPay) {
        // 已支付，幂等返回成功
        return response()->json(['received' => true]);
    }

    // --- 2. 更新订单 ---
    $order->pay_time = time();
    $order->pay_status = Vip::PayStatusPay;
    $order->save();

    // --- 3. 更新用户 VIP ---
    $user = User::find($order->user_id);
    $user->vip_type = $vip_type;
    $user->vip_id = $order->vip_id;
    $user->vip_name = $vip->name;

    // 修复：基于 max(当前时间, 旧过期时间) 累加
    $baseTime = max(time(), $user->vip_expiration_time);
    $user->vip_expiration_time = $baseTime + Vip::TimeTypeDay[$vip->time_type];

    if (!empty($vip_company_auth)) {
        $user->vip_company_auth = json_encode($vip_company_auth);
    }
    $user->vip_free = 0;
    $user->save();

    // --- 4. 积分发放（加保护）---
    if ($user->inviter_id > 0) {
        SystemIntegralConfig::saveData($user->inviter_id, $mark);
    }

    // --- 5. 延迟任务 ---
    // (EmailRemindJob, VipExpiredJob, InvoiceJob 等)

    DB::commit();

    return response()->json(['received' => true]);

} catch (\Throwable $th) {
    DB::rollBack();
    Log::error('Stripe webhook processing failed', [
        'order_sn' => $orderId,
        'error' => $th->getMessage(),
        'trace' => $th->getTraceAsString()
    ]);
    // ✅ 返回 500，Stripe 会重试
    return response()->json(['error' => 'Internal server error'], 500);
}
```

---

## Issue 004 · `reserveCompanyEdit` 缺少请求验证

**文件**: `app/Http/Controllers/Api/UserController.php`

**当前代码**:
```php
public function reserveCompanyEdit(UserService $service, Request $request)
{
    $id = $request->post('id', 0) ?? 0;
    if ($id <= 0) {
        return $this->error(__('res.id_required'));
    }
    $service->reserveCompanyEdit($id, $request->all());  // ❌ 无验证
    return $this->success(__('res.success'));
}
```

**修复方案 1**（如果有现成的 FormRequest）：
```php
use App\Http\Requests\ReserveGuideRequest;  // 或创建 ReserveCompanyRequest

public function reserveCompanyEdit(UserService $service, ReserveGuideRequest $request)
{
    $id = $request->post('id', 0) ?? 0;
    if ($id <= 0) {
        return $this->error(__('res.id_required'));
    }
    $service->reserveCompanyEdit($id, $request->validated());  // ✅
    return $this->success(__('res.success'));
}
```

**修复方案 2**（如果需要创建专用 FormRequest）：

创建文件 `app/Http/Requests/ReserveCompanyRequest.php`:
```php
<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ReserveCompanyRequest extends FormRequest
{
    public function authorize() { return true; }

    public function rules()
    {
        return [
            'id'          => 'required|integer|min:1',
            'content_id'  => 'required|integer|min:1',
            'reserve_time'=> 'required|date',
            'remarks'     => 'nullable|string|max:500',
            // 根据实际业务字段补充
        ];
    }
}
```

然后修改控制器：
```php
use App\Http\Requests\ReserveCompanyRequest;

public function reserveCompanyEdit(UserService $service, ReserveCompanyRequest $request)
{
    $id = $request->post('id', 0) ?? 0;
    if ($id <= 0) {
        return $this->error(__('res.id_required'));
    }
    $service->reserveCompanyEdit($id, $request->validated());
    return $this->success(__('res.success'));
}
```

---

## Issue 005 · `addContentReserve` 缺少请求验证

**文件**: `app/Http/Controllers/Api/CityController.php`

修复方式与 Issue 004 相同。创建 `app/Http/Requests/AddContentReserveRequest.php` 或使用现有的验证类：

```php
// 修改前
public function addContentReserve(CityService $service, Request $request)
{
    $content_id = $request->post('content_id', 0) ?? 0;
    if ($content_id <= 0) {
        return $this->error(__('res.id_required'));
    }
    $service->addContentReserve($request->all());  // ❌
    return $this->success(__('res.success'));
}

// 修改后
public function addContentReserve(CityService $service, AddContentReserveRequest $request)
{
    $content_id = $request->post('content_id', 0) ?? 0;
    if ($content_id <= 0) {
        return $this->error(__('res.id_required'));
    }
    $service->addContentReserve($request->validated());  // ✅
    return $this->success(__('res.success'));
}
```

---

## Issue 006 · 用户昵称未转义可能 XSS

**文件**: `app/helpers.php`

**当前代码**:
```php
function reserveMessage(string $user_nickname, int $status)
{
    switch ($status) {
        case 1:
            $text = "[$user_nickname] 提交了预约消息";
            break;
        // ... 其他 case
    }
    return $text;
}

function reserveUserMessage(string $str, int $status)
{
    switch ($status) {
        case 5:
            $text = "您的预约被拒绝:[$str]";
            break;
        // ...
    }
    return $text;
}
```

**修复方案**：对用户输入做 HTML 实体转义。

```php
function reserveMessage(string $user_nickname, int $status)
{
    $nickname = htmlspecialchars($user_nickname, ENT_QUOTES, 'UTF-8');
    switch ($status) {
        case 1:
            $text = "[{$nickname}] 提交了预约消息";
            break;
        case 2:
            $text = "您确认了 [{$nickname}] 提交的预约消息";
            break;
        case 3:
            $text = "[{$nickname}] 预约消息已完成";
            break;
        case 4:
            $text = "[{$nickname}] 取消了预约";
            break;
        case 5:
            $text = "您已拒绝 [{$nickname}] 的预约";
            break;
        default:
            $text = '';
            break;
    }
    return $text;
}

function reserveUserMessage(string $str, int $status)
{
    $escaped = htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
    switch ($status) {
        case 2:
            $text = "预约消息已确认";
            break;
        case 3:
            $text = "预约消息已完成";
            break;
        case 4:
            $text = "您取消了预约";
            break;
        case 5:
            $text = "您的预约被拒绝:[{$escaped}]";
            break;
        default:
            $text = '';
            break;
    }
    return $text;
}
```

---

## Issue 007 · `Authenticate` 中间件死代码

**文件**: `app/Http/Middleware/Authenticate.php`

**当前代码**:
```php
protected function redirectTo($request)
{
    if (! $request->expectsJson()) {
        return null;
        return route('login');  // ❌ 永远不会执行
    }
}
```

**修复方案**：根据项目需求选择：

**方案 A**（全部 API 返回 JSON 401 — 当前行为）：
```php
protected function redirectTo($request)
{
    // 所有未认证请求统一返回 JSON 401，由 Handler::unauthenticated() 处理
    return null;
}
```

**方案 B**（保留 Web 重定向 + API JSON 401）：
```php
protected function redirectTo($request)
{
    if (! $request->expectsJson()) {
        return route('login');
    }
    return null;
}
```

推荐方案 A，因为项目是 SPA + API 架构，所有前端请求都期望 JSON。

---

## Issue 008 · 邀请码无唯一性检查

**文件**: `app/helpers.php`

**当前代码**:
```php
function generateUniqueInviteCode(): string
{
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $code = '';
    for ($i = 0; $i < 7; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;  // ❌ 未检查唯一性
}
```

**修复方案**：循环重试直到生成唯一码。

```php
use App\Models\User;

function generateUniqueInviteCode(): string
{
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $maxAttempts = 10;

    for ($attempt = 0; $attempt < $maxAttempts; $attempt++) {
        $code = '';
        for ($i = 0; $i < 7; $i++) {
            $code .= $chars[random_int(0, strlen($chars) - 1)];
        }
        // 检查数据库中是否已存在
        if (!User::where('invite_code', $code)->exists()) {
            return $code;
        }
    }

    // 极端情况：10 次都碰撞，增加长度
    $code = '';
    for ($i = 0; $i < 10; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;
}
```

---

## Issue 009 · `compressImage` 禁用 SSL 验证

**文件**: `app/helpers.php`
**函数**: `compressImage`

**当前代码**:
```php
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_TIMEOUT => 15,
    CURLOPT_SSL_VERIFYPEER => false,  // ❌
]);
```

**修复方案**：启用 SSL 验证。

```php
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_TIMEOUT => 15,
    CURLOPT_SSL_VERIFYPEER => true,   // ✅ 启用 SSL 验证
    CURLOPT_SSL_VERIFYHOST => 2,      // ✅ 验证 hostname
]);
```

如果服务器缺少 CA 证书包，可以显式指定：
```php
curl_setopt($ch, CURLOPT_CAINFO, '/path/to/cacert.pem');
```

---

## Issue 010 · `saveData` 未检查 inviter_id 有效性

此修复与 Issue 003 合并处理（见上方 Issue 003 的完整修复代码）。关键改动：

```php
// 修改前
SystemIntegralConfig::saveData($user->inviter_id, $mark);

// 修改后
if ($user->inviter_id > 0) {
    SystemIntegralConfig::saveData($user->inviter_id, $mark);
}
```

---

## Issue 011 · VIP 过期时间基于旧时间累加

此修复与 Issue 003 合并处理。关键改动：

```php
// 修改前
if ($user->vip_expiration_time == 0) {
    $user->vip_expiration_time = time() + Vip::TimeTypeDay[$vip->time_type];
} else {
    $user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
}

// 修改后
$baseTime = max(time(), $user->vip_expiration_time);
$user->vip_expiration_time = $baseTime + Vip::TimeTypeDay[$vip->time_type];
```

---

## Issue 012 · VIP 到期 Job 对未知 time_type 默认 1 天

此修复与 Issue 003 合并处理。关键改动：

```php
// 修改前
$day = 1;
if ($vip->time_type == Vip::TimeTypeMonth) { $day = 30; }
if ($vip->time_type == Vip::TimeTypeYear)  { $day = 365; }

// 修改后（使用映射表，新增类型只需加条目）
$vipDayMap = [
    Vip::TimeTypeMonth => 30,
    Vip::TimeTypeYear  => 365,
    // 未来新增: Vip::TimeTypeQuarter => 90,
];
$day = $vipDayMap[$vip->time_type] ?? 30;  // 默认 30 天
```

---

## Issue 013 · `handleIsRead` N+1 查询

**文件**: `app/helpers.php`

调用方应使用批量版本 `handleIsReadBatch` 代替循环中的 `handleIsRead`。

由于调用方在加密的 Service 文件中，无法直接修改。如果你有 Service 源码：

```php
// 修改前（在循环中）
foreach ($messages as $message) {
    handleIsRead($message);  // ❌ 每条一个 UPDATE
}

// 修改后
$unreadIds = $messages->where('is_read', 0)->pluck('id')->toArray();
if (!empty($unreadIds)) {
    handleIsReadBatch(MessageModel::class, $unreadIds);  // ✅ 一条 UPDATE
}
```

---

## Issue 014 · Stripe webhook 缺少幂等性保护

此修复与 Issue 003 合并处理。关键是在处理开始前检查事件是否已处理：

```php
// 在 webhook 方法开始处
$eventId = $event->id;

// 检查是否已处理过（用缓存或数据库记录）
if (Cache::has('stripe_event_' . $eventId)) {
    return response()->json(['received' => true]);  // 幂等返回
}

try {
    // ... 处理逻辑 ...
    Cache::put('stripe_event_' . $eventId, true, now()->addDays(30));
} catch (\Throwable $th) {
    // ...
}
```

或者利用订单状态作为自然幂等屏障（已在 Issue 003 修复中包含）。

---

## Issue 015 · Vue 内部 API `__vue_app__`

**文件**: `frontend/js/api/provider.js`

**当前代码** (约第 82 行):
```javascript
if ((code === 401 || response.status === 401) && !this._redirecting) {
    this._redirecting = true;
    Storage.clearAuth();
    const app = document.querySelector('#app').__vue_app__;  // ❌ 内部 API
    if (app) {
        const router = app.config.globalProperties.$router;
        if (router) router.push('/login');
    }
}
```

**修复方案**：在 app.js 中将 router 挂载到 window 全局对象。

**步骤 1** — 修改 `frontend/js/app.js`（在创建 router 之后添加）：
```javascript
const router = VueRouter.createRouter({ ... });
// ...

const app = Vue.createApp({ ... });
app.use(router);
// ...
app.mount('#app');

// ✅ 暴露 router 给 ApiProvider 使用
window.__router = router;
```

**步骤 2** — 修改 `frontend/js/api/provider.js`：
```javascript
if ((code === 401 || response.status === 401) && !this._redirecting) {
    this._redirecting = true;
    Storage.clearAuth();
    // ✅ 使用暴露的全局 router
    if (window.__router) {
        window.__router.push('/login');
    } else {
        window.location.href = '/login';
    }
}
```

---

## Issue 016 · 邮箱无条件存储到 localStorage

**文件**: `frontend/js/stores/user.js`

**当前代码**:
```javascript
saveCredentials(email, password, remember) {
    Storage.account = email;  // ❌ 总是存储
    // ...
}
```

**修复方案**：仅在勾选"记住我"时存储邮箱。

```javascript
saveCredentials(email, remember) {
    if (remember) {
        Storage.account = email;
        Storage.rememberMe = true;
    } else {
        Storage.account = '';
        Storage.rememberMe = false;
    }
}
```

注意：此修复与 Issue 002 的修复合并后，函数签名变为 `(email, remember)`，不再接收 password 参数。

---

## Issue 017 · `redirectTo` 隐式 null 返回

此修复与 Issue 007 相同。参见上方 Issue 007 的修复方案。

---

## Issue 018 · `handleIsRead` 批量版本未被使用

与 Issue 013 相同。确认 Service 层使用 `handleIsReadBatch` 而非循环中的 `handleIsRead`。

---

## 修复优先级建议

| 优先级 | Issue | 原因 |
|--------|-------|------|
| 🔴 第一轮 | #002, #003 | 安全问题+资金损失风险 |
| 🟠 第二轮 | #004, #005, #006 | 输入验证+XSS |
| 🟡 第三轮 | #007, #008, #009, #010, #011 | 逻辑错误+安全 |
| 🟢 第四轮 | #012, #013, #014, #015, #016, #017, #018 | 边缘情况+维护性 |

> **注意**：Issue #003 的修复同时解决了 #010, #011, #012, #014，可以一次性处理。

---

# End of Fix Guide
