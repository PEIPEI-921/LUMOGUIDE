# 預約拒絕模板 — 前端實施指南

## 概述

`GET /api/common/config` 現已返回 `reserve_reject_templates` 欄位，
前端在拒絕預約的對話框中顯示模板快速選擇，導遊/商家點擊即可自動填入。

## API 回傳格式

```json
{
  "code": 200,
  "data": {
    "reserve_reject_templates": {
      "zh_TW": [
        {"key": "fully_booked", "text": "抱歉，當日預約已滿..."},
        {"key": "time_unavailable", "text": "抱歉，該時段無法配合..."},
        {"key": "on_break", "text": "抱歉，目前暫時休息中..."},
        {"key": "out_of_scope", "text": "抱歉，您需要的服務超出..."}
      ],
      "zh_CN": [...],
      "en": [...]
    }
  }
}
```

## Flutter 端實現

```dart
// 從 config API 獲取模板
final config = await ApiService.getConfig();
final templates = config['reserve_reject_templates'];

// 根據當前語言選擇對應的模板列表
String currentLang = Localizations.localeOf(context).languageCode;
// 映射：zh → zh_CN, zh_Hant → zh_TW, en → en
String langKey = currentLang == 'zh' ? 'zh_CN' : 
                 currentLang == 'zh_Hant' ? 'zh_TW' : 'en';
final langTemplates = templates?[langKey] ?? [];

// 拒絕對話框
showDialog(
  context: context,
  builder: (ctx) {
    String reason = '';
    return StatefulBuilder(builder: (ctx, setState) {
      return AlertDialog(
        title: Text('拒絕預約'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模板快速選擇
            ...langTemplates.map((t) => ListTile(
              title: Text(t['text'], maxLines: 2, overflow: TextOverflow.ellipsis),
              leading: Radio<String>(
                value: t['text'],
                groupValue: reason,
                onChanged: (v) => setState(() => reason = v!),
              ),
              onTap: () => setState(() => reason = t['text']),
            )),
            Divider(),
            // 自定義輸入
            TextField(
              decoration: InputDecoration(
                hintText: '或手動輸入拒絕原因...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => setState(() => reason = v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          ElevatedButton(
            onPressed: reason.trim().isEmpty ? null : () {
              Navigator.pop(ctx, reason.trim());
            },
            child: Text('確認拒絕'),
          ),
        ],
      );
    });
  },
).then((reason) {
  if (reason != null) {
    api.post('/guide/rejectReserve', {'id': reserveId, 'reason': reason});
  }
});
```

## Web 端實現

```javascript
// rejectReserve 方法 — 加到 guide/company 的預約列表頁面
async rejectReserve(item) {
  const config = await ApiProvider.get(ApiUrl.config);
  const templates = (config.data && config.data.reserve_reject_templates) || {};
  
  // 根據 I18n.locale 選語言
  const langMap = { 'zh-TW': 'zh_TW', 'zh-CN': 'zh_CN', 'en': 'en' };
  const langKey = langMap[I18n.locale] || 'zh_TW';
  const langTemplates = templates[langKey] || [];
  
  // 彈出選擇器
  const reason = await this.$showRejectDialog(langTemplates);
  if (!reason) return;
  
  const res = await ApiProvider.post('/guide/rejectReserve', {
    id: item.id,
    reason: reason,
  });
  if (res.success) {
    this.load();
  }
}

// 對話框模板
// 顯示模板列表（點擊選中）+ 文字輸入框（可編輯）
// 樣式參考 Flutter 端，用 v-for 渲染模板選項
```

## 使用者體驗

1. 導遊/商家看到 reject 對話框
2. 根據當前 App 語言顯示對應語言的模板列表
3. 點擊模板 → 文字自動填入輸入框（仍可手動編輯）
4. 送出 → `POST /guide/rejectReserve` 或 `POST /company/rejectReserve`
5. 使用者收到的拒絕訊息即為選定的專業模板文字

## 後端已就緒

- `system_config` (Redis + DB): `reserve_reject_templates` 已寫入
- `GET /api/common/config`: 回傳 `reserve_reject_templates`
- `POST /guide/rejectReserve` / `POST /company/rejectReserve`: 無需改動，`reason` 欄位就是模板文字
