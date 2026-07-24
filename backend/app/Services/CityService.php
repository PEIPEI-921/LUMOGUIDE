<?php

namespace App\Services;

use App\Enums\System;
use App\Enums\User;
use App\Enums\Vip;
use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContent;
use App\Models\ContentEvaluate;
use App\Models\CityType;
use App\Models\CityTypeClass;
use App\Models\Company;
use App\Models\Guide;
use App\Models\GuideType;
use App\Models\Reserve;
use App\Models\ReserveGuide;
use App\Models\SystemIntegralConfig;
use App\Models\UserFollow;
use App\Models\UserFollowShop;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Validator;
use Throwable;

class CityService
{

    const KeyArr = [
        1 => ['id', 'name', 'first_picture', 'start_time', 'tickets_free'],
        2 => ['id', 'name', 'first_picture', 'phone', 'address'],
        3 => ['id', 'name', 'first_picture', 'phone', 'address'],
        4 => ['id', 'name', 'first_picture', 'phone', 'address'],
        5 => ['id', 'name', 'first_picture', 'phone', 'address'],
        6 => ['id', 'name', 'first_picture', 'phone', 'address'],
        7 => ['id', 'name', 'first_picture', 'start_time', 'end_time'],
        8 => ['id', 'name', 'first_picture', 'phone'],
    ];

    /**
     * 城市列表
     * @param string $name
     * @param int $continents_id
     * @param int $area_id
     * @param int $limit
     * @return array
     */
    public function lists(string $name, int $continents_id, int $area_id, int $limit)
    {
        $query = City::with(['area'])->where('audit_status', 1);

        if (!empty($name)) {
            $query->where(function ($query) use ($name) {
                $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
            });
        }

        if ($area_id && $continents_id != 10001) {
            if ($continents_id == 10000) {
                $query->where('recommend', 1);
            } else {
                $query->where('continents_id', $continents_id);
            }
        }
        if ($area_id && $area_id != 10001) {
            if ($area_id == 10000) {
                $query->where('recommend', 1);
            } else {
                $query->where('area_id', $area_id);
            }
        }

        $data = $query->orderBy('order', 'desc')->paginate($limit, ['id', 'area_id', 'name', 'name_en', 'is_capital', 'first_picture'])->toArray();
        $res = $data['data'];
        foreach ($res as &$item) {
            $item['area_name'] = $item['area']['name'];
            unset($item['area'], $item);
        }
        return ['total' => $data['total'], 'list' => $res];
    }


    /**
     * 选项
     * @return array
     */
    public function options()
    {
        $data = City::query()->where('audit_status', 1)->orderBy('order', 'desc')->get(['id', 'name'])->toArray();
        array_unshift($data, ['id' => 0, 'name' => '不選擇']);

        return $data;
    }


    /**
     * 获取城市下分类
     * @param int $city_id
     * @return array
     */
    public function class(int $city_id)
    {
        $guide_type_id = Guide::query()->where('city_id', $city_id)
            ->where('audit_status', \App\Enums\Guide::StatusPass)
            ->groupBy('identity_type')
            ->pluck('identity_type')->toArray();
        $guide_type_id = array_unique($guide_type_id);

        $guide_type = GuideType::query()->whereIn('id', $guide_type_id)->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
        if (!empty($guide_type)) {
            $guide_recommend = Guide::query()->where('city_id', $city_id)
                ->where('audit_status', \App\Enums\Guide::StatusPass)
                ->where('recommend', 1)->exists();
            if ($guide_recommend) {
                array_unshift($guide_type, ['id' => 10000, 'name' => '推薦']);
            }
        }

        $type = CityType::with(['child'])->get(['id', 'name'])->toArray();
        foreach ($type as $k => $v) {
            $child = [];
            foreach ($v['child'] as $vv) {
                if (CityContent::query()->where('city_id', $city_id)->where('type_class_id', $vv['id'])->where('audit_status', 1)->exists()) {
                    $child[] = $vv;
                }
            }
            if (!empty($child)) {
                if (CityContent::query()->where("city_id", $city_id)->where('type_id', $v['id'])->where('audit_status', 1)->where('recommend', 1)->exists()) {
                    array_unshift($child, [
                        'id' => 10000,
                        'type_id' => $v['id'],
                        'name' => '推薦列表'
                    ]);
                }
            }
            $type[$k]['child'] = $child;
        }

        return [
            'guide_type' => $guide_type,
            'type' => $type,
        ];
    }


