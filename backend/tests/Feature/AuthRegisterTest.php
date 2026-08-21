<?php

namespace Tests\Feature;

use App\Models\User;

/**
 * 注册流程回归测试
 * 重点覆盖 2026-08-19 账号删除修复：软删除用户的邮箱可被重新注册，且残留记录被清理
 */
class AuthRegisterTest extends FeatureTestCase
{
    public function test_register_success_creates_active_user()
    {
        $inviter = $this->createUser('inviter@example.com');

        $response = $this->postJson('/api/auth/register', [
            'inviter_code' => $inviter->inviter_code,
            'email' => 'newbie@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200]);

        $user = User::where('email', 'newbie@example.com')->first();
        $this->assertNotNull($user, '注册后用户应存在');
        $this->assertNull($user->deleted_at);
        $this->assertNotEmpty($user->number, '注册应生成 number');
        $this->assertEquals(1, $user->im_login);
        $this->assertNotNull($user->inviter_code, '注册应生成邀请码');
    }

    public function test_register_duplicate_active_email_rejected()
    {
        $inviter = $this->createUser('inviter@example.com');
        $this->createUser('taken@example.com');

        $response = $this->postJson('/api/auth/register', [
            'inviter_code' => $inviter->inviter_code,
            'email' => 'taken@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '重复邮箱注册应失败');
        $this->assertEquals(1, User::where('email', 'taken@example.com')->count());
    }

    public function test_register_with_soft_deleted_email_succeeds_and_purges_trash()
    {
        $inviter = $this->createUser('inviter@example.com');
        $deleted = $this->createUser('recycled@example.com');
        $deleted->delete();
        $this->assertSoftDeleted('users', ['email' => 'recycled@example.com']);

        $response = $this->postJson('/api/auth/register', [
            'inviter_code' => $inviter->inviter_code,
            'email' => 'recycled@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200], '注销邮箱应可重新注册');

        $active = User::where('email', 'recycled@example.com')->whereNull('deleted_at')->first();
        $this->assertNotNull($active, '新注册用户应存在且未删除');
        $trashed = User::where('email', 'recycled@example.com')->whereNotNull('deleted_at')->count();
        $this->assertEquals(0, $trashed, '注册时应清理同邮箱的软删除残留记录');
    }

    public function test_register_invalid_inviter_code_rejected()
    {
        $response = $this->postJson('/api/auth/register', [
            'inviter_code' => 'NO_SUCH_CODE',
            'email' => 'solo@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '无效邀请码应注册失败');
        $this->assertDatabaseMissing('users', ['email' => 'solo@example.com']);
    }

    public function test_register_requires_password_confirmation()
    {
        $inviter = $this->createUser('inviter@example.com');

        $response = $this->postJson('/api/auth/register', [
            'inviter_code' => $inviter->inviter_code,
            'email' => 'noconfirm@example.com',
            'password' => 'password123',
        ]);

        // 应用约定：校验失败同样返回 HTTP 200 + 业务错误码
        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '缺少 password_confirmation 应校验失败');
        $this->assertDatabaseMissing('users', ['email' => 'noconfirm@example.com']);
    }
}
