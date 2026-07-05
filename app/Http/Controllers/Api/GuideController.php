<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AddActivityRequest;
use App\Http\Requests\AddAttractionRequest;
use App\Http\Requests\AddFacilityRequest;
use App\Http\Requests\AddInformationRequest;
use App\Http\Requests\AddTransportationRequest;
use App\Http\Requests\PublishCityRequest;
use App\Services\GuideService;
use Illuminate\Http\Request;

class GuideController extends BaseController
{

    /**
     * 发布城市
     * @param GuideService $service
     * @param PublishCityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function publishCity(GuideService $service, PublishCityRequest $request)
    {
        $service->publishCity($request->validated());
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 切换城市
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function changeCity(GuideService $service, Request $request)
    {
        $city_id = $request->post('city_id', -1) ?? -1;
        if ($city_id < 0) {
            return $this->error(__('res.city_id_required'));
        }

        $service->changeCity($city_id);
        return $this->success(__('res.success'));
    }


    /**
     * 发布城市列表
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function cityLists(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->cityLists($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 发布城市详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function cityInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.city_id_required'));
        }

        $data = $service->cityInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 修改发布城市
     * @param GuideService $service
     * @param PublishCityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function editCity(GuideService $service, PublishCityRequest $request)
    {
        $service->editCity($request->validated());
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 删除城市
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function delCity(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.city_id_required'));
        }

        $service->delCity($id);
        return $this->success(__('res.success'));
    }


    /**
     * 景点列表
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function attraction(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->cityContent(1, $limit);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 添加景点
     * @param GuideService $service
     * @param AddAttractionRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function attractionAdd(GuideService $service, AddAttractionRequest $request)
    {
        $service->cityContentAdd($request->validated(), 1);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 获取景点详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function attractionInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->cityContentInfo($id, 1);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 修改景点
     * @param GuideService $service
     * @param AddAttractionRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function attractionEdit(GuideService $service, AddAttractionRequest $request)
    {
        $service->cityContentEdit($request->validated(), 1);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 删除城市内容
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function cityContentDel(GuideService $service, Request $request)
    {
        $id = $request->post('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }
        $service->cityContentDel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 发布交通
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function transportation(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->cityContent(5, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加交通
     * @param GuideService $service
     * @param AddTransportationRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function transportationAdd(GuideService $service, AddTransportationRequest $request)
    {
        $service->cityContentAdd($request->validated(), 5);
        return $this->success(__('res.success_wait_audit'));
    }

    /**
     * 交通详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function transportationInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->cityContentInfo($id, 5);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 修改交通
     * @param GuideService $service
     * @param AddTransportationRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function transportationEdit(GuideService $service, AddTransportationRequest $request)
    {
        $service->cityContentEdit($request->validated(), 5);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 发布设施
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function facility(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->cityContent(6, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加设施
     * @param GuideService $service
     * @param AddFacilityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function facilityAdd(GuideService $service, AddFacilityRequest $request)
    {
        $service->cityContentAdd($request->validated(), 6);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 设施详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function facilityInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->cityContentInfo($id, 6);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 设施编辑
     * @param GuideService $service
     * @param AddFacilityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function facilityEdit(GuideService $service, AddFacilityRequest $request)
    {
        $service->cityContentEdit($request->validated(), 6);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 发布活动
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function activity(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->cityContent(7, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加活动
     * @param GuideService $service
     * @param AddActivityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function activityAdd(GuideService $service, AddActivityRequest $request)
    {
        $service->cityContentAdd($request->validated(), 7);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 活动详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function activityInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->cityContentInfo($id, 7);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 修改活动
     * @param GuideService $service
     * @param AddActivityRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function activityEdit(GuideService $service, AddActivityRequest $request)
    {
        $service->cityContentEdit($request->validated(), 7);
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 资讯列表
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function information(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->informationList($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 发布资讯
     * @param GuideService $service
     * @param AddInformationRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function informationAdd(GuideService $service, AddInformationRequest $request)
    {
        $service->informationAdd($request->validated());
        return $this->success(__('res.success_wait_audit'));
    }


    /**
     * 资讯详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function informationInfo(GuideService $service, Request $request)
    {
        $id = $request->get('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->informationInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 资讯修改
     * @param GuideService $service
     * @param AddInformationRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function informationEdit(GuideService $service, AddInformationRequest $request)
    {
        $service->informationEdit($request->validated());
        return $this->success(__('res.success_wait_audit'));
    }

    /**
     * 删除资讯
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function informationDel(GuideService $service, Request $request)
    {
        $id = $request->post('id');
        if (!$id) {
            return $this->error(__('res.id_required'));
        }
        $service->informationDel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 预约我的
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserve(GuideService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $start_time = $request->get('start_time', '') ?? '';
        $end_time = $request->get('end_time', '') ?? '';

        $data = $service->reserve($limit, $start_time, $end_time);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取预约我的详情
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveInfo(GuideService $service, Request $request)
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
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function confirmReserve(GuideService $service, Request $request)
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
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function rejectReserve(GuideService $service, Request $request)
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
     * @param GuideService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function delReserve(GuideService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->delReserve($id);
        return $this->success(__('res.success'));
    }


}
