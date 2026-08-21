<?php

namespace Tests\Feature;

use App\Models\User;

/**
 * 登录与账号注销回归测试
 * 重点覆盖 2026-08-19 修复：delAccount 硬删除，邮箱可立即复用
 */
class AuthLoginTest extends FeatureTestCase
{
    public function test_login_success_returns_token_user_sig_and_number()
    {
        $this->createUser('member@example.com');

        $response = $this->postJson('/api/auth/login', [
            'email' => 'member@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200]);
        $this->assertNotEmpty($response->json('data.token'), '登录应返回 JWT token');
        // LUMO-Chat 替换腾讯云 IM：登录返回 lumo_chat_token 字段（测试环境无 LUMO-Chat 服务时为空串，但字段必须存在）
        $data = $response->json('data');
        $this->assertArrayHasKey('lumo_chat_token', $data, '登录应返回 lumo_chat_token 字段');
        $this->assertArrayNotHasKey('user_sig', $data, '腾讯云 IM user_sig 已移除');
        $this->assertNotEmpty($response->json('data.user_number'));
    }

    public function test_login_wrong_password_rejected()
    {
        $this->createUser('member@example.com');

        $response = $this->postJson('/api/auth/login', [
            'email' => 'member@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '密码错误应登录失败');
    }

    public function test_login_unknown_email_rejected()
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'nobody@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'));
    }

    public function test_del_account_hard_deletes_user()
    {
        $user = $this->createUser('leaver@example.com');
        $token = $this->loginToken('leaver@example.com');

        $response = $this->postJson('/api/user/delAccount', [], $this->authHeaders($token));

        $response->assertStatus(200)->assertJson(['code' => 200]);
        $this->assertDatabaseMissing('users', ['email' => 'leaver@example.com']);
        $this->assertNull(User::withTrashed()->where('email', 'leaver@example.com')->first(), '软删除残留也不应存在');
    }

    public function test_email_reusable_immediately_after_account_deletion()
    {
        $inviter = $this->createUser('inviter@example.com');
        $this->createUser('reborn@example.com');
        $token = $this->loginToken('reborn@example.com');

        $del = $this->postJson('/api/user/delAccount', [], $this->authHeaders($token));
        $del->assertStatus(200)->assertJson(['code' => 200]);

        $reg = $this->postJson('/api/auth/register', [
            'inviter_code' => $inviter->inviter_code,
            'email' => 'reborn@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $reg->assertStatus(200)->assertJson(['code' => 200], '注销后邮箱应立即可重新注册');
        $this->assertEquals(1, User::where('email', 'reborn@example.com')->count());
    }

    public function test_protected_endpoint_requires_token()
    {
        // 应用约定：HTTP 200 + 业务码 401（System::AUTH_ERROR）
        foreach (['/api/user/index', '/api/integral/userDetails', '/api/message/lists'] as $path) {
            $this->getJson($path)
                ->assertStatus(200)
                ->assertJson(['code' => 401], "未带 token 访问 {$path} 应返回业务码 401");
        }
    }

    public function test_invalid_token_rejected()
    {
        $this->getJson('/api/user/index', ['Authorization' => 'Bearer invalid.token.here'])
            ->assertStatus(200)
            ->assertJson(['code' => 401]);
    }
}
