# LuMo Guide 深度 Bug 扫描报告

> **扫描日期**: 2026-07-07
> **扫描范围**: 前端 53 个 JS/CSS/HTML 文件 + 后端 9 个配置文件/路由/helpers
> **总计发现**: 62 个 Bug（4 严重 / 14 高危 / 29 中等 / 15 轻微）
> **用途**: 供开发同事逐一修复，每个 Bug 包含问题说明、复现条件、修复代码、预防措施

---

## 🔧 给 Claude Code 的修复指令

> **如果你是 Claude Code**，请按以下流程执行修复：

### 修复流程

1. **先读完这份文档**，了解全部 62 个 Bug 的分布和严重程度
2. **按附录 B 的优先级分批修复**：
   - 第一轮：修复 BUG-001 ~ BUG-004（4 个严重 Bug）
   - 第二轮：修复 BUG-005 ~ BUG-018（14 个高危 Bug）
   - 第三轮：修复 BUG-019 ~ BUG-047（29 个中等 Bug）
   - 第四轮：修复 BUG-048 ~ BUG-062（15 个轻微 Bug）
3. **每修复完一轮**，向用户汇报修复了哪些 Bug，让用户确认后再继续下一轮
4. **修复每个 Bug 时**：
   - 阅读对应文件的相关代码上下文（不要只看文档中摘录的片段）
   - 按照每个 Bug 下标注的"修复"方案进行修改
   - 如果修复方案与实际代码有出入，以实际代码为准，向用户说明差异
   - 修复后运行 `frontend/` 下的 HTML/CSS/JS 不需要编译，直接生效
   - 后端 PHP 文件修复后需要 `php artisan config:clear && php artisan cache:clear && php artisan route:clear`

### 注意事项

- **不要修改 `app/` 下被 swoole_loader 编码的文件**（这些文件无法读取，会显示乱码）。只能修改文档中标记为 ✅ plaintext 的文件
- **不要创建新的组件文件** — Vue 3 CDN 构建中，独立组件文件会导致组件渲染空白。所有模板必须内联在父组件中
- **不要修改 `public/css/` 和 `public/js/`** — 它们是 symlink，修改 `frontend/css/` 和 `frontend/js/` 即可
- 前端文件的修改无需构建/编译，刷新浏览器即可看到效果
- 每轮修复完成后，建议在提交前用浏览器验证关键页面（登录、首页、个人中心、城市详情）

### 关键文件路径

| 类型 | 路径 |
|------|------|
| 前端页面 | `frontend/js/pages/` |
| 前端核心 | `frontend/js/app.js`, `router.js`, `stores/`, `api/`, `utils/`, `i18n/` |
| 前端样式 | `frontend/css/variables.css`, `app.css`, `components.css` |
| SPA 外壳 | `frontend/index.html` |
| 后端路由 | `routes/api.php`, `routes/web.php` |
| 后端配置 | `config/app.php`, `config/admin.php` |
| 后端 helpers | `app/helpers.php` ✅ plaintext |

---

## 严重 Bug（应用崩溃 / 安全漏洞 / 数据丢失）

### BUG-001 · 用户密码明文存储到 localStorage

- **文件**: `frontend/js/stores/user.js` 第 147-157 行
- **严重程度**: ⚠️ 严重（安全漏洞）
- **影响范围**: 所有使用"记住我"登录的用户

**问题**: 选中"记住密码"登录后，用户密码以**明文**写入 `localStorage.setItem('password', password)`。任何同源 XSS 或浏览器扩展都能直接读取密码。

**代码**:
```javascript
// user.js saveCredentials 方法
if (remember) {
  Storage.account = email;
  Storage.password = password;  // ❌ 明文存储密码
  Storage.rememberMe = true;
}
```

**复现**:
1. 登录时勾选"记住我"
2. 打开浏览器 DevTools → Application → Local Storage → 查看 `password` 键
3. 密码以明文显示

**修复**:
```javascript
// 不要存密码，依赖 token 即可保持登录态
saveCredentials(email, remember) {
  if (remember) {
    Storage.account = email;
    Storage.rememberMe = true;
  }
  // 删除 Storage.password 的存储和读取逻辑
}
```

**预防**: OWASP 明确禁止 localStorage 存储敏感凭据。Token 已足够维持登录态，记住密码功能用 token 判断即可。

---

### BUG-002 · ProfilePage 模板多余的 `</div>` 导致页面完全白屏

- **文件**: `frontend/js/pages/mine/profile.js` 第 168 行
- **严重程度**: ⚠️ 严重（页面崩溃）
- **影响范围**: `/profile`（编辑资料页），用户从个人中心点击"編輯資料"进入

**问题**: 模板中 31 个 `</div>` 但只有 30 个 `<div`，多了一个结束标签。Vue 3 模板编译器直接报错，组件无法渲染，页面白屏。

**代码**:
```
// 第 167-168 行附近，模板末尾
          </div>  ← 正常的结束标签
        </div>    ← ❌ 多余的，没有对应的开始标签
```

**修复**: 数一下模板中 `<div` 和 `</div>` 的数量，删掉多余的那一个 `</div>`。

**预防**: 在编辑器中安装 Vue 模板高亮/校验插件（如 Vetur、Volar），标签不匹配会直接标红。

---

### BUG-003 · `'城市'` 翻译键被覆盖，Tab 导航栏显示错误

- **文件**: `frontend/js/i18n/en.js` 第 9 行 和 第 262 行
- **严重程度**: ⚠️ 严重（用户可见错误）
- **影响范围**: 英文语言下所有引用 `$t('城市')` 的地方

**问题**: JavaScript 对象中同一键 `'城市'` 出现了两次。第 9 行值为 `'Cities'`（Tab 标签用），第 262 行值为 `'City'`（搜索用）。后者覆盖前者，导致顶部导航栏的 Tab 标签显示 `"City"` 而不是 `"Cities"`。

**代码**:
```javascript
// 第 9 行 (Tabs 区域)
'城市': 'Cities',   // 被覆盖
// ...
// 第 262 行 (Search 区域)
'城市': 'City',     // ❌ 覆盖了上面的值
```

**修复**: 删除第 262 行的 `'城市': 'City'`（如果要区分场景用不同翻译，应使用不同的 key，如 `'tab.城市'` / `'search.城市'`）。

