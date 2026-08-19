# 后端实现方案：企业认证通过时自动创建首个商铺

## 需求

企业会员在认证资料中填写城市和经营类型，管理员审核通过后，**自动创建第一个商铺**并出现在：
1. 前端「商铺管理」列表（`GET /company/shop`）
2. 对应城市的对应经营类型列表（`GET /city/restaurant`、`GET /city/shopping` 等）

审核未通过时，用户在前端认证资料页修改内容后再次提交，再次审核通过后同样自动创建。

## 触发时机

管理员审核 `applyCompany`，`audit_status` 从 **0 → 1**（审核中 → 审核通过）时触发。

## 数据映射

### 表映射：`company_apply` → `shop`

| 商铺字段 (shop) | 来源 (company_apply) | 说明 |
|-----------------|---------------------|------|
| `user_id` | `user_id` | 关联用户 |
| `city_id` | `city_id` | 直接复制 |
| `type_id` | `business_type` 映射 | 字符串 → 整型，见下方映射表 |
| `name` | `name` | 公司名称作为首个商铺名 |
| `address` | `address` | 直接复制 |
| `phone` | `phone` | 直接复制 |
| `email` | `email` | 直接复制 |
| `website` | `website` | 直接复制 |
| `introduce` | `introduction` | 企业简介 → 商铺介绍 |
| `pictures` | `picture` | JSON 数组，直接复制 |
| `other_phone` | `other_contact` | 直接复制 |
| `audit_status` | `1` | 随公司认证一同通过，无需再审核 |

### 不填的字段（留 null / 默认值）

| 字段 | 原因 |
|------|------|
| `type_class_id` | 认证表单无子分类选择，留空后续手动补 |
| `type_class_name` | 同上 |
| `start_time` | 认证表单无营业时间字段 |
| `capacity` | 认证表单无容量字段 |
| `price` | 认证表单无价格字段 |
| `tickets_free` | 默认 1（免费） |
| `longitude` / `latitude` | 认证表单无坐标字段 |
| `how_arrive` | 认证表单无到达方式字段 |

### `business_type` → `type_id` 映射

| business_type（后台配置） | type_id | 枚举含义 |
|--------------------------|---------|---------|
| "餐廳" / "餐厅" | 2 | restaurant |
| "購物" / "购物" | 3 | shopping |
| "住宿" / "酒店" | 4 | hotel |
| "景點" / "景点" | 1 | scenic |
| "票務" / "票务" | 8 | ticket |
| 其他/未匹配 | 2 | 默认餐厅 |

## 实现逻辑

### 1. 在审核通过逻辑中追加

```php
// admin 审核 company_apply
function approveCompanyApply($applyId) {
    $apply = CompanyApply::find($applyId);
    $oldStatus = $apply->audit_status;
    
    // 更新审核状态为通过
    $apply->audit_status = 1;
    $apply->save();
    
    // 更新用户身份为企业
    $user = User::find($apply->user_id);
    $user->identity = 3;  // 企业身份
    $user->company_audit_status = 1;
    $user->save();
    
    // 🆕 审核通过时自动创建第一个商铺
    if ($oldStatus != 1) {
        autoCreateFirstShop($apply);
    }
}
```

### 2. 自动创建商铺方法

```php
function autoCreateFirstShop($apply) {
    // 防止重复创建（已存在该用户的商铺则跳过）
    $exists = Shop::where('user_id', $apply->user_id)->exists();
    if ($exists) {
        return;
    }
    
    // business_type → type_id 映射
    $typeId = match (trim($apply->business_type)) {
        '餐廳', '餐厅' => 2,
        '購物', '购物' => 3,
        '住宿', '酒店' => 4,
        '景點', '景点' => 1,
        '票務', '票务' => 8,
        default => 2,  // 默认餐厅
    };
    
    Shop::create([
        'user_id'      => $apply->user_id,
        'city_id'      => $apply->city_id,
        'type_id'      => $typeId,
        'name'         => $apply->name,
        'address'      => $apply->address,
        'phone'        => $apply->phone,
        'email'        => $apply->email,
        'website'      => $apply->website,
        'introduce'    => $apply->introduction,
        'pictures'     => $apply->picture,       // JSON array
        'other_phone'  => $apply->other_contact,
        'audit_status' => 1,                     // 直接通过
    ]);
}
```

## 涉及的 API 端点

商铺创建后需要能在以下前端接口中返回：

| API | 前端页面 | 说明 |
|-----|---------|------|
| `GET /company/shop` | 商铺管理列表 | 必须返回此商铺 |
| `GET /city/restaurant?city_id=X` | 城市餐厅列表 | type_id=2 时需返回 |
| `GET /city/shopping?city_id=X` | 城市购物列表 | type_id=3 时需返回 |
| `GET /city/accommodation?city_id=X` | 城市酒店列表 | type_id=4 时需返回 |
| `GET /city/attraction?city_id=X` | 城市景点列表 | type_id=1 时需返回 |
| `GET /city/ticket?city_id=X` | 城市票务列表 | type_id=8 时需返回 |
| `GET /company/info?id=X` | 商家详情页 | 根据 shop.id 查询 |

**注意：** 城市分类列表 API 中，`type_class_id` 为 null 的商铺也应被返回（可归入"全部"或默认分类）。

## 校验清单

- [ ] 审核通过（0→1）时自动创建商铺
- [ ] 已存在商铺时不重复创建（防止反复审核导致重复数据）
- [ ] 拒绝（0→2）时**不**创建商铺
- [ ] 拒绝后再提交、再次审核通过时，如仍未创建商铺则自动创建
- [ ] `GET /company/shop` 返回此商铺
- [ ] `GET /city/{type}?city_id=X` 返回此商铺
- [ ] 商铺 `audit_status = 1`，无需前端再次提交审核
