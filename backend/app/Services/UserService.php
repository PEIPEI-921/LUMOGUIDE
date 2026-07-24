<?php

namespace App\Services;

use App\Enums\Reserve as ReserveCode;
use App\Enums\System;
use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContent;
use App\Models\Company;
use App\Models\CompanyEdit;
use App\Models\Guide;
use App\Models\GuideEdit;
use App\Models\GuideType;
use App\Models\Reserve;
use App\Models\ReserveGuide;
use App\Models\SystemContactUs;
use App\Models\SystemFeedback;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Models\UserAddress;
use App\Models\UserFollow;
use App\Models\UserFollowShop;
use App\Models\UserInviteLog;
use App\Rules\PhoneWithCountryCode;
use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Writer\PngWriter;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Validator;
use Throwable;

class UserService
{

    /**
     * 记录登录
     * @return void
     */
    public function loginRecord()
    {
        $user_id = auth('api')->id();

        // 每日登录增加积分
        SystemIntegralConfig::saveData($user_id, 'login');

        DB::table('user_login')->insert([
            'user_id' => $user_id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }


    /**
     * 根据number 获取信息
     * @param string $number
     * @return array
     * @throws ApiException
     */
    public function numberInfo(string $number)
    {
        $user = User::query()->where('number', $number)->first();
        if (!$user) {
            throw new ApiException(__('res.user_not'));
        }

        $guide_info = [];
        if ($user->guide_id > 0) {
            $guide_info = Guide::find($user->guide_id);
        }

        $company_info = [];
        if ($user->company_id > 0) {
            $company_info = Company::find($user->company_id);
        }

        return [
            'identity' => $user->identity,
            'guide_id' => $user->guide_id,
            'guide_info' => $guide_info,
            'company_id' => $user->company_id,
            'company_info' => $company_info,
        ];
    }


    /**
     * 个人信息
     * @return array
     */
    public function index()
    {
        $user = auth('api')->user();

        $follow_count = UserFollow::query()->where('user_id', $user->id)->count();
        $fan_count = UserFollow::query()->where('followed_id', $user->id)->count();

        $guide_audit_status = Guide::query()->where('user_id', $user->id)->value('audit_status') ?? 9;
        $company_audit_status = Company::query()->where('user_id', $user->id)->value('audit_status') ?? 9;

        // 预约我的未读
        $reserve_count = 0;
        // 城市管理未读
        $city_remind_count = 0;
        // 我的发布未读
        $content_remind_count = 0;
        // 关注未读
        $follow_my_count = 0;

        $list_data = Redis::hGetAll("message_list:{$user->id}") ?? [];

        $guide = (object)[];
        if ($user->guide_id > 0) {
            $guide = Guide::query()->where('id', $user->guide_id)->first(['id', 'name', 'photo', 'city_name', 'identity_type'])->toArray();
            $reserve_count = ReserveGuide::query()->where('guide_id', $user->guide_id)->where('is_read', 0)->count();

            $city_remind_count = City::query()->where("guide_id", $user->guide_id)->where('is_read', 0)->count();
            $content_remind_count = CityContent::query()->where("publisher_id", $user->guide_id)->where("publisher_type", 'guide')->where('is_read', 0)->count();
            $follow_my_count = $list_data['follow_my'] ?? 0;
        }

        $company = (object)[];
        if ($user->company_id > 0) {
            $company = Company::query()->where('id', $user->company_id)->first(['id', 'name', 'city_name', 'business_type'])->toArray();
            $fan_count = UserFollowShop::query()->where('followed_user_id', $user->id)->count();

            $reserve_count = Reserve::query()->where('company_id', $user->company_id)->where('is_read', 0)->count();

            $content_remind_count = CityContent::query()->where("publisher_id", $user->company_id)->where("publisher_type", 'company')->where('is_read', 0)->count();
            $follow_my_count = $list_data['follow_my_shop'] ?? 0;
        }

        // 判断用户状态
        $user_status = 0;
        $user_status_id = env('USER_STATUS_ID');
        if ($user_status_id) {
            $user_status_id_arr = explode(',', $user_status_id);
            if (in_array($user->id, $user_status_id_arr)) {
                $user_status = 1;
            }
        }

//        // 邀请码图片
//        $path = public_path("storage/user_invite/{$user->id}.png");
//        if (!file_exists($path)) {
//            // 二维码
//            $result = Builder::create()
//                ->writer(new PngWriter())
//                ->data(env('WEB_URL') . '/invite.html?code=' . $user->inviter_code)
//                ->build();
//            $result->saveToFile($path);
//        }

        return [
            'id' => $user->id,
            'number' => $user->number,
            'email' => $user->email,
            'nickname' => $user->nickname,
            'avatar' => $user->avatar,
            'phone' => $user->phone,
            'birthday' => $user->birthday,
            'inviter_code' => $user->inviter_code,
            'integral' => $user->integral,
            'identity' => $user->identity,
            'identity_str' => $user->identity_str ?? '',
            'vip_type' => $user->vip_type,
            'vip_id' => $user->vip_id,
            'vip_name' => $user->vip_name,
            'vip_expiration_time' => $user->vip_expiration_time,
            'vip_free' => $user->vip_free,
            'vip_free_day' => 30,
            'follow_count' => $follow_count,
            'fan_count' => $fan_count,
            'guide_audit_status' => $guide_audit_status,
            'guide_id' => $user->guide_id,
            'guide_info' => $guide,
            'company_audit_status' => $company_audit_status,
            'company_info' => $company,
            'reserve_count' => $reserve_count,
            'city_remind_count' => $city_remind_count,
            'content_remind_count' => $content_remind_count,
            'fans_remind_count' => $follow_my_count,
            'reg_time' => substr($user->created_at, 0, 10),
            'user_status' => $user_status,
            'invite_url' => env('WEB_URL') . '/invite.html?code=' . $user->inviter_code,
//            'invite_img' => env('APP_URL') . "/storage/user_invite/{$user->id}.png",
        ];
    }


    /**
     * 修改用户信息
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function editInfo(array $data)
    {
        $user_id = auth('api')->id();
        $user = User::find($user_id);

        try {
            foreach ($data as $key => $value) {
                $user->{$key} = $value;
            }
            $user->save();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除账号
     * @return void
     * @throws ApiException
     */
    public function delAccount()
    {
        $user_id = auth('api')->id();

        try {
            User::destroy($user_id);
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 绑定手机号
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function bindPhone(array $data)
    {
        $phone = $data['phone'];
        $code = $data['phone_code'];
        $cacheCode = Cache::get("verification_phone_{$phone}");
        if (!$cacheCode || $cacheCode != $code) {
            //            throw new ApiException('短信验证码错误');
        }

        $this->editInfo(['phone' => $phone]);
    }


    /**
     * 联系我们提交
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function contactUs(array $data)
    {
        $user_id = auth('api')->id();

        try {
            $model = new SystemContactUs();
            $model->user_id = $user_id;
            $model->title = $data['title'];
            $model->email = $data['email'];
            $model->content = $data['content'];
            $model->save();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 用户反馈
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function feedback(array $data)
    {
        $user_id = auth('api')->id();
        try {
            $model = new SystemFeedback();
            $model->user_id = $user_id;
            $model->title = $data['title'];
            $model->content = $data['content'];
            if (!empty($data['pictures'])) {
                $model->pictures = json_encode($data['pictures'], true);
            }
            $model->save();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 用户地址列表
     * @param int $limit
     * @return array
     */
    public function addressLists(int $limit)
    {
        $user_id = auth('api')->id();
        $data = UserAddress::query()->where('user_id', $user_id)->paginate($limit)->toArray();
        return ['total' => $data['total'], 'list' => $data['data']];
    }


    /**
     * 添加用户地址
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addressAdd(array $data)
    {
        $user_id = auth('api')->id();

//        $country = SystemArea::query()->find($data['country_id']);
//        if (!$country) {
//            throw new ApiException('國家信息不存在');
//        }
//        $city = SystemArea::query()->find($data['city_id']);
//        if (!$city) {
//            throw new ApiException('城市信息不存在');
//        }

        try {
            // 修改其他默认地址
            if (isset($data['default']) && $data['default'] == 1) {
                UserAddress::where('user_id', $user_id)->update(['default' => 0]);
            }

            $model = new UserAddress();
            $model->user_id = $user_id;
            $model->name = $data['name'];
            $model->phone = $data['phone'];
//            $model->country_id = $data['country_id'];
//            $model->country = $country->name;
//            $model->city_id = $data['city_id'];
//            $model->city = $data['city'];
//            $model->street = $data['street'];
            $model->address = $data['address'];
            $model->post_code = $data['post_code'];
            $model->default = $data['default'] ?? 0;
            $model->save();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 编辑用户地址
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addressEdit(array $data)
    {
        if (!isset($data['id'])) {
            throw new ApiException(__('res.id_required'));
        }
        $user_id = auth('api')->id();

        $address = UserAddress::query()->where('user_id', $user_id)->find($data['id']);
        if (!$address) {
            throw new ApiException(__('res.address_not'));
        }
//        $country = SystemArea::query()->find($data['country_id']);
//        if (!$country) {
//            throw new ApiException('國家信息不存在');
//        }
//        $city = SystemArea::query()->find($data['city_id']);
//        if (!$city) {
//            throw new ApiException('城市信息不存在');
//        }
        try {
            // 修改其他默认地址
            if (isset($data['default']) && $data['default'] == 1) {
                UserAddress::where('user_id', $user_id)->update(['default' => 0]);
            }

            $address->name = $data['name'];
            $address->phone = $data['phone'];
//            $address->country_id = $data['country_id'];
//            $address->country = $country->name;
//            $address->city_id = $data['city_id'];
//            $address->city = $data['city'];
//            $address->street = $data['street'];
            $address->address = $data['address'];
            $address->post_code = $data['post_code'];
            $address->default = $data['default'] ?? 0;
            $address->save();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除用户地址
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function addressDelete(int $id)
    {
        $user_id = auth('api')->id();
        $address = UserAddress::query()->where('user_id', $user_id)->find($id);
        if (!$address) {
            throw new ApiException(__('res.address_not'));
        }
        try {
            $address->delete();
        } catch (Throwable $e) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 邀请记录
     * @param int $limit
     * @return array
     */
    public function inviteLog(int $limit)
    {
        $user = auth('api')->user();
        $user_id = $user->id;
        $data = UserInviteLog::with(['invitees'])->where('user_id', $user_id)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'invitees_uid', 'created_at'])
            ->toArray();

        $res = [];
        foreach ($data['data'] as $v) {
            if (isset($v['invitees'])) {
                $res[] = [
                    'invitees_nickname' => $v['invitees']['nickname'],
                    'invitees_avatar' => $v['invitees']['avatar'],
                    'created_at' => substr($v['created_at'], 0, 10),
                ];
            }
        }
        return ['inviter_code' => $user->inviter_code, 'total' => $data['total'], 'list' => $res];
    }


    /**
     * 预约导游
     * @param int $limit
     * @param string $start_time
     * @param string $end_time
     * @return array
     */
    public function reserveGuide(int $limit, string $start_time, string $end_time)
    {
        $user_id = auth('api')->id();

        $query = ReserveGuide::with(['guide'])->where('user_id', $user_id);
        if (!empty($start_time)) {
            $query->where('arrival_time', '>=', "$start_time 00:00:00");

            if (!empty($end_time)) {
                $query->where('arrival_time', '<', "$end_time 23:59:59");
            }
        }

        $res = $query->where('user_del', 0)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'guide_id', 'arrival_time', 'reason', 'status', 'created_at'])->toArray();

        $guide_type = GuideType::query()->pluck('name', 'id')->toArray();

        $data = [];
        foreach ($res['data'] as $k => $v) {
            $status = $v['status'];
            $arrival_time = strtotime($v['arrival_time']);

            // 到达日期已过 导游没有处理 代表过期
            if ($arrival_time < time()) {
                if ($status == ReserveCode::StatusNew) {
                    $status = ReserveCode::StatusExpired;
                }
            }

            $data[] = [
                'id' => $v['id'],
                'guide' => [
                    'id' => $v['guide_id'],
                    'photo' => $v['guide']['photo'],
                    'name' => $v['guide']['name'],
                    'city_name' => $v['guide']['city_name'],
                    'language' => json_decode($v['guide']['language'], true),
                    'identity_type' => $guide_type[$v['guide']['identity_type']],
                ],
                'status' => $status,
                'reason' => $v['reason'],
                'created_at' => $v['created_at'],
            ];
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 预约详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function reserveGuideInfo(int $id)
    {
        $data = ReserveGuide::with(['guide'])->find($id);
        if (!$data) {
            throw new ApiException(__('res.data_not'));
        }
        $data = $data->toArray();

        $guide_type = GuideType::query()->pluck('name', 'id')->toArray();
        $city_name = City::query()->where('id', $data['city_id'])->value('name');

        $status = $data['status'];
        $arrival_time = strtotime($data['arrival_time']);

        // 到达日期已过 导游没有处理 代表过期
        if ($arrival_time < time()) {
            if ($status == ReserveCode::StatusNew) {
                $status = ReserveCode::StatusExpired;
            }
        }

        return [
            'id' => $data['id'],
            'city_id' => $data['city_id'],
            'city_name' => $city_name,
            'arrival_time' => $data['arrival_time'],
            'number' => $data['number'],
            'remark' => $data['remark'],
            'contact' => $data['contact'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'other' => $data['other'],
            'status' => $status,
            'reason' => $data['reason'],
            'created_at' => $data['created_at'],
            'guide' => [
                'id' => $data['guide']['id'],
                'photo' => $data['guide']['photo'],
                'name' => $data['guide']['name'],
                'city_id' => $data['city_id'],
                'city_name' => $data['guide']['city_name'],
                'language' => json_decode($data['guide']['language'], true),
                'identity_type' => $guide_type[$data['guide']['identity_type']],
            ],
        ];
    }


    /**
     * 修改预约
     * @param int $id
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function reserveGuideEdit(int $id, array $data)
    {
        $user_id = auth('api')->id();

        if (!Guide::query()->where('id', $data['guide_id'])->exists()) {
            throw new ApiException(__('res.guide_not'));
        }
        if (!City::query()->where('id', $data['city_id'])->exists()) {
            throw new ApiException(__('res.city_not'));
        }

        $reserve = ReserveGuide::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        try {
            foreach ($data as $k => $v) {
                $reserve->{$k} = $v;
            }
            $reserve->status = ReserveCode::StatusNew;
            $reserve->save();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除预约(隐藏)
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function reserveGuideDel(int $id)
    {
        $user_id = auth('api')->id();

        $reserve = ReserveGuide::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        $reserve->user_del = 1;
        $reserve->save();
    }


    /**
     * 取消预约
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function reserveGuideCancel(int $id)
    {
        $user_id = auth('api')->id();

        $reserve = ReserveGuide::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve || $reserve->status != ReserveCode::StatusNew) {
            throw new ApiException(__('res.data_not'));
        }
        $reserve->status = ReserveCode::StatusCancel;
        $reserve->save();
    }


    /**
     * 我的预约商家
     * @param int $limit
     * @param string $start_time
     * @param string $end_time
     * @return array
     */
    public function reserveCompany(int $limit, string $start_time, string $end_time)
    {
        $user_id = auth('api')->id();

        $query = Reserve::with(['content'])->where('user_id', $user_id);
        if (!empty($start_time)) {
            $query->where('arrival_time', '>=', "$start_time 00:00:00");

            if (!empty($end_time)) {
                $query->where('arrival_time', '<', "$end_time 23:59:59");
            }
        }

        $res = $query->where('user_del', 0)->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'content_id', 'arrival_time', 'status', 'reason', 'created_at'])->toArray();

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
                'status' => $status,
                'reason' => $v['reason'],
                'created_at' => $v['created_at'],
                'content' => [
                    'name' => $v['content']['name'] ?? '',
                    'first_picture' => $v['content']['first_picture'] ?? '',
                    'phone' => $v['content']['phone'] ?? '',
                    'address' => $v['content']['address'] ?? ''
                ]
            ];
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 预约商家详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function reserveCompanyInfo(int $id)
    {
        $data = Reserve::with(['content'])->find($id);
        if (!$data) {
            throw new ApiException(__('res.data_not'));
        }

        $status = $data['status'];
        $arrival_time = strtotime($data['arrival_time']);

        // 到达日期已过 状态没有处理 代表过期
        if ($arrival_time < time()) {
            if ($status == ReserveCode::StatusNew) {
                $status = ReserveCode::StatusExpired;
            }
        }

        $data = $data->toArray();
        $data['status'] = $status;
        $content = $data['content'];
        $data['content']['pictures'] = json_decode($content['pictures']);
        $data['content']['tickets_free'] = (string)$content['tickets_free'];
        $data['content']['order_food'] = (string)$content['order_food'];
        return $data;
    }


    /**
     * 预约商家修改
     * @param int $id
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function reserveCompanyEdit(int $id, array $data)
    {
        $user_id = auth('api')->id();
        $content_id = $data['content_id'];

        $content = CityContent::query()->where('id', $content_id)->first();
        if (!$content) {
            throw new ApiException(__('res.data_not'));
        }
        if (!in_array($content->type_id, [1, 2, 3, 4, 8])) {
            throw new ApiException(__('res.content_type_reserve_error'));
        }

        switch ($content->type_id) {
            case 1:
                // 景点
                $rule = [
                    'arrival_time' => 'required',
                    'number' => 'required',
                    'tickets_type' => 'required',
                    'remark' => 'required',
                ];
                $message = [
                    'arrival_time.required' => __('res.arrival_time_required'),
                    'number.required' => __('res.number_required'),
                    'tickets_type.required' => __('res.tickets_type_required'),
                    'remark.required' => __('res.remark_required'),
                ];
                break;
            case 2:
                // 住宿
                $rule = [
                    'arrival_time' => 'required',
                    'number' => 'required',
                    'remark' => 'required',
                ];
                $message = [
                    'arrival_time.required' => __('res.arrival_time_required'),
                    'number.required' => __('res.number_required'),
                    'remark.required' => __('res.remark_required'),
                ];
                break;
            case 3:
                // 购物
                $rule = [
                    'arrival_time' => 'required',
                    'number' => 'required',
                    'remark' => 'required',
                    'file' => 'sometimes',
                ];
                $message = [
                    'arrival_time.required' => __('res.arrival_time_required'),
                    'number.required' => __('res.number_required'),
                    'remark.required' => __('res.remark_required'),
                ];
                break;
            case 4:
                // 住宿
                $rule = [
                    'arrival_time' => 'required',
                    'leave_time' => 'required',
                    'number' => 'required',
                    'room_number' => 'required',
                    'remark' => 'required',
                ];
                $message = [
                    'arrival_time.required' => __('res.arrival_time_required'),
                    'leave_time.required' => __('res.leave_time_required'),
                    'number.required' => __('res.number_required'),
                    'room_number.required' => __('res.room_number_required'),
                    'remark.required' => __('res.remark_required'),
                ];
                break;
            case 8:
                // 门票
                $rule = [
                    'number' => 'required',
                    'remark' => 'required',
                ];
                $message = [
                    'number.required' => __('res.number_required'),
                    'remark.required' => __('res.remark_required'),
                ];
                break;
        }
        $rule['contact'] = 'required';
        $rule['email'] = 'required';
        $rule['phone'] = ['required', new PhoneWithCountryCode];
        $rule['other'] = 'sometimes';
        $rule['content_id'] = 'sometimes';

        $message['contact.required'] = __('res.contact_required');
        $message['email.required'] = __('res.email_required');
        $message['phone.required'] = __('res.phone_required');

        $validator = Validator::make($data, $rule, $message);
        if ($validator->fails()) {
            throw new ApiException($validator->errors()->first());
        }

        $reserve = Reserve::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve) {
            throw new ApiException('预约数据不存在');
        }
        try {
            foreach ($validator->validated() as $k => $v) {
                $reserve->{$k} = $v;
            }
            $reserve->status = ReserveCode::StatusNew;
            $reserve->save();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除商家预约(隐藏)
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function reserveCompanyDel(int $id)
    {
        $user_id = auth('api')->id();

        $reserve = Reserve::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        $reserve->user_del = 1;
        $reserve->save();
    }


    /**
     * 取消预约
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function reserveCompanyCancel(int $id)
    {
        $user_id = auth('api')->id();

        $reserve = Reserve::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$reserve || $reserve->status != ReserveCode::StatusNew) {
            throw new ApiException(__('res.data_not'));
        }
        $reserve->status = ReserveCode::StatusCancel;
        $reserve->save();
    }


    /**
     * 导游认证提交
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function applyGuide(array $data)
    {
        $user_id = auth('api')->id();

        // 不可恶意操作
        if (Company::query()->where('user_id', $user_id)->exists()) {
            throw new ApiException(__('res.auth_error'));
        }

        $guide = Guide::query()->where('user_id', $user_id)->first();
        $is_guide = false;
        if ($guide) {
            if ($guide->audit_status == \App\Enums\Guide::StatusSubmit) {
                throw new ApiException(__('res.apply_auditing'));
            }

            // 存在审核中数据
            if (GuideEdit::query()->where('guide_id', $guide->id)->where('audit_status', 0)->exists()) {
                throw new ApiException(__('res.apply_auditing'));
            }

            $is_guide = true;
//            if ($guide->audit_status == \App\Enums\Guide::StatusPass) {
//                throw new ApiException('您已通过审核,无需修改');
//            }
        }

        $identity_type = GuideType::query()->where('name', $data['identity_type'])->value('id');
        if (!$identity_type) {
            throw new ApiException(__('res.type_id_error'));
        }

        // 判断提交的信息是否相同
        if ($is_guide) {
            $old_data = [];
            foreach ($data as $k => $v) {
                $value = $guide->{$k};
                if ($k == 'identity_type') {
                    $value = GuideType::query()->where('id', $value)->value('name');
                }
                if ($k == 'language' || $k == 'industry_type' || $k == 'car_pictures') {
                    $value = json_decode($value, true);
                }
                $old_data[$k] = $value;
            }
            if (arrayEqual($old_data, $data)) {
                throw new ApiException(__('res.updated_no'));
            }
        }

        DB::beginTransaction();
        try {
            if (!$guide) {
                $model = new Guide();
                $model->user_id = $user_id;
            } else {
                // 当存在导游记录 且被拒绝时 说明是初次申请 并且被拒绝 则重新提交
                if ($guide->is_finish == 0 && $guide->audit_status == \App\Enums\Guide::StatusReject) {
                    $model = $guide;
                    $model->audit_status = \App\Enums\Guide::StatusSubmit;
                    $model->audit_feedback = null;
                } else {
                    // 如果导游通过 则代表增加审核记录
                    $model = new GuideEdit();
                    $model->guide_id = $guide->id;
                }

                // 导游表暂不审核
//                $guide->audit_status = \App\Enums\Guide::StatusSubmit;
//                $guide->audit_feedback = null;
//                $guide->save();
            }

            $model->photo = $data['photo'];
            $model->name = $data['name'];
            if (isset($data['name_en'])) {
                $model->name_en = $data['name_en'];
            }
            $model->phone = $data['phone'];
            $model->email = $data['email'];
            $model->bill_address = $data['bill_address'];
            if (isset($data['other_contact'])) {
                $model->other_contact = $data['other_contact'];
            }
            if (isset($data['wechat'])) {
                $model->wechat = $data['wechat'];
            }
            if (isset($data['whats_app'])) {
                $model->whats_app = $data['whats_app'];
            }
            if (isset($data['line'])) {
                $model->line = $data['line'];
            }
            $model->language = json_encode($data['language']);
            $model->year = $data['year'];
            $model->industry_type = json_encode($data['industry_type']);
            $model->identity_type = $identity_type;
            if (isset($data['other_type'])) {
                $model->other_type = $data['other_type'];
            }
            $model->introduction = $data['introduction'];
            $model->business_contact = $data['business_contact'];
            $model->have_vehicle = $data['have_vehicle'];
            if ($data['have_vehicle'] == 1) {
                $model->vehicle_info = $data['vehicle_info'];
            }
            $model->vehicle_rent = $data['vehicle_rent'];
            $model->certificate_picture = $data['certificate_picture'];
            if (isset($data['passport_picture'])) {
                $model->passport_picture = $data['passport_picture'];
            }
            if (isset($data['driver_license_front'])) {
                $model->driver_license_front = $data['driver_license_front'];
            }
            if (isset($data['driver_license_back'])) {
                $model->driver_license_back = $data['driver_license_back'];
            }
            if (isset($data['car_pictures'])) {
                $model->car_pictures = json_encode($data['car_pictures']);
            }

            // 处理审核驳回
//            if ($model->audit_status == \App\Enums\Guide::StatusReject) {
//                $model->audit_status = \App\Enums\Guide::StatusSubmit;
//                $model->audit_feedback = null;
//            }
            // 审核通过重新审核
//            if ($model->audit_status == \App\Enums\Guide::StatusPass) {
//                $model->audit_status = \App\Enums\Guide::StatusSubmit;
//                $model->audit_feedback = null;
//            }

            $model->save();

            DB::commit();
        } catch (Throwable $e) {
            Db::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 导游认证资料
     * @return array
     * @throws ApiException
     */
    public function applyGuideInfo()
    {
        $user_id = auth('api')->id();
        $guide = Guide::query()->where('user_id', $user_id)->first();
        if (!$guide) {
            throw new ApiException(__('res.apply_not'));
        }

        // 存在待审核数据 / 审核失败数据 有则覆盖当前数据 最新一条数据
        $guide_edit = GuideEdit::query()->where('guide_id', $guide->id)
//            ->whereIn('audit_status', [0, 2])
            ->orderBy('id', 'desc')
            ->first();
        if ($guide_edit && in_array($guide_edit->audit_status, [0, 2])) {
            $guide = $guide_edit;
        }

//        if ($guide->audit_status == \App\Enums\Guide::StatusSubmit) {
//
//        }
        // 处理语言选择问题
        $system_languages = json_decode(systemConfig('languages'), true);
        $guide_language = json_decode($guide->language, true);

        foreach ($guide_language as $k => $v) {
            if (!in_array($v, $system_languages)) {
                $is_have = false;
                foreach ($system_languages as $language) {
                    if (str_contains($language, $v)) {
                        $guide_language[$k] = $language;
                        $is_have = true;
                        break;
                    }
                }
                if (!$is_have) {
                    unset($guide_language[$k]);
                }
            }
        }
        $guide_language = array_unique($guide_language);

        $guide->identity_type = GuideType::query()->where('id', $guide->identity_type)->value('name') ?? '';
        $guide->language = $guide_language;
        $guide->industry_type = json_decode($guide->industry_type, true);
        $guide->car_pictures = json_decode($guide->car_pictures, true);

        unset($guide->created_at, $guide->updated_at, $guide->recommend);
        return $guide->toArray();
    }


    /**
     * 提交商家认证
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function applyCompany(array $data)
    {
        $user_id = auth('api')->id();

        // 不可恶意操作
        if (Guide::query()->where('user_id', $user_id)->exists()) {
            throw new ApiException(__('res.auth_error'));
        }

        $city_name = null;
        if (isset($data['city_id']) && $data['city_id'] > 0) {
            $city_name = City::query()->where('id', $data['city_id'])->value('name');
            if (!$city_name) {
                throw new ApiException(__('res.city_not'));
            }
        }
        $company = Company::query()->where('user_id', $user_id)->first();
        $is_company = false;
        if ($company) {
            if ($company->audit_status == \App\Enums\Company::StatusSubmit) {
                throw new ApiException(__('res.apply_auditing'));
            }

            // 存在审核中数据
            if (CompanyEdit::query()->where('company_id', $company->id)->where('audit_status', 0)->exists()) {
                throw new ApiException(__('res.apply_auditing'));
            }

            $is_company = true;
//            if ($company->audit_status == \App\Enums\Company::StatusPass) {
//                throw new ApiException('您已通过审核,无需修改');
//            }
        }

        // 判断提交的信息是否相同
        if ($is_company) {
            $old_data = [];
            foreach ($data as $k => $v) {
                $value = $company->{$k};
                if ($k == 'picture') {
                    $value = json_decode($value, true);
                }
                $old_data[$k] = $value;
            }

            if (arrayEqual($old_data, $data)) {
                throw new ApiException(__('res.updated_no'));
            }
        }

        DB::beginTransaction();
        try {
            if (!$company) {
                $model = new Company();
                $model->user_id = $user_id;
            } else {
                // 当存在公司 且被拒绝时 说明是初次申请 并且被拒绝 则重新提交
                if ($company->is_finish == 0 && $company->audit_status == \App\Enums\Company::StatusReject) {
                    $model = $company;
                    $model->audit_status = \App\Enums\Guide::StatusSubmit;
                    $model->audit_feedback = null;
                } else {
                    // 如果公司初步通过 则代表增加审核记录
                    $model = new CompanyEdit();
                    $model->company_id = $company->id;
                }

                // 企业表增加待审核
//                $company->audit_status = \App\Enums\Guide::StatusSubmit;
//                $company->audit_feedback = null;
//                $company->save();
            }

            $model->name = $data['name'];
            if (isset($data['name_en'])) {
                $model->name_en = $data['name_en'];
            }
            $model->city_id = $data['city_id'] ?? 0;
            $model->city_name = $city_name;
            $model->address = $data['address'];
            $model->tax_id = $data['tax_id'];
            if (isset($data['business_type'])) {
                $model->business_type = $data['business_type'];
            }
            if (isset($data['introduction'])) {
                $model->introduction = $data['introduction'];
            }
            if (isset($data['email'])) {
                $model->email = $data['email'];
            }
            if (isset($data['phone'])) {
                $model->phone = $data['phone'];
            }
            $model->website = $data['website'];
            if (isset($data['other_contact'])) {
                $model->other_contact = $data['other_contact'];
            }
            if (isset($data['wechat'])) {
                $model->wechat = $data['wechat'];
            }
            if (isset($data['whats_app'])) {
                $model->whats_app = $data['whats_app'];
            }
            if (isset($data['line'])) {
                $model->line = $data['line'];
            }
            if (isset($data['documents_picture'])) {
                $model->documents_picture = $data['documents_picture'];
            }
            if (isset($data['picture'])) {
                $model->picture = json_encode($data['picture']);
            }

//            // 处理审核驳回
//            if ($model->audit_status == \App\Enums\Guide::StatusReject) {
//                $model->audit_status = \App\Enums\Guide::StatusSubmit;
//                $model->audit_feedback = null;
//            }
//            if ($model->audit_status == \App\Enums\Guide::StatusPass) {
//                $model->audit_status = \App\Enums\Guide::StatusSubmit;
//                $model->audit_feedback = null;
//            }

            $model->save();
            DB::commit();
        } catch (Throwable $e) {
            Db::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 商家认证资料
     * @return array
     * @throws ApiException
     */
    public function applyCompanyInfo()
    {
        $user_id = auth('api')->id();
        $company = Company::query()->where('user_id', $user_id)->first();
        if (!$company) {
            throw new ApiException(__('res.apply_not'));
        }

        // 存在审核中 审核失败 最新一条数据
        $company_edit = CompanyEdit::query()->where('company_id', $company->id)
//            ->whereIn('audit_status', [0, 2])
            ->orderBy('id', 'desc')
            ->first();
        if ($company_edit && in_array($company_edit->audit_status, [0, 2])) {
            $company = $company_edit;
        }

//        if ($company->audit_status == \App\Enums\Company::StatusSubmit) {
//
//        }

        $company->picture = json_decode($company->picture, true);

        unset($company->created_at, $company->updated_at, $company->recommend);
        return $company->toArray();
    }

}