**预防**: 翻译文件应加 lint 校验，同一 JSON 对象内不允许重复 key。

---

### BUG-004 · `publish-city.js` 模板表达式中 `?.5` 语法错误

- **文件**: `frontend/js/pages/guide/publish-city.js` 第 49 行
- **严重程度**: ⚠️ 严重（模板编译失败）
- **影响范围**: 导游城市管理页面 `/guide/publish-city`

**问题**: 三元表达式写成了 `?.5:1`，可选链操作符 `?.` 后面不能直接跟数字，Vue 模板编译器会报语法错误。

**代码**:
```html
:style="{opacity:addingId===city.id?.5:1}"
<!--                               ↑↑ 应该是 ? 0.5 : 1 -->
```

**修复**:
```html
:style="{ opacity: addingId === city.id ? 0.5 : 1 }"
```

**预防**: 三元表达式始终在三段之间加空格（`a ? b : c`），否则 `?.` 与 `?` 极易混淆。

---

## 高危 Bug（功能不可用 / 逻辑错误）

### BUG-005 · 导游"标记为已完成"调用了"拒绝预约"的接口

- **文件**: `frontend/js/pages/guide/bookings.js` 第 311 行
- **严重程度**: 🔴 高危（功能错误）
- **影响范围**: 导游预约详情页的"标记为已完成"按钮

**问题**: `handleComplete` 方法（标记预约为已完成）调用了 `ApiUrl.guideRejectReserve`（拒绝预约接口），而不是完成预约的接口。

**代码**:
```javascript
async handleComplete() {
  if (!confirm('確定標記為已完成？')) return;
  this.submitting = true;
  try {
    const result = await ApiProvider.post(
      ApiUrl.guideRejectReserve,  // ❌ 这是拒绝接口，不是完成接口
      { id: this.detail.id, status: 3 }
    );
```

**修复**: 确认后端对应接口名后替换为正确的 URL。如果后端没有单独的"完成"接口，需要确认是否通过 `status: 3` 参数区分，若是则应创建一个对应命名的 URL 常量，不要复用 `guideRejectReserve`。

**预防**: API URL 命名应与业务动作一致。`xxxRejectReserve` 只能用于拒绝操作。

---

### BUG-006 · 搜索页读 `query.q` 但首页传的是 `query.keyword`，参数名不匹配

- **文件**: `frontend/js/pages/home/index.js` 第 494 行 和 `frontend/js/pages/search/index.js` 第 167 行
- **严重程度**: 🔴 高危（功能不可用）
- **影响范围**: 从首页搜索框输入关键词跳转到搜索页时

**问题**: 首页跳转时传参 `?keyword=xxx`，但搜索页读取的是 `this.$route.query.q`，始终为 `undefined`。从首页搜索后，搜索页不会自动填入关键词，也不会自动触发搜索。

**代码**:
```javascript
// home/index.js — 传的关键词参数名是 keyword
this.$router.push('/search?keyword=' + encodeURIComponent(keyword));

// search/index.js — 读的却是 q
const q = this.$route.query.q;  // ❌ undefined
```

**修复**: 统一参数名，两个文件保持一致。
```javascript
// search/index.js
const q = this.$route.query.keyword;  // 改成 keyword
```

**预防**: 路由参数名应定义为常量（如 `const SEARCH_QUERY_PARAM = 'keyword'`），两个文件引用同一个常量。

---

### BUG-007 · i18n 不可被 Vue 追踪，切换语言后 UI 不更新

- **文件**: `frontend/js/i18n/index.js` 第 17-18 行 和 `frontend/js/app.js` 第 131-134 行
- **严重程度**: 🔴 高危（功能不可用）
- **影响范围**: 所有页面的多语言切换

**问题**: `I18n` 是普通 JavaScript 对象（未用 `Vue.reactive()` 包裹），`_locale` 是普通字符串。Vue 模板在渲染时调用 `$t()`，但 Vue 无法追踪普通对象的属性变化，切换语言后**没有任何组件重新渲染**，用户看到的一直是旧语言，直到刷新页面。

**代码**:
```javascript
// i18n/index.js
const I18n = {           // ❌ 普通对象，不具备响应式
  _locale: 'zh-CN',
  t(key) { ... }
};

// app.js
I18n.init();             // ❌ 在 mount() 之后调用，第一帧渲染时 locale 还是默认 zh-CN
app.mount('#app');
```

**修复**: 两步修复。
```javascript
// 1. 用 Vue.reactive 包裹 I18n
const I18n = Vue.reactive({
  _locale: 'zh-CN',
  t(key) { ... },
  setLocale(locale) { this._locale = locale; }
});

// 2. init() 必须在 mount() 之前
I18n.init();
app.mount('#app');
```

**预防**: 任何影响渲染的状态对象必须用 Vue 响应式 API（`reactive` / `ref` / `computed`）包裹。初始化（init/start）必须在 mount 之前执行。

---

### BUG-008 · 管理后台路由前缀与 catch-all 正则不匹配

- **文件**: `config/admin.php` 第 70 行 和 `routes/web.php` 第 34 行
- **严重程度**: 🔴 高危（管理后台不可访问）
- **影响范围**: 当 `.env` 未设置 `ADMIN_ROUTE_PREFIX` 时，管理后台无法访问

**问题**: `config/admin.php` 默认前缀是 `admin`，但 SPA catch-all 的正则只排除了 `manage`，没排除 `admin`。如果 `.env` 中没有设置 `ADMIN_ROUTE_PREFIX=manage`，所有 `/admin/*` 路径会被 SPA 捕获而不是路由到 Dcat Admin。

**代码**:
```php
// config/admin.php
'prefix' => env('ADMIN_ROUTE_PREFIX', 'admin'),  // 默认是 admin

// routes/web.php
->where('any', '^(?!api|manage)[^.]*$');  // ❌ 只排除了 manage，没排除 admin
```

**修复**: 从配置读取，而不是硬编码。
```php
// routes/web.php
$adminPrefix = config('admin.route.prefix', 'admin');
Route::get('/{any}', fn() => ...)
    ->where('any', '^(?!api|' . $adminPrefix . ')[^.]*$');
```

