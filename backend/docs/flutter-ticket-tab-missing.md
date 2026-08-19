# Flutter 城市详情页 — 票務（type_id=8）tab 缺失

## 问题

手机端 App 城市详情页（萨尔茨堡）看不到票務商鋪內容，但網站端正常顯示。

## 根因

Flutter 城市详情页的內容類型 tab 列表**漏掉了 type_id=8（票務）**。

票務是後期新增的類型，type_id=8，不在 1-7 的连续范围内。Flutter 端大概率硬编码了 `[1, 2, 3, 4, 5, 6, 7]`，没有包含 8。

## 后端 API 验证

以下 API 均正常返回数据，不需要修改后端：

**1. 内容列表** — `GET /api/city/ticket?city_id=23`

```json
{
  "code": 200,
  "data": {
    "total": 2,
    "list": [
      { "id": 167, "name": "wew", "first_picture": "https://...", "phone": "+43...", "evaluate_count": 0 },
      { "id": 85, "name": "Salzburg Card", "first_picture": "https://...", "phone": "+43...", "evaluate_count": 1 }
    ]
  }
}
```

**2. 分类列表** — `GET /api/city/class?city_id=23`

返回的 `type` 数组中包含 type_id=8：
```json
{
  "type": [
    ...,
    { "id": 8, "name": "票務", "child": [{ "id": 16, "name": "訂票服務" }] }
  ]
}
```

**3. city_type 表**

| id | name |
|----|------|
| 1  | 景點 |
| 2  | 餐飲 |
| 3  | 購物 |
| 4  | 住宿 |
| 5  | 交通 |
| 6  | 設施 |
| 7  | 活動 |
| 8  | 票務 |

## 修复方案

在 Flutter 项目的城市详情页中，确保内容类型 tab 列表包含 type_id=8。

### Web 端 tab 顺序（参考）

Web 前端的 tab 定义在 `frontend/js/pages/city/detail.js`：

| 位置 | Tab | typeId | 说明 |
|------|-----|--------|------|
| 0 | 概覽 | 0 | 城市信息，非内容 |
| 1 | 導遊 | 0 | 导游列表，非内容 |
| 2 | 景點 | 1 | |
| 3 | 餐廳 | 2 | |
| 4 | 購物 | 3 | |
| 5 | **票務** | **8** | **← 不在 1-7 序列中** |
| 6 | 住宿 | 4 | |
| 7 | 交通 | 5 | |
| 8 | 設施 | 6 | |
| 9 | 活動 | 7 | |

### API 端点映射

内容类型的 API 路径格式为 `/api/city/{typeName}`：

| type_id | 端点 |
|---------|------|
| 1 | `/city/attraction` |
| 2 | `/city/restaurant` |
| 3 | `/city/shopping` |
| 4 | `/city/accommodation` |
| 5 | `/city/transportation` |
| 6 | `/city/facility` |
| 7 | `/city/activity` |
| 8 | `/city/ticket` |

### 请求参数

所有内容类型共用相同的请求参数：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `city_id` | int | 是 | 城市 ID |
| `type_class_id` | int | 否 | 子分类 ID，不传则返回全部 |
| `limit` | int | 否 | 每页条数，默认 15 |

### 返回字段（type_id=8）

```json
["id", "name", "first_picture", "phone"]
```

加上分页信息和 `evaluate_count`。

## 验证

修复后在 App 中打开萨尔茨堡（city_id=23）城市详情页，确认：
1. 「票務」tab 出现在内容类型列表中
2. 点击后能看到 2 条内容：Salzburg Card 和 wew

## 相关

- [[flutter-publish-city-bug]] — 之前发现的另一个 Flutter 端 bug
