<?php

namespace App\Http\Controllers\Api;


use App\Http\Requests\ExchangeRequest;
use App\Services\IntegralService;
use App\Services\UserService;
use App\Services\VipService;
use Illuminate\Http\Request;

class VipController extends BaseController
{

    /**
     * 会员权益
     * @param VipService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function ability(VipService $service)
    {
        $data = $service->ability();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 导游会员
     * @param VipService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function guide(VipService $service)
    {
        $data = $service->guide();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 企业会员
     * @param VipService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function company(VipService $service)
    {
        $data = $service->company();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 订阅导游会员
     * @param VipService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function subscriptionGuide(VipService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->subscriptionGuide($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 订阅企业会员
     * @param VipService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function subscriptionCompany(VipService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->subscriptionCompany($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 查询支付状态
     * @param VipService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function payStatus(VipService $service, Request $request)
    {
        $order_sn = $request->get('order_sn', '') ?? '';
        if (!$order_sn) {
            return $this->error(__('res.order_sn_required'));
        }

        $data = $service->payStatus($order_sn);
        return $this->success(__('res.success'), $data);
    }

}