**预防**: 正则表达式中的动态值必须从配置读取，不能硬编码。

---

### BUG-009 · `api.php` 中 `/user` 端点用了 `auth:sanctum` 而其他路由都是 `auth:api`

- **文件**: `routes/api.php` 第 28 行
- **严重程度**: 🔴 高危（认证失败）
- **影响范围**: 使用 JWT Token 的客户端调用 `/api/user` 端点

**问题**: 项目使用 JWT（`tymon/jwt-auth`），其他所有受保护路由用 `auth:api` 中间件。唯独 `/user` 端点用了 `auth:sanctum`。Sanctum 守卫不认识 JWT Token，导致该端点对 API 客户端返回 401。

**代码**:
```php
// ❌ auth:sanctum 和 JWT 不兼容
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
```

**修复**:
```php
Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});
```

**预防**: 同一个路由文件内认证中间件必须统一。添加 CI 检查：一个路由组内不允许混用多种 auth guard。

---

### BUG-010 · `systemConfig()` 的 falsy 检查导致合法值 `'0'` / `''` 每次回退查询数据库

- **文件**: `app/helpers.php` 第 82-93 行
- **严重程度**: 🔴 高危（逻辑错误 + Redis 故障无兜底）
- **影响范围**: 所有调用 `systemConfig()` 的地方

**问题**: 两个错误叠加：
1. 用 `!$res` 判断 Redis 是否命中，但当配置值恰好是 `'0'` 或空字符串时，`!$res` 也为 true，导致每次调用都回退查数据库，Redis 缓存形同虚设
2. `Redis::hGet()` 没有 try/catch，Redis 不可用时直接抛异常

**代码**:
```php
function systemConfig(string $mark) {
    $res = Redis::hGet('system_config', $mark);
    if (!$res) {  // ❌ 值为 '0' 或 '' 时也会进这个分支
        // 每次加载全表 ...
    }
    return $res;
}
```

**修复**:
```php
function systemConfig(string $mark) {
    try {
        if (Redis::hExists('system_config', $mark)) {
            return Redis::hGet('system_config', $mark);
        }
    } catch (\Exception $e) {
        // Redis 不可用，降级到数据库
    }
    $config = SystemConfig::where('mark', $mark)->first(['value']);
    if ($config) {
        try { Redis::hSet('system_config', $mark, $config->value); } catch (\Exception $e) {}
        return $config->value;
    }
    return null;
}
```

**预防**: 对 Redis 操作始终用 try/catch 包裹。判断缓存命中用 `hExists()` 而非依赖返回值的 truthiness。

---

### BUG-011 · `guide/certify.js` 车辆照片上传后提交时被丢弃

- **文件**: `frontend/js/pages/guide/certify.js` 第 300-302 行、第 361-369 行
- **严重程度**: 🔴 高危（功能数据丢失）
- **影响范围**: 导游认证流程中的车辆照片上传

**问题**: 用户选择照片后只保存了 `URL.createObjectURL(file)` 生成的 blob URL，`File` 对象本身被丢弃了。提交表单时，代码检测到 `pic.startsWith('blob:')` 就替换为空字符串，然后被 `.filter(Boolean)` 过滤掉。**新上传的车辆照片全部丢失，只有服务器上已有的旧照片能被提交。**

**代码**:
```javascript
// 上传时 — 只保存了 blob URL，丢了 File 对象
onCarPicAdd(e) {
  const file = e.target.files?.[0];
  if (file) this.carPics.push(URL.createObjectURL(file));  // ❌ File 对象丢失
}

// 提交时 — blob URL 被替换为空
for (const pic of this.carPics) {
  if (pic.startsWith('blob:')) {
    carUrls.push('');  // ❌ 新上传的照片全变成空字符串
  }
}
const validCarUrls = carUrls.filter(Boolean);  // ❌ 被过滤掉
```

**修复**: 同时保存 File 对象和 blob URL，提交时先上传 File 拿到服务器 URL。
```javascript
onCarPicAdd(e) {
  const file = e.target.files?.[0];
  if (file) {
    this.carPics.push({ file, preview: URL.createObjectURL(file) });
  }
}
// 提交时遍历 carPics，对 file 类型的逐个 upload 拿到 url
```

**预防**: `URL.createObjectURL()` 只生成临时预览 URL，不能代替真实文件上传。代码审查时重点检查：文件选择器→提交的完整链路中 File 对象有没有丢失。

---

### BUG-012 · `merchant/entry.js` 店铺照片同样的问题

- **文件**: `frontend/js/pages/merchant/entry.js` 第 218-221 行、第 263 行
- **严重程度**: 🔴 高危（功能数据丢失）
- **影响范围**: 商家入驻流程中的店铺照片上传

**问题**: 与 BUG-011 完全相同的模式，blob URL 被保存但 File 对象丢失，提交时新照片被丢弃。

**修复**: 同上，同时保存 `{ file, preview }`，提交时先上传 file 拿到 URL。

**预防**: 与 BUG-011 相同。

---

### BUG-013 · `common/details.js` 关注/取消关注按钮始终调用同一个接口

- **文件**: `frontend/js/pages/common/details.js` 第 256 行
- **严重程度**: 🔴 高危（功能错误）
- **影响范围**: 通用详情页（CommonDetailPage）的关注/取消关注

**问题**: `toggleFollow` 的 if/else 两个分支都用的是 `ApiUrl.followShop`，取消关注时没有调用 unfollow 接口。

**代码**:
```javascript
async toggleFollow() {
  // ...
  const ep = this.item.is_follow ? ApiUrl.followShop : ApiUrl.followShop;
  //                               ↑ 和右边一样！            ↑
```

**修复**: 参考 `GuideDetailPage` 的正确写法：
```javascript
const ep = this.item.is_follow ? ApiUrl.unfollowShop : ApiUrl.followShop;
```

**预防**: if/else 赋值时，两边的值必须不同。可以用 ESLint no-constant-binary-expression 规则捕获。

---

### BUG-014 · `mine/extra.js` 取关用户调用了 "取消关注店铺" 的接口

- **文件**: `frontend/js/pages/mine/extra.js` 第 339 行
- **严重程度**: 🔴 高危（功能错误）
- **影响范围**: "我的关注" 页面取消关注某个用户

