# LUMOGUIDE 测试套件

本目录汇总前后端的回归测试。**任何代码改动、部署、构建之后，运行对应套件排查问题。**

## 套件一览

| 套件 | 位置 | 运行方式 | 覆盖范围 | 副作用 |
|---|---|---|---|---|
| 后端 API 回归测试 | `backend/tests/Feature/` | `php vendor/bin/phpunit`（在 backend/ 下） | 注册/登录/注销/验证码/城市/通用/积分/资讯接口业务逻辑 | 无（SQLite 内存库 + 外部服务打桩） |
| 线上冒烟测试 | `tests/smoke/run.sh` | `bash tests/smoke/run.sh` | 线上站点：页面、bundle 产物、公开 API、上传文件、安全头、错误处理 | 无（只读请求） |
| 前端构建校验 | `tests/frontend/check_build.mjs` | `node tests/frontend/check_build.mjs` | dist 产物完整性、资源引用、JS 语法 | 无 |
| 移动端 Flutter 测试 | `tests/mobile/run.sh` | `bash tests/mobile/run.sh` | mobile/ 应用单元/组件测试 | 无 |

## 后端 API 回归测试

```bash
cd /www/wwwroot/lumo_family/lumo_guide/backend
su -s /bin/bash www -c "php vendor/bin/phpunit --do-not-cache-result"
```

- 运行环境：`phpunit.xml` 强制 SQLite 内存库（`:memory:`）、array 缓存、sync 队列、array 邮件 —— **绝不触碰生产 MySQL / Redis / 腾讯 IM**。
- Redis 与腾讯 IM 在测试中被 mock（`tests/Feature/FeatureTestCase.php`）。
- 必须以 `www` 用户运行（root 运行会产生 root 属主文件，破坏线上日志写入）。
- 每次改完 API 代码后运行。单文件：`phpunit --filter AuthRegisterTest`。

### 已覆盖的关键回归点

- **账号删除修复**：`delAccount` 硬删除、注销邮箱可立即重注册、sendCode/register 忽略软删除记录
- **积分明细字段契约**：`/api/integral/userDetails` 必须返回 `type` 与 `amount`（前端积分页依赖）
- **认证链路**：JWT 登录返回 token/user_sig/user_number、未授权业务码 401、无效 token 401、限流 429
- **密码重置全链路**：forget 验证码 → 重置 → 新密码登录 / 错误验证码 / 未知邮箱
- **用户中心**：地址 CRUD（含国家码手机号校验）、资料编辑、联系客服、反馈、绑定邀请人
- **我的历程**：历程与工作模板 CRUD、未授权拦截
- **预约导游**：预约流程、VIP 校验、必填校验、不存在导游拒绝
- **移动端支撑**：appError 上报、深度链接创建/查询/非法参数、支付回调优雅拒绝、分享二维码鉴权
- **前后端契约**：urls.js 中 ~110 个前端调用路径必须全部在后端注册（曾抓到 /common/getCountry 死条目）
- **公开接口结构**：城市、通用、资讯各接口返回 `{code, message, data}` 结构

## 线上冒烟测试

```bash
bash /www/wwwroot/lumo_family/lumo_guide/tests/smoke/run.sh
```

- 每次 **部署/切换代码之后** 运行（包括 nginx 配置、构建、迁移）。
- 已知行为：无效 API 路径返回 nginx 404 页（`fastcgi_intercept_errors` 配置所致），冒烟测试按 404 断言。

## 前端构建校验

```bash
node /www/wwwroot/lumo_family/lumo_guide/tests/frontend/check_build.mjs
```

- 前端重新构建（`node frontend/build.mjs`）后运行，确认 dist 产物完整、未回退到源文件引用、JS 无语法错误。

## 移动端 Flutter 测试

```bash
bash /www/wwwroot/lumo_family/lumo_guide/tests/mobile/run.sh
```

- 移动端代码改动后运行。首次运行含依赖拉取，耗时较长。

## 建议流程

1. **改代码后**：后端改动 → phpunit；前端改动 → check_build.mjs + 冒烟；移动端改动 → flutter test。
2. **部署/上线后**：冒烟测试（验证 nginx、构建产物、公开接口、上传文件全链路）。
3. **任何测试失败**：优先看失败用例名称定位模块，再查 `backend/storage/logs/` 与 `/www/wwwlogs/` 日志。
