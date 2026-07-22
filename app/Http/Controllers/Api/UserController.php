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
use App\Models\JourneyTemplate;
use App\Models\JourneyWork;
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

    // ============================================
    // JourneyWork — 我的历程 CRUD
    // ============================================

    /**
     * 将 content JSON 展开为平铺字段返回给前端
     */
    private function expandJourneyWork($work)
    {
        if (!$work) return null;
        $arr = $work->toArray();
        $content = $arr['content'] ?? [];
        if (is_array($content)) {
            unset($arr['content']);
            $arr = array_merge($content, $arr);
        }
        return $arr;
    }

    /**
     * 对分页器的每一项展开 content，返回 {list, total, page, limit}
     */
    private function paginateAndExpand($paginator, $limit)
    {
        $list = $paginator->getCollection()->map(fn($m) => $this->expandJourneyWork($m))->toArray();
        return $this->success(__('res.success'), [
            'list'  => $list,
            'total' => $paginator->total(),
            'page'  => $paginator->currentPage(),
            'limit' => $limit,
        ]);
    }

    public function journeyList(Request $request)
    {
        $user = auth()->user();
        $limit = (int)($request->get('limit', 15) ?: 15);
        $status = (int)($request->get('status', 0) ?: 0);
        $area_id = (int)($request->get('area_id', 0) ?: 0);
        $keyword = $request->get('keyword', '') ?: '';

        $query = JourneyWork::where('user_id', $user->id);
        if ($status > 0) $query->where('status', $status);
        if ($area_id > 0) $query->where('area_id', $area_id);
        if ($keyword) {
            $query->where('title', 'like', "%{$keyword}%");
        }

        return $this->paginateAndExpand($query->orderBy('id', 'desc')->paginate($limit), $limit);
    }

    public function journeyDetail(Request $request)
    {
        $id = (int)($request->get('id', 0) ?: 0);
        if ($id <= 0) return $this->error(__('res.id_required'));

        $work = JourneyWork::where('user_id', auth()->id())->find($id);
        if (!$work) return $this->error(__('res.not_found'), 404);

        return $this->success(__('res.success'), $this->expandJourneyWork($work));
    }

    public function journeyCreate(Request $request)
    {
        $user = auth()->user();

        // 接收前端平铺字段，全部存入 content JSON
        $all = $request->post();
        $content = is_array($all) ? $all : [];
        unset($content['user_id'], $content['_token'], $content['id']); // 移除不安全字段

        if (empty($content)) return $this->error(__('res.param_error'));

        $title = $content['title'] ?? ($content['name'] ?? '');
        $status = (int)($content['status'] ?? 1);
        $areaId = (int)($content['area_id'] ?? 0);
        unset($content['title'], $content['name'], $content['status'], $content['area_id']); // 已提取到独立列，不重复存 JSON

        $work = JourneyWork::create([
            'user_id' => $user->id,
            'title'   => $title,
            'status'  => $status,
            'area_id' => $areaId,
            'content' => $content,
        ]);

        return $this->success(__('res.success'), $this->expandJourneyWork($work));
    }

    public function journeyUpdate(Request $request)
    {
        $id = (int)($request->post('id', 0) ?: 0);
        if ($id <= 0) return $this->error(__('res.id_required'));

        $work = JourneyWork::where('user_id', auth()->id())->find($id);
        if (!$work) return $this->error(__('res.not_found'), 404);

        $all = $request->post();
        $content = is_array($all) ? $all : [];
        unset($content['user_id'], $content['_token'], $content['id']);

        $update = [];
        if (isset($content['title'])) { $update['title'] = $content['title']; unset($content['title']); }
        elseif (isset($content['name'])) { $update['title'] = $content['name']; unset($content['name']); }
        if (isset($content['status'])) { $update['status'] = (int)$content['status']; unset($content['status']); }
        if (isset($content['area_id'])) { $update['area_id'] = (int)$content['area_id']; unset($content['area_id']); }

        // 合并已有 content + 新提交字段（过滤 null 值，避免覆盖已有数据）
        $existing = $work->content ?? [];
        $filtered = array_filter($content, fn($v) => $v !== null);
        $merged = array_merge(is_array($existing) ? $existing : [], $filtered);
        $update['content'] = $merged;

        $work->update($update);
        return $this->success(__('res.success'), $this->expandJourneyWork($work->fresh()));
    }

    public function journeyDelete(Request $request)
    {
        $id = (int)($request->post('id', 0) ?: 0);
        if ($id <= 0) return $this->error(__('res.id_required'));

        $work = JourneyWork::where('user_id', auth()->id())->find($id);
        if (!$work) return $this->error(__('res.not_found'), 404);

        $work->delete();
        return $this->success(__('res.success'));
    }

    // ============================================
    // JourneyTemplate — 工作模板
    // ============================================

    public function journeyTemplateList(Request $request)
    {
        $user = auth()->user();
        $limit = (int)($request->get('limit', 15) ?: 15);

        return $this->paginateAndExpand(
            JourneyTemplate::where('user_id', $user->id)->orderBy('id', 'desc')->paginate($limit),
            $limit
        );
    }

    public function journeyTemplateSave(Request $request)
    {
        $user = auth()->user();

        $all = $request->post();
        $content = is_array($all) ? $all : [];
        unset($content['user_id'], $content['_token'], $content['id']);

        if (empty($content)) return $this->error(__('res.param_error'));

        $title = $content['title'] ?? ($content['name'] ?? '');
        unset($content['title'], $content['name']);

        $template = JourneyTemplate::create([
            'user_id' => $user->id,
            'title'   => $title,
            'content' => $content,
        ]);

        return $this->success(__('res.success'), $this->expandJourneyWork($template));
    }

    public function journeyTemplateDelete(Request $request)
    {
        $id = (int)($request->post('id', 0) ?: 0);
        if ($id <= 0) return $this->error(__('res.id_required'));

        $template = JourneyTemplate::where('user_id', auth()->id())->find($id);
        if (!$template) return $this->error(__('res.not_found'), 404);

        $template->delete();
        return $this->success(__('res.success'));
    }

}
