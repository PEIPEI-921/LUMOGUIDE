# 「我的历程」工作日历 — 完整实施计划 v2

> **For Hermes:** 按此计划逐 Phase 执行，每个 Phase 完成后请冠培确认再继续。

**核心定位：** 「我的历程」是导游的 **工作中枢** —— 不只记录工作，而是「工作创建 → 信息整合 → 客户服务」的全链路工具。

---

## 用户需求完整梳理

### 工作创建（3 种方式 + 1 种自动）
| # | 方式 | 说明 |
|---|------|------|
| A | **手动创建** | 已有 journey_editor，填写表单新建 |
| B | **模板复用** | 从历史行程克隆，修改日期后一键生成 |
| C | **扫描导入** | 拍照/上传旅行社 itinerary PDF，OCR 自动提取 |
| D | **预约同步** | 导游/商户确认预约后自动进日历 |

### 信息整合
- 工作详情 → 城市资源（景点/活动/商家）交叉查看
- 全 App 任意位置 → 可回到所属工作上下文

### 客户服务（⭐ 核心新需求）
- 导游从工作数据一键生成**客制化行程建议**
- 面向客人展示，带日行程安排、景点图片、实用贴士
- 支持分享（链接/PDF/保存）

---

## 整体架构

```
                        ┌─────────────────────┐
                        │   我的历程 (Journey)    │
                        │   工作日历 + 列表        │
                        └──────────┬──────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
     ┌────────▼────────┐  ┌───────▼───────┐  ┌────────▼────────┐
     │   工作创建        │  │   工作详情      │  │   客户行程        │
     │                  │  │               │  │                  │
     │ A 手动           │  │ 行程概览       │  │ 日行程安排        │
     │ B 模板复用       │  │ 城市资源 Tab   │  │ 景点/活动/商家     │
     │ C 扫描导入 ──NEW │  │ 备注与操作     │  │ 天气/贴士/地图     │
     │ D 预约同步       │  │               │  │ 分享导出 ──NEW    │
     └─────────────────┘  └───────────────┘  └──────────────────┘
              │                    │                    │
              └────────────────────┼────────────────────┘
                                   │
                         ┌────────▼────────┐
                         │   后端 API        │
                         │   /user/journey*  │
                         │   /user/itinerary*│
                         └──────────────────┘
```

---

## Phase 1: 数据模型全面升级

### Task 1.1: 扩展 JourneyWork（工作主模型）
**文件：** `lib/common/models/journey_work.dart`

```dart
class JourneyWork {
  // === 现有字段 ===
  int? id;
  String? title;
  String? region;
  int? status;
  int? peopleCount;
  String? startDate;
  String? endDate;
  List<String> cities;
  String? departureCity;
  String? arrivalMethod;
  String? arrivalTime;
  String? arrivalLocation;
  String? endCity;
  String? departureMethod;
  String? description;
  String? createdAt;
  bool isFromBooking;

  // === 新增：创建来源 ===
  String? sourceType;        // 'manual' | 'template' | 'scan' | 'booking'
  int? sourceTemplateId;     // 模板 ID（模板复用时）
  int? sourceBookingId;      // 预约 ID（预约同步时）
  String? sourceBookingType; // 'guide' | 'merchant'

  // === 新增：关联资源 ===
  List<int>? attractionIds;
  List<int>? activityIds;
  List<int>? merchantIds;
  List<int>? facilityIds;

  // === 新增：日行程明细 ===
  List<ItineraryDay>? itineraryDays;  // 每日安排

  // === 新增：客户行程 ===
  bool hasClientItinerary;           // 是否已生成客户行程
  String? clientItineraryShareCode;  // 分享码
}
```

### Task 1.2: 新建 ItineraryDay 模型（日行程）
**新建：** `lib/common/models/itinerary_day.dart`

```dart
/// 行程中的一天
class ItineraryDay {
  int? id;
  int dayNumber;            // 第几天
  String? date;             // 日期
  String? theme;            // 当日主题（如「罗马古城探秘」）
  List<ItineraryItem> items; // 当日活动列表
  String? hotelName;        // 住宿
  String? meals;            // 餐饮（早餐/午餐/晚餐推荐）
  String? weatherTip;       // 天气提示
  String? transportTip;     // 交通提示
}

/// 单个行程项目
class ItineraryItem {
  String? time;             // 时间（如 09:00）
  String? title;            // 活动名称
  String? type;             // 'attraction' | 'activity' | 'meal' | 'transport' | 'free'
  String? description;      // 描述
  String? imageUrl;         // 配图
  int? resourceId;          // 关联 App 内资源 ID
  String? resourceType;     // 资源类型
  Duration? duration;       // 预计时长
  String? note;             // 导游备注
}
```

