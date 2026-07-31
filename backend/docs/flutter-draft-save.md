# Flutter 端草稿自动保存 — 修改文档

## 概述

在导游认证和企业入駐表单中添加草稿自动保存/恢复功能。用户填写表单后离开，再次进入时提示是否继续编辑。

Web 端已实现（`frontend/js/pages/guide/certify.js`、`merchant/entry.js`），Flutter 端需同步。

## 涉及页面

| 页面 | 路由 | 存储 Key |
|------|------|----------|
| 导游认证 | 导游认证申请页 | `guide_certify_draft` |
| 企业入駐 | 企业入駐申请页 | `merchant_entry_draft` |

## 行为逻辑

### 自动保存
- 监听表单所有字段变化（文本、选择、图片），400ms 防抖后保存到本地存储
- **不保存** blob URL 或本地文件路径（图片只保存已上传的服务器 URL）
- **不保存** 空草稿（所有字段为空 + 无图片时跳过）
- 已提交/已审核状态（只读模式）不触发保存

### 恢复提示
- 进入页面 → 加载已有申请数据 → 检查本地是否有草稿
- 如果存在草稿 **且** 当前不是只读模式 → 显示提示卡片：
  - "偵測到未完成的認證資料，是否繼續編輯？"（导游）
  - "偵測到未完成的入駐資料，是否繼續編輯？"（企业）
- 用户点击「繼續編輯」→ 恢复草稿数据到表单
- 用户点击「重新填寫」→ 删除草稿，保留当前表单数据

### 清除时机
- 用户点击「重新填寫」
- 表单提交成功后

## 存储数据结构

### 导游认证 (`guide_certify_draft`)

```json
{
  "form": {
    "name": "",
    "name_en": "",
    "phone": "",
    "email": "",
    "bill_address": "",
    "wechat": "",
    "whats_app": "",
    "line": "",
    "other_contact": "",
    "invite_code": "",
    "photo": "https://...",
    "year": "",
    "identity_type": "",
    "introduction": "",
    "business_contact": "",
    "have_vehicle": 0,
    "vehicle_rent": 0,
    "vehicle_info": "",
    "other_type": "",
    "certificate_picture": "https://...",
    "passport_picture": "https://...",
    "driver_license_front": "https://...",
    "driver_license_back": "https://..."
  },
  "selectedLangs": ["中文", "英文"],
  "selectedTypes": ["當地導遊"],
  "photoPreview": "https://...",
  "carPics": ["https://..."]
}
```

### 企业入駐 (`merchant_entry_draft`)

```json
{
  "form": {
    "name": "",
    "name_en": "",
    "contact_name": "",
    "phone": "",
    "email": "",
    "country": "",
    "address": "",
    "introduction": "",
    "city_id": "",
    "tax_id": "",
    "website": "",
    "wechat": "",
    "whats_app": "",
    "line": "",
    "other_contact": "",
    "contact_phone": "",
    "contact_email": "",
    "photo": "https://...",
    "license": "https://...",
    "id_card_front": "https://...",
    "id_card_back": "https://..."
  },
  "selectedTypes": ["餐廳", "住宿"],
  "storePics": ["https://...", "https://..."]
}
```

## Flutter 实现要点

### 1. 本地存储
使用 `shared_preferences` 存储 JSON 字符串（数据结构简单，不需要 SQLite）。

```dart
// 读取
final json = prefs.getString('guide_certify_draft');
if (json != null) {
  final draft = jsonDecode(json);
}

// 写入
prefs.setString('guide_certify_draft', jsonEncode(draft));

// 删除
prefs.remove('guide_certify_draft');
```

### 2. 防抖监听
对表单字段集合添加 400ms 防抖监听。表单控制器变化 → 重置防抖定时器 → 400ms 后执行保存。

### 3. 草稿检测时机
在 `initState` 中：
1. 先加载已有申请数据（API 调用）
2. 如果返回的是待审核/已通过状态 → 不检测草稿
3. 否则调用 `checkDraft()` 检测本地草稿

### 4. 图片字段处理
- **已上传的图片**（有服务器 URL）：保存 URL 到草稿
- **新选择但未上传的图片**（File/XFile 对象或本地路径）：**不保存**（页面刷新后无效）
- 恢复时只恢复 URL 字符串，用户需重新上传的图片字段保持空

### 5. 草稿提示 UI
进入页面后在表单上方显示一个卡片：
- 背景色：浅紫色（`#EEEDFF` 或 `Color(0xFF666FFF).withOpacity(0.08)`）
- 左边文字，右边两个按钮：「繼續編輯」「重新填寫」
- 参考 Web 端样式

## 测试用例

1. 填写一半 → 退出页面 → 重新进入 → 应弹出提示
2. 点击「繼續編輯」→ 之前填写的内容应恢复
3. 点击「重新填寫」→ 草稿清除，表单保留 API 返回的原始数据
4. 提交成功 → 再次进入 → 不应弹出提示
5. 已审核通过 → 进入页面 → 不应弹出提示（只读模式）
6. 完全空白 → 退出 → 再次进入 → 不应弹出提示（空草稿不保存）
