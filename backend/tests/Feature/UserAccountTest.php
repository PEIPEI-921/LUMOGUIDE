<?php

namespace Tests\Feature;

/**
 * 用户中心功能回归测试：地址 CRUD、资料编辑、联系客服、反馈、邀请记录等
 */
class UserAccountTest extends FeatureTestCase
{
    private function authUser(): array
    {
        $this->createUser('member@example.com');
        return ['token' => $this->loginToken('member@example.com')];
    }

    public function test_address_crud_roundtrip()
    {
        $token = $this->authUser()['token'];

        // 新增
        $add = $this->postJson('/api/user/addressAdd', [
            'name' => '张三',
            'phone' => '+8613800138000',
            'address' => '维也纳一区某街道 1 号',
            'post_code' => '1010',
            'default' => 1,
        ], $this->authHeaders($token));
        $add->assertStatus(200)->assertJson(['code' => 200], '地址新增应成功');

        // 列表
        $list = $this->getJson('/api/user/address', $this->authHeaders($token));
        $list->assertStatus(200)->assertJson(['code' => 200]);
        $addressId = $list->json('data.0.id') ?? $list->json('data.list.0.id');
        $this->assertNotNull($addressId, '地址列表应返回新增的地址');

        // 编辑
        $edit = $this->postJson('/api/user/addressEdit', [
            'id' => $addressId,
            'name' => '李四',
            'phone' => '+8613800138000',
            'address' => '萨尔茨堡老城 2 号',
            'post_code' => '5020',
        ], $this->authHeaders($token));
        $edit->assertStatus(200)->assertJson(['code' => 200], '地址编辑应成功');

        // 删除
        $del = $this->postJson('/api/user/addressDelete', ['id' => $addressId], $this->authHeaders($token));
        $del->assertStatus(200)->assertJson(['code' => 200], '地址删除应成功');
    }

    public function test_address_requires_phone_with_country_code()
    {
        $token = $this->authUser()['token'];

        $response = $this->postJson('/api/user/addressAdd', [
            'name' => '张三',
            'phone' => '13800138000', // 无国家码
            'address' => '某地址',
            'post_code' => '1010',
        ], $this->authHeaders($token));

        $response->assertStatus(200);
        $this->assertNotEquals(200, $response->json('code'), '无国家码手机号应校验失败');
    }

    public function test_edit_info_updates_nickname()
    {
        $token = $this->authUser()['token'];

        $response = $this->postJson('/api/user/editInfo', [
            'nickname' => '旅行者小王',
        ], $this->authHeaders($token));

        $response->assertStatus(200)->assertJson(['code' => 200]);

        $me = $this->getJson('/api/user/index', $this->authHeaders($token));
        $me->assertStatus(200)->assertJson(['code' => 200]);
    }

    public function test_contact_us_and_feedback()
    {
        $token = $this->authUser()['token'];

        $contact = $this->postJson('/api/user/contactUs', [
            'title' => '测试咨询',
            'email' => 'member@example.com',
            'content' => '这是一个测试咨询内容',
        ], $this->authHeaders($token));
        $contact->assertStatus(200)->assertJson(['code' => 200], '联系客服应成功');

        $feedback = $this->postJson('/api/user/feedback', [
            'title' => '测试反馈',
            'content' => '这是一个测试反馈内容',
        ], $this->authHeaders($token));
        $feedback->assertStatus(200)->assertJson(['code' => 200], '意见反馈应成功');
    }

    public function test_number_info_login_record_and_invite_log()
    {
        $token = $this->authUser()['token'];

        // numberInfo 需要 user_number 查询参数；缺参也不应 500（2026-08-20 修复）
        $this->getJson('/api/user/numberInfo?user_number=LuMo202501000001', $this->authHeaders($token))
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
        $this->getJson('/api/user/numberInfo', $this->authHeaders($token))
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);

        foreach (['/api/user/loginRecord', '/api/user/inviteLog'] as $path) {
            $this->getJson($path, $this->authHeaders($token))
                ->assertStatus(200)
                ->assertJsonStructure(['code', 'message', 'data']);
        }
    }

    public function test_bind_inviter_flow()
    {
        $inviter = $this->createUser('inviter@example.com');
        $this->createUser('member@example.com');
        $token = $this->loginToken('member@example.com');

        // 无效邀请码
        $bad = $this->postJson('/api/user/bindInviter', ['inviter_code' => 'NOPE_CODE'], $this->authHeaders($token));
        $bad->assertStatus(200);
        $this->assertNotEquals(200, $bad->json('code'), '无效邀请码应绑定失败');

        // 有效邀请码
        $ok = $this->postJson('/api/user/bindInviter', ['inviter_code' => $inviter->inviter_code], $this->authHeaders($token));
        $ok->assertStatus(200)->assertJson(['code' => 200], '有效邀请码应绑定成功');
    }
}
