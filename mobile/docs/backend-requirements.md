# LUMOTRIP 后端修改需求清单

> 基于前端代码全面扫描结果，整理所有需要后端配合修改的事项。
> 扫描日期：2026-07-21 | 前端版本：1.0.6+19

---

## 一、API 未对接（需后端提供接口）

### 1.1 我的历程 — 工作日增删改查

**优先级：最高**

| 需求 | 说明 |
|------|------|
| 当前状态 | 全部使用 `JourneyWork.mockData()` 硬编码的 4 条数据（`lib/common/models/journey_work.dart:389-517`），128 行硬编码 |
| 涉及文件 | `lib/pages/journey/controller.dart:43`，`lib/pages/journey_detail/controller.dart:32` |

需要以下接口：

| 接口 | 方法 | 路由建议 | 说明 |
|------|------|---------|------|
| 工作列表 | GET | `/user/journeyList` | 已在 `ApiUrl.userJourneyList` 定义，支持分页、状态/区域筛选、关键词搜索 |
| 工作详情 | GET | `/user/journeyDetail` | 按 id 查询单个 JourneyWork |
| 创建工作 | POST | `/user/journeyCreate` | 提交 JourneyWork 完整 JSON |
| 更新工作 | PUT | `/user/journeyUpdate` | 按 id 更新 |
| 删除工作 | DELETE | `/user/journeyDelete` | 按 id 删除 |

**注意：** 前端 `onSubmit()`（`lib/pages/journey_editor/controller.dart:714-718`）目前仅做本地校验后就提示"成功"并关闭页面，**没有实际调用任何 API**。

### 1.2 工作模板 — 增删查

**优先级：高**

当前模板数据完全存储在本地 `SharedPreferences`（`lib/pages/journey/widgets/template_picker_sheet.dart`），换设备即丢失。

| 接口 | 方法 | 路由建议 | 说明 |
|------|------|---------|------|
| 模板列表 | GET | `/user/journeyTemplateList` | 获取用户保存的模板 |
| 保存模板 | POST | `/user/journeyTemplateSave` | 从 JourneyWork 创建模板 |
| 删除模板 | DELETE | `/user/journeyTemplateDelete` | 按 id 删除 |

### 1.3 客户行程生成/分享

**优先级：中**

`onGenerateClientItinerary()` 目前纯前端生成（PNG/PDF/Word），未调后端。如果需要服务端生成分享码或持久化客户行程：

| 接口 | 方法 | 路由建议 | 说明 |
|------|------|---------|------|
| 生成客户行程 | POST | `/user/clientItineraryCreate` | 生成分享码等 |
| 通过分享码查看 | GET | `/clientItinerary/{code}` | 客户免登录查看 |

---

## 二、API 返回字段缺失

### 2.1 城市列表缺少国家信息（最影响用户体验）

**优先级：最高**

| 当前 API | 问题 |
|----------|------|
| `GET /city/lists` | 只返回 `area_id`/`area_name`（如"中歐""東歐"），**`country` 字段始终为空** |

**影响范围：**

| 页面 | 文件 | 当前表现 |
|------|------|---------|
| 城市浏览页 | `lib/pages/city/widgets/list.dart:158` | 显示 `areaName`（如"中歐"），用户看不到"德国""奥地利"等国家名 |
| 旅程编辑器 — 城市选择器 | `lib/pages/journey_editor/controller.dart:173-177` | 前端已通过 `/manage/systemContinents` 做了**临时补丁**映射 cityId→国家，但补丁复杂且局限于编辑器页面 |
| 旅程编辑器 — 标签显示 | `lib/pages/journey_editor/page.dart:240` | 直接读 `city.country` 字段，为空时不显示国家 |

**期望修改：** `/city/lists` 的返回数据中直接填充 `country` 字段（或增加 `country_id`/`country_name`），让城市直接关联所属国家。

### 2.2 systemContinents 接口应纳入标准 API 路径

**优先级：中**

| 当前 | 问题 |
|------|------|
| `https://api.lumoguide.com/manage/systemContinents` | 硬编码完整 URL（`lib/common/apis/urls.dart:56`），不走 `apiUrl` 前缀，与其他接口风格不一致 |

**期望修改：** 将此接口纳入标准 `/api/` 或 `/manage/` 路径，或者确认该接口是管理后台接口、前端不应直接调用。

---

## 三、API 响应格式不一致

### 3.1 `list` 字段名不统一

**优先级：中**

绝大部分接口返回列表数据时，key 是 `list`（单数），前端代码中有 30+ 处使用 `res.dataJson['list']`。

但"我的发布"系列接口使用的是 `data` 作为列表 key：

| 文件 | 使用的 key |
|------|-----------|
| `my_publish_city/controller.dart:36` | `res.dataJson['data']` |
| 5 个 `my_publish/widgets/*_list.dart` | `res.dataJson['data']` |

