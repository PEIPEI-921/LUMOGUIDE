# LUMOGUIDE 聊天 IM 运维手册

> 生产环境：阿里云 `47.76.27.105`（SSH: `ssh root@47.76.27.105`，免密）
> 更新时间：2026-08-23

## 一、服务架构

| 组件 | 位置 | 运行方式 |
|------|------|---------|
| LUMO-Chat（NestJS IM 服务） | `/www/wwwroot/lumo_family/lumo_chat/apps/server` | pm2 `im-server`（`node dist/main.js`） |
| Laravel API（业务后端） | `/www/wwwroot/lumo_family/lumo_guide/backend` | nginx + php-fpm（宝塔面板） |
| 静态站点 / APK 下载 | `/www/wwwroot/lumo_family/lumo_guide_site` | nginx（`lumoguide.com`） |
| MySQL（Laravel 数据） | 宿主机 mysqld | 宝塔面板管理 |
| PostgreSQL（LUMO-Chat 会话/成员） | docker `im-postgres` | 5433→5432 |
| MongoDB（LUMO-Chat 消息） | docker `im-mongodb` | 27017 |
| Redis（在线状态/device token/队列） | docker `im-redis` | 6381→6379 |
| MinIO（图片等媒体） | docker `im-minio` | 9000/9001 |

反向代理（nginx `api.lumoguide.com.conf`）：
- `/api/*` → Laravel（php-fpm）
- `/im/*` → LUMO-Chat REST（127.0.0.1:3000）
- `/socket.io/*` → LUMO-Chat WebSocket（127.0.0.1:3000）

---

## 二、备份命令（每日 / 上线前执行）

### 一键全量备份（MySQL + PG + Mongo）
```bash
ssh root@47.76.27.105
BK=/www/backup
DATE=$(date +%Y%m%d)

# 1. MySQL（Laravel 业务数据）
DB_USER=$(grep '^DB_USERNAME=' /www/wwwroot/lumo_family/lumo_guide/backend/.env | cut -d= -f2)
DB_PASS=$(grep '^DB_PASSWORD=' /www/wwwroot/lumo_family/lumo_guide/backend/.env | cut -d= -f2)
DB_NAME=$(grep '^DB_DATABASE=' /www/wwwroot/lumo_family/lumo_guide/backend/.env | cut -d= -f2)
mysqldump --single-transaction -u$DB_USER -p$DB_PASS $DB_NAME | gzip > $BK/lumo_guide_full_$DATE.sql.gz

# 2. LUMO-Chat PostgreSQL（会话/群成员）
docker exec im-postgres pg_dump -U im_admin im_service | gzip > $BK/im_postgres_$DATE.sql.gz

# 3. LUMO-Chat MongoDB（消息）
# ⚠️ 勿用 --archive 管道（docker exec stdout 会截断导致 EOF）；用 --out 目录 + docker cp
docker exec im-mongodb mongodump --host localhost -u im_admin -p im_secret_2024 \
  --authenticationDatabase admin --db im_messages --out /tmp/im_mongo_dump_$DATE
rm -rf $BK/im_mongo_$DATE
docker cp im-mongodb:/tmp/im_mongo_dump_$DATE $BK/im_mongo_$DATE
docker exec im-mongodb rm -rf /tmp/im_mongo_dump_$DATE
tar czf $BK/im_mongo_$DATE.tar.gz -C $BK im_mongo_$DATE && rm -rf $BK/im_mongo_$DATE
```

### 恢复
```bash
# MySQL
gunzip -c $BK/lumo_guide_full_$DATE.sql.gz | mysql -u$DB_USER -p$DB_PASS $DB_NAME
# PostgreSQL
gunzip -c $BK/im_postgres_$DATE.sql.gz | docker exec -i im-postgres psql -U im_admin im_service
# MongoDB
tar xzf $BK/im_mongo_$DATE.tar.gz -C /tmp
docker cp /tmp/im_mongo_$DATE im-mongodb:/tmp/im_mongo_restore
docker exec im-mongodb mongorestore --host localhost -u im_admin -p im_secret_2024 \
  --authenticationDatabase admin --drop /tmp/im_mongo_restore/im_messages
```

### APK 备份（发版时自动执行）
发版命令已在部署流程中内置：部署前自动 `cp app-release.apk /www/backup/apk-bak/app-release-<版本>.bak.apk`。
**建议**：每周清理 30 天前的备份（见第三节清理）。

