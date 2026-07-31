# 後端修改文檔 — 導遊認證新增「常駐城市」

## 概述

導遊認證資料（`POST /user/applyGuide`）新增「常駐城市」功能。導遊可選擇平台現有城市，或直接新增一個城市。新增城市的審核狀態與導遊認證審核聯動。

---

## 一、API 改動

### `POST /api/user/applyGuide` — 新增字段

前端提交的 JSON payload 新增以下字段：

#### 場景 1：選擇現有城市

```json
{
  "resident_city_id": 5,
  "resident_city_name": "東京",
  "is_new_city": 0
}
```

#### 場景 2：新增城市

```json
{
  "is_new_city": 1,
  "new_city_name": "鹿特丹",
  "new_city_name_en": "Rotterdam",
  "new_city_continents_id": 1,
  "new_city_continents_name": "歐洲",
  "new_city_area_id": 7,
  "new_city_area_name": "西歐",
  "new_city_country_id": 22,
  "new_city_country_name": "荷蘭"
}
```

### 字段說明

| 字段 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `resident_city_id` | int | `is_new_city=0` 時必填 | 現有城市 ID |
| `resident_city_name` | string | 否 | 現有城市名稱（展示用） |
| `is_new_city` | int | 是 | 0=現有城市 / 1=新增城市 |
| `new_city_name` | string | `is_new_city=1` 時必填 | 新城市中文名 |
| `new_city_name_en` | string | `is_new_city=1` 時必填 | 新城市英文名 |
| `new_city_continents_id` | int | `is_new_city=1` 時必填 | 大洲 ID |
| `new_city_continents_name` | string | 否 | 大洲名稱 |
| `new_city_area_id` | int | `is_new_city=1` 時必填 | 地區 ID |
| `new_city_area_name` | string | 否 | 地區名稱 |
| `new_city_country_id` | int | `is_new_city=1` 時必填 | 國家 ID |
| `new_city_country_name` | string | 否 | 國家名稱 |

### `GET /api/user/applyGuideInfo` — 返回新增字段

獲取已提交的認證資料時，同樣返回上述字段，前端用於表單回填。

---

## 二、資料庫改動

### 1. `guide_applications` 表（或當前儲存導遊認證資料的表）

新增字段：

```sql
ALTER TABLE guide_applications ADD COLUMN resident_city_id INT DEFAULT NULL COMMENT '常駐城市ID（現有城市）';
ALTER TABLE guide_applications ADD COLUMN resident_city_name VARCHAR(255) DEFAULT NULL COMMENT '常駐城市名稱';

ALTER TABLE guide_applications ADD COLUMN is_new_city TINYINT DEFAULT 0 COMMENT '是否新增城市 0否1是';
ALTER TABLE guide_applications ADD COLUMN new_city_name VARCHAR(255) DEFAULT NULL COMMENT '新城市中文名';
ALTER TABLE guide_applications ADD COLUMN new_city_name_en VARCHAR(255) DEFAULT NULL COMMENT '新城市英文名';
ALTER TABLE guide_applications ADD COLUMN new_city_continents_id INT DEFAULT NULL COMMENT '新城市大洲ID';
ALTER TABLE guide_applications ADD COLUMN new_city_continents_name VARCHAR(255) DEFAULT NULL;
ALTER TABLE guide_applications ADD COLUMN new_city_area_id INT DEFAULT NULL COMMENT '新城市地區ID';
ALTER TABLE guide_applications ADD COLUMN new_city_area_name VARCHAR(255) DEFAULT NULL;
ALTER TABLE guide_applications ADD COLUMN new_city_country_id INT DEFAULT NULL COMMENT '新城市國家ID';
ALTER TABLE guide_applications ADD COLUMN new_city_country_name VARCHAR(255) DEFAULT NULL;

-- 新增城市與申請的關聯（記錄由此申請創建的城市 ID，用於審核聯動）
ALTER TABLE guide_applications ADD COLUMN linked_city_id INT DEFAULT NULL COMMENT '關聯的新增城市ID（審核聯動用）';
```

