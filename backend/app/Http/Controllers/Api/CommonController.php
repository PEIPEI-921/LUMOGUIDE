<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\Company;
use App\Models\Guide;
use App\Http\Requests\FileRequest;
use App\Models\SystemContinents;
use App\Models\User;
use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Writer\PngWriter;
use Illuminate\Support\Facades\Cache;
use App\Services\CommonService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

// use Illuminate\Support\Carbon;

class CommonController extends BaseController
{



    /**
     * 系统配置
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function config(CommonService $service)
    {
        $data = $service->config();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 文件上传
     * @param CommonService $service
     * @param FileRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function fileUpload(CommonService $service, FileRequest $request)
    {
        $data = $service->upload($request);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取地区
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getArea(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getArea($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取大洲
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getContinents(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getContinents($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 大洲列表
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getContinentsList(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getContinentsList($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取类型
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getType(CommonService $service)
    {
        $data = $service->getType();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取类型分类
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTypeClass(CommonService $service, Request $request)
    {
        $type_id = $request->get('type_id', 0) ?? 0;
        if (!$type_id) {
            return $this->error(__('res.type_id_required'));
        }
        $data = $service->getTypeClass($type_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 资讯分类
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getInformationClass(CommonService $service)
    {
        $data = $service->getInformationClass();
        return $this->success(__('res.success'), $data);
    }

    /**
     * 导游分类
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getGuideType(CommonService $service)
    {
        $data = $service->getGuideType();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取推荐城市
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function location(CommonService $service, Request $request)
    {
        $longitude = $request->get('longitude', '') ?? '';
        $latitude = $request->get('latitude', '') ?? '';

        $user_id = auth('api')->id();
        Log::debug("{$user_id}:UserAddress-longitude: $longitude, UserAddress-latitude: $latitude");

        $data = [];
        if ($longitude && $latitude) {
            $data = $service->location($longitude, $latitude);
        }
        return $this->success(__('res.success'), $data);
    }


    /**
     * 首页数据
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function homeData(CommonService $service)
    {
        $data = $service->homeData();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 首页搜索
     * @param Request $request
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function homeSearch(Request $request, CommonService $service)
    {
        $name = $request->get('name', '') ?? '';
        $limit = (int)($request->get('limit', 2) ?? 2);

        if (!$name) {
            $data = [];
        } else {
            $data = $service->homeSearch($name, $limit);
        }
        return $this->success(__('res.success'), $data);
    }


    /**
     * 全部导游列表（按洲分组）
     */
    public function guideList(Request $request, CommonService $service)
    {
        $continentsId = (int)($request->get('continents_id', 0) ?? 0);
        $limit = (int)($request->get('limit', 100) ?? 100);
        $search = $request->get('search', '') ?? '';
        $data = $service->guideList($continentsId, $limit, $search);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 全部商家列表（按分类分组）
     */
    public function merchantList(Request $request, CommonService $service)
    {
        $limit = (int)($request->get('limit', 500) ?? 500);
        $search = $request->get('search', '') ?? '';
        $data = $service->merchantList($limit, $search);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 搜索页接口
     * @param Request $request
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function search(Request $request, CommonService $service)
    {
        $name = $request->get('name', '') ?? '';
        $type = $request->get('type', '') ?? '';
        $type_id = $request->get('type_id', 1) ?? 1;

        if (!$name && !in_array($type, ['guide', 'city_content'])) {
            $data = [];
        } else {
            $data = $service->searchData($name, $type, $type_id);
        }
        return $this->success(__('res.success'), $data);
    }


    /**
     * 大洲/国家/城市 层级树（前端 _walkTree 直接遍历）
     */
    public function systemContinents(Request $request)
    {
        $tree = Cache::remember('system_continents_tree', 86400, function () {
            $all = SystemContinents::orderBy('order')
                ->get(['id', 'parent_id', 'name', 'order'])
                ->toArray();

            $childrenMap = [];
            foreach ($all as $node) {
                $pid = $node['parent_id'] ?? 0;
                $childrenMap[$pid][] = $node;
            }

            $buildTree = function ($pid) use (&$childrenMap, &$buildTree) {
                $nodes = $childrenMap[$pid] ?? [];
                $result = [];
                foreach ($nodes as $node) {
                    $node['children'] = $buildTree($node['id']);
                    $result[] = $node;
                }
                return $result;
            };

            return $buildTree(0);
        });

        return $this->success(__('res.success'), ['data' => $tree]);
    }

    public function health()
    {
        return $this->success('ok');
    }


    /**
     * App 运行时错误上报（Flutter FlutterError/PlatformDispatcher 全局错误）
     * 公开接口：错误可能发生在登录之前，只记录日志，不暴露任何内部信息
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function appError(Request $request)
    {
        $page = mb_substr((string)$request->post('page', 'unknown'), 0, 100, 'UTF-8');
        $error = mb_substr((string)$request->post('error', ''), 0, 2000, 'UTF-8');
        $stack = mb_substr((string)$request->post('stack', ''), 0, 4000, 'UTF-8');
        $time = $request->post('time', '');

        Log::error("AppError [page={$page}] [time={$time}]: {$error}\n{$stack}");
        return $this->success(__('res.success'));
    }

    public function data($lang, CommonService $service)
    {
        $config = $service->config();
        return $this->success('success', [
            'appIcon' => systemConfig('app_icon') ?: '',
            'logo' => systemConfig('system_logo') ?: '',
            'home' => [
                'welcome_zh' => $config['system_welcome_zh'] ?? '',
                'welcome_en' => $config['system_welcome_en'] ?? '',
            ],
        ]);
    }

    /**
     * 生成分享二维码
     */
    public function shareQrcode(Request $request)
    {
        $type = $request->get('type', '');
        $id = (int) $request->get('id', 0);

        if (!in_array($type, ['guide', 'city', 'content', 'trip']) || $id <= 0) {
            throw new ApiException(__('res.param_error'));
        }

        $user = auth('api')->user();
        $inviterCode = $user->inviter_code;
        if (!$inviterCode) {
            $inviterCode = generateUniqueInviteCode();
            $user->inviter_code = $inviterCode;
            $user->save();
        }

        $shareUrl = config('app.web_url') . '/share?c=' . $inviterCode . '&t=' . $type . '&i=' . $id;

        $result = Builder::create()
            ->writer(new PngWriter())
            ->data($shareUrl)
            ->size(300)
            ->margin(10)
            ->build();

        return response($result->getString(), 200)
            ->header('Content-Type', 'image/png')
            ->header('Cache-Control', 'no-cache, no-store, must-revalidate');
    }

    /**
     * 儲存延遲深度鏈接（冷啟動：App 未安裝時暫存參數）
     * POST /api/common/deferredLink
     */
    public function deferredLink(Request $request)
    {
        $token = $request->post('token', '');
        $contentType = $request->post('content_type', '');
        $contentId = (int) $request->post('content_id', 0);
        $inviterCode = $request->post('inviter_code', '');

        if (strlen($token) < 8 || strlen($token) > 32) {
            throw new ApiException(__('res.param_error'));
        }
        if (!in_array($contentType, ['guide', 'city', 'content', 'trip', 'invite'])) {
            throw new ApiException(__('res.param_error'));
        }

        \DB::table('deferred_deep_links')->insert([
            'token' => $token,
            'inviter_code' => $inviterCode,
            'content_type' => $contentType,
            'content_id' => $contentId,
            'ip_address' => $request->ip() ?? '',
            'user_agent' => substr($request->userAgent() ?? '', 0, 500),
            'created_at' => now(),
        ]);

        return $this->success('ok');
    }

    /**
     * 查詢延遲深度鏈接（App 首次啟動時調用）
     * GET /api/common/checkDeferredLink?token=xxx
     * 無 token 時按 IP + 時間窗口（24h）匹配最近一條
     */
    public function checkDeferredLink(Request $request)
    {
        $token = $request->get('token', '');

        $query = \DB::table('deferred_deep_links')->where('consumed', 0);

        if (!empty($token)) {
            $query->where('token', $token);
        } else {
            $ip = $request->ip();
            $query->where('ip_address', $ip)
                  ->where('created_at', '>=', now()->subHours(24));
        }

        $link = $query->orderBy('created_at', 'desc')->first();

        if (!$link) {
            return $this->success('ok', ['found' => false]);
        }

        // 標記已消費
        \DB::table('deferred_deep_links')->where('id', $link->id)->update(['consumed' => 1]);

        return $this->success('ok', [
            'found' => true,
            'inviter_code' => $link->inviter_code,
            'content_type' => $link->content_type,
            'content_id' => (int) $link->content_id,
        ]);
    }

}
