<?php

namespace App\Services;

use App\Enums\Reserve as ReserveCode;
use App\Enums\System;
use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContentEdit;
use App\Models\CityType;
use App\Models\CityTypeClass;
use App\Models\CityContent;
use App\Models\Company;
use App\Models\Guide;
use App\Models\Reserve;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Throwable;

class CompanyService
{
    const KeyArr = [
        // 景点
        1 => ['city_id', 'type_id', 'type_class_id', 'name', 'start_time', 'tickets_free', 'price', 'phone', 'email', 'website',
            'address', 'longitude', 'latitude', 'how_arrive', 'introduce', 'pictures'],
        // 餐厅
        2 => ['city_id', 'type_id', 'type_class_id', 'name', 'start_time', 'capacity', 'order_food', 'phone', 'email', 'website',
            'address', 'longitude', 'latitude', 'introduce', 'pictures'],
        // 购物
        3 => ['city_id', 'type_id', 'type_class_id', 'name', 'start_time', 'phone', 'email', 'website', 'address',
            'longitude', 'latitude', 'introduce', 'pictures'],
        // 住宿
        4 => ['city_id', 'type_id', 'type_class_id', 'name', 'phone', 'email', 'website', 'address', 'longitude', 'latitude', 'introduce', 'pictures'],
        // 票务
        8 => ['city_id', 'type_id', 'type_class_id', 'name', 'phone', 'email', 'website', 'other_phone', 'price', 'address',
            'longitude', 'latitude', 'introduce', 'pictures'],
    ];


    /**
     * 企业详情
     * @param int $company_id
     * @return array
     * @throws ApiException
     */
    public function info(int $company_id)
    {
        $info = Company::query()->where('id', $company_id)->first([
            'id', 'name', 'name_en', 'city_name', 'address', 'business_type', 'introduction', 'email', 'phone', 'website', 'other_contact', 'wechat', 'whats_app', 'line'
        ]);
        if (!$info) {
            throw new ApiException(__('res.company_not'));
        }
        $info = $info->toArray();
        $info['other_contact'] = $info['other_contact'] ?? '';
        $info['wechat'] = $info['wechat'] ?? '';
        $info['whats_app'] = $info['whats_app'] ?? '';
        $info['line'] = $info['line'] ?? '';

        $types = CityType::options();

        $where['publisher_id'] = $company_id;
        $where['publisher_type'] = 'company';

        $res = CityContent::query()->where($where)
            ->orderBy('id', 'desc')
            ->get(['id', 'city_id', 'type_id', 'name', 'phone', 'address', 'first_picture'])
            ->toArray();
        foreach ($res as &$item) {
            $item['type'] = $types[$item['type_id']];
            unset($item);
        }

        $info['shop'] = $res;
        return $info;
    }