**问题**: 取消关注**用户**调用了 `ApiUrl.messageUnFollowShop`（取消关注**店铺**）。

**代码**:
```javascript
const res = await ApiProvider.post(
  ApiUrl.messageUnFollowShop,  // ❌ 这是取关店铺的接口
  { user_id: item.user_id || item.id }
);
```

**修复**: 确认后端提供的用户取关接口，替换过来。

**预防**: API URL 常量名应与业务对象一致。`xxxShop` 只能用于店铺相关操作。

---

### BUG-015 · `mine/extra.js` 验证码倒计时定时器未清除

- **文件**: `frontend/js/pages/mine/extra.js` 第 140 行（ModifyPhonePage）
- **严重程度**: 🔴 高危（内存泄漏）
- **影响范围**: 修改手机号页面，用户在倒计时期间离开页面

**问题**: `setInterval` 返回的句柄没有保存到组件实例上，也没有 `beforeUnmount` 来清除。用户在倒计时未结束时切换到其他页面，定时器继续运行，持续尝试更新已销毁组件的 `this.countdown`。

**代码**:
```javascript
// ❌ t 是局部变量，离开页面后无法清除
const t = setInterval(() => {
  this.countdown--;
  if (this.countdown <= 0) clearInterval(t);
}, 1000);
```

**修复**:
```javascript
// 挂到实例上
this._timer = setInterval(() => {
  this.countdown--;
  if (this.countdown <= 0) { clearInterval(this._timer); this._timer = null; }
}, 1000);

// 在组件中新增
beforeUnmount() {
  if (this._timer) { clearInterval(this._timer); this._timer = null; }
}
```

**预防**: 所有 `setInterval` / `setTimeout` 必须有对应的 `beforeUnmount` 清理代码。ESLint 规则 `vue/no-set-interval-not-cleared` 可捕获。

---

### BUG-016 · `vip/index.js` 支付后立即检查状态永远显示未支付

- **文件**: `frontend/js/pages/vip/index.js` 第 147-156 行
- **严重程度**: 🔴 高危（功能逻辑错误）
- **影响范围**: VIP 订阅支付流程

**问题**: `window.open(pay_url)` 打开支付页面后，**紧接着**就调 `vipPayStatus` 检查支付状态。用户还没完成支付，这个检查永远返回"未支付"。

**代码**:
```javascript
if (res.success && res.data?.pay_url) {
  window.open(res.data.pay_url, '_blank');
}
// ❌ 立即检查，用户还没付钱
const statusRes = await ApiProvider.get(ApiUrl.vipPayStatus, { id: planId });
if (statusRes.success && Number(statusRes.data?.status) === 1) {
  alert('訂閱成功！');  // 永远不会执行
}
```

**修复**: 改为轮询模式，每隔几秒检查一次，设置超时。
```javascript
window.open(res.data.pay_url, '_blank');
let attempts = 0;
const pollTimer = setInterval(async () => {
  const statusRes = await ApiProvider.get(ApiUrl.vipPayStatus, { id: planId });
  if (statusRes.success && Number(statusRes.data?.status) === 1) {
    clearInterval(pollTimer);
    alert('訂閱成功！');
    this.loadUserInfo();
    this.$router.push('/profile');
  }
  if (++attempts > 60) clearInterval(pollTimer); // 最多等 5 分钟
}, 5000);
```

**预防**: 涉及用户跳转到外部页面完成操作的流程，不能用"立即检查"模式，必须是"轮询"或"回调"模式。

---

### BUG-017 · `booking/form.js` 加载店铺信息用错了接口

- **文件**: `frontend/js/pages/booking/form.js` 第 215 行
- **严重程度**: 🔴 高危（功能错误）
- **影响范围**: 预约商家时加载商家信息

**问题**: 路由参数 `id` 是内容项 ID（content item ID），但加载时调了 `ApiUrl.companyInfo`（需要 company ID）。如果 content ID 和 company ID 不同值，加载的是错误的数据。

**代码**:
```javascript
const result = await ApiProvider.get(ApiUrl.companyInfo, { id: Number(id) });
// ❌ id 可能是 content ID，不是 company ID
```

**修复**: 确认路由传参的来源（是哪里 push 过来的，传的到底是什么 ID），使用对应的正确接口。

**预防**: 接口参数类型和路由参数类型要在命名上对齐（`contentId` vs `companyId` 而不是笼统的 `id`）。

---

### BUG-018 · `generateUniqueInviteCode()` 精度溢出和碰撞风险

- **文件**: `app/helpers.php` 第 52-71 行
- **严重程度**: 🔴 高危（数据正确性）
- **影响范围**: 所有用户的邀请码生成

**问题**: 
1. `base_convert()` 在 PHP 中内部使用浮点数，超过 `PHP_INT_MAX` 的数值精度丢失，转换结果错误
2. 取 `substr($inviteCode, -7)` 取的是低 7 位（熵最低的部分），碰撞概率高于预期

**修复**:
```php
function generateUniqueInviteCode(): string {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 排除易混淆字符
    $code = '';
    for ($i = 0; $i < 7; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;
}
```

**预防**: 不要用 `base_convert()` 处理接近或超过 `PHP_INT_MAX` 的数值。唯一码用 `random_int()` 或 UUID 更安全。

---

## 中等 Bug（UI 问题 / 边缘情况 / 体验缺陷）

### BUG-019 · `evaluation.js` 同一属性名同时出现在 data 和 computed 中

- **文件**: `frontend/js/pages/evaluation.js` 第 77-79 行（computed）、第 83 行（data）
- **严重程度**: 🟡 中等（可能导致 Vue 警告或行为不确定）

**问题**: `tPlaceholder` 在 `data()` 中定义为 `''`，又在 `computed` 中定义为一个函数。Vue 3 不允许同名，可能导致警告或其中一个被覆盖。

**修复**: 删除 data 中的 `tPlaceholder: ''`，只保留 computed 属性。

**预防**: Vue 组件中 data 和 computed 属性名必须互斥。

---

### BUG-020 · `integral/index.js` 初始加载时 `fetchGoods` 被调用两次（竞态条件）

- **文件**: `frontend/js/pages/integral/index.js` 第 102-107 行、第 127 行
- **严重程度**: 🟡 中等（数据可能不一致）

