<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;

/**
 * 忘记密码 → 验证码 → 重置密码 → 新密码登录 全链路回归测试
 */
class PasswordResetTest extends FeatureTestCase
{
    public function test_full_password_reset_flow()
    {
        $this->createUser('member@example.com', 'old-password-1');

        // 1. 请求忘记密码验证码
        $send = $this->postJson('/api/auth/sendCode', [
            'email' => 'member@example.com',
            'type' => 'forget',
        ]);
        $send->assertStatus(200)->assertJson(['code' => 200], '忘记密码验证码应发送成功');

        // 2. 从缓存读取验证码（array 驱动，测试可直接读取）
        $code = Cache::get('verification_email_member@example.com');
        $this->assertNotNull($code, '验证码应写入缓存');

        // 3. 重置密码
        $reset = $this->postJson('/api/auth/resetPassword', [
            'email' => 'member@example.com',
            'verify_code' => $code,
            'password' => 'new-password-1',
            'password_confirmation' => 'new-password-1',
        ]);
        $reset->assertStatus(200)->assertJson(['code' => 200], '密码重置应成功');

        // 4. 旧密码登录失败
        $old = $this->postJson('/api/auth/login', [
            'email' => 'member@example.com',
            'password' => 'old-password-1',
        ]);
        $this->assertNotEquals(200, $old->json('code'), '旧密码应失效');

        // 5. 新密码登录成功
        $new = $this->postJson('/api/auth/login', [
            'email' => 'member@example.com',
            'password' => 'new-password-1',
        ]);
        $new->assertStatus(200)->assertJson(['code' => 200], '新密码应可登录');
        $this->assertNotEmpty($new->json('data.token'));
    }

    public function test_reset_with_wrong_code_rejected()
    {
        $this->createUser('member@example.com');

        $response = $this->postJson('/api/auth/resetPassword', [
            'email' => 'member@example.com',
            'verify_code' => '000000',
            'password' => 'whatever-123',
            'password_confirmation' => 'whatever-123',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '错误验证码应重置失败');
    }

    public function test_reset_for_unknown_email_rejected()
    {
        $response = $this->postJson('/api/auth/resetPassword', [
            'email' => 'ghost@example.com',
            'verify_code' => '123456',
            'password' => 'whatever-123',
            'password_confirmation' => 'whatever-123',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '不存在的邮箱应重置失败');
    }
}
