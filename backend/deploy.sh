#!/bin/bash
#
# LuMo Guide 一键部署脚本
# 适用环境: Ubuntu/Debian/CentOS + Nginx + PHP 8.x + MySQL/Redis
#
# 用法:
#   chmod +x deploy.sh
#   ./deploy.sh              # 交互模式，逐步确认
#   ./deploy.sh --auto       # 自动模式，跳过确认
#

set -eu

# ── 颜色输出 ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
step()  { echo -e "\n${BLUE}▶ $1${NC}"; }

AUTO_MODE=false
[[ "${1:-}" == "--auto" ]] && AUTO_MODE=true

confirm() {
    if $AUTO_MODE; then return 0; fi
    read -rp "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── 检查是否为 root ──
[[ "$(id -u)" -eq 0 ]] || error "请以 root 用户运行此脚本"

PROJECT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$PROJECT_DIR"

echo "============================================"
echo "  LuMo Guide (路盟) 部署脚本"
echo "  项目目录: $PROJECT_DIR"
echo "============================================"

# ────────────────────────────────────────────
# Step 1: 环境检查
# ────────────────────────────────────────────
step "1/11 检查运行环境"

PHP_BIN=$(command -v php 2>/dev/null) || error "未找到 PHP，请先安装 PHP 8.x"
PHP_VER=$($PHP_BIN -r 'echo PHP_VERSION;')
info "PHP 版本: $PHP_VER"

# 检查 PHP 主版本 >= 8
PHP_MAJOR=$($PHP_BIN -r 'echo PHP_MAJOR_VERSION;')
[[ "$PHP_MAJOR" -ge 8 ]] || error "需要 PHP >= 8.0，当前: $PHP_VER"

REQUIRED_EXTS=("bcmath" "ctype" "curl" "dom" "exif" "fileinfo" "gd" "json" "mbstring" "openssl" "pdo" "pdo_mysql" "redis" "tokenizer" "xml" "zip")
MISSING_EXTS=()
for ext in "${REQUIRED_EXTS[@]}"; do
    $PHP_BIN -m | grep -qi "^$ext$" || MISSING_EXTS+=("$ext")
done
if [[ ${#MISSING_EXTS[@]} -gt 0 ]]; then
    warn "缺少 PHP 扩展: ${MISSING_EXTS[*]}"
    confirm "是否继续？（缺少扩展可能导致功能异常）" || error "请先安装缺少的 PHP 扩展"
else
    info "所有必需 PHP 扩展已安装"
fi

COMPOSER_BIN=$(command -v composer 2>/dev/null) || {
    warn "未找到 Composer，正在安装..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    COMPOSER_BIN=$(command -v composer)
}
info "Composer: $($COMPOSER_BIN --version 2>/dev/null | head -1)"

MYSQL_BIN=$(command -v mysql 2>/dev/null) || warn "未找到 mysql 客户端（数据库导入需手动执行）"

# ────────────────────────────────────────────
# Step 2: 配置文件
# ────────────────────────────────────────────
step "2/11 配置环境变量"

if [[ -f .env ]]; then
    info ".env 已存在，跳过创建"
else
    cp .env.example .env
    info "已从 .env.example 创建 .env"

    # 生成 APP_KEY
    $PHP_BIN artisan key:generate --no-interaction 2>/dev/null && info "APP_KEY 已生成" || warn "APP_KEY 生成失败，请手动执行: php artisan key:generate"

    # 生成 JWT_SECRET
    $PHP_BIN artisan jwt:secret --no-interaction 2>/dev/null && info "JWT_SECRET 已生成" || warn "JWT_SECRET 生成失败，请手动执行: php artisan jwt:secret"

    warn "请编辑 .env 填入以下必要配置:"
    echo "  - APP_ENV=production / APP_DEBUG=false (生产环境务必修改)"
    echo "  - APP_URL / WEB_URL (替换为你的域名)"
    echo "  - DB_HOST / DB_PORT / DB_DATABASE / DB_USERNAME / DB_PASSWORD"
    echo "  - REDIS_HOST / REDIS_PORT / REDIS_PASSWORD (队列必需)"
    echo "  - MAIL_USERNAME / MAIL_PASSWORD (邮件发送)"
    echo "  - STRIPE_KEY / STRIPE_SECRET / STRIPE_WEBHOOK_SECRET"
    echo "  - SDK_APP_ID / SECRET_KEY (腾讯 IM)"

    if ! $AUTO_MODE; then
        read -rp "按回车键继续..."
    fi
fi

# ────────────────────────────────────────────
# Step 3: 安装依赖
# ────────────────────────────────────────────
step "3/11 安装 Composer 依赖"

if confirm "运行 composer install？"; then
    $COMPOSER_BIN install --no-dev --optimize-autoloader --no-interaction
    info "依赖安装完成"
else
    warn "跳过 composer install"
fi

# ────────────────────────────────────────────
# Step 4: 目录权限
# ────────────────────────────────────────────
step "4/11 设置目录权限"

chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || \
chown -R nginx:nginx storage bootstrap/cache 2>/dev/null || \
chown -R www:www storage bootstrap/cache 2>/dev/null || \
warn "无法自动设置 storage/ 目录所有者，请手动执行: chown -R <web-user> storage bootstrap/cache"
info "目录权限已设置"

# ────────────────────────────────────────────
# Step 5: 数据库导入
# ────────────────────────────────────────────
step "5/11 数据库导入"

if [[ -n "${MYSQL_BIN:-}" ]] && [[ -f database/lumo_guide_full.sql ]]; then
    # 尝试从 .env 读取数据库配置
    DB_USER="root"
    DB_PASS=""
    if [[ -f .env ]]; then
        ENV_USER=$(grep -E '^DB_USERNAME=' .env | head -1 | cut -d= -f2)
        ENV_PASS=$(grep -E '^DB_PASSWORD=' .env | head -1 | cut -d= -f2)
        [[ -n "$ENV_USER" ]] && DB_USER="$ENV_USER"
        [[ -n "$ENV_PASS" ]] && DB_PASS="$ENV_PASS"
    fi

    # 构建 mysql 连接参数
    MYSQL_ARGS="-u $DB_USER"
    [[ -n "$DB_PASS" ]] && MYSQL_ARGS="$MYSQL_ARGS -p$DB_PASS"

    if $AUTO_MODE; then
        $MYSQL_BIN $MYSQL_ARGS -e "CREATE DATABASE IF NOT EXISTS lumo_guide DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || {
            warn "自动连接 MySQL 失败，尝试无密码 root..."
            $MYSQL_BIN -u root -e "CREATE DATABASE IF NOT EXISTS lumo_guide DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || warn "数据库创建失败，跳过（可稍后手动导入）"
        }
        $MYSQL_BIN $MYSQL_ARGS lumo_guide < database/lumo_guide_full.sql 2>/dev/null && \
            info "数据库导入完成" || warn "数据库导入失败，请手动执行"
    else
        if confirm "导入数据库？这将创建/覆盖 lumo_guide 库 (database/lumo_guide_full.sql)"; then
            echo "MySQL 连接信息: 用户=$DB_USER 密码=${DB_PASS:+<已从.env读取>}"
            $MYSQL_BIN $MYSQL_ARGS -e "CREATE DATABASE IF NOT EXISTS lumo_guide DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"
            $MYSQL_BIN $MYSQL_ARGS lumo_guide < database/lumo_guide_full.sql
            info "数据库导入完成"
        fi
    fi
else
    if [[ ! -f database/lumo_guide_full.sql ]]; then
        warn "未找到 database/lumo_guide_full.sql，跳过数据库导入"
    fi
fi

# ────────────────────────────────────────────
# Step 6: 前端构建
# ────────────────────────────────────────────
step "6/11 前端生产构建"

if [[ -f frontend/build.mjs ]]; then
    NODE_BIN=$(command -v node 2>/dev/null) || warn "未找到 Node.js，跳过前端构建"
    if [[ -n "${NODE_BIN:-}" ]]; then
        if confirm "构建前端生产包（esbuild 打包 53 JS + 3 CSS → 1 JS + 1 CSS）？"; then
            npm install --no-save 2>/dev/null && (cd frontend && node build.mjs) && info "前端构建完成 → frontend/dist/" || warn "前端构建失败，将使用独立文件"
        else
            warn "跳过前端构建（生产环境将使用独立文件）"
        fi
    fi
else
    warn "未找到 frontend/build.mjs，跳过"
fi

# ────────────────────────────────────────────
# Step 7: 缓存优化
# ────────────────────────────────────────────
step "7/11 优化缓存"

$PHP_BIN artisan config:cache 2>/dev/null  && info "配置缓存已生成"  || warn "config:cache 失败"
$PHP_BIN artisan route:cache 2>/dev/null   && info "路由缓存已生成"   || warn "route:cache 失败"
$PHP_BIN artisan view:cache 2>/dev/null    && info "视图缓存已生成"   || warn "view:cache 失败"
$PHP_BIN artisan event:cache 2>/dev/null   && info "事件缓存已生成"   || warn "event:cache 失败"

# ────────────────────────────────────────────
# Step 8: Nginx 配置
# ────────────────────────────────────────────
step "8/11 Nginx 配置"

NGINX_CONF="/etc/nginx/sites-available/lumoguide.conf"
PHP_FPM_SOCK=$(find /var/run/php -name "php*-fpm.sock" 2>/dev/null | head -1 || true)
PHP_FPM_SOCK="${PHP_FPM_SOCK:-unix:/var/run/php/php8.0-fpm.sock}"

if [[ ! -f "$NGINX_CONF" ]]; then
    cat > "$NGINX_CONF" << NGINX_TEMPLATE
server {
    listen 80;
    server_name your-domain.com;   # ← 修改为你的域名
    root $PROJECT_DIR/public;
    index index.php index.html;

    # 所有请求优先匹配静态文件，其次走 Laravel
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass $PHP_FPM_SOCK;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    access_log /var/log/nginx/lumoguide-access.log;
    error_log  /var/log/nginx/lumoguide-error.log;
}
NGINX_TEMPLATE
    info "Nginx 配置已创建: $NGINX_CONF"

    if confirm "是否启用站点并重载 Nginx？"; then
        # 适配不同系统路径
        if [[ -d /etc/nginx/sites-enabled ]]; then
            ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/lumoguide.conf
        elif [[ -d /etc/nginx/conf.d ]]; then
            ln -sf "$NGINX_CONF" /etc/nginx/conf.d/lumoguide.conf
        fi
        nginx -t && systemctl reload nginx && info "Nginx 已重载" || error "Nginx 配置测试失败，请检查"
    fi
else
    info "Nginx 配置已存在，跳过"
fi

# ────────────────────────────────────────────
# Step 9: 恢复上传文件
# ────────────────────────────────────────────
step "9/11 恢复上传文件"

STORAGE_BACKUP="storage-uploads.tar.gz"
UPLOADS_DIR="$PROJECT_DIR/storage/app/public"

if [[ -f "$STORAGE_BACKUP" ]]; then
    if confirm "恢复上传文件（图片/附件）到 storage/app/public/？"; then
        mkdir -p "$UPLOADS_DIR"
        tar xzf "$STORAGE_BACKUP" -C "$UPLOADS_DIR" 2>/dev/null && \
            info "上传文件已恢复" || warn "上传文件恢复失败，请检查 $STORAGE_BACKUP"
    fi
else
    warn "未找到 $STORAGE_BACKUP，跳过上传文件恢复"
    echo "  从旧服务器获取: tar czf $STORAGE_BACKUP -C /www/wwwroot/lumo/storage/app/public ."
    echo "  放到项目根目录后重新运行此脚本"
fi

# ────────────────────────────────────────────
# Step 10: 队列 Worker (Supervisor)
# ────────────────────────────────────────────
step "10/11 队列 Worker"

SUPERVISOR_CONF="/etc/supervisor/conf.d/lumoguide-worker.conf"

if [[ ! -f "$SUPERVISOR_CONF" ]]; then
    if command -v supervisorctl &>/dev/null; then
        cat > "$SUPERVISOR_CONF" << SUPERVISOR
[program:lumoguide-worker]
process_name=%(program_name)s_%(process_num)02d
command=php $PROJECT_DIR/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=$PROJECT_DIR/storage/logs/worker.log
stopwaitsecs=3600
SUPERVISOR
        supervisorctl reread && supervisorctl update && supervisorctl start lumoguide-worker:*
        info "Supervisor 队列 Worker 已配置并启动"
    else
        warn "未找到 supervisorctl，跳过队列 Worker 配置"
        echo "  手动启动: php $PROJECT_DIR/artisan queue:work redis --daemon"
    fi
else
    info "Supervisor 配置已存在，跳过"
fi

# ────────────────────────────────────────────
# Step 11: 定时任务 (Crontab)
# ────────────────────────────────────────────
step "11/11 定时任务"

CRON_JOB="* * * * * php $PROJECT_DIR/artisan schedule:run >> $PROJECT_DIR/storage/logs/cron.log 2>&1"

if crontab -l 2>/dev/null | grep -qF "artisan schedule:run"; then
    info "定时任务已存在，跳过"
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab - && \
        info "定时任务已添加: artisan schedule:run (每分钟)" || \
        warn "定时任务添加失败，请手动执行: crontab -e"
fi

# ── 存储软链 ──
if [[ ! -L "$PROJECT_DIR/public/storage" ]]; then
    php "$PROJECT_DIR/artisan" storage:link 2>/dev/null && \
        info "storage:link 已创建" || \
        warn "storage:link 创建失败，请手动执行: php artisan storage:link"
fi

# ── 完成 ──
echo ""
echo "============================================"
echo "  部署完成！"
echo "============================================"
echo ""
echo "后续事项:"
echo "  1. ⚠️  编辑 .env: 设置 APP_ENV=production, APP_DEBUG=false"
echo "  2. 编辑 .env: 填入数据库/Redis/邮件/Stripe/IM 密钥"
echo "  3. 确保 Redis 已启动: systemctl start redis"
echo "  4. 配置 SSL 证书 (推荐 Let's Encrypt): certbot --nginx"
echo "  5. 确认上传文件已恢复: ls storage/app/public/"
echo "  6. 检查队列 Worker: supervisorctl status lumoguide-worker:*"
