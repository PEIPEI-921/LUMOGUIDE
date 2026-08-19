# 會員到期提醒 — 後端實現說明

> 前端已完成所有 UI 改動，本文檔供後端同僚參照實現排程任務、系統消息推送及 Email 發送。
> 日期：2026-07-27 | 前端版本：1.0.6+21

---

## 一、需求概述

會員到期前，按四個時間節點發送雙語（繁體中文 + English）提醒：

| 階段 | 觸發時機 | 管道 |
|------|---------|------|
| 第一階段 | 到期前 30 天 | 平台系統消息 + Email |
| 第二階段 | 到期前 10 天 | 平台系統消息 + Email |
| 第三階段 | 到期前 3 天 | 平台系統消息 + Email |
| 第四階段 | 到期前 1 天 | 平台系統消息 + Email |

每階段只發一次，不可重複。

---

## 二、前端已就緒

### 2.1 系統消息 — 會員類型支援

`MessageSystemModel`（`lib/common/models/message.dart`）已擴充 `content_type: "membership"`：

- `hasLinkedContent` → `content_type == 'membership'` 時返回 `true`（無需 `content_id`）
- `openLinkedContent()` → 跳轉 `AppRoutes.MEMBER_CENTER`（會員中心頁面 `/member_center`）
- 消息詳情頁連結文字為「前往會員中心」

### 2.2 後端只需發送消息

後端將消息寫入系統消息表，前端自動適配顯示與跳轉。消息 JSON 格式見下方。

---

## 三、資料庫設計

### 3.1 會員到期記錄表（如尚無）

追蹤每位會員的到期日及提醒發送狀態：

```sql
-- 建議新增欄位或獨立的會員到期提醒記錄表
CREATE TABLE member_expiry_reminders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    expire_date DATE NOT NULL COMMENT '會員到期日',
    stage_30_sent TINYINT DEFAULT 0 COMMENT '30天提醒 0=未發 1=已發',
    stage_10_sent TINYINT DEFAULT 0 COMMENT '10天提醒',
    stage_3_sent  TINYINT DEFAULT 0 COMMENT '3天提醒',
    stage_1_sent  TINYINT DEFAULT 0 COMMENT '1天提醒',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_expire_date (expire_date),
    INDEX idx_user_id (user_id)
);
```

或直接利用 `users` 表的 `membership_expire_date` 欄位 + 獨立的 `member_notifications` 日誌表：

```sql
CREATE TABLE member_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    expire_date DATE NOT NULL,
    stage VARCHAR(10) NOT NULL COMMENT '30d / 10d / 3d / 1d',
    channel VARCHAR(10) NOT NULL COMMENT 'system / email',
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    UNIQUE KEY uk_user_stage_channel (user_id, expire_date, stage, channel)
);
```

### 3.2 系統消息表記錄

利用已有的 `system_messages` 表（或等價表），每條記錄的前端對應欄位見下方 API 合約。

---

## 四、排程任務（Cron Job）

### 4.1 Laravel Task Scheduling

在 `App\Console\Kernel.php` 註冊每日排程：

```php
// 每日凌晨 02:00 執行會員到期提醒檢查
$schedule->command('member:expiry-remind')->dailyAt('02:00');
```

### 4.2 Artisan Command 邏輯

```php
// App\Console\Commands\MemberExpiryRemind.php

public function handle()
{
    $today = now()->startOfDay();
    $stages = [
        '30d' => $today->copy()->addDays(30),
        '10d' => $today->copy()->addDays(10),
        '3d'  => $today->copy()->addDays(3),
        '1d'  => $today->copy()->addDays(1),
    ];

    foreach ($stages as $stage => $targetDate) {
        $users = User::whereDate('membership_expire_date', $targetDate)
            ->where('membership_status', 'active')  // 僅活躍會員
            ->whereDoesntHave('notifications', function ($q) use ($stage, $targetDate) {
                $q->where('stage', $stage)
                  ->where('channel', 'system')
                  ->whereDate('expire_date', $targetDate);
            })
            ->get();

        foreach ($users as $user) {
            // 1. 發送平台系統消息
            $this->sendSystemMessage($user, $stage);

            // 2. 發送 Email（如用戶開啟了郵件通知）
            if ($user->email_notifications_enabled ?? true) {
                $this->sendEmail($user, $stage);
            }

            // 3. 記錄已發送
            MemberNotification::create([
                'user_id'    => $user->id,
                'expire_date' => $targetDate->toDateString(),
                'stage'      => $stage,
                'channel'    => 'system',
                'sent_at'    => now(),
            ]);
        }
    }
}
```

