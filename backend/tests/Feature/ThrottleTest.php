<?php

namespace Tests\Feature;

/**
 * 认证接口限流回归测试（throttle:6,1）
 * 注意：本测试方法内部连续请求，不刷新缓存，验证限流真实生效。
 */
class ThrottleTest extends FeatureTestCase
{
    public function test_auth_endpoints_throttle_after_six_attempts_per_minute()
    {
        $this->createUser('member@example.com');

        // 前 6 次：正常业务响应（错误凭据也算次数）
        for ($i = 0; $i < 6; $i++) {
            $response = $this->postJson('/api/auth/login', [
                'email' => 'member@example.com',
                'password' => 'wrong-password',
            ]);
            $this->assertEquals(200, $response->status(), "第 {$i} 次请求不应触发限流");
        }

        // 第 7 次：触发限流 → HTTP 429
        $limited = $this->postJson('/api/auth/login', [
            'email' => 'member@example.com',
            'password' => 'wrong-password',
        ]);
        $this->assertEquals(429, $limited->status(), '第 7 次请求应触发 429 限流');
    }
}
