# 聊天 IM 功能完善 — 部署与配置指南

> 2026-08：一次性补齐 5 项聊天 IM 缺口（Android 推送 / 历史分页 / 消息编辑 / 群名修改+扫码加群 / 商家侧聊天入口）。
> 涉及三个仓库：**LUMO-Chat（服务端）**、**LUMOGUIDE/mobile（Flutter）**、**LUMOGUIDE/backend（Laravel）**。

## ✅ P1-4 / P2-10 落地（2026-08-23 追加）

| 项目 | 状态 |
|------|------|
| **P1-4 群公告持久化** | ✅ 新基线已实现（实体 + 表列 + 真实写库 + 接口返回），生产端到端验证通过（写入 → 详情返回 → 数据库直查一致） |
| **P2-10 i18n 补齐** | ✅ 三语补齐 25 个 key（18 个审计缺失 + 7 个扫描发现），代码引用的 chat 相关 key 全部三语齐全，`flutter analyze` 0 issues |
| **App 1.0.9+30**（含 i18n 补齐） | ✅ 已部署 `https://lumoguide.com/dl/app-release.apk`（MD5 7e0e00b4...，备份 app-release-1.0.8.bak.apk，version.txt=1.0.9） |

## ✅ P0 落地进度（2026-08-23）

| 项目 | 状态 |
|------|------|
| LUMO-Chat 服务端新接口（群名/加群/device-token/admin push） | ✅ **已部署生产**（pm2 im-server，PID 验证通过） |
| 多平台推送架构（`PUSH_PROVIDER=all`：iOS→APNs + Android→FCM） | ✅ **已部署生产** |
| APNs（iOS）推送 | ✅ 保持正常（生产凭据齐全） |
| **FCM（Android）推送** | ✅ **已启用**：服务账号已配置（project=lumoguide），日志确认 `Composite push enabled: apns(ios), fcm(android)`，实测请求送达 Firebase（`[fcm-push] ... → N/N delivered`） |
| App 新版本（1.0.9+30） | ✅ release APK 已部署 `https://lumoguide.com/dl/app-release.apk`（118.5MB，备份 app-release-1.0.8.bak.apk，version.txt=1.0.9） |

### FCM 凭据获取（Android 推送启用步骤）

