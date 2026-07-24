# LuMo Guide（路盟）

> **"路上有光，盟友相伴"** — 旅游行业人士的专业信息交流平台

面向导游、商家、内容创作者的综合性平台。提供 REST API（Flutter 移动端）、Vue 3 SPA Web 前端、Dcat Admin 管理后台。覆盖城市目的地、导游、商户、资讯文章、预约、Stripe VIP 订阅、积分商城等功能。

**所有用户需登录并通过身份审核方可访问内容。**

## 目录结构

```
├── app/                        # 后端源码（全部明文，2026-07-22 解码）
│   ├── Admin/                  # Dcat Admin 管理后台
│   ├── Http/Controllers/Api/   # API 控制器
│   ├── Models/                 # Eloquent 模型
│   ├── Services/               # 业务逻辑层（11 个 Service）
│   ├── Enums/                  # 常量枚举
│   ├── Jobs/                   # 后台任务
│   └── helpers.php             # 全局辅助函数
├── config/                     # 配置文件
├── routes/                     # 路由定义
│   ├── api.php                 # API 路由
│   └── web.php                 # Web 路由（SPA catch-all）
├── database/                   # 数据库
│   ├── migrations/             # 迁移文件（16 个）
│   ├── lumo_guide_full.sql     # 完整生产 dump（56 表，1.6M）
│   ├── schema.sql              # 仅表结构（66K）
│   ├── seed.sql                # 配置/查找数据（349K）
│   └── data.sql                # 用户内容数据（1.2M）
├── frontend/                   # Web 前端（Vue 3 SPA）
│   ├── index.html              # SPA 外壳
│   ├── build.mjs               # 生产构建脚本（esbuild）
│   ├── dist/                   # 构建输出（gitignored）
│   ├── images/                 # 图片资源
│   ├── css/                    # 样式表（3 文件）
│   └── js/                     # JavaScript（53 文件，69 路由）
├── public/                     # 公开资源（css/js 为 → frontend/ 的 symlink）
├── deploy.sh                   # 一键部署脚本（11 步）
├── storage-uploads.tar.gz      # 用户上传文件打包（342MB，1201 文件）
└── .claude/                    # Claude Code 配置
    └── bug-report-2026-07-07.md # 深度 Bug 扫描报告（62 个）
```

## 技术栈

| 层 | 技术 | 说明 |
|---|------|------|
| 后端框架 | Laravel 9 | PHP 8.x |
| 数据库 | MySQL 5.7+ | 56 张表 |
| 队列 | Redis | 后台任务驱动 |
| API 认证 | JWT (tymon/jwt-auth) | TTL 7 天 |
| 管理后台 | Dcat Admin | 路径 `/manage` |
| 支付 | Stripe | VIP 订阅 |
| Web 前端 | Vue 3 + Vue Router 4 | CDN 加载，同源 API |
| 移动端 | Flutter | REST API 客户端 |
| 即时通讯 | 腾讯 IM | 仅移动端 |

## 快速部署

### 在新服务器上一键部署

```bash
git clone <仓库地址> lumo_guide
cd lumo_guide

# 确保 storage-uploads.tar.gz 在项目根目录（用户上传的图片等）

# 交互模式（推荐首次部署）
./deploy.sh

# 或自动模式
./deploy.sh --auto
```

脚本执行 11 个步骤：环境检查 → 配置文件 → Composer 依赖 → 目录权限 → 数据库导入 → 前端构建 → 缓存优化 → Nginx 配置 → 上传文件恢复 → 队列 Worker → 定时任务。

### 手动部署步骤

```bash
# 1. 配置环境
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
# 编辑 .env 填入数据库密码、Stripe、邮件、AUDIT_EMAIL、IM 等密钥

# 2. 安装依赖
composer install --no-dev --optimize-autoloader

# 3. 导入数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS lumo_guide DEFAULT CHARSET utf8mb4"
mysql -u root -p lumo_guide < database/lumo_guide_full.sql
php artisan migrate  # 运行未应用的迁移（如 journey_work/journey_template）

# 4. 设置权限
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# 5. 恢复上传文件
tar xzf storage-uploads.tar.gz -C storage/app/public/
php artisan storage:link

# 6. 前端构建
npm install --no-save
npm run build:prod

# 7. 优化
php artisan config:cache && php artisan view:cache && php artisan event:cache

# 8. Nginx 配置 → 见 deploy.sh 第 8 步生成的模板
# 9. 队列 Worker → Supervisor 配置
# 10. 定时任务 → crontab -e
```

## 本地开发

```bash
# 启动
/opt/homebrew/bin/php artisan serve --host=0.0.0.0 --port=8000

# 导入本地数据库
mysql -u root -p lumo_guide < database/lumo_guide_full.sql

# 清除缓存
php artisan config:clear && php artisan cache:clear && php artisan route:clear

# 前端开发模式 — 无需构建，直接修改 JS/CSS 刷新浏览器即可
```