---

## 三、清理命令（磁盘空间维护）

> 磁盘告警线：`df -h /` 超过 85% 时应执行。

```bash
ssh root@47.76.27.105

# 1. APK 旧备份：保留最近 5 个，删除更早的
ls -t /www/backup/apk-bak/*.apk | tail -n +6 | xargs -r rm -f

# 2. 数据库备份：保留最近 7 天
find /www/backup -name 'lumo_guide_full_*.sql.gz' -mtime +7 -delete
find /www/backup -name 'im_postgres_*.sql.gz' -mtime +7 -delete
find /www/backup -name 'im_mongo_*.tar.gz' -mtime +7 -delete

# 3. Laravel 日志：归档/轮转（保留 14 天）
cd /www/wwwroot/lumo_family/lumo_guide/backend/storage/logs
find . -name 'laravel-*.log' -mtime +14 -delete
[ -f laravel.log ] && mv laravel.log "laravel-$(date +%Y-%m-%d).log" && : > laravel.log

# 4. LUMO-Chat 进程日志（pm2，保留最近）
# 默认由 pm2 管理；如需清理：pm2 flush im-server

# 5. 部署残留备份目录
rm -rf /www/wwwroot/lumo_family/lumo_chat/apps/server/dist.bak.* /www/wwwroot/lumo_family/lumo_chat/apps/server/.env.bak.*
```

---

## 四、部署/更新流程

### LUMO-Chat 服务端
```bash
ssh root@47.76.27.105
cd /www/wwwroot/lumo_family/lumo_chat
git pull
cd apps/server && npm install   # 有新依赖时
npm run build
pm2 restart im-server --update-env
pm2 logs im-server --lines 20 --nostream   # 确认 Composite push enabled
```

### Laravel 后端
```bash
ssh root@47.76.27.105
cd /www/wwwroot/lumo_family/lumo_guide/backend
git pull
/www/server/php/80/bin/php artisan config:clear
/www/server/php/80/bin/php artisan cache:clear
```

### App 发版
```bash
# 本地：bump pubspec version → 构建
cd mobile && flutter build apk --release
# 上传（自动备份旧版）
scp build/app/outputs/flutter-apk/app-release.apk root@47.76.27.105:/tmp/new.apk
ssh root@47.76.27.105 "
  cp /www/wwwroot/lumo_family/lumo_guide_site/dl/app-release.apk /www/backup/apk-bak/app-release-$(date +%Y%m%d).bak.apk
  mv /tmp/new.apk /www/wwwroot/lumo_family/lumo_guide_site/dl/app-release.apk
  echo '<版本号>' > /www/wwwroot/lumo_family/lumo_guide_site/dl/version.txt
"
```

---

## 五、常用运维命令

```bash
# 服务状态
pm2 list
pm2 logs im-server            # 实时日志（含 fcm-push / apns delivered）
pm2 logs im-server --err      # 错误日志

# 推送验证
docker exec im-redis redis-cli -a im_redis_2024 --no-auth-warning HGETALL "device_tokens:app_dev_001:<用户编号>"
# 日志中应见: [fcm-push] user=... → 1/1 delivered（Android）/ [apns] delivered status=200（iOS）

# 数据库
docker exec im-postgres psql -U im_admin -d im_service -c "SELECT id,type,title FROM conversations ORDER BY updated_at DESC LIMIT 10;"

# .env 权限（勿改为 600！php-fpm 以 www 运行需可读）
chown root:www .env && chmod 640 .env
```

---

## 六、上线检查清单

- [ ] `pm2 list` 中 im-server online
- [ ] 核心接口 200：`/api/common/config` `/api/city/info?id=23` `/api/common/guideList`
- [ ] LUMO-Chat 换 token 200：POST `/im/api/v1/auth/token`
- [ ] WebSocket 反代 200：`/socket.io/?EIO=4&transport=polling`
- [ ] `/dl/app-release.apk` HTTP 200（版本号 = version.txt）
- [ ] 日志无 ERROR 增长（`pm2 logs im-server --err`）
- [ ] 磁盘 < 85%（`df -h /`）、内存可用 > 1G
- [ ] 当天全量备份存在（`ls /www/backup/*_$(date +%Y%m%d).*`）
- [ ] 真机：Android FCM 通知 + 角标、iOS APNs、实时消息、版本升级自动登出
