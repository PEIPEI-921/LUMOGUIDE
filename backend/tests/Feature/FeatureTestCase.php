<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Redis;
use Mockery;
use Tests\TestCase;

/**
 * 特性测试基类：
 *  - SQLite 内存库（phpunit.xml 已配置），每个测试自动 migrate:fresh
 *  - 打桩外部依赖：Redis（登录/注册会写）、腾讯 IM（注册会 account_import）
 *  - 每个测试前清空 array 缓存，避免 auth 路由 throttle:6,1 跨用例累积触发限流
 */
abstract class FeatureTestCase extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Cache::flush();

        Redis::shouldReceive('set')->andReturn(true);
        Redis::shouldReceive('hSet')->andReturn(true);
        Redis::shouldReceive('hExists')->andReturn(false);
        Redis::shouldReceive('hGet')->andReturnNull();
        Redis::shouldReceive('hGetAll')->andReturn([]);
        Redis::shouldReceive('get')->andReturnNull();
        Redis::shouldReceive('exists')->andReturn(false);
        Redis::shouldReceive('del')->andReturn(true);

        // 注意：IM facade 的 im() 是真实静态方法（return app('im')），
        // 不会经过 facade mock 分发，必须直接替换容器绑定。
        $imClient = Mockery::mock(\Hedeqiang\TenIM\IM::class);
        $imClient->shouldReceive('send')->andReturn(['ActionStatus' => 'OK']);
        $this->app->instance('im', $imClient);
    }

    /**
     * 直接落库创建用户（绕过注册流程），im_login=1 使登录跳过 IM 调用
     */
    protected function createUser(string $email, string $password = 'password123', array $attrs = []): User
    {
        $user = new User();
        $user->email = $email;
        $user->password = Hash::make($password);
        $user->name = $email;
        $user->nickname = $email;
        $user->number = 'LuMo' . random_int(10000000, 99999999);
        $user->inviter_code = generateUniqueInviteCode();
        $user->im_login = 1;
        foreach ($attrs as $key => $value) {
            $user->{$key} = $value;
        }
        $user->save();

        return $user;
    }

    /**
     * 通过真实登录接口换取 JWT token
     */
    protected function loginToken(string $email, string $password = 'password123'): string
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => $email,
            'password' => $password,
        ]);

        $response->assertStatus(200)->assertJson(['code' => 200]);
        $token = $response->json('data.token');
        $this->assertNotEmpty($token, '登录未返回 token');

        return $token;
    }

    protected function authHeaders(string $token): array
    {
        return [
            'Authorization' => 'Bearer ' . $token,
            'Accept' => 'application/json',
        ];
    }
}