**问题**: `fetchCategories` 成功后：
1. 第 102 行设置 `activeCategory`，触发第 127 行的 `watch` 调用 `fetchGoods()`
2. 第 107 行又直接调用 `fetchGoods()`
两次请求并发，后返回的结果覆盖先返回的，如果网络时序反常，用户看到的数据可能不是最新选择的分类的结果。

**修复**: 删除第 107 行的直接调用，只依赖 watch 触发。
```javascript
// 删除 fetchCategories 中的 fetchGoods() 调用
// 只保留 watch 来响应 activeCategory 变化
```

**预防**: 异步操作的状态变更（如切换分类）应只有**一个**触发入口，不要既在用户操作中调用又在 watch 中调用。

---

### BUG-021 · `home/index.js` 搜索框的搜索结果浮层缺少定位父容器

- **文件**: `frontend/js/pages/home/index.js` 第 51-61 行
- **严重程度**: 🟡 中等（布局错位）

**问题**: 搜索结果浮层用 `position: absolute`，但 `.search-bar` 没有设 `position: relative`。浮层会相对于更上层的定位祖先定位，可能出现在错误的位置。

**修复**: 给 `.search-bar` 添加 `position: relative`。

---

### BUG-022 · `city/detail.js` banner 轮播用数组索引作 `:key`

- **文件**: `frontend/js/pages/city/detail.js` 第 14 行
- **严重程度**: 🟡 中等（渲染错误风险）

**问题**: `v-for="(pic, idx) in banners" :key="idx"`。当 banners 数组变化时（如切换城市），Vue 可能复用旧 DOM 显示新图片，导致短暂显示旧图。

**修复**:
```html
:key="'banner-' + idx + '-' + pic.substring(pic.lastIndexOf('/'))"
```

**预防**: v-for 的 `:key` 使用数据本身的唯一标识，不要用数组索引。

---

### BUG-023 · `MinePage` 在 userInfo 为空时缺少 loading 状态

- **文件**: `frontend/js/pages/mine/index.js` 第 19 行
- **严重程度**: 🟡 中等（体验问题）

**问题**: 登录态模板用 `v-if="UserStore.isLogin && profile"` 包裹，`profile` 返回 `UserStore.userInfo`。API 数据到达前 `userInfo` 为 null，页面显示空白，没有 loading 动画。对比 ProfilePage 是有 loading spinner 的。

**修复**: 用一个三态判断：null→loading 动画，数据到达→正常内容，网络错误→错误提示。

---

### BUG-024 · `MinePage` 调用 `UserStore.getProfile()` 但这个方法可能不存在

- **文件**: `frontend/js/pages/mine/index.js` 第 163 行
- **严重程度**: 🟡 中等（可能抛 TypeError）

**问题**: MinePage 直接调用 `UserStore.getProfile()`，但 ProfilePage 用的是 `UserStore.fetchProfile?.() || UserStore.init?.()`（可选链）。如果 `getProfile` 不在 UserStore 上，MinePage 会抛 TypeError。

**修复**: 统一用 `UserStore.fetchProfile?.() || UserStore.init?.()`。

---

### BUG-025 · `MinePage` 中 `t()` / `$t()` 混用

- **文件**: `frontend/js/pages/mine/index.js` 第 12、14、33、34 行
- **严重程度**: 🟡 中等（维护隐患）

**问题**: 模板前面用 `t('...')`（组件 methods 里定义的），后面用 `$t('...')`（全局 globalProperties）。两者功能相同但不一致。

**修复**: 统一用 `$t()`，删除 methods 中的 `t` 方法。

---

### BUG-026 · `app-topbar` 未隐藏忘记密码/验证码等认证页面

- **文件**: `frontend/js/app.js` 第 74-77 行
- **严重程度**: 🟡 中等（UI 异常）

**问题**: `showTopBar` 的 hideOn 列表只有 `['/welcome', '/login', '/register']`，没有 `/forget-password`、`/verify-code`、`/password-input`。用户在忘记密码流程中会看到顶部导航栏（首页/城市/资讯等 Tab），与认证页面风格不搭。

**修复**:
```javascript
const hideOn = ['/welcome', '/login', '/register', '/forget-password', '/verify-code', '/password-input'];
```

---

### BUG-027 · `router.afterEach` 设置 activeTab 到了错误的组件实例

- **文件**: `frontend/js/router.js` 第 143-152 行
- **严重程度**: 🟡 中等（功能不生效）

**问题**: `afterEach` 中通过 `app._instance.proxy` 取到的是根组件实例，而 `activeTab` 是 `AppShell` 子组件的数据。设到根组件上不会影响 AppShell 的渲染。好在 AppShell 自己有 `watch $route` 做同样的事，所以目前没有可见 bug，但这段死代码是隐患。

**修复**: 删除这段 afterEach（AppShell 的 watch 已经在正确的位置处理了）。

---

### BUG-028 · `provider.js` 中多重 401 竞态条件

- **文件**: `frontend/js/api/provider.js` 第 71-79 行
- **严重程度**: 🟡 中等（边缘情况）

**问题**: 多个并行 API 请求同时返回 401 时，每个都会执行 `Storage.logout()` + `router.push('/login')`，重复操作可能导致状态异常。

**修复**: 添加防重入锁。
```javascript
if ((code === 401 || response.status === 401) && !this._redirecting) {
  this._redirecting = true;
  Storage.logout();
  router.push('/login');
}
```

---

### BUG-029 · `provider.js` 中 `parseInt(json.code)` 返回 NaN 时没有被处理

- **文件**: `frontend/js/api/provider.js` 第 66 行
- **严重程度**: 🟡 中等（返回数据格式错误）

**问题**: 如果后端返回 `code: "success"`（字符串），`parseInt("success")` 返回 `NaN`。随后 `NaN === 401` 为 false，但 `NaN === 200` 也为 false，`success` 为 false 但 code 为 NaN，调用方无法正确处理。

**修复**:
```javascript
const parsed = parseInt(json.code, 10);
const code = !isNaN(parsed) ? parsed : response.status;
```

---

### BUG-030 · `helpers.js` `showToast()` 多次快速调用时 toast 堆叠

