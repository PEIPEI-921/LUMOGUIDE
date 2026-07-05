<?php

namespace App\Http\Controllers\Api;


use App\Services\MessageService;
use Illuminate\Http\Request;

class MessageController extends BaseController
{


    /**
     * 消息列表
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function lists(Request $request, MessageService $service)
    {
        $data = $service->lists();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 好友关注分类
     * @param MessageService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function followClass(MessageService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;
        $type = $request->get('type', 1) ?? 1;

        $data = $service->followClass($parent_id, $type);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 我的评价
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function myEvaluate(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;

        $data = $service->myEvaluate($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 评价我的
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function evaluateMy(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;

        $data = $service->evaluateMy($limit);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 我的关注
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function myFollow(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;
        $continents_id = $request->get('continents_id', 0) ?? 0;
        $area_id = $request->get('area_id', 0) ?? 0;

        $data = $service->myFollow($limit, $continents_id, $area_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 关注我的
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function followMy(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;
        $continents_id = $request->get('continents_id', 0) ?? 0;
        $area_id = $request->get('area_id', 0) ?? 0;

        $data = $service->followMy($limit, $continents_id, $area_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 关注我的店铺
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function followMyShop(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;
        $continents_id = $request->get('continents_id', 0) ?? 0;
        $area_id = $request->get('area_id', 0) ?? 0;

        $data = $service->followMyShop($limit, $continents_id, $area_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 关注/取关
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function follow(Request $request, MessageService $service)
    {
        $user_id = $request->post('user_id', 0) ?? 0;
        if ($user_id == 0) {
            return $this->error(__('res.id_required'));
        }

        $service->follow($user_id);
        return $this->success(__('res.success'));
    }


    /**
     * 取关店铺
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function unFollowShop(Request $request, MessageService $service)
    {
        $shop_id = $request->post('shop_id', 0) ?? 0;
        if ($shop_id == 0) {
            return $this->error(__('res.shop_id_required'));
        }

        $service->unFollowShop($shop_id);
        return $this->success(__('res.success'));
    }


    /**
     * 系统消息
     * @param Request $request
     * @param MessageService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function systemList(Request $request, MessageService $service)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $page = $request->get('page', 1) ?? 1;

        $data = $service->systemList($limit);
        return $this->success(__('res.success'), $data);
    }
}
