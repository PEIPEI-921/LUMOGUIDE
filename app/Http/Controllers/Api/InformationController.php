<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AddEvaluateRequest;
use App\Http\Requests\FileRequest;
use App\Services\CommonService;
use App\Services\InformationService;
use Illuminate\Http\Request;

class InformationController extends BaseController
{

    /**
     * 资讯列表
     * @param InformationService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function lists(InformationService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $class_id = $request->get('class_id', 0) ?? 0;

        $data = $service->lists($class_id, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 资讯详情
     * @param InformationService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function info(InformationService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->info($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 评价
     * @param InformationService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function evaluate(InformationService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->evaluate($id, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加评价
     * @param InformationService $service
     * @param AddEvaluateRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addEvaluate(InformationService $service, AddEvaluateRequest $request)
    {
        $service->addEvaluate($request->validated());
        return $this->success(__('res.success'));
    }

}
