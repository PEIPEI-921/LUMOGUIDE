<?php

namespace Tests\Feature;

/**
 * 验证码下发回归测试
 * 重点覆盖 2026-08-19 修复：sendCode 的 reg 类型检查忽略软删除用户
 */
class AuthSendCodeTest extends FeatureTestCase
{
    public function test_send_code_for_new_email_succeeds()
    {
        $response = $this->postJson('/api/auth/sendCode', [
            'email' => 'fresh@example.com',
            'type' => 'reg',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200]);
    }

    public function test_send_code_for_active_email_rejected()
    {
        $this->createUser('registered@example.com');

        $response = $this->postJson('/api/auth/sendCode', [
            'email' => 'registered@example.com',
            'type' => 'reg',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '活跃邮箱不应再发注册验证码');
    }

    public function test_send_code_for_soft_deleted_email_succeeds()
    {
        $deleted = $this->createUser('gone@example.com');
        $deleted->delete();

        $response = $this->postJson('/api/auth/sendCode', [
            'email' => 'gone@example.com',
            'type' => 'reg',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200], '注销邮箱应可重新获取注册验证码');
    }

    public function test_send_code_without_email_rejected()
    {
        $response = $this->postJson('/api/auth/sendCode', ['type' => 'reg']);
        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'));
    }
}
