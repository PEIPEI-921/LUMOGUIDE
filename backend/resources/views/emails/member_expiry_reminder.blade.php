<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? '' }}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f7fa;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .mail-wrapper {
            width: 100%;
            padding: 40px 0;
            background-color: #f5f7fa;
        }
        .mail-container {
            max-width: 640px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }
        .mail-header {
            background: linear-gradient(135deg, #666FFF, #4A52E0);
            color: #fff;
            text-align: center;
            padding: 30px 20px;
        }
        .mail-header h1 {
            font-size: 20px;
            margin: 0;
            line-height: 1.5;
        }
        .mail-content {
            padding: 40px 30px;
            line-height: 1.8;
        }
        .mail-content p {
            margin: 0 0 15px;
        }
        .divider {
            border: none;
            border-top: 1px solid #e5e7eb;
            margin: 25px 0;
        }
        .renew-steps {
            background: #f9fafb;
            border-radius: 8px;
            padding: 20px 25px;
            margin: 20px 0;
        }
        .renew-steps ol {
            margin: 10px 0 0;
            padding-left: 20px;
        }
        .renew-steps li {
            margin-bottom: 6px;
        }
        .mail-footer {
            text-align: center;
            background-color: #f5f7fa;
            padding: 20px;
            font-size: 13px;
            color: #888;
        }
    </style>
</head>
<body>
<div class="mail-wrapper">
    <div class="mail-container">
        <div class="mail-header">
            <h1>{{ $title ?? '' }}</h1>
        </div>

        <div class="mail-content">
            {{-- 中文段落 --}}
            <p>{{ $user_name }} 您好：</p>
            <p>{{ $email_body['zh_body'] }}</p>

            <div class="renew-steps">
                <strong>續費方式：</strong>
                <ol>
                    <li>打開 LUMOGUIDE App</li>
                    <li>進入「我的」→「會員中心」</li>
                    <li>選擇適合的方案完成續費</li>
                </ol>
            </div>

            @if($email_body['zh_close'])
                <p>{{ $email_body['zh_close'] }}</p>
            @endif
            <p>如已續費，請忽略此郵件。</p>
            <p>LUMOGUIDE 團隊敬上</p>

            <hr class="divider">

            {{-- English section --}}
            <p>Dear {{ $user_name }},</p>
            <p>{{ $email_body['en_body'] }}</p>

            <div class="renew-steps">
                <strong>How to renew:</strong>
                <ol>
                    <li>Open the LUMOGUIDE App</li>
                    <li>Go to "Mine" → "Membership Center"</li>
                    <li>Choose a plan and complete your renewal</li>
                </ol>
            </div>

            @if($email_body['en_close'])
                <p>{{ $email_body['en_close'] }}</p>
            @endif
            <p>If you have already renewed, please disregard this email.</p>
            <p>Best regards,<br>The LUMOGUIDE Team</p>
        </div>

        <div class="mail-footer">
            <p>{{ systemConfig('system_slogan') }}</p>
        </div>
    </div>
</div>
</body>
</html>