    /**
     * 店铺列表
     * @param int $limit
     * @return array
     */
    public function shopLists(int $limit)
    {
        $user = auth('api')->user();

        $user_id = $user->id;
        $company_id = $user->company_id;

        $where['user_id'] = $user_id;
        $where['publisher_id'] = $company_id;
        $where['publisher_type'] = 'company';

        $types = CityType::options();

        $res = CityContent::with(['edit_data'])->where($where)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'type_id', 'name', 'phone', 'address', 'first_picture', 'audit_status', 'is_read', 'audit_feedback', 'created_at'])
            ->toArray();
        $data = $res['data'];
        foreach ($data as $k => $v) {
            // 存在待审核 审核失败的才同步状态
            if (!empty($v['edit_data']) && ($v['edit_data']['audit_status'] == 0 || $v['edit_data']['audit_status'] == 2)) {
                $data[$k]['audit_status'] = $v['edit_data']['audit_status'];
                $data[$k]['audit_feedback'] = $v['edit_data']['audit_feedback'];
            }

            $data[$k]['type'] = $types[$v['type_id']];
            unset($data[$k]['edit_data']);
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 添加店铺
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addShop(array $data)
    {
        $user = auth('api')->user();

        $company_auth = json_decode($user->vip_company_auth, true) ?? [];

        $first_type = CityContent::query()->where('publisher_type', 'company')->where('publisher_id', $user->company_id)->value('type_id') ?? 0;


        // 判断发布第二个店铺时
        if ($first_type > 0) {
            // 只能发布一个
            if ($company_auth['shop_number'] == 1) {
                throw new ApiException(__('res.shop_auth_number_error'));
            } else {
                // 只能发布同类型店铺
                if ($company_auth['shop_type'] == 1) {
                    $city_count_count = CityContent::query()->where('publisher_type', 'company')
                        ->where('type_id', $first_type)
                        ->where('publisher_id', $user->company_id)
                        ->count();

                    // 并且数量超出要发布的
                    if ($city_count_count >= $company_auth['shop_number']) {
                        throw new ApiException(__('res.shop_auth_number_error'));
                    }
                } else {
                    // 不限制店铺 查询总数是否超出
                    $city_count_count = CityContent::query()->where('publisher_type', 'company')
                        ->where('publisher_id', $user->company_id)->count();

                    // 并且数量超出要发布的
                    if ($city_count_count >= $company_auth['shop_number']) {
                        throw new ApiException(__('res.shop_auth_number_error'));
                    }
                }
            }
        }

        $city = City::query()->where('id', $data['city_id'])->first();
        if (!$city) {
            throw new ApiException(__('res.city_not'));
        }

        // 商家不允许发布其他类型
        $type_id = $data['type_id'];
        if (!in_array($type_id, [1, 2, 3, 4, 8])) {
            throw new ApiException(__('res.type_id_error'));
        }
        $city_type_name = CityType::query()->where('id', $type_id)->value('name');

        if (!CityTypeClass::query()->where('id', $data['type_class_id'])->where('type_id', $type_id)->exists()) {
            throw new ApiException(__('res.type_class_id_not'));
        }

        $key_arr = self::KeyArr[$type_id];

        // 给用户信息设置
        $user_set_arr = [];
        if (!$user->continents_id && !$user->area_id) {
            $user_set_arr['continents_id'] = $city->continents_id;
            $user_set_arr['area_id'] = $city->area_id;
        }
        if (!$user->identity_str) {
            $user_set_arr['identity_str'] = $city_type_name;
        }
        $data['order_food'] = $data['order_food'] ?? 0;

        DB::beginTransaction();
        try {
            $model = new CityContent();
            $model->type_id = $type_id;
            $model->user_id = $user->id;
            $model->publisher_id = $user->company_id;
            $model->publisher_type = 'company';
            foreach ($key_arr as $key) {
                if ($key != 'pictures') {
                    $model->{$key} = $data[$key];
                }
            }
            if (isset($data['pictures']) && is_array($data['pictures'])) {
                $model->first_picture = $data['pictures'][0];
                $model->pictures = json_encode($data['pictures']);
            }
            $model->save();

            // 用户字段修改
            if (!empty($user_set_arr)) {
                User::query()->where('id', $user->id)->update($user_set_arr);
            }
            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 获取详情
     * @param int $id
     * @param int $user_id
     * @param int $company_id
     * @return CityContent
     * @throws ApiException
     */
    protected function getCityContentInfo(int $id, int $user_id, int $company_id): CityContent
    {
        $model = CityContent::query()->where('id', $id)->where('publisher_type', 'company')->first();
        if (!$model) {
            throw new ApiException(__('res.content_not'));
        }
        if ($model->publisher_id != $company_id) {
            throw new ApiException(__('res.auth_error'));
        }
        return $model;
    }


    /**
     * 店铺详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function shopInfo(int $id)
    {
        $user = auth('api')->user();

        $user_id = $user->id;
        $company_id = $user->company_id;

        $data = $this->getCityContentInfo($id, $user_id, $company_id);
        handleIsRead($data);// 商家店铺

        $res['id'] = $data->id;
        $key_arr = self::KeyArr[$data->type_id];
        foreach ($key_arr as $key) {
            $res[$key] = $data->{$key};
        }
        $res['pictures'] = json_decode($data['pictures'], true);
        return $res;
    }


    /**
     * 修改店铺
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function shopEdit(array $data)
    {
        $user = auth('api')->user();
        $user_id = $user->id;
        $company_id = $user->company_id;

        if (!City::query()->where('id', $data['city_id'])->exists()) {
            throw new ApiException(__('res.city_not'));
        }

        // 商家不允许发布其他类型
        $type_id = $data['type_id'];
        if (!in_array($type_id, [1, 2, 3, 4, 8])) {
            throw new ApiException(__('res.type_id_error'));
        }

        if (!CityTypeClass::query()->where('id', $data['type_class_id'])->where('type_id', $type_id)->exists()) {
            throw new ApiException(__('res.type_class_id_not'));
        }

        $content = $this->getCityContentInfo($data['id'], $user_id, $company_id);
        if ($content->audit_status == 0) {
            throw new ApiException(__('res.content_auditing'));
        }
        unset($data['id']);

        $key_arr = self::KeyArr[$type_id];

        $old_data = [];
        $new_data = [];
        foreach ($key_arr as $v) {
            $value = $content->{$v};
            if ($v == 'pictures') {
                $value = json_decode($value, true);
            }
            $old_data[$v] = $value;
            $new_data[$v] = $data[$v];
        }

        if (arrayEqual($old_data, $new_data)) {
            throw new ApiException(__('res.updated_no'));
        }

        // 存在审核中数据
        if (CityContentEdit::query()->where('city_content_id', $content->id)->where('audit_status', 0)->exists()) {
            throw new ApiException(__('res.content_auditing'));
        }

        $key_arr = self::KeyArr[$type_id];
        DB::beginTransaction();
        try {
            // 首次创建驳回后
            if ($content->is_finish == 0 && $content->audit_status == 2) {
                foreach ($key_arr as $key) {
                    if (!in_array($key, ['pictures', 'type_id', 'first_picture'])) {
                        $content->{$key} = $data[$key];
                    }
                }
                if (isset($data['pictures']) && is_array($data['pictures'])) {
                    $content->first_picture = $data['pictures'][0];
                    $content->pictures = json_encode($data['pictures']);
                }

                $content->audit_status = 0;
                $content->audit_feedback = null;
                $content->save();
            } else {
                // 增加修改记录
                $res = new CityContentEdit();
                $res->city_content_id = $content->id;
                $res->type_id = $type_id;
                foreach ($key_arr as $key) {
                    if ($key != 'pictures') {
                        $res->{$key} = $data[$key];
                    }
                }
                if (isset($data['pictures']) && is_array($data['pictures'])) {
                    $res->first_picture = $data['pictures'][0];
                    $res->pictures = json_encode($data['pictures']);
                }
                $res->audit_status = 0;
                $res->audit_feedback = null;
                $res->save();
            }
            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function shopDel(int $id)
    {
        $user = auth('api')->user();
        $model = $this->getCityContentInfo($id, $user->id, $user->company_id);
        try {
            $model->delete();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 预约我的
     * @param int $limit
     * @param string $start_time
     * @param string $end_time
     * @param string $guide
     * @return array
     * @throws ApiException
     */
    public function reserve(int $limit, string $start_time, string $end_time, string $guide)
    {
        $user = auth('api')->user();
        $company_id = $user->company_id;

        if ($company_id == 0) {
            throw new ApiException(__('res.auth_error'));
        }

        $query = Reserve::with(['user', 'content'])->where('company_id', $company_id);
        if (!empty($start_time)) {
            $query->where('arrival_time', '>=', "$start_time 00:00:00");
            if (!empty($end_time)) {
                $query->where('arrival_time', '<=', "$end_time 23:59:59");
            }
        }

        if (!empty($guide)) {
            $guide_user_id = Guide::query()->where('audit_status', 1)->where(function ($query) use ($guide) {
                $query->where('name', 'like', "%$guide%")->orWhere('phone', 'like', "%$guide%");
            })->pluck('user_id')->toArray();

            if (!empty($guide_user_id)) {
                $query->whereIn('user_id', $guide_user_id);
            }
        }

        $res = $query->where('company_del', 0)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'user_id', 'city_id', 'content_id', 'arrival_time', 'number', 'is_read', 'status', 'created_at'])
            ->toArray();

        $data = [];
        foreach ($res['data'] as $k => $v) {
            $status = $v['status'];
            $arrival_time = strtotime($v['arrival_time']);

            // 到达日期已过 状态没有处理 代表过期
            if ($arrival_time < time()) {
                if ($status == ReserveCode::StatusNew) {
                    $status = ReserveCode::StatusExpired;
                }
            }

            $data[] = [
                'id' => $v['id'],
                'arrival_time' => $v['arrival_time'],
                'number' => $v['number'],
                'status' => $status,
                'is_read' => $v['is_read'],
                'created_at' => $v['created_at'],
                'user' => $v['user'],
                'content' => [
                    'id' => $v['content_id'],
                    'name' => $v['content']['name'],
                    'type_id' => $v['content']['type_id'],
                    'first_picture' => $v['content']['first_picture'],
                ],
            ];
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 获取预约我的详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function reserveInfo(int $id)
    {
        $data = Reserve::with(['user', 'content'])->find($id);
        if (!$data) {
            throw new ApiException(__('res.data_not'));
        }
        handleIsRead($data);
        $data = $data->toArray();

        $status = $data['status'];
        $arrival_time = strtotime($data['arrival_time']);

        // 到达日期已过 状态没有处理 代表过期
        if ($arrival_time < time()) {
            if ($status == ReserveCode::StatusNew) {
                $status = ReserveCode::StatusExpired;
            }
        }

        return [
            'id' => $data['id'],
            'content_type' => $data['content_type'],
            'arrival_time' => $data['arrival_time'],
            'leave_time' => $data['leave_time'],
            'number' => $data['number'],
            'room_number' => $data['room_number'],
            'remark' => $data['remark'],
            'file' => $data['file'],
            'contact' => $data['contact'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'other' => $data['other'],
            'status' => $status,
            'reason' => $data['reason'],
            'created_at' => $data['created_at'],
            'user' => $data['user'],
            'content' => [
                'id' => $data['content_id'],
                'name' => $data['content']['name'],
                'type_id' => $data['content']['type_id'],
                'first_picture' => $data['content']['first_picture'],
            ],
        ];
    }


    /**
     * 确认预约
     * @param int $id
     * @param int $status
     * @return void
     * @throws ApiException
     */
    public function confirmReserve(int $id, int $status)
    {
        $user = auth('api')->user();
        $company_id = $user->company_id;

        $data = Reserve::query()->where('id', $id)
            ->where('company_id', $company_id)
            ->first();
        if (!$data) {
            throw new ApiException(__('res.data_not'));
        }
        $data->status = $status;
        $data->save();
    }


    /**
     * 拒绝预约
     * @param int $id
     * @param string $reason
     * @return void
     * @throws ApiException
     */
    public function rejectReserve(int $id, string $reason)
    {
        $user = auth('api')->user();
        $company_id = $user->company_id;

        $reserve = Reserve::query()->where('id', $id)
            ->where('company_id', $company_id)
            ->where('status', ReserveCode::StatusNew)->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        try {
            $reserve->status = ReserveCode::StatusReject;
            $reserve->reason = $reason;
            $reserve->save();
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除预约(隐藏)
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function delReserve(int $id)
    {
        $user = auth('api')->user();
        $company_id = $user->company_id;

        $reserve = Reserve::query()->where('id', $id)
            ->where('company_id', $company_id)
            ->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        try {
            $reserve->company_del = 1;
            $reserve->save();
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }

}