### 4.3 防重複發送邏輯

以 `member_notifications` 表的 `UNIQUE KEY uk_user_stage_channel` 確保同一用戶、同一到期日、同一階段、同一管道不會重複發送。

---

## 五、系統消息推送

### 5.1 API 合約

將消息寫入系統消息表，前端通過 `/message/system` 接口拉取。每條記錄需包含以下欄位：

| 欄位 | 類型 | 說明 |
|------|------|------|
| `title` | string | 消息標題（已含中英雙語，一行） |
| `desc` | string | 簡短摘要，顯示在消息列表 |
| `content` | string | 完整正文（中英雙語，前端渲染為 RichText） |
| `content_type` | string | **固定值 `"membership"`**，觸發前端跳轉會員中心 |
| `content_id` | int\|null | 會員類型不需，可為 null |
| `city_id` | int\|null | 不需 |
| `city_content_type` | int\|null | 不需 |
| `time` | string | 發送時間 `YYYY-MM-DD HH:mm:ss` |

### 5.2 各階段消息內容

以下為後端組裝 JSON 時使用的內容模板。變數替換規則：

- `{user_name_zh}` → 會員認證中文姓名（來自 `users.name_zh` 或等價欄位）
- `{user_name_en}` → 會員認證英文姓名（來自 `users.name_en` 或等價欄位）
- `{expire_date}` → 到期日期，格式 `YYYY年M月D日`（中文）/ `F j, Y`（英文）

#### 階段 1 — 到期前 30 天

**title:**
```
您的 LUMOGUIDE 會員將於 30 天後到期 / Your LUMOGUIDE Membership Expires in 30 Days
```

**desc:**
```
您的會員資格將於 {expire_date} 到期，還剩 30 天。請提前前往會員中心延長資格。
```

**content:**
```
{user_name_zh} 您好，您的會員資格將於 {expire_date} 到期，還剩 30 天。建議您提前前往 會員中心 延長資格，持續享受會員專屬權益。

Dear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date}, with 30 days remaining. Please visit the Membership Center to renew and continue enjoying your exclusive benefits.
```

---

#### 階段 2 — 到期前 10 天

**title:**
```
您的 LUMOGUIDE 會員將於 10 天後到期 / Your LUMOGUIDE Membership Expires in 10 Days
```

**desc:**
```
您的會員資格將於 {expire_date} 到期，僅剩 10 天。到期後部分功能將受限，請盡快延長資格。
```

**content:**
```
{user_name_zh} 您好，您的會員資格將於 {expire_date} 到期，僅剩 10 天。到期後部分會員功能將受限，請前往 會員中心 盡快延長資格。

Dear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date}, with only 10 days left. Some features will be restricted after expiration. Please visit the Membership Center to renew as soon as possible.
```

---

#### 階段 3 — 到期前 3 天

**title:**
```
⚠️ 您的 LUMOGUIDE 會員將於 3 天後到期 / ⚠️ Your Membership Expires in 3 Days
```

**desc:**
```
您的會員資格將於 {expire_date} 到期，僅剩 3 天！請立即前往會員中心延長資格。
```

**content:**
```
{user_name_zh} 您好，您的會員資格將於 {expire_date} 到期，僅剩 3 天！到期後會員功能將暫停，請立即前往 會員中心 延長資格，以免影響使用。

Dear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date} — only 3 days left! Membership features will be suspended after expiration. Please visit the Membership Center now to renew and avoid any disruption.
```

---

#### 階段 4 — 到期前 1 天

**title:**
```
🔴 您的 LUMOGUIDE 會員將於明天到期 / 🔴 Your Membership Expires Tomorrow
```

**desc:**
```
您的會員資格將於明天（{expire_date}）到期！請把握最後機會，立即前往會員中心延長資格。
```