**期望：** 确认"我的发布"系列接口是否确实返回 `{"data": [...]}`而非 `{"list": [...]}`。建议统一为 `list` 以消除混淆。

### 3.2 11 处缺少 null 安全降级

**优先级：低**

以下文件使用 `res.dataJson['list'] as List<dynamic>` 无 `?? []` 降级，当 API 返回格式异常时会直接崩溃：

| 文件 | 行号 |
|------|------|
| `common_detail/controller.dart` | 527 |
| `comment/controller.dart` | 70, 84 |
| `evaluate_list/controller.dart` | 48, 64 |
| `shipping_address/controller.dart` | 26 |
| `news_detail/controller.dart` | 75 |
| `integral_goods_exchange/controller.dart` | 81 |
| `invite/controller.dart` | 377 |
| `integral_exchange_record/controller.dart` | 21 |
| `merchant_management/controller.dart` | 79 |

---

## 四、字段命名/类型不匹配

### 4.1 ShippingAddress 的 `default` 字段

**优先级：中**

`lib/common/models/shipping_address.dart:27`:
```dart
isDefault: json['default']  // Dart 关键字冲突，API 字段名是 "default"
```

如果 API 后续改为 `is_default`（更规范的命名），前端将读取失败。建议后端确认字段名为 `is_default` 并前端同步修改。

### 4.2 MerchantShop.toJson() 注释掉的字段

**优先级：低**

`lib/common/models/merchant_shop.dart:105-107` 中 `audit_status`、`audit_feedback`、`created_at` 等字段被注释掉不参与序列化回传。确认后端是否不需要这些字段，还是前端遗漏。

---

## 五、硬编码敏感信息

### 5.1 Stripe 生产密钥硬编码

**优先级：高（安全）**

`lib/common/services/stripe.dart:33`:
```dart
const String stripePublishableKey = 'pk_live_51RkgWL...';
```

这是 Stripe 生产环境 live key，硬编码在源码中。**建议移到后端 `/common/config` 接口返回**，前端动态获取。

### 5.2 Debug 模式预填登录凭据

**优先级：中（安全）**

`lib/pages/login/controller.dart:31-42`:
```dart
if (kDebugMode) {
  email.value = 'zhouguanpei@hotmail.com';
  password.value = 'zhou123';
}
```

Debug 构建中预填真实账号密码，如果 Debug APK 泄露可能造成安全隐患。建议改为测试账号。

---

## 六、禁用功能待开启

**优先级：低（需确认产品计划）**

`lib/pages/mine/controller.dart` 中以下菜单项在所有用户角色下都被注释掉：

| 菜单 | 枚举值 | 状态 |
|------|--------|------|
| LuMoFun | `MineMenu.fun` | 第 13/30/40 行注释，全部禁用 |
| 兑换记录 | `MineMenu.exchange` | 第 19/32/42 行注释，全部禁用 |
| 发布城市（导游） | `MineMenu.publishCity` | 第 13 行注释 |

**期望：** 确认这些功能是否需要上线。如果需要，后端需确认对应 API 已就绪；如果不需要，前端可清理相关代码。

---

## 七、其他后端相关建议

### 7.1 API timeout 过短

`lib/common/apis/provider.dart:13-15` 中 connect/receive/send timeout 均为 60 秒。对于文件上传或复杂查询，60 秒可能不够。建议评估是否需要调大或按接口区分 timeout。

### 7.2 分页 limit 不一致

| 文件 | limit 值 |
|------|---------|
| city_detail 各种 fetch | `const limit = 100` |
| CityListStore | 1000 |
| journey_editor | 1000 |
| shopping | 10 |

建议后端统一分页上限（如 100），前端统一 limit 值。

### 7.3 错误信息国际化

当前 `ApiResult.failure`（`lib/common/apis/result.dart:62-69`）从 DioException 提取错误信息，后端返回的 `message` 字段是中文。建议后端错误信息支持多语言（根据请求 Accept-Language 头）。

---

## 八、优先级汇总

| 优先级 | 事项 | 分类 |
|--------|------|------|
| **P0-最高** | 提供 JourneyWork 增删改查 API | 未对接 |
| **P0-最高** | `/city/lists` 返回 `country` 字段 | 字段缺失 |
| **P1-高** | 提供 JourneyTemplate API | 未对接 |
| **P1-高** | Stripe Key 移到后端配置 | 安全 |
| **P2-中** | "我的发布"系列 `list` vs `data` key 统一 | 格式不一致 |
| **P2-中** | systemContinents 纳入标准路径 | 架构一致性 |
| **P2-中** | ShippingAddress `default` 字段名确认 | 命名对齐 |
| **P2-中** | Debug 凭据改为测试账号 | 安全 |
| **P3-低** | 11 处 null 安全降级（前端可自行修复） | 容错性 |
| **P3-低** | 分页 limit 值统一 | 一致性 |
| **P3-低** | 禁用功能确认去留 | 产品决策 |
