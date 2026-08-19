<?php

namespace Tests\Feature;

/**
 * 城市相关公开接口结构回归测试（SQLite 空库，仅验证接口可用性与返回结构）
 */
class CityApiTest extends FeatureTestCase
{
    public function test_city_lists_returns_success_shape()
    {
        $this->getJson('/api/city/lists')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_city_options_returns_success_shape()
    {
        $this->getJson('/api/city/options')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_city_class_returns_success_shape()
    {
        $this->getJson('/api/city/class')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_city_guide_returns_success_shape()
    {
        $this->getJson('/api/city/guide?city_id=1')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_city_guide_info_returns_success_shape()
    {
        $this->getJson('/api/city/guideInfo?id=1')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_city_content_endpoints_available()
    {
        foreach (['attraction', 'restaurant', 'shopping', 'accommodation', 'transportation', 'facility', 'activity', 'ticket'] as $type) {
            $this->getJson("/api/city/{$type}?city_id=1")
                ->assertStatus(200)
                ->assertJsonStructure(['code', 'message', 'data']);
        }
    }
}
