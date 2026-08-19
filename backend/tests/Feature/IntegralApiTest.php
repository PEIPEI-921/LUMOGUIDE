<?php

namespace Tests\Feature;

use App\Models\UserIntegralLog;

/**
 * 积分明细接口回归测试
 * 重点覆盖 2026-08-19 前端修复依赖：接口必须返回 type 与 amount 字段
 */
class IntegralApiTest extends FeatureTestCase
{
    public function test_user_details_returns_type_and_amount_fields()
    {
        $user = $this->createUser('points@example.com');
        $token = $this->loginToken('points@example.com');

        $log = new UserIntegralLog();
        $log->user_id = $user->id;
        $log->type = 1; // 1=消费/扣减
        $log->title = '兑换测试商品';
        $log->amount = 50;
        $log->created_at = now();
        $log->updated_at = now();
        $log->save();

        $response = $this->getJson('/api/integral/userDetails', $this->authHeaders($token));

        $response->assertStatus(200)->assertJson(['code' => 200]);
        $item = $response->json('data.list.0');
        $this->assertNotNull($item, '明细列表应包含记录');
        $this->assertArrayHasKey('type', $item, '明细必须包含 type 字段（前端按 type===1 判断扣减）');
        $this->assertArrayHasKey('amount', $item, '明细必须包含 amount 字段（前端展示金额）');
        $this->assertArrayHasKey('title', $item);
        $this->assertEquals(1, $item['type']);
        $this->assertEquals(50, $item['amount']);
    }

    public function test_user_details_requires_auth()
    {
        $this->getJson('/api/integral/userDetails')
            ->assertStatus(200)
            ->assertJson(['code' => 401]);
    }

    public function test_goods_endpoints_require_auth()
    {
        $this->getJson('/api/integral/goods')->assertStatus(200)->assertJson(['code' => 401]);
        $this->getJson('/api/integral/exchangeOrders')->assertStatus(200)->assertJson(['code' => 401]);
    }
}
