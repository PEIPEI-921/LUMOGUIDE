<?php

namespace App\Http\Controllers\Api;


use App\Http\Requests\ApplyCompanyRequest;
use App\Http\Requests\ApplyGuideRequest;
use App\Http\Requests\BindPhoneRequest;
use App\Http\Requests\ContactUsRequest;
use App\Http\Requests\EditInfoRequest;
use App\Http\Requests\FeedbackRequest;
use App\Http\Requests\ReserveGuideRequest;
use App\Http\Requests\UserAddressRequest;
use App\Services\CityService;
use App\Services\UserService;
use Illuminate\Http\Request;

class UserController extends BaseController
{

    /**
     * 记录登录
     * @param UserService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function loginRecord(UserService $service)
    {
        $service->loginRecord();
        return $this->success(__('res.success'));
    }


    /**
     * 根据number 获取信息
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function numberInfo(UserService $service, Request $request)
    {
        $user_number = $request->get('user_number');

        $data = $service->numberInfo($user_number);
        return $this->success(__('res.success'), $data);
    }

    /**
     * 个人信息
     * @param UserService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(UserService $service)
    {
        $users = $service->index();
        return $this->success(__('res.success'), $users);
    }


    /**
     * 修改用户信息
     * @param UserService $service
     * @param EditInfoRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function editInfo(UserService $service, EditInfoRequest $request)
    {
        $service->editInfo($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 删除账号
     * @param UserService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function delAccount(UserService $service)
    {
        $service->delAccount();
        return $this->success(__('res.success'));
    }


    /**
     * 绑定手机号
     * @param UserService $service
     * @param BindPhoneRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function bindPhone(UserService $service, BindPhoneRequest $request)
    {
        $service->bindPhone($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 联系我们提交
     * @param UserService $service
     * @param ContactUsRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function contactUs(UserService $service, ContactUsRequest $request)
    {
        $service->contactUs($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 用户反馈
     * @param UserService $service
     * @param FeedbackRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function feedback(UserService $service, FeedbackRequest $request)
    {
        $service->feedback($request->validated());
        return $this->success(__('res.success'));
    }


    public function addressLists(UserService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->addressLists($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 添加地址
     * @param UserService $service
     * @param UserAddressRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addressAdd(UserService $service, UserAddressRequest $request)
    {
        $service->addressAdd($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 修改地址
     * @param UserService $service
     * @param UserAddressRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addressEdit(UserService $service, UserAddressRequest $request)
    {
        $service->addressEdit($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 删除地址
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function addressDelete(UserService $service, Request $request)
    {
        $id = $request->post('id') ?? 0;
        if (!$id) {
            return $this->error(__('res.id_required'));
        }
        $service->addressDelete($id);
        return $this->success(__('res.success'));
    }


    /**
     * 邀请记录
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function inviteLog(UserService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;

        $data = $service->inviteLog($limit);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 预约导游
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function reserveGuide(UserService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $start_time = $request->get('start_time', '') ?? '';
        $end_time = $request->get('end_time', '') ?? '';

        $data = $service->reserveGuide($limit, $start_time, $end_time);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 预约详情
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveGuideInfo(UserService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->reserveGuideInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 修改导游预约
     * @param UserService $service
     * @param ReserveGuideRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveGuideEdit(UserService $service, ReserveGuideRequest $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $service->reserveGuideEdit($id, $request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 删除预约(隐藏)
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveGuideDel(UserService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->reserveGuideDel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 取消预约
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveGuideCancel(UserService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->reserveGuideCancel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 我的预约商家
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function reserveCompany(UserService $service, Request $request)
    {
        $limit = $request->get('limit', 15) ?? 15;
        $start_time = $request->get('start_time', '') ?? '';
        $end_time = $request->get('end_time', '') ?? '';

        $data = $service->reserveCompany($limit, $start_time, $end_time);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 预约商家详情
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveCompanyInfo(UserService $service, Request $request)
    {
        $id = $request->get('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $data = $service->reserveCompanyInfo($id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 预约商家修改
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveCompanyEdit(UserService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }
        $service->reserveCompanyEdit($id, $request->all());
        return $this->success(__('res.success'));
    }


    /**
     * 预约商家删除(隐藏)
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveCompanyDel(UserService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->reserveCompanyDel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 取消预约
     * @param UserService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function reserveCompanyCancel(UserService $service, Request $request)
    {
        $id = $request->post('id', 0) ?? 0;
        if ($id <= 0) {
            return $this->error(__('res.id_required'));
        }

        $service->reserveCompanyCancel($id);
        return $this->success(__('res.success'));
    }


    /**
     * 导游认证提交
     * @param UserService $service
     * @param ApplyGuideRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function applyGuide(UserService $service, ApplyGuideRequest $request)
    {
        $service->applyGuide($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 导游认证资料
     * @param UserService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function applyGuideInfo(UserService $service)
    {
        $data = $service->applyGuideInfo();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 修改认证
     * @param UserService $service
     * @param ApplyGuideRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function editApplyGuide(UserService $service, ApplyGuideRequest $request)
    {
        $service->editApplyGuide($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 提交企业认证
     * @param UserService $service
     * @param ApplyCompanyRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function applyCompany(UserService $service, ApplyCompanyRequest $request)
    {
        $service->applyCompany($request->validated());
        return $this->success(__('res.success'));
    }


    /**
     * 企业认证资料
     * @param UserService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function applyCompanyInfo(UserService $service)
    {
        $data = $service->applyCompanyInfo();
        return $this->success(__('res.success'), $data);
    }

    /**
     * 修改企业认证
     * @param UserService $service
     * @param ApplyCompanyRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function editApplyCompany(UserService $service, ApplyCompanyRequest $request)
    {
        $service->editApplyCompany($request->validated());
        return $this->success(__('res.success'));
    }

}