**content:**
```
{user_name_zh} 您好，您的會員資格將於明天（{expire_date}）到期！明天起會員功能將暫停。請把握最後機會，立即前往 會員中心 延長資格。如有疑問請聯繫客服。

Dear {user_name_en}, your LUMOGUIDE membership expires tomorrow ({expire_date})! Membership features will be suspended starting tomorrow. Please seize this final opportunity — visit the Membership Center now to renew. Contact customer service if you have any questions.
```

---

## 六、Email 郵件發送

### 6.1 郵件配置

- **發送服務**：使用現有郵件服務（Laravel Mail / SMTP / SendGrid 等）
- **發送時機**：與系統消息同時觸發（見排程任務）
- **發送條件**：用戶 `email_notifications_enabled` 為 `true`（若無此欄位則預設發送）

### 6.2 郵件主旨

| 階段 | 主旨（中英合併） |
|------|-----------------|
| 30 天 | 【LUMOGUIDE】您的會員將於 30 天後到期 / Your Membership Expires in 30 Days |
| 10 天 | 【LUMOGUIDE】距離會員到期僅剩 10 天 / Only 10 Days Until Membership Expires |
| 3 天 | 【LUMOGUIDE】⚠️ 會員僅剩 3 天到期 / ⚠️ Only 3 Days Left — Renew Now |
| 1 天 | 【LUMOGUIDE】🔴 最後提醒：您的會員明天到期 / 🔴 Final Reminder: Your Membership Expires Tomorrow |

### 6.3 郵件內文（四階段通用模板）

```
{user_name_zh} 您好：

{中文內文段落}

續費方式：
1. 打開 LUMOGUIDE App
2. 進入「我的」→「會員中心」
3. 選擇適合的方案完成續費

{結尾文字}
如已續費，請忽略此郵件。

LUMOGUIDE 團隊敬上


Dear {user_name_en},

{English body paragraph}

How to renew:
1. Open the LUMOGUIDE App
2. Go to "Mine" → "Membership Center"
3. Choose a plan and complete your renewal

{Closing text}
If you have already renewed, please disregard this email.

Best regards,
The LUMOGUIDE Team
```

### 6.4 各階段差異內容

| 階段 | 中文內文 | English body | 結尾文字 | Closing text |
|------|---------|-------------|---------|-------------|
| 30 天 | 感謝您一直以來對 LUMOGUIDE 的支持！您的會員資格將於 {expire_date} 到期，距離到期還有 30 天。為確保您的會員權益不受影響，歡迎您提前登入平台，前往「會員中心」延長會員資格。 | Thank you for your continued support of LUMOGUIDE! Your membership will expire on {expire_date}, with 30 days remaining. To ensure uninterrupted access to your membership benefits, we recommend renewing early by visiting the Membership Center. | 如有任何疑問，歡迎聯繫我們。 | If you have any questions, please feel free to contact us. |
| 10 天 | 溫馨提醒，您的 LUMOGUIDE 會員資格將於 {expire_date} 到期，僅剩 10 天。到期後部分會員功能將受到限制，建議您盡早登入平台，前往「會員中心」延長資格，確保功能不受影響。 | A friendly reminder — your LUMOGUIDE membership will expire on {expire_date}, with only 10 days left. Some membership features will be restricted after expiration. We recommend renewing soon by visiting the Membership Center to keep your account fully active. | （無） | (none) |
| 3 天 | 您的 LUMOGUIDE 會員資格將於 {expire_date} 到期，僅剩 3 天。到期後您的會員功能將立即暫停，請盡快登入平台前往「會員中心」延長資格。 | Your LUMOGUIDE membership will expire on {expire_date} — only 3 days remaining. Your membership features will be suspended immediately upon expiration. Please log in and visit the Membership Center to renew as soon as possible. | （無） | (none) |
| 1 天 | 這是最後一次提醒——您的 LUMOGUIDE 會員資格將於明天（{expire_date}）到期。明天起，您的會員功能將被暫停。現在是最後的續費時機！ | This is your final reminder — your LUMOGUIDE membership expires tomorrow ({expire_date}). Starting tomorrow, your membership features will be suspended. This is your last chance to renew! | 如需協助，請隨時聯繫我們：{contact_email} | If you need assistance, please contact us at: {contact_email} |

