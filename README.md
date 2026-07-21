# LuMo Guide（路盟）

> **"路上有光，盟友相伴"** — 旅游行业人士的专业信息交流平台

面向导游、商家、内容创作者的综合性平台。提供 REST API（Flutter 移动端）、Vue 3 SPA Web 前端、Dcat Admin 管理后台。覆盖旅游目的地（城市）、导游、商户、资讯文章、预约、Stripe VIP 订阅、积分商城等功能。

**所有用户需登录并通过身份审核方可访问内容。**

## 目录结构

```
├── app/                        # 后端源码（swoole_loader 编码，大部分不可直接编辑）
│   ├── Admin/                  # Dcat Admin 管理后台
│   ├── Http/Controllers/Api/   # API 控制器
│   ├── Models/                 # Eloquent 模型
│   ├── Services/               # 业务逻辑层
│   ├── Enums/                  # 常量枚举
│   ├── Jobs/                   # 后台任务
│   └── helpers.php             # 全局辅助函数 ✅ 可编辑
├── config/                     # 配置文件 ✅ 可编辑
├── routes/                     # 路由定义 ✅ 可编辑
│   ├── api.php                 # API 路由
│   └── web.php                 # Web 路由（SPA catch-all）
├── database/migrations/        # 数据库迁移 ✅ 可编辑
├── frontend/                   # Web 前端（Vue 3 SPA 源文件目录）
│   ├── index.html              # SPA 外壳（CDN 链接 + <div id="app">）
│   ├── build.mjs               # 生产构建脚本（esbuild 合并压缩）
│   ├── dist/                   # 构建输出（生产环境使用，gitignored）
│   ├── images/                 # 图片资源
│   ├── css/                    # 样式表
│   │   ├── variables.css       # 设计 token（颜色、圆角、间距）
│   │   ├── app.css             # 全局布局、排版、工具类
│   │   └── components.css      # .ds-* 组件类、topbar、认证卡片
│   └── js/                     # JavaScript
│       ├── app.js              # Vue 应用入口、AppShell 组件、全局注册
│       ├── router.js           # Hash 路由（69 条路由 + auth guard）
│       ├── api/                # API 调用层（provider.js + 183 个 URL 常量）
│       ├── stores/             # 响应式状态（user.js、config.js）
│       ├── i18n/               # 多语言（zh-CN、zh-TW、en）
│       ├── utils/              # 工具函数
│       ├── components/         # 共享组件
│       └── pages/              # 页面组件（36 个文件，69 个路由）
├── public/                     # 公开资源（css/js 为 → frontend/ 的 symlink）
├── resources/views/            # Blade 模板
└── .claude/                    # Claude Code 配置
    └── bug-report-2026-07-07.md # ⚠️ 深度 Bug 扫描报告（待修复）
```

## 技术栈

| 层 | 技术 | 说明 |
|---|------|------|
| 后端框架 | Laravel 9 | PHP 8.3 |
| 数据库 | MySQL | 生产库 `lumo_guide` |
| 队列 | Redis | 后台任务驱动 |
| API 认证 | JWT (tymon/jwt-auth) | TTL 7 天 |
| 管理后台 | Dcat Admin | 路径 `/manage` |
| 支付 | Stripe | VIP 订阅 |
| Web 前端 | Vue 3 + Vue Router 4 | CDN 加载，无构建工具 |
| 移动端 | Flutter | 参考源 `/Users/guanpei/Downloads/LUMOGUIDE- Front/` |
| 即时通讯 | 腾讯 IM | 仅移动端 |

## 本地开发环境

```bash
# PHP 8.3.21 via Homebrew
# 启动开发服务器（自动建立 SSH 隧道连接生产数据库）
./start.sh

# 或手动
/opt/homebrew/bin/php artisan serve

# 清除缓存（修改路由/配置后）
/opt/homebrew/bin/php artisan config:clear && php artisan cache:clear && php artisan route:clear

# 运行测试
/opt/homebrew/bin/php artisan test
```