### 2. `cities` 表

如果 `cities` 表尚無 `audit_status` 字段，需新增（用於由導遊申請創建的城市）：

```sql
ALTER TABLE cities ADD COLUMN audit_status TINYINT DEFAULT 1 COMMENT '審核狀態 0待審核 1通過 2駁回';
-- 現有城市的 audit_status 默認為 1
```

### 3. 導遊-城市關聯

確認導遊與城市之間的展示關聯如何查詢。有兩種方式：

**方式 A（推薦）：導遊表增加 resident_city_id**
```sql
ALTER TABLE guides ADD COLUMN resident_city_id INT DEFAULT NULL COMMENT '常駐城市ID';
-- 審核通過後寫入此字段，前端查詢城市下的導遊時用 WHERE resident_city_id = ?
```

**方式 B：關聯表**
```sql
CREATE TABLE guide_cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guide_id INT NOT NULL,
    city_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (guide_id, city_id)
);
```

---

## 三、業務邏輯

### 流程圖

```
導遊提交認證 POST /user/applyGuide
         │
         ├── is_new_city = 0（現有城市）
         │         │
         │         └── 儲存申請，resident_city_id = 選擇的城市 ID
         │              linked_city_id = NULL
         │
         └── is_new_city = 1（新增城市）
                   │
                   └── INSERT INTO cities (name, name_en, continents_id, area_id, country_id, ..., audit_status = 0)
                       獲取 new_city_id
                       儲存申請：linked_city_id = new_city_id, is_new_city = 1
```

### 審核通過（管理員操作）

```
管理員審核導遊認證「通過」
         │
         ├── 更新 guide_applications.audit_status = 1
         │
         ├── 更新 guides 表的 resident_city_id：
         │   ├── is_new_city = 0 → resident_city_id = application.resident_city_id
         │   └── is_new_city = 1 → resident_city_id = application.linked_city_id
         │
         └── is_new_city = 1 時：
               UPDATE cities SET audit_status = 1 WHERE id = application.linked_city_id
               （新增城市自動通過審核，在平台上展示）
```

### 審核駁回（管理員操作）

```
管理員審核導遊認證「駁回」
         │
         ├── 更新 guide_applications.audit_status = 2
         │
         └── is_new_city = 1 時：
               UPDATE cities SET audit_status = 2 WHERE id = application.linked_city_id
               （新增城市自動駁回，不在平台上展示）
```

### 城市列表查詢（前端展示導遊）

查詢某城市下的導遊列表時，增加 `audit_status` 過濾：

```sql
SELECT * FROM guides
WHERE resident_city_id = ?
  AND audit_status = 1   -- 只展示審核通過的導遊
```

---

## 四、關鍵約束

| 規則 | 說明 |
|------|------|
| **城市不重複創建** | 新增城市前檢查 `name` + `country_id` 是否已存在，若存在則直接關聯，不重複創建 |
| **審核聯動** | 城市 `audit_status` 與導遊認證 `audit_status` 同步變更，不可獨立操作 |
| **舊數據兼容** | 所有新增字段設 `DEFAULT NULL`，舊導遊申請的 `is_new_city` 為 0 |

---

## 五、城市新增時的最小字段

後端創建城市 `INSERT INTO cities` 時，除前端傳遞的字段外，請設置：

| 字段 | 值 | 說明 |
|------|-----|------|
| `name` | `new_city_name` | 中文名 |
| `name_en` | `new_city_name_en` | 英文名 |
| `continents_id` | `new_city_continents_id` | 大洲 |
| `area_id` | `new_city_area_id` | 地區 |
| `country_id` | `new_city_country_id` | 國家 |
| `audit_status` | `0` | 待審核 |
| `created_by` | 當前導遊的 user_id | 記錄創建者 |
