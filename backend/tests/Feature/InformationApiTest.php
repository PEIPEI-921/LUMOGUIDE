<?php

namespace Tests\Feature;

/**
 * 资讯公开接口结构回归测试
 */
class InformationApiTest extends FeatureTestCase
{
    public function test_information_lists_returns_success_shape()
    {
        $this->getJson('/api/information/lists')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }

    public function test_information_info_returns_success_shape()
    {
        $this->getJson('/api/information/info?id=1')
            ->assertStatus(200)
            ->assertJsonStructure(['code', 'message', 'data']);
    }
}