---

## 七、Laravel 實現代碼參考

### 7.1 Command

```php
<?php
// app/Console/Commands/MemberExpiryRemind.php

namespace App\Console\Commands;

use App\Models\MemberNotification;
use App\Models\SystemMessage;
use App\Models\User;
use App\Mail\MemberExpiryReminder;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class MemberExpiryRemind extends Command
{
    protected $signature = 'member:expiry-remind';
    protected $description = 'Send membership expiry reminders at 30/10/3/1 days before expiration';

    private const STAGES = [
        '30d' => 30,
        '10d' => 10,
        '3d'  => 3,
        '1d'  => 1,
    ];

    public function handle(): void
    {
        $today = now()->startOfDay();

        foreach (self::STAGES as $stage => $days) {
            $targetDate = $today->copy()->addDays($days);

            User::whereDate('membership_expire_date', $targetDate)
                ->where('membership_status', 'active')
                ->get()
                ->each(function (User $user) use ($stage, $targetDate) {
                    $this->processUser($user, $stage, $targetDate);
                });
        }

        $this->info('Member expiry reminders sent.');
    }

    private function processUser(User $user, string $stage, $targetDate): void
    {
        // 防重複檢查
        $alreadySent = MemberNotification::where('user_id', $user->id)
            ->where('expire_date', $targetDate->toDateString())
            ->where('stage', $stage)
            ->exists();

        if ($alreadySent) return;

        $data = $this->buildMessageData($user, $stage, $targetDate);

        // 1. 系統消息
        SystemMessage::create([
            'user_id'       => $user->id,
            'title'         => $data['title'],
            'desc'          => $data['desc'],
            'content'       => $data['content'],
            'content_type'  => 'membership',
            'time'          => now()->toDateTimeString(),
        ]);

        MemberNotification::create([
            'user_id'     => $user->id,
            'expire_date' => $targetDate->toDateString(),
            'stage'       => $stage,
            'channel'     => 'system',
            'sent_at'     => now(),
        ]);

        // 2. Email
        if ($user->email_notifications_enabled ?? true) {
            Mail::to($user->email)->send(
                new MemberExpiryReminder($user, $stage, $targetDate, $data)
            );

            MemberNotification::create([
                'user_id'     => $user->id,
                'expire_date' => $targetDate->toDateString(),
                'stage'       => $stage,
                'channel'     => 'email',
                'sent_at'     => now(),
            ]);
        }
    }

    private function buildMessageData(User $user, string $stage, $targetDate): array
    {
        $zhDate = $targetDate->format('Y年n月j日');
        $enDate = $targetDate->format('F j, Y');

        $templates = $this->stageTemplates();
        $tpl = $templates[$stage];

        $replace = fn(string $text) => str_replace(
            ['{user_name_zh}', '{user_name_en}', '{expire_date_zh}', '{expire_date_en}', '{contact_email}'],
            [$user->name_zh, $user->name_en, $zhDate, $enDate, config('mail.contact_email')],
            $text
        );

        return [
            'title'   => $replace($tpl['title']),
            'desc'    => $replace($tpl['desc']),
            'content' => $replace($tpl['content']),
        ];
    }

    private function stageTemplates(): array
    {
        return [
            '30d' => [
                'title'   => '您的 LUMOGUIDE 會員將於 30 天後到期 / Your LUMOGUIDE Membership Expires in 30 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，還剩 30 天。請提前前往會員中心延長資格。',
                'content' => "{user_name_zh} 您好，您的會員資格將於 {expire_date_zh} 到期，還剩 30 天。建議您提前前往 會員中心 延長資格，持續享受會員專屬權益。\n\nDear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date_en}, with 30 days remaining. Please visit the Membership Center to renew and continue enjoying your exclusive benefits.",
            ],
            '10d' => [
                'title'   => '您的 LUMOGUIDE 會員將於 10 天後到期 / Your LUMOGUIDE Membership Expires in 10 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，僅剩 10 天。到期後部分功能將受限，請盡快延長資格。',
                'content' => "{user_name_zh} 您好，您的會員資格將於 {expire_date_zh} 到期，僅剩 10 天。到期後部分會員功能將受限，請前往 會員中心 盡快延長資格。\n\nDear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date_en}, with only 10 days left. Some features will be restricted after expiration. Please visit the Membership Center to renew as soon as possible.",
            ],
            '3d' => [
                'title'   => '⚠️ 您的 LUMOGUIDE 會員將於 3 天後到期 / ⚠️ Your Membership Expires in 3 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，僅剩 3 天！請立即前往會員中心延長資格。',
                'content' => "{user_name_zh} 您好，您的會員資格將於 {expire_date_zh} 到期，僅剩 3 天！到期後會員功能將暫停，請立即前往 會員中心 延長資格，以免影響使用。\n\nDear {user_name_en}, your LUMOGUIDE membership will expire on {expire_date_en} — only 3 days left! Membership features will be suspended after expiration. Please visit the Membership Center now to renew and avoid any disruption.",
            ],
            '1d' => [
                'title'   => '🔴 您的 LUMOGUIDE 會員將於明天到期 / 🔴 Your Membership Expires Tomorrow',
                'desc'    => '您的會員資格將於明天（{expire_date_zh}）到期！請把握最後機會，立即前往會員中心延長資格。',
                'content' => "{user_name_zh} 您好，您的會員資格將於明天（{expire_date_zh}）到期！明天起會員功能將暫停。請把握最後機會，立即前往 會員中心 延長資格。如有疑問請聯繫客服。\n\nDear {user_name_en}, your LUMOGUIDE membership expires tomorrow ({expire_date_en})! Membership features will be suspended starting tomorrow. Please seize this final opportunity — visit the Membership Center now to renew. Contact customer service if you have any questions.",
            ],
        ];
    }
}
```

