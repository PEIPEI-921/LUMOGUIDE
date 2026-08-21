<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * LUMO-Chat（IM-as-a-Service）集成服务。
 *
 * 职责：以应用级 app_id + app_secret 为用户换取 access_token。
 * 客户端（Flutter/Web）拿到 token 后直连 LUMO-Chat 的 REST API 与 WebSocket（/ws）。
 *
 * 接口文档见 LUMO-Chat 仓库 docs/API.md。
 */
class LumoChatService
{
    /**
     * LUMO-Chat 服务根地址（去除末尾斜杠）。
     */
    public function baseUrl(): string
    {
        return rtrim((string) config('lumochat.base_url'), '/');
    }

    /**
     * 注册本应用租户（幂等：已存在返回 1005，忽略即可）。
     * 一般在部署初始化时调用一次；未配置时静默跳过。
     */
    public function ensureAppRegistered(): void
    {
        $appId = (string) config('lumochat.app_id');
        $appSecret = (string) config('lumochat.app_secret');
        if ($appId === '' || $appSecret === '') {
            return;
        }
        try {
            $res = Http::timeout(10)->post($this->baseUrl() . '/api/v1/auth/apps', [
                'app_id' => $appId,
                'app_secret' => $appSecret,
                'name' => (string) config('lumochat.app_name', 'LUMOGUIDE'),
            ]);
            $json = $res->json();
            $code = $json['code'] ?? null;
            // 1005 = App already exists，属正常
            if (!$res->ok() && $code != 1005) {
                Log::warning('LumoChatService ensureAppRegistered: ' . $res->body());
            }
        } catch (\Throwable $e) {
            Log::warning('LumoChatService ensureAppRegistered error: ' . $e->getMessage());
        }
    }

    /**
     * 为用户换取 LUMO-Chat access_token（有效期 3600 秒）。
     *
     * @param string $userId 用户 ID（即 LUMOGUIDE user.number，≤64 字符，无需预注册）
     * @param string $deviceId 设备 ID（默认 mobile）
     * @return array{access_token: string, expires_in: int}
     * @throws \RuntimeException 换取失败（未配置或服务不可达）
     */
    public function createToken(string $userId, string $deviceId = 'mobile'): array
    {
        $appId = (string) config('lumochat.app_id');
        $appSecret = (string) config('lumochat.app_secret');
        if ($appId === '' || $appSecret === '') {
            throw new \RuntimeException('LUMO_CHAT_APP_ID / LUMO_CHAT_APP_SECRET not configured');
        }

        $res = Http::timeout(10)->post($this->baseUrl() . '/api/v1/auth/token', [
            'app_id' => $appId,
            'app_secret' => $appSecret,
            'user_id' => $userId,
            'device_id' => $deviceId,
        ]);

        $json = $res->json();
        if (!$res->ok() || !isset($json['data']['access_token'])) {
            Log::error('LumoChatService createToken error: ' . $res->body());
            throw new \RuntimeException('chat token exchange failed');
        }

        return [
            'access_token' => (string) $json['data']['access_token'],
            'expires_in' => (int) ($json['data']['expires_in'] ?? 3600),
        ];
    }
}