- **文件**: `frontend/js/utils/helpers.js` 第 76-84 行
- **严重程度**: 🟡 中等（UI 混乱）

**问题**: 快速多次调用 `showToast()` 时，每个都创建一个新 DOM 元素，全部叠在一起显示。

**修复**:
```javascript
function showToast(msg, duration = 2000) {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();  // 先移除旧的
  const el = document.createElement('div');
  el.className = 'toast';
  el.textContent = msg;
  document.body.appendChild(el);
  setTimeout(() => el.remove(), duration);
}
```

---

### BUG-031 · `helpers.js` `timeAgo()` 对无效日期返回 `NaN年前`

- **文件**: `frontend/js/utils/helpers.js` 第 10-22 行
- **严重程度**: 🟡 中等（UI 显示异常）

**问题**: 如果传入的 time 字符串无法解析（如 `"2024-13-01"`），`new Date(...)` 产生 Invalid Date，`getTime()` 返回 NaN，最终显示 `NaN年前`。

**修复**: 在日期构造后加校验。
```javascript
const date = typeof time === 'string' ? new Date(time.replace(/-/g, '/')) : new Date(time);
if (isNaN(date.getTime())) return '';
```

---

### BUG-032 · CSS 变量 `--color-text-primary` 未定义，引用处回退为黑色

- **文件**: `frontend/css/components.css` 第 2839、2857 行
- **严重程度**: 🟡 中等（视觉不一致）

**问题**: 两处使用了 `var(--color-text-primary)`，但 `variables.css` 中定义的是 `--color-primary-text`（顺序不同）。浏览器回退为默认黑色 `#000`，而不是设计系统中的 `#162539`。

**修复**: 改为 `var(--color-primary-text)`。

**预防**: CSS 变量名必须在 variables.css 中能查到。加 lint 规则校验所有 `var(--xxx)` 中的变量名是否已定义。

---

### BUG-033 · `app-header.js` 返回按钮可能退出 SPA

- **文件**: `frontend/js/components/app-header.js` 第 26 行
- **严重程度**: 🟡 中等（用户体验）

**问题**: `window.history.back()` 在无应用内历史时（用户从外部链接直接进入），会导航到浏览器前一个页面（可能是外部网站）。

**修复**:
```javascript
goBack() {
  if (window.history.length > 1) {
    this.$router.back();
  } else {
    this.$router.push('/home');
  }
}
```

---

### BUG-034 · `storage.js` `clearAll()` 调用了 `localStorage.clear()` 影响同源其他应用

- **文件**: `frontend/js/utils/storage.js` 第 55-57 行
- **严重程度**: 🟡 中等（数据安全）

**问题**: `localStorage.clear()` 清空整个 origin 下所有 key，如果同一个域名下有其他应用部署，会误删其他应用的数据。

**修复**: 只删除本项目用到的 key。
```javascript
clearAll() {
  this.logout();
  ['locale', 'account', 'rememberMe', 'cityAreaMap'].forEach(k => localStorage.removeItem(k));
}
```

---

### BUG-035 · `app-nav.js` 表情图标用 `v-html` 渲染

- **文件**: `frontend/js/components/app-nav.js` 第 16 行
- **严重程度**: 🟡 中等（XSS 风险）

**问题**: 图标是纯文本 emoji（🏠、🏙️），用 `v-html` 渲染没有必要，且如果将来图标数据来自后端，存在 XSS 注入风险。

**修复**: 改为文本插值 `{{ currentTab === tab.key ? tab.iconActive : tab.icon }}`。

**预防**: 除非内容确实包含 HTML，否则永远不用 `v-html`。用 `{{ }}` 文本插值。

---

### BUG-036 · `provider.js` 中 no timeout — fetch 可能无限等待

- **文件**: `frontend/js/api/provider.js` 第 44-97 行
- **严重程度**: 🟡 中等（用户体验）

**问题**: fetch 没有设置超时时间，网络慢时页面永远卡在 loading 状态。

**修复**: 使用 AbortController 加 15 秒超时。
```javascript
const controller = new AbortController();
const timeout = setTimeout(() => controller.abort(), 15000);
try {
  const response = await fetch(url, { ...opts, signal: controller.signal });
  // ...
} finally {
  clearTimeout(timeout);
}
```

---

### BUG-037 · `search/index.js` 防抖定时器未在组件销毁时清除

- **文件**: `frontend/js/pages/search/index.js` 第 128 行
- **严重程度**: 🟡 中等（潜在内存泄漏 + 控制台错误）

**问题**: 搜索输入框防抖用了 `setTimeout` 但组件没有 `beforeUnmount` 来清理。用户输入后立即跳转其他页面，定时器到期后会调用已销毁组件的方法。

**修复**: 添加 `beforeUnmount` 清除 `this.searchTimer`。

---

### BUG-038 · `city/detail.js` `cityInfo` API 没有错误处理

- **文件**: `frontend/js/pages/city/detail.js` 第 237 行
- **严重程度**: 🟡 中等（页面加载失败无提示）

**问题**: `cityInfo` 的 API 调用没有 `.catch()`，如果抛出异常会变成未处理的 Promise rejection。

**修复**: 给 `cityInfo` 调用也加上 `.catch()` 或在 `loadCity` 外层加 try/catch。

---

### BUG-039 · `helpers.php` `compressImage()` 强制输出 JPEG，销毁 PNG 透明和 GIF 动画

- **文件**: `app/helpers.php` 第 427 行
- **严重程度**: 🟡 中等（图片处理）

**问题**: 无论源图是什么格式，都用 `imagejpeg()` 输出，PNG 的透明通道变成黑/白背景，GIF 动图变单帧。

**修复**: 根据源图 MIME 类型选择输出格式。
```php
if ($info['mime'] == 'image/png') {
    imagesavealpha($image, true);
    imagepng($image, $destination_url, round(9 - $quality / 11));
} elseif ($info['mime'] == 'image/gif') {
    imagegif($image, $destination_url);
} else {
    imagejpeg($image, $destination_url, $quality);
}
```

---

### BUG-040 · `helpers.php` `compressImage()` 在远程 URL 上依赖 `allow_url_fopen`

- **文件**: `app/helpers.php` 第 400 行
- **严重程度**: 🟡 中等（生产环境可能失败）

