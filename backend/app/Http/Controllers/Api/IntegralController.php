<?php

namespace App\Http\Controllers\Api;


use App\Http\Requests\ExchangeRequest;
use App\Services\IntegralService;
use App\Services\UserService;
use Illuminate\Http\Request;

class IntegralController extends BaseController
{

    /**
     * 用户积分明细
     * @param IntegralService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function userDetails(IntegralService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->userDetails($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 积分商品分类
     * @param IntegralService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function goodsClassLists(IntegralService $service)
    {
        $data = $service->goodsClassLists();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 积分商品列表
     * @param IntegralService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function goodsLists(IntegralService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $class_id = $request->get('class_id', 0) ?? 0;

        $data = $service->goodsLists($limit, $class_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 积分商品详情
     * @param IntegralService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function goodsInfo(IntegralService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if (!$id || $id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->goodsInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 积分兑换
     * @param IntegralService $service
     * @param ExchangeRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function exchange(IntegralService $service, ExchangeRequest $request)
    {
        $data = $service->exchange($request->validated());
        return $this->success(__('res.success'), $data);
    }


    /**
     * 兑换积分订单
     * @param IntegralService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function exchangeOrders(IntegralService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->exchangeOrders($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 兑换订单详情
     * @param IntegralService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function exchangeOrderInfo(IntegralService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if (!$id || $id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->exchangeOrderInfo($id);
        return $this->success(__('res.success'), $data);
    }

}