## 环境要求

| 组件 | 最低版本 | 说明 |
|------|---------|------|
| PHP | 8.0+ | 必需扩展: bcmath, ctype, curl, dom, exif, fileinfo, gd, json, mbstring, openssl, pdo, pdo_mysql, redis, tokenizer, xml, zip |
| MySQL | 5.7+ | 56 表 |
| Redis | 任意 | 队列和配置缓存 |
| Node.js | 16+ | 前端生产构建（esbuild） |
| Composer | 2.x | PHP 依赖管理 |
| Nginx | 任意 | Web 服务器 |

## 前端关键约束

1. **不要创建独立组件文件** — Vue 3 CDN 构建中，`components: {}` 注册在子组件模板中不解析，组件会静默渲染空白。所有模板必须内联在父组件中
2. **所有前端文件放在 `frontend/`** — `public/css/` 和 `public/js/` 是 symlink，不要直接编辑
3. **API 使用同源路径** — API URL 由 `window.location.origin` 自动检测，不依赖特定域名
4. **生产构建**: `npm run build:prod` 用 esbuild 合并压缩（53 JS + 3 CSS → 1+1，57→4 请求）
5. **多语言**: I18n 对象必须用 `Vue.reactive()` 包裹，`I18n.init()` 必须在 `app.mount()` 之前
6. **文件上传**: 使用 `URL.createObjectURL()` 预览时必须同时保存 `File` 对象，提交时上传 File
7. **定时器**: 所有 `setInterval`/`setTimeout` 必须在 `beforeUnmount` 中清除

## 数据库

- **56 张表**，42 张有数据（dump 自生产 MySQL 5.7.44）
- 14 张空表为按需填充（failed_jobs、password_resets 等），正常
- 3 个内置管理员账户：`admin`、`lumo`、`Zhou Guanpei`（bcrypt 密码）
- 导入后运行 `php artisan migrate` 确保 journey_work/journey_template 表被创建

## 管理后台

- 路径: `/manage`（由 `.env` 中 `ADMIN_ROUTE_PREFIX=manage` 配置）
- 内置账户: `admin`
- 功能: 城市审核、导游/商户管理、内容管理、积分/VIP 配置、系统设置等

## 更新日志

### 2026-07-24 — 安全加固

- 全面安全审查，修复 9 个漏洞（2 严重 + 2 高危 + 5 中等）
- 删除后门密码 `654123` 和万能验证码 `4321`
- 文件上传：MIME 类型白名单 + 扩展名校验 + 10MB 限制，防止 RCE
- 新增 `escapeLike()` 辅助函数，所有 LIKE 查询转义通配符
- 错误消息：所有 Service 层异常脱敏，统一返回通用错误
- 登录：统一失败提示，防止用户枚举
- Stripe Webhook：幂等性检查，防止重复处理
- SSL：移除 `CURLOPT_SSL_VERIFYPEER = false`
- `/api/common/test` 添加 `auth:api` 中间件

### 2026-07-24 — 部署独立性加固 + CLAUDE.md 精简

- `public/index.php` API 代理修复：增加 `APP_ENV=local` 检查
- `.env.example` 新增 `AUDIT_EMAIL` 配置项
- `deploy.sh` 配置提示增加 `AUDIT_EMAIL`
- `CLAUDE.md` 从 590 行精简至 440 行

### 2026-07-22 — 代码独立化

- 11 个 Service 文件从 swoole_loader 解码为明文，不再需要特殊扩展
- API 代理添加 `APP_ENV=local` 守卫，仅在本地开发时生效，生产环境请求由 Laravel 正常处理
- 前端 JS 中硬编码的 `api.lumoguide.com` 改为 `window.location.origin` 同源自适应
- `.env` 中所有生产凭据替换为占位符
- `start.sh` 移除 SSH 密码和生产 IP
- 创建 `deploy.sh` 11 步一键部署脚本（Docker 验证通过）
- 数据库 dump（`database/lumo_guide_full.sql`）+ 上传文件打包（`storage-uploads.tar.gz`）纳入仓库
- Laravel 调度器 + Supervisor 队列 Worker 配置加入部署脚本

### 2026-07-21

- JourneyWork CRUD、JourneyTemplate、systemContinents 层级树、城市 country_name 注入
- esbuild 前端生产构建、62 个 Bug 扫描报告

## Bug 修复指引

项目根目录的 `bug-report-2026-07-07.md` 包含 62 个已知 Bug 的详细报告，按优先级分四轮修复：严重（4）→ 高危（14）→ 中等（29）→ 轻微（15）。

## 许可

内部项目。含原始第三方 API 密钥的数据需在部署后替换为新凭据。
