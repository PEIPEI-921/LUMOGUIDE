<?php

namespace Tests\Feature;

use App\Models\City;
use App\Models\Guide;
use App\Models\User;

/**
 * 预约导游流程回归测试
 * 注意：预约要求用户持有有效 VIP（handleUserVip 校验）
 */
class ReserveGuideTest extends FeatureTestCase
{
    private function seedGuide(): array
    {
        $guideUser = $this->createUser('guide@example.com');
        $city = new City();
        $city->name = '维也纳';
        $city->name_en = 'Vienna';
        $city->currency = 'EUR';
        $city->language = 'German';
        $city->population = '190万';
        $city->race = '—';
        $city->overview = '音乐之都';
        $city->history = '历史悠久';
        $city->save();

        $guide = new Guide();
        $guide->user_id = $guideUser->id;
        $guide->city_id = $city->id;
        $guide->city_name = '维也纳';
        $guide->name = '测试导游';
        $guide->phone = '+8613800138000';
        $guide->email = 'guide@example.com';
        $guide->bill_address = '维也纳一区';
        $guide->other_contact = 'wechat-test';
        $guide->year = '5';
        $guide->introduction = '专业中文导游';
        $guide->business_contact = '测试联系人';
        $guide->audit_status = 1;
        $guide->save();

        return ['city' => $city, 'guide' => $guide, 'guideUser' => $guideUser];
    }

    private function vipUser(): array
    {
        $user = $this->createUser('member@example.com', 'password123', [
            'vip_type' => 1,
            'vip_expiration_time' => time() + 86400 * 30,
        ]);
        return ['token' => $this->loginToken('member@example.com'), 'user' => $user];
    }

    private function reservePayload(array $seeded): array
    {
        return [
            'city_id' => $seeded['city']->id,
            'guide_id' => $seeded['guide']->id,
            'arrival_time' => '2026-09-01 10:00',
            'number' => '2',
            'remark' => '蜜月旅行',
            'contact' => '张三',
            'email' => 'member@example.com',
            'phone' => '+8613800138000',
        ];
    }

    public function test_reserve_guide_flow()
    {
        $seeded = $this->seedGuide();
        $token = $this->vipUser()['token'];

        // 提交预约
        $reserve = $this->postJson('/api/city/reserveGuide', $this->reservePayload($seeded), $this->authHeaders($token));
        $reserve->assertStatus(200)->assertJson(['code' => 200], '预约导游应成功');

        // 我的预约列表
        $list = $this->getJson('/api/user/reserveGuide', $this->authHeaders($token));
        $list->assertStatus(200)->assertJsonStructure(['code', 'message', 'data']);

        // 取消预约
        $reserveId = $list->json('data.list.0.id') ?? $list->json('data.0.id');
        if ($reserveId) {
            $cancel = $this->postJson('/api/user/reserveGuideCancel', ['id' => $reserveId], $this->authHeaders($token));
            $cancel->assertStatus(200)->assertJson(['code' => 200], '取消预约应成功');
        }
    }

    public function test_reserve_guide_requires_vip()
    {
        $seeded = $this->seedGuide();
        // 普通用户（无 VIP）
        $this->createUser('member@example.com');
        $token = $this->loginToken('member@example.com');

        $reserve = $this->postJson('/api/city/reserveGuide', $this->reservePayload($seeded), $this->authHeaders($token));

        $reserve->assertStatus(200);
        $this->assertNotEquals(200, $reserve->json('code'), '无 VIP 用户预约应被拒绝');
    }

    public function test_reserve_guide_validation()
    {
        $seeded = $this->seedGuide();
        $token = $this->vipUser()['token'];

        // 缺必填字段
        $bad = $this->postJson('/api/city/reserveGuide', [
            'guide_id' => $seeded['guide']->id,
        ], $this->authHeaders($token));

        $bad->assertStatus(200);
        $this->assertNotEquals(200, $bad->json('code'), '缺少必填字段应校验失败');
    }

    public function test_reserve_nonexistent_guide_rejected()
    {
        $seeded = $this->seedGuide();
        $token = $this->vipUser()['token'];

        $payload = $this->reservePayload($seeded);
        $payload['guide_id'] = 99999;

        $reserve = $this->postJson('/api/city/reserveGuide', $payload, $this->authHeaders($token));
        $reserve->assertStatus(200);
        $this->assertNotEquals(200, $reserve->json('code'), '不存在的导游应预约失败');
    }
}