    /**
     * 城市详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function info(int $id)
    {
        $data = City::find($id);
        if (!$data) {
            throw new ApiException(__('res.city_not'));
        }

        return [
            'id' => $data->id,
            'name' => $data->name,
            'name_en' => $data->name_en,
            'is_capital' => $data->is_capital,
            'pictures' => json_decode($data->pictures, true) ?? [],
            'currency' => $data->currency,
            'language' => $data->language,
            'population' => $data->population,
            'race' => $data->race,
            'overview' => $data->overview,
            'history' => $data->history
        ];
    }


    /**
     * 导游列表
     * @param int $city_id
     * @param int $guide_type
     * @param int $limit
     * @return array
     */
    public function guide(int $city_id, int $guide_type, int $limit)
    {
        $query = Guide::query()->where("city_id", $city_id);
        if ($guide_type > 0) {
            if ($guide_type == 10000) {
                $query->where('recommend', 1);
            } else {
                $query->where('identity_type', $guide_type);
            }
        }

        $res = $query->where('audit_status', 1)->orderBy('id', 'desc')->paginate($limit, ['id', 'photo', 'name', 'language'])->toArray();

        $data = $res['data'];
        foreach ($data as $k => &$v) {
            $v['language'] = json_decode($v['language'], true) ?? [];
            unset($v);
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 导游详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function guideInfo(int $id)
    {
        $user = auth('api')->user();
        $user_id = 0;
        if ($user) {
            $user_id = $user->id;
        }

        $data = Guide::with(['user', 'city', 'type'])->find($id);
        if (!$data) {
            throw new ApiException(__('res.guide_not'));
        }
        // 当前是否关注
        $is_follow = UserFollow::query()->where('user_id', $user_id)->where('followed_id', $data->user_id)->exists();

        // 是否可以预约 (只有导游可以)
        $is_reserve = 0;
        if ($user && $user->identity == \App\Enums\User::identityGuide) {
            $is_reserve = 1;
        }

        // 是否可以关注
        $can_follow = 1;
        if ($user && $user->identity == User::identityUser) {
            $can_follow = 0;
        }
        // 自己不能关注自己
        if ($user) {
            if ($user_id == $data->user_id || $user->vip_expiration_time < time()) {
                $can_follow = 0;
            }
        }

        return [
            'id' => $data->id,
            'user_number' => $data->user->number,
            'name' => $data->name,
            'name_en' => $data->name_en,
            'photo' => $data->photo,
            'city_id' => $data->city_id,
            'city_name' => $data->city->name ?? '',
            'identity_type_name' => $data->type->name ?? '',
            'language' => json_decode($data->language, true) ?? [],
            'phone' => $data->phone,
            'email' => $data->email,
            'other_contact' => $data->other_contact ?? '',
            'wechat' => $data->wechat ?? '',
            'whats_app' => $data->whats_app ?? '',
            'line' => $data->line ?? '',
            'industry_type' => implode(',', json_decode($data->industry_type, true) ?? []),
            'have_vehicle' => \App\Enums\Guide::HaveVehicle[$data->have_vehicle],
            'vehicle_rent' => \App\Enums\Guide::VehicleRent[$data->vehicle_rent],
            'car_pictures' => json_decode($data->car_pictures, true) ?? [],
            'introduction' => $data->introduction,
            'is_follow' => $is_follow ? 1 : 0,
            'is_reserve' => $is_reserve,
            'can_follow' => $can_follow,
        ];
    }


    /**
     * 关注导游
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function guideFollow(int $id)
    {
        $user = auth('api')->user();
        if ($user->identity == User::identityUser) {
            throw new ApiException(__('res.auth_error'));
        }
        $user_id = $user->id;

        $guide = Guide::with(['user'])->find($id);
        if (!$guide || $guide->audit_status != \App\Enums\Guide::StatusPass) {
            throw new ApiException(__('res.guide_not'));
        }

        if ($user->id == $guide->user_id) {
            throw new ApiException(__('res.follow_self_error'));
        }

        if (UserFollow::query()->where('user_id', $user_id)->where('followed_identity', User::identityGuide)->where('followed_identity_id', $id)->exists()) {
            throw new ApiException(__('res.follow_repeat_error'));
        }

        $user_identity_id = 0;
        $user_city_name = '';
        if ($user->identity == User::identityGuide) {
            handleUserVip($user);

            $user_identity_id = $user->guide_id;
            $user_city_name = Guide::query()->where('id', $user->guide_id)->value('city_name');
        }
        if ($user->identity == User::identityCompany) {
            handleUserVip($user);

            $user_identity_id = $user->company_id;
            $user_city_name = Company::query()->where('id', $user->company_id)->value('city_name');
        }

        try {
            $model = new UserFollow();
            $model->user_id = $user_id;
            $model->user_continents_id = $user->continents_id;
            $model->user_area_id = $user->area_id;
            $model->user_identity = $user->identity;
            $model->user_identity_id = $user_identity_id;
            $model->user_identity_tag = $user->identity_str;
            $model->user_city_name = $user_city_name;
            $model->followed_id = $guide->user_id;
            $model->followed_continents_id = $guide->user->continents_id;
            $model->followed_area_id = $guide->user->area_id;
            $model->followed_identity = User::identityGuide;
            $model->followed_identity_id = $guide->id;
            $model->followed_identity_tag = $guide->user->identity_str;
            $model->followed_city_name = $guide->city_name;
            $model->save();

            // 给关注人增加关注我的信息
            $count = Redis::hGet("message_list:$id", 'follow_my') ?? 0;
            Redis::hSet("message_list:$id", 'follow_my', $count + 1);
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 导游取关
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function guideUnFollow(int $id)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        $guide = Guide::find($id);
        if (!$guide) {
            throw new ApiException(__('res.guide_not'));
        }

        $data = UserFollow::query()->where('user_id', $user_id)->where('followed_identity', User::identityGuide)->where('followed_identity_id', $id)->first();
        if (!$data) {
            throw new ApiException(__('follow_no_error'));
        }
        $data->delete();
    }


    /**
     * 预约导游
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function reserveGuide(array $data)
    {
        $user = auth('api')->user();
        handleUserVip($user);

        if (!Guide::query()->where('id', $data['guide_id'])->exists()) {
            throw new ApiException(__('res.guide_not'));
        }
        if (!City::query()->where('id', $data['city_id'])->exists()) {
            throw new ApiException(__('res.city_not'));
        }

        try {
            $model = new ReserveGuide();
            $model->user_id = $user->id;
            foreach ($data as $k => $v) {
                $model->{$k} = $v;
            }
            // 预约导游增加未读
            $model->is_read = 0;
            $model->save();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 城市内容列表
     * @param int $city_id
     * @param int $type_id
     * @param int $type_class_id
     * @param int $limit
     * @return array
     */
    public function getCityContentList(int $city_id, int $type_id, int $type_class_id, int $limit)
    {
        $query = CityContent::query()->where('city_id', $city_id)->where('type_id', $type_id);
        if ($type_class_id > 0) {
            if ($type_class_id == 10000) {
                $query->where('recommend', 1)
                    ->where(function ($query) {
                        $query->where('recommend_time', '=', 999999999)->orWhere('recommend_time', '>', time());
                    });
            } else {
                $query->where('type_class_id', $type_class_id);
            }
        }

        $field = self::KeyArr[$type_id];

        $res = $query->where('audit_status', \App\Enums\City::AuditStatusPass)
            ->where('status', 1)
            ->orderBy('id', 'desc')
            ->orderBy('order', 'desc')
            ->paginate($limit, $field)->toArray();

        $data = $res['data'];
        foreach ($data as $k => &$v) {
            if (isset($v['tickets_free'])) {
                $v['tickets_free'] = \App\Enums\City::TicketsFree[$v['tickets_free']];
            }
            $v['evaluate_count'] = ContentEvaluate::query()->where('content_type', \App\Enums\City::ContentTypeCity)->where('content_id', $v['id'])->count();
            unset($v);
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 获取内容详情
     * @param int $city_id
     * @param int $type_id
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function getContentInfo(int $city_id, int $type_id, int $id)
    {
        $user = auth('api')->user();

        $data = CityContent::with(['user', 'city'])->where('city_id', $city_id)
//            ->where('type_id', $type_id)
            ->where('id', $id)->first();
        if (!$data) {
            throw new ApiException(__('res.content_not'));
        }

        // 景点,交通,设施,活动 可评价
        $is_evaluate = 0;
//        if (in_array($type_id, [1, 5, 6, 7])) {
//            if ($user->vip_type == \App\Enums\Vip::OrderVipTypeGuide) {
//                $is_evaluate = 1;
//            }
//        }

//        if ($user->vip_type == \App\Enums\Vip::OrderVipTypeGuide) {
//            $is_evaluate = 1;
//        }
        // 导游身份可以评价 不过期
        if ($user && ($user->identity == \App\Enums\User::identityGuide && $user->vip_type == Vip::OrderVipTypeGuide)) {
            $is_evaluate = 1;
        }

        $is_user = 0;
        if ($user && $user->identity > \App\Enums\User::identityUser) {
            $is_user = 1;
        }

        // 可预约
        $is_reserve = 0;
        $is_shop = 0;
        $is_follow = 0;
        $can_follow = 1;
        if ($is_user && ($data->publisher_type == 'company' && in_array($type_id, [1, 2, 3, 4, 8]))) {
            $is_reserve = 1;
            $is_shop = 1;
            $is_follow = UserFollowShop::query()->where('user_id', $user->id)->where('followed_id', $id)->exists() ? 1 : 0;

            // 自己不能关注自己 不能预约自己
            if ($data->user_id == $user->id) {
                $can_follow = 0;
                $is_reserve = 0;
            }
        }

        $data = $data->toArray();
        $data['pictures'] = json_decode($data['pictures'], true) ?? [];

        // 普通用户无权限
        if ($is_user == 0) {
            $can_follow = 0;
        }

        return [
            'id' => $id,
            'user_number' => $data['user']['number'],
            'city_name' => $data['city']['name'],
            'name' => $data['name'],
            'class_name' => CityTypeClass::query()->where('id', $data['type_class_id'])->value('name') ?? '',
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'tickets_free' => (string)$data['tickets_free'],
            'capacity' => $data['capacity'],
            'order_food' => (string)$data['order_food'],
            'price' => $data['price'],
            'phone' => $data['phone'],
            'other_phone' => $data['other_phone'],
            'email' => $data['email'],
            'website' => $data['website'],
            'address' => $data['address'],
            'longitude' => $data['longitude'],
            'latitude' => $data['latitude'],
            'how_arrive' => $data['how_arrive'],
            'introduce' => $data['introduce'],
            'pictures' => $data['pictures'],
            'is_evaluate' => $is_evaluate,
            'is_reserve' => $is_reserve,
            'is_shop' => $is_shop,
            'is_follow' => $is_follow,
            'can_follow' => $can_follow,
        ];
    }


    /**
     * 内容评价
     * @param int $city_id
     * @param int $id
     * @param int $limit
     * @return array
     */
    public function getContentEvaluate(int $city_id, int $id, int $limit)
    {
        $res = ContentEvaluate::with(['user'])
            ->where('content_type', \App\Enums\City::ContentTypeCity)
            ->where('content_id', $id)
            ->orderBy('star', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($limit, ['id', 'user_id', 'content', 'pictures', 'star', 'created_at'])
            ->toArray();

        $data = $res['data'];
        foreach ($data as $k => &$v) {
            $v['pictures'] = json_decode($v['pictures'], true) ?? [];
            unset($v);
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 添加内容评价
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addContentEvaluate(array $data)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        if ($user->identity !== \App\Enums\User::identityGuide) {
            throw new ApiException(__('res.auth_error'));
        }

        handleUserVip($user);

        $city_content = CityContent::query()->where('id', $data['content_id'])->first();
        if (!$city_content) {
            throw new ApiException(__('res.content_not'));
        }
//        if (!in_array($city_content->type_id, [1, 5, 6, 7])) {
//            throw new ApiException('当前内容不可以评价');
//        }

        DB::beginTransaction();
        try {
            $model = new ContentEvaluate();
            $model->user_id = $user_id;
            $model->user_type = 'guide';// 只有导游可以评价
            $model->content_id = $data['content_id'];
            $model->content_name = $city_content->name;
            $model->content_user_id = $city_content->user_id;// 内容发布者
            $model->content = $data['content'];
            if (isset($data['pictures'])) {
                $model->pictures = json_encode($data['pictures']);
            }
            $model->star = $data['star'];
            $model->save();

            // 添加评论增加积分
            SystemIntegralConfig::saveData($user->id, 'evaluate');

            // 评价我的
            $count = Redis::hGet("message_list:{$city_content->user_id}", 'evaluate_my') ?? 0;
            Redis::hSet("message_list:{$city_content->user_id}", 'evaluate_my', $count + 1);

            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 关注企业
     * @param int $company_id
     * @return void
     * @throws ApiException
     */
    public function companyFollow(int $company_id)
    {
        $user = auth('api')->user();
        if ($user->identity == User::identityUser) {
            throw new ApiException(__('res.auth_error'));
        }
        $user_id = $user->id;

        $company = Company::with(['user'])->where('id', $company_id)->first();
        if (!$company || $company->audit_status != \App\Enums\Company::StatusPass) {
            throw new ApiException(__('res.company_not'));
        }

        if ($user_id == $company->user_id) {
            throw new ApiException(__('res.follow_self_error'));
        }

        $follow = UserFollow::query()->where('user_id', $user_id)->where('followed_identity', User::identityCompany)
            ->where('followed_identity_id', $company_id)->first();

        $user_identity_id = 0;
        $user_city_name = '';
        if ($user->identity == User::identityGuide) {
            handleUserVip($user);

            $user_identity_id = $user->guide_id;
            $user_city_name = Guide::query()->where('id', $user->guide_id)->value('city_name');
        }
        if ($user->identity == User::identityCompany) {
            handleUserVip($user);

            $user_identity_id = $user->company_id;
            $user_city_name = Company::query()->where('id', $user->company_id)->value('city_name');
        }

        try {
            if ($follow) {
                $follow->delete();
            } else {
                $model = new UserFollow();
                $model->user_id = $user->id;
                $model->user_continents_id = $user->continents_id;
                $model->user_area_id = $user->area_id;
                $model->user_identity = $user->identity;
                $model->user_identity_id = $user_identity_id;
                $model->user_identity_tag = $user->identity_str;
                $model->user_city_name = $user_city_name;
                $model->followed_id = $company->user_id;
                $model->followed_continents_id = $company->user->continents_id;
                $model->followed_area_id = $company->user->area_id;
                $model->followed_identity = User::identityCompany;
                $model->followed_identity_id = $company->id;
                $model->followed_identity_tag = $company->user->identity_str;
                $model->followed_city_name = $company->city_name;
                $model->save();

                // 关注我的
                $count = Redis::hGet("message_list:$user_id", 'follow_my') ?? 0;
                Redis::hSet("message_list:$user_id", 'follow_my', $count + 1);
            }
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 关注店铺
     * @param int $content_id
     * @return void
     * @throws ApiException
     */
    public function shopFollow(int $content_id)
    {
        $user = auth('api')->user();
        if ($user->identity == User::identityUser) {
            throw new ApiException(__('res.auth_error'));
        }
        $user_id = $user->id;

        $content = CityContent::with(['city'])->find($content_id);
        if (!$content || $content->audit_status != \App\Enums\City::AuditStatusPass) {
            throw new ApiException(__('res.shop_not'));
        }
        if ($content->publisher_type !== 'company') {
            throw new ApiException(__('res.shop_type_error'));
        }

        if ($user_id == $content->user_id) {
            throw new ApiException(__('res.follow_self_error'));
        }

        $follow = UserFollowShop::query()->where('user_id', $user_id)->where('followed_id', $content_id)->first();

        $user_identity_id = 0;
        $user_city_name = '';
        if ($user->identity == User::identityGuide) {
            handleUserVip($user);

            $user_identity_id = $user->guide_id;
            $user_city_name = Guide::query()->where('id', $user->guide_id)->value('city_name');
        }
        if ($user->identity == User::identityCompany) {
            handleUserVip($user);

            $user_identity_id = $user->company_id;
            $user_city_name = Company::query()->where('id', $user->company_id)->value('city_name');
        }

        try {
            if ($follow) {
                $follow->delete();
            } else {
                $model = new UserFollowShop();
                $model->user_id = $user->id;
                $model->user_continents_id = $user->continents_id;
                $model->user_area_id = $user->area_id;
                $model->user_identity = $user->identity;
                $model->user_identity_id = $user_identity_id;
                $model->user_identity_tag = $user->identity_str;
                $model->user_city_name = $user_city_name;
                $model->followed_id = $content_id;
                $model->followed_continents_id = $content->city->continents_id;
                $model->followed_area_id = $content->city->area_id;
                $model->followed_user_id = $content->user_id;
                $model->followed_name = $content->name;
                $model->followed_city_name = $content->city->name;
                $model->save();

                // 关注我的
                $count = Redis::hGet("message_list:$user_id", 'follow_my_shop') ?? 0;
                Redis::hSet("message_list:$user_id", 'follow_my_shop', $count + 1);
            }
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 增加预约信息
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addContentReserve(array $data)
    {
        $user = auth('api')->user();
        handleUserVip($user);

        $content_id = $data['content_id'];

        $content = CityContent::query()->where('id', $content_id)->first();
        if (!$content) {
            throw new ApiException(__('res.content_not'));
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
                    //                    'file.required' => '请上传客户名单',
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
        //        $message['other.required'] = '请输入其他联系方式';

        $validator = Validator::make($data, $rule, $message);
        if ($validator->fails()) {
            throw new ApiException($validator->errors()->first());
        }

        try {
            $model = new Reserve();
            $model->user_id = $user->id;
            $model->company_id = $content->publisher_id;
            $model->city_id = $content->city_id;
            $model->content_type = $content->type_id;
            foreach ($validator->validated() as $k => $v) {
                $model->{$k} = $v;
            }
            // 预约商家增加未读
            $model->is_read = 0;
            $model->save();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }
}
