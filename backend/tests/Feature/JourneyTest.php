<?php

namespace Tests\Feature;

/**
 * 我的历程（Journey）与工作模板 CRUD 回归测试
 */
class JourneyTest extends FeatureTestCase
{
    public function test_journey_full_crud_roundtrip()
    {
        $this->createUser('member@example.com');
        $token = $this->loginToken('member@example.com');

        // 创建
        $create = $this->postJson('/api/user/journeyCreate', [
            'title' => '维也纳三日行程',
            'city' => '维也纳',
            'days' => 3,
        ], $this->authHeaders($token));
        $create->assertStatus(200)->assertJson(['code' => 200], '历程创建应成功');

        // 列表包含新历程
        $list = $this->getJson('/api/user/journeyList', $this->authHeaders($token));
        $list->assertStatus(200)->assertJson(['code' => 200]);
        $journeyId = $list->json('data.list.0.id') ?? $list->json('data.0.id');
        $this->assertNotNull($journeyId, '历程列表应包含刚创建的历程');

        // 详情
        $detail = $this->getJson("/api/user/journeyDetail?id={$journeyId}", $this->authHeaders($token));
        $detail->assertStatus(200)->assertJsonStructure(['code', 'message', 'data']);

        // 更新
        $update = $this->putJson('/api/user/journeyUpdate', [
            'id' => $journeyId,
            'title' => '维也纳深度五日行程',
            'days' => 5,
        ], $this->authHeaders($token));
        $update->assertStatus(200)->assertJson(['code' => 200], '历程更新应成功');

        // 删除
        $delete = $this->deleteJson('/api/user/journeyDelete', ['id' => $journeyId], $this->authHeaders($token));
        $delete->assertStatus(200)->assertJson(['code' => 200], '历程删除应成功');

        $after = $this->getJson('/api/user/journeyList', $this->authHeaders($token));
        $after->assertStatus(200);
    }

    public function test_journey_template_crud_roundtrip()
    {
        $this->createUser('member@example.com');
        $token = $this->loginToken('member@example.com');

        $save = $this->postJson('/api/user/journeyTemplateSave', [
            'title' => '通用工作模板',
            'content' => '接机-酒店-景点',
        ], $this->authHeaders($token));
        $save->assertStatus(200)->assertJson(['code' => 200], '模板保存应成功');

        $list = $this->getJson('/api/user/journeyTemplateList', $this->authHeaders($token));
        $list->assertStatus(200)->assertJsonStructure(['code', 'message', 'data']);
        $templateId = $list->json('data.list.0.id') ?? $list->json('data.0.id');

        if ($templateId) {
            $del = $this->deleteJson('/api/user/journeyTemplateDelete', ['id' => $templateId], $this->authHeaders($token));
            $del->assertStatus(200)->assertJson(['code' => 200], '模板删除应成功');
        }
    }

    public function test_journey_endpoints_require_auth()
    {
        foreach (['/api/user/journeyList', '/api/user/journeyTemplateList'] as $path) {
            $this->getJson($path)->assertStatus(200)->assertJson(['code' => 401], $path);
        }
        $this->postJson('/api/user/journeyCreate', ['title' => 'x'])
            ->assertStatus(200)->assertJson(['code' => 401]);
    }
}
