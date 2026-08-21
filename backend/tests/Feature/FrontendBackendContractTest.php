<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Route;

/**
 * 前后端接口契约测试：
 * SPA（frontend/js/api/urls.js）中声明的所有 API 路径，必须已在后端 routes/api.php 注册。
 * 防止前端调用被删除/改名的接口而无人察觉。
 */
class FrontendBackendContractTest extends FeatureTestCase
{
    public function test_all_frontend_api_paths_are_registered_in_backend()
    {
        $urlsFile = base_path('frontend/js/api/urls.js');
        $this->assertFileExists($urlsFile, 'urls.js 不存在，前端目录结构可能已变化');

        $content = file_get_contents($urlsFile);
        preg_match_all("/^\s*\w+:\s*'([^']+)'[,]?$/m", $content, $matches, PREG_SET_ORDER);
        $this->assertGreaterThan(50, count($matches), 'urls.js 应解析出 50+ 个路径，解析逻辑可能失效');

        $registered = collect(Route::getRoutes())->pluck('uri')->all();

        $missing = [];
        foreach ($matches as $m) {
            $path = $m[1];
            $uri = 'api' . $path;
            if (!in_array($uri, $registered, true)) {
                $missing[] = $path;
            }
        }

        $this->assertEmpty(
            $missing,
            '前端 urls.js 调用了但后端未注册的接口: ' . implode(', ', $missing)
        );
    }
}