**问题**: `getimagesize($source_url)` 和 `imagecreatefrom*()` 在远程 URL 上依赖 `allow_url_fopen` 配置，很多生产环境禁用此选项，图片处理静默失败。

**修复**: 先检测 URL 是否是远程的，远程文件先通过 cURL 下载到临时路径再处理。

---

### BUG-041 · `handleIsRead()` 在循环中调用产生 N+1 查询问题

- **文件**: `app/helpers.php` 第 297-303 行
- **严重程度**: 🟡 中等（性能）

**问题**: `handleIsRead()` 每次调用执行一次 `UPDATE`，如果在批量列表循环中调用会产生 N+1 问题。

**修复**: 提供批量版本 `handleIsReadBatch($modelClass, $ids)`，一次性 `UPDATE ... WHERE id IN (...)`。

---

### BUG-042 · `api.php` webhook 路由用了 `Route::any` 而非 `Route::post`

- **文件**: `routes/api.php` 第 61 行
- **严重程度**: 🟡 中等（安全 + 规范）

**问题**: Stripe webhook 端点用了 `Route::any`，接受所有 HTTP 方法。GET 请求也能触发支付处理逻辑。

**修复**: 改为 `Route::post('webhook', ...)`。

**预防**: Webhook 只应接受 POST。永远不用 `Route::any`。

---

### BUG-043 · `web.php` 协议页 `systemConfig()` 返回 false 时未处理

- **文件**: `routes/web.php` 第 24-25 行
- **严重程度**: 🟡 中等（体验）

**问题**: `/protocol/{type}` 路由在 `systemConfig($type)` 返回 false 时（协议类型不存在），仍然传给 Blade 模板，页面显示空白而不是 404。

**修复**:
```php
$content = systemConfig($type);
if (!$content) abort(404);
return view('protocol', ['content' => $content]);
```

---

### BUG-044 · `config/app.php` 默认 APP_NAME 为 'Laravel'

- **文件**: `config/app.php` 第 18 行
- **严重程度**: 🟡 中等（品牌显示）

**问题**: 如果 `.env` 漏配 `APP_NAME`，邮件、通知等处显示的是 "Laravel" 而非 "LuMo Guide"。

**修复**: 将默认值改为 `'LuMo Guide'`。

---

### BUG-045 · body 背景色硬编码 `#7C5CFF` 且非 CSS 变量

- **文件**: `frontend/css/app.css` 第 22 行 和 `frontend/css/components.css` 第 18 行
- **严重程度**: 🟡 中等（维护性）

**问题**: `#7C5CFF` 出现在两处，且不是 CSS 变量。品牌色如果调整（如变成 primary 的 `#666FFF`），这两处需要手动更新且容易遗漏。

**修复**: 创建 `--color-topbar-bg: #7C5CFF` 变量，两处引用 `var(--color-topbar-bg)`。

---

### BUG-046 · CSS 非标准 font-weight 值 530、650

- **文件**: `frontend/css/app.css` 第 260 行（650）、`frontend/css/components.css` 第 363/427/479 行（530）、第 836/1136 行（650）
- **严重程度**: 🟡 中等（跨浏览器渲染不一致）

**问题**: CSS 标准 font-weight 是 100 的倍数（100-900）。530 在不同浏览器会向下取整为 500 或向上为 600，650 可能在 600 和 700 之间摇摆，视觉效果不一致。

**修复**: 530 → `500` 或 `600`；650 → `600` 或 `700`。

---

### BUG-047 · 禁用按钮 `btn-primary:disabled` 对比度极低

- **文件**: `frontend/css/components.css` 第 1868 行
- **严重程度**: 🟡 中等（无障碍）

**问题**: 白色文字 `#fff` 在 `#C4C6E8` 背景上的对比度约 1.35:1，WCAG AA 要求 4.5:1。按钮上的文字几乎看不见。

**修复**: 改为 `opacity: 0.5`（与 `.ds-btn-primary:disabled` 一致）。

---

## 轻微 Bug（代码质量 / 维护性 / 最佳实践）

### BUG-048 · `--radius-sm` 和 `--radius-md` 值相同

- **文件**: `frontend/css/variables.css` 第 73-74 行
- **严重程度**: 🟢 轻微

**问题**: 两个变量都是 `12px`，sm 和 md 没有区分度。

**修复**: 给 `--radius-md` 设为 16px 或合并两个变量。

---

### BUG-049 · z-index 值散落在各处，缺少集中管理

- **文件**: `frontend/css/components.css` → app-topbar (100), ds-header (100), toast (9999), photo-viewer (9999)
- **严重程度**: 🟢 轻微

**问题**: z-index 硬编码，toast 和 photo-viewer 都是 9999，可能导致堆叠不确定。

**修复**: 在 `variables.css` 中定义 z-index 变量体系。
```css
--z-topbar: 100;
--z-overlay: 1000;
--z-toast: 9998;
--z-photo-viewer: 9999;
```

---

### BUG-050 · i18n `zh-CN.js` 重复键 `'城市'` 和 `'內容'`

- **文件**: `frontend/js/i18n/zh-CN.js` 第 9/263 行、第 232/264 行
- **严重程度**: 🟢 轻微

**问题**: 对象字面量中同一键出现两次，后者覆盖前者。目前值相同所以没问题，但维护时容易出错。

**修复**: 删除 Search 区域的重复定义。

---

### BUG-051 · i18n `zh-TW.js` 搜索区域缺少 `'城市'` 和 `'內容'` 键

- **文件**: `frontend/js/i18n/zh-TW.js` 搜索区域
- **严重程度**: 🟢 轻微

**问题**: 与其他两个语言文件（zh-CN、en）的键集不一致。

**修复**: 补上缺失的键。

---

### BUG-052 · i18n 所有语言文件中 `'巳拒絕'` 应为 `'已拒絕'`

- **文件**: `frontend/js/i18n/zh-CN.js`、`zh-TW.js`、`en.js`
- **严重程度**: 🟢 轻微

**问题**: `巳`（sì，地支第六位）是错别字，应为 `已`（yǐ，已经）。如果后端/前端代码发送 `'已拒絕'`（正确的字），`I18n.t('已拒絕')` 会找不到这个 key，显示原始的 key 文本。