### Task 1.3: 新建 JourneyTemplate 模型（行程模板）
**新建：** `lib/common/models/journey_template.dart`

```dart
/// 可复用的行程模板
class JourneyTemplate {
  int? id;
  String title;
  String? region;
  List<String> cities;
  int? defaultDays;         // 默认天数
  List<ItineraryDay>? itineraryDays; // 模板日行程（日期占位符）
  int useCount;             // 使用次数
  String? createdAt;
  int? sourceWorkId;        // 来源工作 ID
}
```

### Task 1.4: 新建扫描行程模型（OCR 结果）
**新建：** `lib/common/models/scanned_itinerary.dart`

```dart
/// OCR 扫描识别结果
class ScannedItinerary {
  String? rawText;              // OCR 原始文本
  String? imagePath;            // 原始图片路径
  List<ScannedDay>? days;       // 识别出的每日安排
  double confidence;            // 识别置信度
  List<FieldCorrection>? corrections; // 用户修正记录
}

class ScannedDay {
  String? date;
  List<ScannedItem>? items;
  String? hotelName;
}

class ScannedItem {
  String? time;
  String? activity;
  String? location;
  String? note;
}
```

---

## Phase 2: 工作创建 — 模板复用 (方式 B)

### Task 2.1: 模板列表页
**新建：** `lib/pages/journey_template/` （page + controller + index）

功能：
- 显示导游保存的行程模板列表
- 每个模板卡片显示：标题、城市、天数、使用次数
- 点击进入模板预览
- 支持从历史工作「保存为模板」

### Task 2.2: 从工作保存为模板
**文件：** `lib/pages/journey_detail/page.dart`

在工作详情页操作区增加「保存为模板」按钮：
```dart
void onSaveAsTemplate() {
  // POST /user/journeyTemplate/create
  // 保存当前工作的 itineraryDays 为模板（清除具体日期）
}
```

### Task 2.3: 模板复用创建
**文件：** `lib/pages/journey_editor/controller.dart`

在编辑器增加「从模板创建」入口：
```dart
void loadFromTemplate(JourneyTemplate template) {
  // 1. 加载模板的 itineraryDays
  // 2. 用户选择新日期
  // 3. 自动计算每天日期、人数等
  // 4. 允许修改后保存
  // 生成新 JourneyWork，sourceType = 'template'
}
```

### Task 2.4: 模板列表 API
**文件：** `lib/common/apis/urls.dart`
```dart
static const journeyTemplateList = '/user/journeyTemplate/list';
static const journeyTemplateCreate = '/user/journeyTemplate/create';
static const journeyTemplateDelete = '/user/journeyTemplate/delete';
```

---

## Phase 3: 工作创建 — 扫描导入 (方式 C) ⭐ 重点

### Task 3.1: 扫描入口页面
**新建：** `lib/pages/journey_scan/` （page + controller）

流程设计：
```
拍照/选图 → OCR 识别 → 预览修正 → 确认导入
```

UI 布局：
- 顶部：相机拍照 / 相册选取按钮
- 中部：已选图片预览区
- 底部：识别结果预览（可编辑的日行程列表）
- 底部按钮：「确认导入」

### Task 3.2: OCR 识别集成
**文件：** `lib/pages/journey_scan/controller.dart`

方案选择（需冠培确认）：
- **方案 A：** 后端 OCR（推荐）—— 图片上传后端，调用 OCR 服务返回结构化数据
- **方案 B：** 前端 OCR —— 用 `google_mlkit_text_recognition` 本地识别，前端解析

推荐方案 A，原因：
- 后端可以做更精准的行程格式解析
- 不受设备性能限制
- 可以持续优化识别模型

```dart
Future<ScannedItinerary> scanImage(File image) async {
  // POST /user/journey/scan (multipart upload)
  // 返回 ScannedItinerary
}
```

### Task 3.3: 扫描结果修正页
**新建：** `lib/pages/journey_scan/widgets/scan_correction.dart`

让导游修正 OCR 识别结果：
- 日期修正（日期选择器）
- 活动时间修正
- 活动名称修正
- 添加/删除活动项
- 关联城市选择

### Task 3.4: 确认导入
修正完成后，将 ScannedItinerary 转为 JourneyWork：
- `sourceType = 'scan'`
- cities 从扫描结果推断
- itineraryDays 从修正后的数据生成
- 保存后跳转到工作详情

### Task 3.5: 扫描 API
```dart
static const journeyScan = '/user/journey/scan';        // POST 图片 OCR
static const journeyScanConfirm = '/user/journey/scanConfirm'; // POST 确认导入
```

---

## Phase 4: 客户行程生成 (⭐ 核心新功能)

### Task 4.1: 客户行程数据模型
**新建：** `lib/common/models/client_itinerary.dart`