### 7.2 Mailable

```php
<?php
// app/Mail/MemberExpiryReminder.php

namespace App\Mail;

use App\Models\User;
use Illuminate\Mail\Mailable;

class MemberExpiryReminder extends Mailable
{
    public function __construct(
        public User $user,
        public string $stage,
        public $targetDate,
        public array $data,
    ) {}

    public function build(): self
    {
        $viewData = [
            'user_name_zh'  => $this->user->name_zh,
            'user_name_en'  => $this->user->name_en,
            'expire_date_zh' => $this->targetDate->format('Y年n月j日'),
            'expire_date_en' => $this->targetDate->format('F j, Y'),
            'stage'          => $this->stage,
            'contact_email'  => config('mail.contact_email'),
        ];

        return $this
            ->subject($this->data['title'])
            ->view('emails.member_expiry_reminder', $viewData);
    }
}
```

### 7.3 Kernel 註冊

```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule): void
{
    $schedule->command('member:expiry-remind')->dailyAt('02:00');
}
```

---

## 八、測試檢查清單

- [ ] 手動將測試帳號的 `membership_expire_date` 設為今天 + 30 天，執行 `php artisan member:expiry-remind`，確認系統消息出現
- [ ] 確認 Email 收到且內容正確
- [ ] 將 `membership_expire_date` 改為今天 + 10/3/1 天，分別測試各階段
- [ ] 再次執行排程，確認不會重複發送（`member_notifications` UNIQUE KEY 阻擋）
- [ ] 前端：打開 App → 消息 → 系統消息，確認四階段消息均顯示
- [ ] 前端：點擊消息 → 詳情頁 → 點擊「前往會員中心」，確認跳轉至會員中心頁面
- [ ] 檢查會員已續費後，排程不會再對該用戶發送後續階段消息
- [ ] 檢查 `membership_status != 'active'` 的用戶不會收到提醒

---

## 九、附錄：相關檔案路徑

| 檔案 | 說明 |
|------|------|
| `lib/common/models/message.dart:133-220` | MessageSystemModel — `hasLinkedContent` + `openLinkedContent` |
| `lib/pages/message_system/detail.dart` | 系統消息詳情頁 — 會員類型顯示「前往會員中心」 |
| `lib/pages/message_system/page.dart` | 系統消息列表頁 |
| `lib/common/routers/names.dart:132` | `AppRoutes.MEMBER_CENTER = '/member_center'` |
| `lib/common/apis/urls.dart` | `ApiUrl.messageSystem` — 系統消息 API 路徑 |

---

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)
