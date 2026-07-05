<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AddEvaluateRequest;
use App\Http\Requests\FileRequest;
use App\Http\Requests\ReserveGuideRequest;
use App\Services\CityService;
use App\Services\CommonService;
use Illuminate\Http\Request;

class CityController extends BaseController
{


    /**
     * 城市列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function lists(CityService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $name = $request->get('name', '') ?? '';
        $continents_id = $request->get('continents_id', 0) ?? 0;
        $area_id = $request->get('area_id', 0) ?? 0;

        $data = $service->lists($name, $continents_id, $area_id, $limit);
        return $this->success(__('res.success'), $data);
    }

    public function options(CityService $service, Request $request)
    {
        $data = $service->options();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取城市下分类
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function class(CityService $service, Request $request)
    {
        $city_id = $request->get('city_id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }

        $data = $service->class($city_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 城市详情
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function info(CityService $service, Request $request)
    {
        $city_id = $request->get('city_id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }

        $data = $service->info($city_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 导游列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function guide(CityService $service, Request $request)
    {
        $guide_type = $request->get('guide_type', 0) ?? 0;
        $limit = $request->get('limit', 15) ?? 15;
        $city_id = $request->get('city_id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }

        $data = $service->guide($city_id, $guide_type, $limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 导游详情
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function guideInfo(CityService $service, Request $request)
    {
        $guide_id = $request->get('guide_id', 0) ?? 0;
        if ($guide_id <= 0) {
            return $this->error(__('res.guide_id_required'));
        }

        $data = $service->guideInfo($guide_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 关注导游
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function guideFollow(CityService $service, Request $request)
    {
        $guide_id = $request->post('guide_id', 0) ?? 0;
        if ($guide_id <= 0) {
            return $this->error(__('res.guide_id_required'));
        }

        $service->guideFollow($guide_id);
        return $this->success(__('res.success'));
    }


    /**
     * 导游取关
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function guideUnFollow(CityService $service, Request $request)
    {
        $guide_id = $request->post('guide_id', 0) ?? 0;
        if ($guide_id <= 0) {
            return $this->error(__('res.guide_id_required'));
        }

        $service->guideUnFollow($guide_id);
        return $this->success(__('res.success'));
    }


    /**
     * 预约导游
     * @param CityService $service
     * @param ReserveGuideRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveGuide(CityService $service, ReserveGuideRequest $request)
    {
        $service->reserveGuide($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 获取城市内容
     * @param CityService $service
     * @param Request $request
     * @param int $type_id
     * @return \Illuminate\Http\JsonResponse
     */
    private function getCityContentList(CityService $service, Request $request, int $type_id)
    {
        $city_id = $request->get('city_id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }
        $type_class_id = $request->get('type_class_id', 0) ?? 0;
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->getCityContentList($city_id, $type_id, $type_class_id, $limit);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 景点列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function attraction(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 1);
    }

    /**
     * 餐厅列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function restaurant(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 2);
    }

    /**
     * 购物列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function shopping(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 3);
    }

    /**
     * 住宿列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function accommodation(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 4);
    }

    /**
     * 交通列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function transportation(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 5);
    }

    /**
     * 设施列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function facility(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 6);
    }

    /**
     * 活动列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function activity(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 7);
    }

    /**
     * 门票列表
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function ticket(CityService $service, Request $request)
    {
        return $this->getCityContentList($service, $request, 8);
    }


    /**
     * 获取内容详情
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function contentInfo(CityService $service, Request $request)
    {
        $city_id = $request->get('city_id', 0) ?? 0;
        $type_id = $request->get('type_id', 0) ?? 0;
        $id = $request->get('id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }
        if ($type_id <= 0) {
            return $this->error(__('res.type_id_required'));
        }
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->getContentInfo($city_id, $type_id, $id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取内容评价
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function contentEvaluate(CityService $service, Request $request)
    {
        $city_id = $request->get('city_id', 0) ?? 0;
        $id = $request->get('id', 0) ?? 0;
        if ($city_id <= 0) {
            return $this->error(__('res.city_id_required'));
        }
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->getContentEvaluate($city_id, $id, $limit);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 添加内容评价
     * @param CityService $service
     * @param AddEvaluateRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addContentEvaluate(CityService $service, AddEvaluateRequest $request)
    {
        $service->addContentEvaluate($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 关注企业
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function companyFollow(CityService $service, Request $request)
    {
        $company_id = $request->post('company_id', 0) ?? 0;
        if ($company_id <= 0) {
            return $this->error(__('res.company_id_required'));
        }

        $service->companyFollow($company_id);
        return $this->success(__('res.success'));
    }


    /**
     * 关注店铺
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function shopFollow(CityService $service, Request $request)
    {
        $content_id = $request->post('content_id', 0) ?? 0;
        if ($content_id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->shopFollow($content_id);
        return $this->success(__('res.success'));
    }


    /**
     * 增加预约信息
     * @param CityService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addContentReserve(CityService $service, Request $request)
    {
        $content_id = $request->post('content_id', 0) ?? 0;
        if ($content_id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->addContentReserve($request->all());
        return $this->success(__('res.success'));
    }

}