- **数据库**: 通过 SSH 隧道连接生产 MySQL（`127.0.0.1:3307` → 服务器 `3306`）
- **API 代理**: `public/index.php` 拦截 `/api/*` 并转发到 `https://api.lumoguide.com`（本地无 swoole_loader）
- **⚠️ 注意**: 本地代理软件（Surge、ClashX）会劫持 DNS 导致 API 代理失败，开发时需关闭
- **后端源文件编码**: `app/` 下大部分 PHP 文件由 swoole_loader 编码，本地不可读取/编辑

## 前端关键约束

1. **不要创建独立组件文件** — Vue 3 CDN 构建中，`components: {}` 注册在子组件模板中不解析，组件会静默渲染空白。所有模板必须内联在父组件中
2. **所有前端文件放在 `frontend/`** — `public/css/` 和 `public/js/` 是 symlink，不要直接编辑
3. **前端开发模式无构建步骤** — 修改 JS/CSS 后刷新浏览器即可看到效果；生产环境 `npm run build:prod` 用 esbuild 合并压缩（53 JS + 3 CSS → 1+1，HTTP 请求 57→4）
4. **多语言**: I18n 对象必须用 `Vue.reactive()` 包裹，`I18n.init()` 必须在 `app.mount()` 之前
5. **文件上传**: 使用 `URL.createObjectURL()` 预览时必须同时保存 `File` 对象，提交时上传 File
6. **定时器**: 所有 `setInterval`/`setTimeout` 必须在 `beforeUnmount` 中清除

## 服务器连接

| 项目 | 值 |
|------|-----|
| 服务商 | easyname |
| IP | 47.76.27.105 |
| SSH | root@47.76.27.105 |
| MySQL | lumo_guide (3306) |
| API | https://api.lumoguide.com |
| 管理后台 | https://api.lumoguide.com/manage |

## 🔧 Bug 修复指引

项目根目录的 `bug-report-2026-07-07.md` 包含 **62 个已知 Bug** 的详细报告，每个 Bug 含问题说明、复现条件、修复代码和预防措施。按优先级分四轮修复：

1. 严重（4 个）— 安全漏洞 + 页面崩溃
2. 高危（14 个）— 功能错误 + 数据丢失
3. 中等（29 个）— UI 问题 + 边缘情况
4. 轻微（15 个）— 代码质量

使用 Claude Code 打开该文件即可按指令逐轮自动修复。

## 最近更新（2026-07-21）

### 新增功能
- **JourneyWork（我的历程）**: 用户工作记录 CRUD，含 `journey_work` 表（JSON content 列 + 软删除），API: `/api/user/journey*`
- **JourneyTemplate（工作模板）**: 模板保存/列表/删除，`journey_template` 表，API: `/api/user/journeyTemplate*`
- **systemContinents 层级树**: `GET /api/common/systemContinents` 返回大洲→地区→国家嵌套结构，替代 Flutter 的硬编码数据
- **城市列表 country_name 注入**: `GET /api/city/lists` 现在返回 `country_name` 和 `country` 字段

### 生产构建
- `npm run build:prod` — esbuild 无依赖构建，将 53 JS + 3 CSS 合并压缩为内容哈希命名的单文件
- 生产环境 `routes/web.php` 自动服务 `frontend/dist/index.html`，开发环境用原始文件
- 构建输出已加入 `.gitignore`（`/frontend/dist`、`/public/dist`）

### Bug 修复
- CityController: `$c->country->name` 改用 nullsafe 操作符 `?->` 防止 null relation 导致 500
- UserController: `expandJourneyWork` 中 `array_merge($content, $arr)` 确保模型真实字段不会被 content JSON 覆盖
- routes/web.php: SPA index 延迟到请求时解析，避免 `route:cache` 烘焙不存在的 `dist/index.html`
