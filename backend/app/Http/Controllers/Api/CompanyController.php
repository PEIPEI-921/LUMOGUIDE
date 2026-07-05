<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AddCompanyShopRequest;
use App\Services\CompanyService;
use Illuminate\Http\Request;

class CompanyController extends BaseController
{

    /**
     * 企业详情
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function info(CompanyService $service, Request $request)
    {
        $company_id = $request->get('company_id', 0) ?? 0;
        if ($company_id == 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->info($company_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 店铺列表
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function shop(CompanyService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->shopLists($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加店铺
     * @param CompanyService $service
     * @param AddCompanyShopRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function shopAdd(CompanyService $service, AddCompanyShopRequest $request)
    {
        $data = $request->validated();
        $service->addShop($data);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 店铺详情
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function shopInfo(CompanyService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.shop_id_required'));
        }

        $data = $service->shopInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 修改店铺
     * @param CompanyService $service
     * @param AddCompanyShopRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function shopEdit(CompanyService $service, AddCompanyShopRequest $request)
    {
        $data = $request->validated();
        $service->shopEdit($data);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 删除
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function shopDel(CompanyService $service, Request $request)
    {
        $id = $request->post('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $service->shopDel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 预约我的
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserve(CompanyService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $start_time = $request->get('start_time', '') ?? '';
        $end_time = $request->get('end_time', '') ?? '';
        $guide = $request->get('guide', '') ?? '';

        $data = $service->reserve($limit, $start_time, $end_time, $guide);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取预约我的详情
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveInfo(CompanyService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->reserveInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 确认预约
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function confirmReserve(CompanyService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $status = $request->post('status', 0) ?? 0;
        if ($status <= 0) {
            return $this->error(__('res.status_required'));
        }

        $service->confirmReserve($id, $status);
        return $this->success(__('res.success'));
    }


    /**
     * 拒绝预约
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function rejectReserve(CompanyService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $reason = $request->post('reason', '') ?? '';
        if (!$reason) {
            return $this->error(__('res.reason_required'));
        }

        $service->rejectReserve($id, $reason);
        return $this->success(__('res.success'));
    }


    /**
     * 删除预约(隐藏)
     * @param CompanyService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function delReserve(CompanyService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->delReserve($id);
        return $this->success(__('res.success'));
    }

}