```dart
/// 面向客户的行程文档
class ClientItinerary {
  int? id;
  int journeyWorkId;
  String title;               // 行程标题（如「罗马 5 天 4 晚深度游」）
  String? coverImageUrl;      // 封面图
  String? greeting;           // 欢迎语
  List<ClientItineraryDay> days;
  String? closingNote;        // 结束语
  String? guideName;          // 导游姓名
  String? guideContact;       // 导游联系方式
  String? shareCode;          // 分享码
  String? shareUrl;           // 分享链接
  String? pdfUrl;             // PDF 下载链接
  String? createdAt;
}

class ClientItineraryDay {
  int dayNumber;
  String date;
  String? theme;
  String? morningActivity;    // 上午
  String? lunchRecommendation; // 午餐推荐
  String? afternoonActivity;  // 下午
  String? dinnerRecommendation; // 晚餐推荐
  String? eveningActivity;    // 晚上
  String? hotelName;
  String? weatherTip;
  String? transportTip;
  String? imageUrl;
  List<String>? highlights;   // 亮点标签
  String? guideNote;          // 导游私密备注（仅导游可见）
}
```

### Task 4.2: 从工作生成客户行程
**新建：** `lib/pages/client_itinerary_editor/` （page + controller）

生成逻辑：
```
JourneyWork → ClientItinerary
  1. 标题自动生成：「{城市} {天数}天 {天数-1}晚 {主题}游」
  2. 封面图从城市图片库选取
  3. 每日行程从 ItineraryDay 转换
  4. 自动补充城市介绍、天气提示
  5. 导游可编辑所有内容
```

编辑功能：
- 修改每日活动描述（面向客人的语言风格）
- 添加/删除日行程
- 添加导游备注（仅自己可见）
- 预览客人视角

### Task 4.3: 客户行程预览页
**新建：** `lib/pages/client_itinerary_preview/`

客人视角的完整行程展示：
- 封面区（标题 + 城市大图）
- 行程概览（天数、城市、亮点标签）
- 日行程时间轴（纵向滚动）
- 每日卡片：上午-午餐-下午-晚餐-晚上
- 实用信息（天气、交通、注意事项）
- 导游联系方式

风格设计：干净优雅，可截图分享，适合发给客户

### Task 4.4: 分享与导出
**文件：** `lib/pages/client_itinerary_preview/`

分享方式：
| 方式 | 说明 |
|------|------|
| 分享链接 | 生成 Web 链接，客人浏览器打开 |
| 保存图片 | 生成长图（截图分享到微信） |
| 导出 PDF | 后端生成 PDF，下载分享 |
| App 内分享 | 通过腾讯 IM 发送给联系人 |

```dart
// 分享操作
void onShare(ClientItinerary itinerary) {
  showModalBottomSheet(
    // 四个选项：复制链接 / 保存图片 / 导出PDF / 发送给联系人
  );
}
```

### Task 4.5: 客户行程 API
```dart
static const clientItineraryGenerate = '/user/clientItinerary/generate'; // POST 生成
static const clientItineraryDetail = '/user/clientItinerary/detail';     // GET 详情
static const clientItineraryUpdate = '/user/clientItinerary/update';     // PUT 更新
static const clientItineraryShare = '/user/clientItinerary/share';       // POST 生成分享链接
static const clientItineraryPdf = '/user/clientItinerary/pdf';           // GET 下载PDF
static const clientItineraryView = '/user/clientItinerary/view';         // GET 公开查看
```

---

## Phase 5: 工作详情页重构

### Task 5.1: 详情页 Tab 结构
**文件：** `lib/pages/journey_detail/page.dart`

重构为 4 个 Tab：

| Tab | 内容 |
|-----|------|
| Tab 1: 行程概览 | 基本信息、日行程时间轴、预约来源 |
| Tab 2: 城市资源 | 按城市分组展示景点/活动/商家（点击跳转） |
| Tab 3: 客户行程 | 如已生成 → 预览 + 分享入口；未生成 →「生成客户行程」按钮 |
| Tab 4: 操作 | 编辑、保存为模板、删除 |

### Task 5.2: 城市资源 Tab
**新建：** `lib/pages/journey_detail/widgets/city_resources.dart`

### Task 5.3: 客户行程 Tab
从工作详情直接查看/管理客户行程。

---

## Phase 6: 预约同步 + 全 App 融合

### Task 6.1: 预约确认 → 自动同步
- 导游确认预约 → `syncFromBooking()`
- 商户确认预约 → 同上
- 后端 `source_booking_id` 去重

### Task 6.2: 全 App 返回工作上下文
- 城市详情页 → 「相关工作」区块
- 通用详情页 → 返回面包屑
- 商家列表 → 返回面包屑

---

## Phase 7: 日历增强

