<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

/**
 * 全局 helper 函数单元测试（不依赖数据库）
 */
class HelpersTest extends TestCase
{
    public function test_generate_unique_invite_code_is_nonempty_and_unique()
    {
        $codes = [];
        for ($i = 0; $i < 50; $i++) {
            $code = generateUniqueInviteCode();
            $this->assertNotEmpty($code);
            $this->assertNotContains($code, $codes, '邀请码不应重复');
            $codes[] = $code;
        }
    }

    public function test_reserve_message_returns_text_for_known_statuses()
    {
        foreach ([1, 2, 3, 4, 5] as $status) {
            $text = reserveMessage('小明', $status);
            $this->assertIsString($text);
            $this->assertNotEmpty($text);
        }
    }

    public function test_reserve_message_handles_unknown_status()
    {
        $text = reserveMessage('小明', 999);
        $this->assertIsString($text);
    }
}
