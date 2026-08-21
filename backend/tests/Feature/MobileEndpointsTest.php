<?php

namespace Tests\Feature;

/**
 * 移动端支撑接口回归测试：错误上报、深度链接、支付回调、分享二维码
 */
class MobileEndpointsTest extends FeatureTestCase
{
    public function test_app_error_reporting()
    {
        $response = $this->postJson('/api/common/appError', [
            'page' => 'WelcomePage',
            'error' => 'connectivity check timeout',
            'stack' => 'at main.dart:42',
            'time' => '2026-08-20 01:00:00',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200]);
    }

    public function test_deferred_link_create_and_check()
    {
        $token = 'testtoken12345678';

        // 合法创建
        $create = $this->postJson('/api/common/deferredLink', [
            'token' => $token,
            'content_type' => 'guide',
            'content_id' => 1,
            'inviter_code' => 'ABC123',
        ]);
        $create->assertStatus(200)->assertJson(['code' => 200], '深度链接创建应成功');

        // 查询
        $check = $this->getJson('/api/common/checkDeferredLink?token=' . $token);
        $check->assertStatus(200)->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_deferred_link_rejects_bad_payload()
    {
        // token 过短
        $short = $this->postJson('/api/common/deferredLink', [
            'token' => 'abc',
            'content_type' => 'guide',
            'content_id' => 1,
        ]);
        $this->assertNotEquals(200, $short->json('code'), '过短 token 应被拒绝');

        // 非法 content_type
        $badType = $this->postJson('/api/common/deferredLink', [
            'token' => 'testtoken12345678',
            'content_type' => 'hacker',
            'content_id' => 1,
        ]);
        $this->assertNotEquals(200, $badType->json('code'), '非法 content_type 应被拒绝');
    }

    public function test_payment_webhook_handles_empty_payload_gracefully()
    {
        $response = $this->postJson('/api/payment/webhook', []);

        // 空载荷：不应 500（当前返回 400，属可接受的优雅拒绝）
        $this->assertNotEquals(500, $response->status(), '空载荷 webhook 不应触发 500');
    }

    public function test_share_qrcode_requires_auth()
    {
        $this->getJson('/api/common/shareQrcode?url=test')
            ->assertStatus(200)
            ->assertJson(['code' => 401]);
    }
}