- 月视图工作密度指示
- 今日快捷入口
- 周视图（可选）

---

## Phase 8: 后端 API 完整清单

| 端点 | 方法 | Phase | 说明 |
|------|------|-------|------|
| `/user/journeyList` | GET | P8 | 工作列表 |
| `/user/journeyDetail` | GET | P8 | 工作详情 |
| `/user/journeyCreate` | POST | P8 | 手动创建 |
| `/user/journeyUpdate` | PUT | P8 | 更新工作 |
| `/user/journeyDelete` | DELETE | P8 | 删除工作 |
| `/user/journeySync` | POST | P6 | 预约同步 |
| `/user/journeyCityResources` | GET | P5 | 城市关联资源 |
| `/user/journey/scan` | POST | P3 | 扫描 OCR |
| `/user/journey/scanConfirm` | POST | P3 | 确认扫描导入 |
| `/user/journeyTemplate/list` | GET | P2 | 模板列表 |
| `/user/journeyTemplate/create` | POST | P2 | 创建模板 |
| `/user/journeyTemplate/delete` | DELETE | P2 | 删除模板 |
| `/user/clientItinerary/generate` | POST | P4 | 生成客户行程 |
| `/user/clientItinerary/detail` | GET | P4 | 客户行程详情 |
| `/user/clientItinerary/update` | PUT | P4 | 更新客户行程 |
| `/user/clientItinerary/share` | POST | P4 | 生成分享链接 |
| `/user/clientItinerary/pdf` | GET | P4 | 导出 PDF |
| `/user/clientItinerary/view` | GET | P4 | 公开查看 |

---

## 新建文件清单

```
lib/
├── common/
│   └── models/
│       ├── itinerary_day.dart          (NEW)
│       ├── client_itinerary.dart       (NEW)
│       ├── journey_template.dart       (NEW)
│       └── scanned_itinerary.dart      (NEW)
└── pages/
    ├── journey/
    │   └── widgets/
    │       └── work_density.dart       (NEW)
    ├── journey_detail/
    │   └── widgets/
    │       └── city_resources.dart     (NEW)
    ├── journey_template/               (NEW - page+controller+index)
    ├── journey_scan/                   (NEW - page+controller+index)
    │   └── widgets/
    │       └── scan_correction.dart    (NEW)
    ├── client_itinerary_editor/        (NEW - page+controller+index)
    └── client_itinerary_preview/       (NEW - page+controller+index)
```

## 修改文件清单

```
lib/
├── common/models/journey_work.dart     (扩展字段)
├── common/apis/urls.dart               (新增 16 个端点)
├── common/routers/pages.dart           (新增 5 个路由)
├── common/routers/names.dart           (新增路由常量)
├── pages/journey/page.dart             (日历增强 + 创建方式入口)
├── pages/journey/controller.dart       (新增模板/scanner入口)
├── pages/journey_detail/page.dart       (重构为4 Tab)
├── pages/journey_detail/controller.dart (城市资源API)
├── pages/journey_editor/controller.dart (模板加载)
├── pages/city_detail/page.dart         (相关工作区块)
├── pages/common_detail/page.dart       (返回面包屑)
├── pages/merchant_list/page.dart       (返回面包屑)
├── pages/guide_booking_detail/         (预约确认后同步)
└── pages/merchant_booking_detail/      (预约确认后同步)
```

---

## 执行顺序（建议）

```
P1 模型 ──→ P2 模板复用 ──→ P3 扫描导入 ──→ P4 客户行程
                                              │
                                              ▼
                P8 API ←── P7 日历 ←── P6 融合 ←── P5 详情重构
```

**推荐分三批实施：**

| 批次 | 内容 | 价值 |
|------|------|------|
| **第一批** | P1 模型 + P5 详情页 + P2 模板复用 | 立即可用的功能升级 |
| **第二批** | P3 扫描导入 + P4 客户行程 | 核心差异化功能 |
| **第三批** | P6 融合 + P7 日历 + P8 API | 打磨与收尾 |

---

## 风险与决策点

| 风险/决策 | 选项 | 建议 |
|-----------|------|------|
| OCR 方案 | A: 后端 OCR / B: 前端 ML Kit | 推荐 A，后端可解析行程格式 |
| 客户行程分享 | 链接/图片/PDF | 三种都做，逐步 |
| 公开查看页 | Web 页面 | 可复用 Web 版 LUMO GUIDE |
| 模板初始数据 | 手动保存 / 系统预设 | 手动保存为主，后续可加系统模板 |
| 天气数据 | 对接天气 API | 后端集成，前端展示 |

---

> **计划 v2 完毕。** 从 6 个 Phase 扩展到 8 个，新增了模板复用、扫描导入、客户行程生成三大模块。请冠培审阅，确认后我按批次执行。
