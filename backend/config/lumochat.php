<?php

/*
 * LUMO-Chat（IM-as-a-Service）接入配置。
 *
 * 后端用 app_id + app_secret 为用户换取 access_token（POST /api/v1/auth/token），
 * 移动端/Web 端凭该 token 直连 LUMO-Chat 的 REST API 与 WebSocket（/ws）。
 */

return [
    // LUMO-Chat 服务地址（默认本地开发 3000 端口）
    'base_url' => env('LUMO_CHAT_BASE_URL', 'http://localhost:3000'),

    // 本应用在 LUMO-Chat 注册的租户 ID（1–32 字符）
    'app_id' => env('LUMO_CHAT_APP_ID', ''),

    // 本应用在 LUMO-Chat 注册的租户密钥（仅后端持有，不下发客户端）
    'app_secret' => env('LUMO_CHAT_APP_SECRET', ''),

    // 注册租户时使用的应用名称
    'app_name' => env('LUMO_CHAT_APP_NAME', 'LUMOGUIDE'),

    // 换取 token 时上报的设备 ID
    'device_id' => env('LUMO_CHAT_DEVICE_ID', 'lumoguide'),

    // LUMO-Chat 管理端 token（系统消息推送等内部接口用，需与 LUMO-Chat .env 的 ADMIN_TOKEN 一致）
    'admin_token' => env('LUMO_CHAT_ADMIN_TOKEN', ''),
];
