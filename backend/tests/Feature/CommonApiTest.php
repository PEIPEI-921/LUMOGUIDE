<?php

namespace Tests\Feature;

/**
 * 通用公开接口结构回归测试
 */
class CommonApiTest extends FeatureTestCase
{
    public function test_health_check()
    {
        $this->getJson('/api/health')
            ->assertStatus(200)
            ->assertJson(['code' => 200]);
    }

    public function test_app_config_returns_data()
    {
        $response = $this->getJson('/api/common/config');
        $response->assertStatus(200)->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_continents_endpoints()
    {
        foreach (['getContinents', 'getContinentsList'] as $endpoint) {
            $this->getJson("/api/common/{$endpoint}")
                ->assertStatus(200)
                ->assertJsonStructure(['code', 'message', 'data']);
        }
    }

    public function test_guide_and_merchant_lists()
    {
        foreach (['guideList', 'merchantList'] as $endpoint) {
            $this->getJson("/api/common/{$endpoint}")
                ->assertStatus(200)
                ->assertJsonStructure(['code', 'message', 'data']);
        }
    }

    public function test_i18n_data_endpoint()
    {
        $this->getJson('/api/data/zh')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }
}