1. [Firebase 控制台](https://console.firebase.google.com) → 项目 `lumoguide` → 齿轮 → **项目设置** → **服务账号** → 「生成新的私钥」下载 JSON
2. 用 JSON 中三个字段填入生产 `/www/wwwroot/lumo_family/lumo_chat/apps/server/.env`：
   ```
   FCM_PROJECT_ID=<project_id>
   FCM_CLIENT_EMAIL=<client_email>
   FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   ```
   （`\n` 需为字面 `\n`，程序会自动还原）
3. `pm2 restart im-server --update-env` → 日志出现 `Composite push enabled: apns(ios), fcm(android)` 即生效

---

## 一、改动清单

### 1. LUMO-Chat 服务端（`~/Downloads/LUMO-Chat/apps/server`）

| 改动 | 文件 |
|------|------|
| 群名修改 `PUT /api/v1/groups/:id`（群主/管理员） | `src/modules/group/group.controller.ts`、`group.service.ts` |
| 扫码加群 `POST /api/v1/groups/:id/join`（幂等） | 同上 |
| 设备 token 表 `user_devices` + 实体 | `sql/init.sql`、`src/database/entities/user-device.entity.ts`、`entities/index.ts` |
| `POST/DELETE /api/v1/users/device-token`（platform: ios\|android） | `src/modules/user/user.controller.ts`、`user.service.ts`、`user.module.ts` |
| FCM 真实推送（firebase-admin，PUSH_PROVIDER=fcm） | `src/modules/push/fcm-push.service.ts`（原 skeleton 已实现）、`push.module.ts` |
| 管理端推送 `POST /api/v1/admin/push`（x-admin-token 鉴权，对接 Laravel `SystemMessage::sendPush`） | `src/modules/admin/admin.controller.ts`、`admin.module.ts`、`app.module.ts` |
| 新环境变量 | `apps/server/.env`、`.env.example`（ADMIN_TOKEN / FCM_SERVICE_ACCOUNT / FCM_SERVICE_ACCOUNT_PATH） |
| 依赖 | `firebase-admin@^14.3.0`（已加至 `apps/server/package.json`） |

### 2. Flutter App（`mobile/`）

| 改动 | 文件 |
|------|------|
| Android 推送（FCM） | `android/.../MyApplication.kt`（新增，修复 manifest 引用缺失）、`FcmService.kt`（新增）、`MainActivity.kt`（推送 MethodChannel）、`AndroidManifest.xml`（注册服务）、`lib/common/services/push.dart`（platform 上报） |
| 历史消息分页（上滑加载更早，cursor） | `lib/common/stores/chat.dart`（`fetchMessagePage`）、`lib/common/models/chat.dart`（`ChatMessagePage`）、`lib/pages/chat/controller.dart`、`page.dart` |
| 消息编辑 UI（长按菜单新增「编辑」+ 已編輯标记） | `lib/pages/chat/page.dart`、`controller.dart` |
| 群名修改 UI（接入真实接口） | `lib/pages/group_profile/page.dart`、`controller.dart`、`lib/common/stores/chat.dart`（`updateGroupTitle`） |
| 扫码加群（扫描群码确认后加入并进入聊天） | `lib/pages/message/controller.dart`、`lib/common/stores/chat.dart`（`joinGroup`） |
| 企业详情页聊天入口（AppBar 气泡按钮） | `lib/pages/company_info/page.dart`、`controller.dart`、`lib/common/models/company.dart`（`userNumber`） |
| 商家列表聊天入口（卡片图右上角气泡按钮） | `lib/pages/merchant_list/widgets/list.dart`、`lib/common/models/merchant_list.dart`（`userNumber`） |
| i18n 三语新增 10 个 key | `lib/common/langs/zh_TW.dart`、`zh_CN.dart`、`en_US.dart` |

### 3. Laravel 后端（`backend/`）

| 改动 | 文件 |
|------|------|
| `/company/info` 返回 `user_number`（企业详情聊天入口） | `app/Services/CompanyService.php` |
| 城市内容列表（餐厅/购物/住宿/票务/交通/设施/活动/景点）返回 `user_number` | `app/Services/CityService.php`（`getCityContentList`） |

---

## 二、部署步骤

### 1. LUMO-Chat 服务端（必须先部署，否则 App 端新功能报错）

```bash
cd ~/Downloads/LUMO-Chat

# ① 数据库：执行新表（user_devices）
#    生产库执行 apps/server/sql/init.sql 中的 user_devices 建表语句（CREATE TABLE IF NOT EXISTS 幂等）

# ② 配置 .env（apps/server/.env，生产同步到部署环境）
PUSH_PROVIDER=fcm                                  # 启用真实 FCM 推送
ADMIN_TOKEN=<与 Laravel .env 的 LUMO_CHAT_ADMIN_TOKEN 一致>
FCM_SERVICE_ACCOUNT_PATH=/path/to/service-account.json   # 或 FCM_SERVICE_ACCOUNT=<base64>

# ③ 构建并重启
cd apps/server && npm install && npm run build
# 重启服务（pm2 / systemd / docker 按现有部署方式）
```

> ⚠️ 部署后需验证：`POST /api/v1/groups/:id/join`、`PUT /api/v1/groups/:id`、`POST /api/v1/users/device-token` 均已存在（401 说明路由存在但需 token；404 说明未生效）。

### 2. Flutter App

```bash
cd mobile
flutter pub get
flutter build apk --release   # Android（需 android/key.jks 签名）
flutter build ipa            # iOS（如需）
```

### 3. Laravel 后端

```bash
cd backend
# 无需迁移；配置 / 路由无新增，直接发布即可
```

---

## 三、Firebase 凭据获取（Android 推送必需）

App 端 `google-services.json` 已就绪（Firebase 项目 `lumoguide`）。服务端 FCM 发送还需**服务账号私钥**：

1. 打开 [Firebase 控制台](https://console.firebase.google.com) → 项目 `lumoguide` → 齿轮图标 → **项目设置** → **服务账号** 标签页
2. 点击「**生成新的私钥**」→ 下载 JSON 文件
3. 部署时二选一：
   - 把 JSON 放到服务器，`.env` 配 `FCM_SERVICE_ACCOUNT_PATH=/path/to/file.json`
   - 或 `base64 -i service-account.json | tr -d '\n'` 后填入 `FCM_SERVICE_ACCOUNT=`
4. 重启 LUMO-Chat 服务；日志出现 `[fcm-push] app=... user=... → N/N delivered` 即生效

> 未配置凭据时服务**不会崩溃**：FcmPushService 仅记录 `FCM_SERVICE_ACCOUNT ... 未配置，Android 推送已禁用`，其余功能正常。

---

## 四、联调验证清单

> 以下为**自动化/接口级**验证（已全部通过）；**真机验收**见第五节。

| 功能 | 验证方法 |
|------|----------|
| 群名修改 | 群主进群详情 → 修改群名称 → 成功提示；消息大厅列表标题同步 |
| 扫码加群 | 群详情 → 群二维码 → 另一账号扫一扫 → 确认加入 → 进入群聊并收到历史消息 |
| Android 推送 | 登录后杀掉 App → 另一账号发消息 → 收到系统通知；点击通知进入对应会话 |
| 历史分页 | 会话消息 >50 条 → 上滑到顶自动加载更早消息 → 「沒有更多消息了」 |
| 消息编辑 | 长按自己的文本消息 → 编辑 → 修改内容 → 气泡显示「已編輯」 |
| 商家聊天 | 企业详情页右上角气泡按钮；商家列表卡片右上角气泡按钮 → 进入单聊 |
| 群公告 | 群主/管理员修改公告 → 重新进入群详情可见（已持久化，DB 直查一致） |

## 五、真机验收清单（上线前执行）

| # | 步骤 | 预期结果 |
|---|------|----------|
| 1 | Android 手机安装新版：`https://lumoguide.com/dl/app-release.apk`（版本 ≥ 1.0.9+30） | 安装成功，覆盖旧版升级 |
| 2 | 登录 → 首次启动允许「通知」权限 | 权限弹窗出现 |
| 3 | 确认 FCM token 已上报：服务器 `docker exec im-redis redis-cli -a im_redis_2024 --no-auth-warning HGETALL 'im:device_tokens:<app_id>:<user_number>'` | 存在 android 平台 token |
| 4 | 另一账号发送消息（App 切后台/杀掉） | Android 收到系统通知，标题含发送者名 |
| 5 | 点击通知 | 进入对应聊天会话 |
| 6 | 消息 >50 条的会话上滑到顶 | 自动加载更早消息，最终显示「沒有更多消息了」 |
| 7 | 长按自己的文本消息 → 编辑 → 保存 | 气泡内容更新并显示「已編輯」 |
| 8 | 群主修改群名 / 群公告 | 群详情即时更新，刷新不丢失 |
| 9 | 扫群二维码 → 确认加入 | 加入群聊，能收历史+实时消息 |
| 10 | 企业详情页 / 商家列表 | 右上角/卡片出现气泡聊天按钮，点击进入单聊 |
| 11 | iOS 设备同测 1-2、4-5（APNs） | iOS 通知正常（生产 composite apns 通道） |
| 12 | 切换 App 语言为 English | 所有聊天/群组界面无繁体中文残留 |

> 服务器监控：`pm2 logs im-server --lines 20 --nostream` 应见 `[fcm-push] ... delivered`（Android）与 APNs delivery 日志。

---

## 六、已知限制（本次未处理）

- **消息状态显示**：SENT/DELIVERED/READ 未渲染；发送失败无本地重试/失败标记。
- **消息类型**：仅文本/图片；语音/文件/视频仍未实现。
- **删除会话**：仍为本地删除（LUMO-Chat 无删除会话接口），刷新后重现。
- **common_detail 联系方式**：`sendEmail()/openWebsite()/openCompany()` 为空 stub。
- **群名/公告修改无 socket 广播**：其他成员需重新进入群详情看到更新。