**修复**: 三个语言文件中将 `'巳拒絕'` 改为 `'已拒絕'`。同时检查后端是否有代码发送这个 key。

---

### BUG-053 · i18n en.js `'內容'` 重复键

- **文件**: `frontend/js/i18n/en.js` 第 230、263 行
- **严重程度**: 🟢 轻微

**修复**: 删除 Search 区域的重复。

---

### BUG-054 · `app.js` `$t` 在 methods 和 globalProperties 中重复定义

- **文件**: `frontend/js/app.js` 第 122、128 行
- **严重程度**: 🟢 轻微

**问题**: 同样的函数定义了两次，维护时可能只改一处导致行为不一致。

**修复**: 只保留 `globalProperties`，删除 methods 中的 `$t`。

---

### BUG-055 · `router.js` 依赖 Vue 内部 API `__vue_app__` / `_instance` / `proxy`

- **文件**: `frontend/js/router.js` 第 146-149 行
- **严重程度**: 🟢 轻微（但脆弱）

**问题**: 这些是 Vue 3 的私有属性，非公开 API，未来 Vue 版本可能改名或删除。

**修复**: 如果确实需要在 router 中获取 app 实例，使用 `router.app`（Vue Router 的公开 API）。

---

### BUG-056 · `profile.js` `identityLabel` 中 `this.$t` 多余的 null 检查

- **文件**: `frontend/js/pages/mine/profile.js` 第 186-189 行
- **严重程度**: 🟢 轻微

**问题**: `this.$t ? this.$t('導遊') : '導遊'` — 如果 `$t` 都没注册，整个应用早就挂了，这个 null 检查没有意义。

**修复**: 直接 `this.$t('導遊')`。

---

### BUG-057 · `guide/certify.js` blob URL 未释放产生内存泄漏

- **文件**: `frontend/js/pages/guide/certify.js` 第 297、302、310-311 行
- **严重程度**: 🟢 轻微（功能正常但浪费内存）

**问题**: `URL.createObjectURL()` 创建了 blob URL 但从未调用 `URL.revokeObjectURL()` 释放。用户多次更换照片后 blob URL 累积。

**修复**: 在 `beforeUnmount` 中释放所有 blob URL，以及在替换照片时先释放旧的。

---

### BUG-058 · `certify.js` 中 `form.language` 和 `form.industry_type` 是死代码

- **文件**: `frontend/js/pages/guide/certify.js` 第 237 行
- **严重程度**: 🟢 轻微

**问题**: `form` 对象中初始化了 `language: []` 和 `industry_type: []`，但提交时用的是 `this.selectedLangs` 和 `this.selectedTypes`，从来不读 `form` 里的这两个字段。

**修复**: 删除 form 中的死字段。

---

### BUG-059 · `MinePage` `myMenus` 中所有 badge 硬编码为 0

- **文件**: `frontend/js/pages/mine/index.js` 第 134-149 行
- **严重程度**: 🟢 轻微

**问题**: 所有菜单项的 badge 值为 0，模板中 `menu.badge > 0` 的条件永远不成立，角标功能是死代码。如果想显示未读消息数，需要从 API 获取实际数据。

---

### BUG-060 · CDN 脚本缺少 SRI 完整性校验

- **文件**: `frontend/index.html` 第 22-23 行等
- **严重程度**: 🟢 轻微（安全增强）

**修复**: 为 Vue 和 Vue Router 的 CDN script 标签添加 `integrity` 属性。

---

### BUG-061 · `<meta viewport>` 中 `user-scalable=no` 违反无障碍标准

- **文件**: `frontend/index.html` 第 5 行
- **严重程度**: 🟢 轻微（WCAG 违规）

**修复**: 移除 `user-scalable=no` 和 `maximum-scale=1.0`，或将 maximum-scale 改为 2.0 以上。

---

### BUG-062 · `home/index.js` 搜索结果列表用 `v-for` 但未处理空状态

- **文件**: `frontend/js/pages/home/index.js` 搜索相关代码
- **严重程度**: 🟢 轻微

**问题**: 搜索列表未显示"无结果"的提示文字。

---

## 附录 A：预防性维护规则清单

将以下规则加入团队开发规范，可预防本次扫描发现的大部分问题：

| 规则 | 预防的 Bug 类型 |
|------|----------------|
| 翻译文件 key 去重 lint | BUG-003, 050, 051, 052, 053 |
| CSS 变量名必须在 variables.css 中有定义 | BUG-032 |
| font-weight 必须是 100 的倍数 | BUG-046 |
| 禁止 `localStorage.setItem('password', ...)` | BUG-001 |
| `setInterval` / `setTimeout` 必须有 `beforeUnmount` 清理 | BUG-015, 037 |
| `URL.createObjectURL()` 必须有对应的 `revokeObjectURL()` | BUG-057 |
| if/else 两分支赋的值不能相同 | BUG-013 |
| `v-for` 的 `:key` 不能是数组索引 | BUG-022 |
| 禁止使用 `v-html`（除非明确需要 HTML） | BUG-035 |
| API URL 常量名必须包含业务对象名 | BUG-005, 014 |
| Redis/外部服务调用必须有 try/catch | BUG-010 |
| 路由跳转参数名定义为常量共享 | BUG-006 |
| 初始化逻辑必须在 `app.mount()` 之前 | BUG-007 |
| 影响渲染的状态必须用 `Vue.reactive()` 包裹 | BUG-007 |
| `window.history.back()` 必须有应用内回退方案 | BUG-033 |
| 禁止调用 `localStorage.clear()` | BUG-034 |
| Webhook 路由只用 `Route::post` | BUG-042 |
| fetch 请求必须设超时 | BUG-036 |

## 附录 B：修复优先级建议

1. **第一轮（立即修复）** — BUG-001（密码明文）、BUG-002（ProfilePage 白屏）、BUG-003（翻译覆盖）、BUG-004（语法错误）、BUG-005（接口用错）
2. **第二轮（本周修复）** — BUG-006 ~ BUG-018（高危功能 Bug）
3. **第三轮（后续迭代）** — BUG-019 ~ BUG-047（中等 Bug）
4. **技术债清理** — BUG-048 ~ BUG-062（轻微问题）
