# Flutter 发布城市 Bug — 文本字段值丢失

## 问题

手机端 App 发布城市时，**已填写城市名称**，仍提示"請填寫城市名稱"，无法提交。

## 根因定位

服务端日志（`storage/logs/laravel-2026-07-26.log`）已捕获实际请求数据：

```json
{
  "name": null,
  "name_en": null,
  "continents_id": 2,
  "continents_name": "歐洲",
  "area_id": 7,
  "area_name": "西歐",
  "country_id": 22,
  "country_name": "英國",
  "currency": null,
  "language": null,
  "population": null,
  "race": null,
  "overview": null,
  "history": null,
  "pictures": []
}
```

**关键发现**：
- 字段名 `name` 正确，**不是字段名不匹配的问题**
- `continents_id`/`area_id`/`country_id` **有值**（级联选择器正常）
- 所有文本字段（`name`、`name_en`、`currency`、`language`、`population`、`race`、`overview`、`history`）全部为 `null`
- `pictures` 为空数组

## 结论

**Flutter 端发布城市页面，文本输入框的值没有被正确收集到 POST 请求中。** 级联选择器（下拉框）的值正常，说明表单提交流程本身没问题，问题出在文本字段的取值方式。

## 排查方向

在 `/Users/xuejingchen/Desktop/vscode/lumotrip/` 中找到发布城市页面（大概率是 `pages/guide/publish_city_page.dart` 或类似路径），检查：

1. **`TextEditingController` 是否已创建并绑定到输入框**
   ```dart
   final _nameController = TextEditingController();
   // TextField 需要绑定: controller: _nameController
   ```

2. **提交时是否从 Controller 取值**
   ```dart
   // 正确
   'name': _nameController.text,
   // 错误 — 可能写了空字符串或未初始化变量
   'name': nameValue,  // nameValue 可能为 null
   ```

3. **是否有条件分支导致变量未赋值**
   - 检查 `if (isEdit)` 等条件是否意外跳过了对文本字段的赋值
   - 编辑模式可能用了不同逻辑，新增模式没覆盖

4. **请求体构造位置**
   - 找到 `POST /api/guide/publishCity` 调用处
   - 对照后端 `PublishCityRequest` 的 required 字段清单（见下方）检查每个字段是否都有对应的值来源

## 后端期望字段清单

`POST /api/guide/publishCity` 必填字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 城市名称 |
| `name_en` | string | 城市英文名称 |
| `continents_id` | int | 大洲 ID |
| `area_id` | int | 区域 ID |
| `country_id` | int | 国家 ID |
| `is_capital` | int | 是否首都 (0/1) |
| `currency` | string | 货币 |
| `language` | string | 语言 |
| `population` | string | 人口 |
| `race` | string | 种族 |
| `overview` | string | 城市概览 |
| `history` | string | 城市历史 |
| `pictures` | array | 图片列表（至少 1 张） |

可选字段：`longitude`、`latitude`、`id`（编辑时传）

## 验证方法

修复后，在服务端查看请求日志确认数据是否正确：

```bash
# 重新加上临时日志，再次测试后查看
tail -50 /www/wwwroot/lumo/storage/logs/laravel-2026-07-26.log | grep "PublishCityRequest"
```
