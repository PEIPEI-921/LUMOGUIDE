<!DOCTYPE html>
<html lang="zh-CN">
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
            background: linear-gradient(135deg, #4f46e5, #3b82f6);
            color: #fff;
            text-align: center;
            padding: 30px 20px;
        }

        .mail-header h1 {
            font-size: 22px;
            margin: 0;
        }

        .mail-content {
            padding: 40px 30px;
            line-height: 1.8;
        }

        .mail-content p {
            margin: 0 0 15px;
        }

        .mail-footer {
            text-align: center;
            background-color: #f5f7fa;
            padding: 20px;
        }

        .mail-footer img {
            width: 200px;
            margin-bottom: 8px;
        }

        .mail-footer p {
            font-size: 13px;
            color: #888;
            margin: 0;
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
            {{-- 主体内容（支持 HTML 渲染） --}}
            {!! $content ?? '' !!}
        </div>

        <div class="mail-footer">
            <img src="{{ systemConfig('system_logo') }}" alt="Logo">
            <p>{{ systemConfig('system_slogan') }}</p>
            <p>{{ systemConfig('system_contact') }}</p>
        </div>
    </div>
</div>
</body>
</html>
