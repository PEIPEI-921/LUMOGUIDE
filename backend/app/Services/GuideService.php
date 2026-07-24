<?php

namespace App\Services;

use App\Enums\System;
use App\Enums\Reserve as ReserveCode;
use App\Exceptions\ApiException;
use App\Mail\AuditMail;
use App\Models\City;
use App\Models\CityContent;
use App\Models\CityContentEdit;
use App\Models\CityEdit;
use App\Models\CityTypeClass;
use App\Models\Guide;
use App\Models\Information;
use App\Models\InformationClass;
use App\Models\ReserveGuide;
use App\Models\SystemContinents;
use App\Models\SystemIntegralConfig;
use App\Models\Trip;
use App\Models\TripDay;
use App\Models\User;
use App\Enums\Trip as TripCode;
use Carbon\Carbon;
use Hedeqiang\TenIM\Facades\IM;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Throwable;

class GuideService
{

    const KeyArr = [
        // 景点
        1 => [
            'city_id',
            'type_id',
            'type_class_id',
            'name',
            'start_time',
            'tickets_free',
            'price',
            'phone',
            'email',
            'website',
            'address',
            'longitude',
            'latitude',
            'how_arrive',
            'introduce',
            'first_picture',
            'pictures'
        ],
        // 交通
        5 => ['city_id', 'type_id', 'type_class_id', 'name', 'phone', 'address', 'longitude', 'latitude', 'introduce', 'first_picture', 'pictures'],
        // 設施
        6 => ['city_id', 'type_id', 'type_class_id', 'name', 'phone', 'address', 'longitude', 'latitude', 'introduce', 'first_picture', 'pictures'],
        // 活動
        7 => ['city_id', 'type_id', 'type_class_id', 'name', 'start_time', 'end_time', 'website', 'address', 'longitude', 'latitude', 'introduce', 'first_picture', 'pictures']
    ];

    const FieldArr = [
        1 => [
            'id',
            'name',
            'start_time',
            'address',
            'first_picture',
            'audit_status',
            'audit_feedback',
            'is_read',
            'created_at'
        ],
        5 => [
            'id',
            'name',
            'phone',
            'address',
            'first_picture',
            'audit_status',
            'audit_feedback',
            'is_read',
            'created_at'
        ],
        6 => [
            'id',
            'name',
            'phone',
            'address',
            'first_picture',
            'audit_status',
            'audit_feedback',
            'is_read',
            'created_at'
        ],
        7 => [
            'id',
            'name',
            'start_time',
            'end_time',
            'first_picture',
            'audit_status',
            'audit_feedback',
            'is_read',
            'created_at'
        ],
    ];


    /**
     * 发布城市
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function publishCity(array $data)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        if (City::query()->where('name', $data['name'])->exists()) {
            throw new ApiException(__('res.city_name_unique'));
        }

        DB::beginTransaction();
        try {
            $model = new City();
            $model->user_id = $user->id;
            $model->guide_id = $user->guide_id;
            $model->name = $data['name'];
            $model->name_en = $data['name_en'];
            $model->country_id = $data['country_id'];
            $model->continents_id = $data['continents_id'];
            $model->area_id = $data['area_id'];
            $model->longitude = $data['longitude'];
            $model->latitude = $data['latitude'];
            $model->is_capital = $data['is_capital'];
            $model->currency = $data['currency'];
            $model->language = $data['language'];
            $model->population = $data['population'];
            $model->race = $data['race'];
            $model->overview = $data['overview'];
            $model->history = $data['history'];
            $model->first_picture = $data['pictures'][0];
            $model->pictures = json_encode($data['pictures']);
            $model->save();

            //            Guide::query()->where('id', $user->guide_id)->where('city_id', 0)->update([
            //                'city_id' => $model->id,
            //                'continents_id' => $data['continents_id'],
            //                'area_id' => $data['area_id'],
            //                'city_name' => $data['name']
            //            ]);
            //            User::query()->where('id', $user->id)->where('continents_id', 0)->update([
            //                'continents_id' => $data['continents_id'],
            //                'area_id' => $data['area_id'],
            //                'city_name' => $data['name']
            //            ]);


            // 发送待审核邮件
            $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/city?status=1";
            Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核城市，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));
            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 切换城市
     * @param int $city_id
     * @return void
     * @throws ApiException
     */
    public function changeCity(int $city_id)
    {
        $user = auth('api')->user();
        if ($user->guide_id == 0) {
            throw new ApiException(__('res.guide_auth_error'));
        }

        $city = '';
        if ($city_id > 0) {
            $city = City::query()->where('id', $city_id)->first(['id', 'name', 'name_en', 'continents_id', 'area_id']);
            if (!$city) {
                throw new ApiException(__('res.city_not'));
            }
        }

        DB::beginTransaction();
        try {
            if ($city_id > 0) {
                Guide::query()->where('id', $user->guide_id)->update([
                    'city_id' => $city_id,
                    'continents_id' => $city->continents_id,
                    'area_id' => $city->area_id,
                    'city_name' => $city->name
                ]);
                User::query()->where('id', $user->id)->update([
                    'continents_id' => $city->continents_id,
                    'area_id' => $city->area_id,
                    'city_name' => $city->name
                ]);

                // 导游资料
                $identity_str = $user->identity_str;
                $user_number = $user->number;
                $city_name = $city->name_en;

                $guide_info = Guide::query()->where('id', $user->guide_id)->first(['id', 'name', 'name_en']);
                $guide_name = $guide_info->name_en ?: $guide_info->name;

                $nickname = "$guide_name($city_name)-$identity_str";

                // 更新腾讯云资料
                $account_body = [
                    'Identifier' => $user_number,
                    'Nick' => $nickname,
                ];
                $im_res = IM::im()->send('im_open_login_svc', 'account_import', $account_body);
                imApiLog('im_open_login_svc', 'account_import', $account_body, $im_res);
            } else {
                Guide::query()->where('id', $user->guide_id)->update([
                    'city_id' => 0,
                    'continents_id' => 0,
                    'area_id' => 0,
                    'recommend' => 0,
                    'home_recommend' => 0,
                    'city_name' => null
                ]);
                User::query()->where('id', $user->id)->update([
                    'continents_id' => 0,
                    'area_id' => 0,
                    'city_name' => null
                ]);
            }
            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 发布城市列表
     * @param int $limit
     * @return array
     * @throws ApiException
     */
    public function cityLists(int $limit)
    {
        $user = auth('api')->user();
        //        handleGuideVip($user);

        $user_id = $user->id;
        $guide_id = $user->guide_id;

        $where['user_id'] = $user_id;
        $where['guide_id'] = $guide_id;

        $res = City::with(['edit_data'])->where($where)->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'name', 'name_en', 'is_capital', 'first_picture', 'is_read', 'audit_status', 'audit_feedback', 'created_at'])->toArray();

        $data = $res['data'];
        foreach ($data as $k => $v) {
            // 存在待审核 审核失败的才同步状态
            if (!empty($v['edit_data']) && ($v['edit_data']['audit_status'] == 0 || $v['edit_data']['audit_status'] == 2)) {
                $data[$k]['audit_status'] = $v['edit_data']['audit_status'];
                $data[$k]['audit_feedback'] = $v['edit_data']['audit_feedback'];
            }
            unset($data[$k]['edit_data']);
        }

        return ['total' => $res['total'], 'data' => $data];
    }


    /**
     * 发布城市详情
     * @param int $city_id
     * @return array
     * @throws ApiException
     */
    public function cityInfo(int $city_id)
    {
        $user = auth('api')->user();

        $user_id = $user->id;
        $guide_id = $user->guide_id;

        $city = City::query()->where('guide_id', $guide_id)->where('id', $city_id)->first();
        if (!$city) {
            throw new ApiException(__('res.city_not'));
        }
        $city->pictures = json_decode($city['pictures'], true);

        handleIsRead($city); //导游城市

        unset($city->created_at, $city->updated_at, $city->recommend);
        $data = $city->toArray();
        $data['continents_name'] = SystemContinents::query()->where('id', $city->continents_id)->value('name');
        $data['area_name'] = SystemContinents::query()->where('id', $city->area_id)->value('name');
        if ($city->country_id > 0) {
            $country_name = SystemContinents::query()->where('id', $city->country_id)->value('name');
        } else {
            $country_name = '';
        }
        $data['country_name'] = $country_name;
        return $data;
    }


    /**
     * 修改发布城市
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function editCity(array $data)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $guide_id = $user->guide_id;

        $city = City::query()->where('guide_id', $guide_id)->where('id', $data['id'])->first();
        if (!$city) {
            throw new ApiException(__('res.city_not'));
        }

        if (City::query()->where('id', '<>', $data['id'])->where('name', $data['name'])->exists()) {
            throw new ApiException(__('res.city_name_unique'));
        }

        $old_data = [];
        $new_data = [];
        foreach ($data as $k => $v) {
            $value = $city->{$k};
            if ($k == 'pictures') {
                $value = json_decode($value, true);
            }
            $old_data[$k] = $value;
            $new_data[$k] = $v;
        }
        if (arrayEqual($old_data, $new_data)) {
            throw new ApiException(__('res.updated_no'));
        }

        try {
            if ($city->is_finish == 0 && $city->audit_status == 2) {
                $city->name = $data['name'];
                $city->name_en = $data['name_en'];
                $city->country_id = $data['country_id'];
                $city->continents_id = $data['continents_id'];
                $city->area_id = $data['area_id'];
                $city->longitude = $data['longitude'] ?? null;
                $city->latitude = $data['latitude'] ?? null;
                $city->is_capital = $data['is_capital'];
                $city->currency = $data['currency'];
                $city->language = $data['language'];
                $city->population = $data['population'];
                $city->race = $data['race'];
                $city->overview = $data['overview'];
                $city->history = $data['history'];
                $city->first_picture = $data['pictures'][0];
                $city->pictures = json_encode($data['pictures']);
                $city->audit_status = 0;
                $city->audit_feedback = null;
                $city->save();
            } else {
                $model = new CityEdit();
                $model->city_id = $city->id;
                $model->user_id = $city->user_id;
                $model->guide_id = $city->guide_id;
                $model->name = $data['name'];
                $model->name_en = $data['name_en'];
                $model->country_id = $data['country_id'];
                $model->continents_id = $data['continents_id'];
                $model->area_id = $data['area_id'];
                $model->longitude = $data['longitude'] ?? null;
                $model->latitude = $data['latitude'] ?? null;
                $model->is_capital = $data['is_capital'];
                $model->currency = $data['currency'];
                $model->language = $data['language'];
                $model->population = $data['population'];
                $model->race = $data['race'];
                $model->overview = $data['overview'];
                $model->history = $data['history'];
                $model->first_picture = $data['pictures'][0];
                $model->pictures = json_encode($data['pictures']);
                $model->save();
            }

            // 发送待审核邮件
            $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/city?status=1";
            Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核城市，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除城市
     * @param int $city_id
     * @return void
     * @throws ApiException
     */
    public function delCity(int $city_id)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $user_id = $user->id;
        $guide_id = $user->guide_id;

        $city = City::query()->where('guide_id', $guide_id)->where('id', $city_id)->first();
        if (!$city) {
            throw new ApiException(__('res.city_not'));
        }
        if ($city->audit_status == \App\Enums\City::AuditStatusPass) {
            throw new ApiException(__('res.del_city_error'));
        }
        $city->delete();
    }


    /**
     * 资讯列表
     * @param int $limit
     * @return array
     * @throws ApiException
     */
    public function informationList(int $limit)
    {
        $user = auth('api')->user();
        //        handleGuideVip($user);

        $user_id = $user->id;
        $guide_id = $user->guide_id;

        $where['user_id'] = $user_id;
        $where['guide_id'] = $guide_id;
        $res = Information::query()->where($where)->orderBy('id', 'desc')->paginate($limit, [
            'id',
            'title',
            'desc',
            'first_picture',
            'audit_status',
            'audit_feedback',
            'created_at'
        ])->toArray();
        return ['total' => $res['total'], 'data' => $res['data']];
    }


    /**
     * 获取城市发布内容
     * @param int $type_id
     * @param int $limit
     * @return array
     * @throws ApiException
     */
    public function cityContent(int $type_id, int $limit)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $user_id = $user->id;
        $guide_id = $user->guide_id;

        $field = self::FieldArr[$type_id];

        $where['type_id'] = $type_id;
        $where['user_id'] = $user_id;
        $where['publisher_id'] = $guide_id;
        $where['publisher_type'] = 'guide';

        $res = CityContent::with(['edit_data'])->where($where)->orderBy('id', 'desc')->paginate($limit, $field)->toArray();

        $data = $res['data'];
        foreach ($data as $k => $v) {
            // 存在待审核 审核失败的才同步状态
            if (!empty($v['edit_data']) && ($v['edit_data']['audit_status'] == 0 || $v['edit_data']['audit_status'] == 2)) {
                $data[$k]['audit_status'] = $v['edit_data']['audit_status'];
                $data[$k]['audit_feedback'] = $v['edit_data']['audit_feedback'];
            }
            unset($data[$k]['edit_data']);
        }

        return ['total' => $res['total'], 'data' => $data];
    }

    /**
     * 添加景点
     * @param array $data
     * @param int $type_id
     * @return void
     * @throws ApiException
     */
    public function cityContentAdd(array $data, int $type_id)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        // 导游不允许发布其他类型
        if (!in_array($type_id, [1, 5, 6, 7])) {
            throw new ApiException(__('res.type_id_error'));
        }

        $city = City::query()->where('id', $data['city_id'])->first(['continents_id', 'area_id']);
        if (!$city) {
            throw new ApiException(__('res.city_not'));
        }
        if (!CityTypeClass::query()->where('id', $data['type_class_id'])->where('type_id', $type_id)->exists()) {
            throw new ApiException(__('res.type_class_id_not'));
        }

        try {
            $model = new CityContent();
            $model->continents_id = $city->continents_id;
            $model->area_id = $city->area_id;
            $model->type_id = $type_id;
            $model->user_id = $user->id;
            $model->publisher_id = $user->guide_id;
            $model->publisher_type = 'guide';
            foreach ($data as $k => $v) {
                if ($k != 'pictures') {
                    $model->{$k} = $v;
                }
            }
            if (isset($data['pictures']) && is_array($data['pictures'])) {
                $model->first_picture = $data['pictures'][0];
                $model->pictures = json_encode($data['pictures']);
            }
            $model->save();

            // 发送待审核邮件
            $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/cityContent?status=1";
            Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核城市內容，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));

            Log::debug('Content-' . json_encode($model->toArray(), JSON_UNESCAPED_UNICODE));
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 获取内容详情
     * @param int $id
     * @param int $user_id
     * @param int $guide_id
     * @return CityContent
     * @throws ApiException
     */
    protected function getCityContentInfo(int $id, int $user_id, int $guide_id): CityContent
    {
        $model = CityContent::query()->where('id', $id)->where('publisher_type', 'guide')->first();
        if (!$model) {
            throw new ApiException(__('res.content_not'));
        }
        if ($model->publisher_id != $guide_id) {
            throw new ApiException(__('res.auth_error'));
        }
        return $model;
    }

    /**
     * 获取城市内容详情
     * @param int $id
     * @param int $type_id
     * @return array
     * @throws ApiException
     */
    public function cityContentInfo(int $id, int $type_id)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $data = $this->getCityContentInfo($id, $user->id, $user->guide_id);
        if ($data->type_id !== $type_id) {
            throw new ApiException(__('res.data_not'));
        }
        // 处理未读
        handleIsRead($data); // 导游发布

        $key_arr = self::KeyArr[$type_id];

        $res['id'] = $data->id;
        foreach ($key_arr as $key) {
            if ($key == 'pictures') {
                $res['pictures'] = json_decode($data['pictures'], true);
            } else {
                $res[$key] = $data->{$key};
            }
        }
        return $res;
    }


    /**
     * 修改城市内容
     * @param array $data
     * @param int $type_id
     * @throws ApiException
     */
    public function cityContentEdit(array $data, int $type_id)
    {
        if (!isset($data['id'])) {
            throw new ApiException(__('res.id_required'));
        }

        $user = auth('api')->user();
        handleGuideVip($user);

        if (!City::query()->where('id', $data['city_id'])->exists()) {
            throw new ApiException(__('res.city_not'));
        }
        if (!CityTypeClass::query()->where('id', $data['type_class_id'])->where('type_id', $type_id)->exists()) {
            throw new ApiException(__('res.type_id_not'));
        }

        // 首次创建
        $content = $this->getCityContentInfo($data['id'], $user->id, $user->guide_id);
        if ($content->audit_status == 0) {
            throw new ApiException(__('res.content_auditing'));
        }

        $key_arr = self::KeyArr[$type_id];

        $old_data = [];
        $new_data = [];
        foreach ($key_arr as $v) {
            if ($v == 'type_id' || $v == 'first_picture') {
                continue;
            }
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
                // 二次提交审核 增加修改记录
                $res = new CityContentEdit();
                $res->city_content_id = $content->id;
                $res->type_id = $content->type_id;
                foreach ($key_arr as $key) {
                    if (!in_array($key, ['pictures', 'type_id', 'first_picture'])) {
                        $res->{$key} = $data[$key];
                    }
                }
                if (isset($data['pictures']) && is_array($data['pictures'])) {
                    $res->first_picture = $data['pictures'][0];
                    $res->pictures = json_encode($data['pictures']);
                }
                $res->save();
            }

            //            $res->city_content_id = $content->id;
            //            $res->type_id = $content->type_id;
            //            foreach ($key_arr as $key) {
            //                if (!in_array($key, ['pictures', 'type_id', 'first_picture'])) {
            //                    $res->{$key} = $data[$key];
            //                }
            //            }
            //            if (isset($data['pictures']) && is_array($data['pictures'])) {
            //                $res->first_picture = $data['pictures'][0];
            //                $res->pictures = json_encode($data['pictures']);
            //            }
            //            $res->audit_status = 0;
            //            $res->audit_feedback = null;


            //            Log::debug('Content-' . json_encode($res->toArray(), JSON_UNESCAPED_UNICODE));
            // 发送待审核邮件
            $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/cityContent?status=1";
            Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核城市內容，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));
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
    public function cityContentDel(int $id)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $model = $this->getCityContentInfo($id, $user->id, $user->guide_id);
        try {
            $model->delete();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 添加资讯
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function informationAdd(array $data)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        if (!InformationClass::query()->where('id', $data['class_id'])->exists()) {
            throw new ApiException(__('res.information_class_not'));
        }

        // 导游身份
        $guide_type_id = Guide::query()->where('id', $user->guide_id)->value('identity_type');

        DB::beginTransaction();
        try {
            $model = new Information();
            $model->user_id = $user->id;
            $model->guide_id = $user->guide_id;
            $model->guide_type_id = $guide_type_id;
            $model->class_id = $data['class_id'];
            $model->title = $data['title'];
            $model->desc = mb_substr($data['content'], 0, 200, 'UTF-8');
            $model->content = $data['content'];
            if (is_array($data['pictures']) && !empty($data['pictures'])) {
                $model->first_picture = $data['pictures'][0];
                $model->pictures = json_encode($data['pictures']);
            }
            $model->look = $data['look'];
            if (env('APP_DEBUG')) {
                $model->is_finish = 1;
                $model->audit_status = 1;
            } else {
                // 发送待审核邮件
                $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/information";
                Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核資訊，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));
            }
            $model->save();

            SystemIntegralConfig::saveData($user->id, 'add_information');

            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 获取资讯
     * @param int $id
     * @param int $user_id
     * @param int $guide_id
     * @return Information
     * @throws ApiException
     */
    protected function getInformationInfo(int $id, int $user_id, int $guide_id): Information
    {
        $data = Information::query()->where('id', $id)->first();
        if (!$data) {
            throw new ApiException(__('res.information_not'));
        }

        if ($data->guide_id != $guide_id) {
            throw new ApiException(__('res.auth_error'));
        }
        return $data;
    }


    /**
     * 资讯详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function informationInfo(int $id)
    {
        $user = auth('api')->user();

        $data = $this->getInformationInfo($id, $user->id, $user->guide_id);
        return [
            'id' => $data->id,
            'class_id' => $data->class_id,
            'title' => $data->title,
            'content' => $data->content,
            'pictures' => json_decode($data->pictures, true) ?? [],
            'look' => $data->look,
            'audit_status' => $data->audit_status,
            'audit_feedback' => $data->audit_feedback,
        ];
    }


    /**
     * 资讯修改
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function informationEdit(array $data)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $res = $this->getInformationInfo($data['id'], $user->id, $user->guide_id);

        if (!InformationClass::query()->where('id', $data['class_id'])->exists()) {
            throw new ApiException(__('res.information_class_not'));
        }

        try {
            $res->class_id = $data['class_id'];
            $res->title = $data['title'];
            $res->desc = substr($data['content'], 0, 100);
            $res->content = $data['content'];
            $pictures = $data['pictures'] ?? [];
            if (is_array($pictures) && !empty($pictures)) {
                $res->first_picture = $pictures[0];
                $res->pictures = json_encode($pictures);
            }
            $res->look = $data['look'];
            $res->audit_status = 0;
            $res->audit_feedback = null;
            $res->save();

            // 发送待审核邮件
            $url = env('APP_URL') . '/' . env('ADMIN_ROUTE_PREFIX', 'admin') . "/information";
            Mail::to(env('AUDIT_EMAIL'))->queue((new AuditMail("有新的待審核資訊，請盡快處理,<br><a href='" . $url . "'>點擊查看</a>"))->onQueue('emails'));
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 删除资讯
     * @param int $id
     * @return void
     * @throws ApiException
     */
    public function informationDel(int $id)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $res = $this->getInformationInfo($id, $user->id, $user->guide_id);
        try {
            $res->delete();
        } catch (Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 预约我的
     * @param int $limit
     * @param string $start_time
     * @param string $end_time
     * @return array
     * @throws ApiException
     */
    public function reserve(int $limit, string $start_time, string $end_time)
    {
        $user = auth('api')->user();
        //        handleGuideVip($user);

        $guide_id = $user->guide_id;

        $query = ReserveGuide::with(['user', 'city'])->where('guide_id', $guide_id);
        if (!empty($start_time)) {
            $query->where('arrival_time', '>=', "$start_time 00:00:00");
            if (!empty($end_time)) {
                $query->where('arrival_time', '<', "$end_time 23:59:59");
            }
        }

        $res = $query->where('guide_del', 0)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'user_id', 'city_id', 'arrival_time', 'number', 'number', 'is_read', 'status', 'created_at'])->toArray();

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

            $v['city_name'] = $v['city']['name'];
            $data[] = [
                'id' => $v['id'],
                'arrival_time' => $v['arrival_time'],
                'number' => $v['number'],
                'is_read' => $v['is_read'],
                'status' => $status,
                'created_at' => $v['created_at'],
                'user' => $v['user'],
                'city_name' => $v['city_name'],
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
        $data = ReserveGuide::with(['user', 'city'])->find($id);
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
            'arrival_time' => $data['arrival_time'],
            'number' => $data['number'],
            'status' => $status,
            'created_at' => $data['created_at'],
            'user' => $data['user'],
            'city_name' => $data['city']['name'],
            'remark' => $data['remark'],
            'contact' => $data['contact'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'other' => $data['other'],
            'reason' => $data['reason'],
            'trip_id' => $data['trip_id'],
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
        $guide_id = $user->guide_id;

        $data = ReserveGuide::query()
            ->where('id', $id)
            ->where('guide_id', $guide_id)
            ->first();
        if (!$data) {
            throw new ApiException(__('res.data_not'));
        }

        DB::beginTransaction();
        try {
            // 预约导游状态
            $data->status = $status;


            // 导游确认预约
            if ($status == 2) {
                // 处理行程状态
                $startTime = Carbon::parse($data->arrival_time);
                $now = now();

                // 待出发
                $tripStatus = TripCode::StatusWait;
                if ($startTime->toDateString() == $now->toDateString()) {
                    // 开始日期 等于 当前日期 代表进行中
                    $tripStatus = TripCode::StatusNow;
                }
                if ($startTime->lt($now)) {
                    // 结束时间小于当前时间代表已结束
                    $tripStatus = TripCode::StatusClose;
                }

                // 增加行程
                $tripModel = new Trip();
                $tripModel->user_id = $user->id;
                $tripModel->guide_id = $guide_id;
                $tripModel->title = '预约行程';
                $tripModel->start_time = $data->arrival_time;
                $tripModel->end_time = $startTime->toDateString() . ' 23:59:59';
                $tripModel->member_count = $data->number;
                $tripModel->start_city_id = $data->city_id;
                $tripModel->end_city_id = $data->city_id;
                $tripModel->vehicle_remark = $data->remark;
                $tripModel->status = $tripStatus;
                $tripModel->reserve_guide_id = $id; // 预约导游ID
                $tripModel->save();
                $trip_id = $tripModel->id;

                // 处理添加时间
                $city = City::query()->where('id', $data->city_id)->first(['name', 'continents_id', 'area_id']);
                $date = $startTime->copy()->toDateString();

                $days[] = [
                    'trip_id' => $trip_id,
                    'user_id' => $user->id,
                    'guide_id' => $guide_id,
                    'day_index' => 1,
                    'date' => $date,
                    'city_id' => $data->city_id,
                    'city_name' => $city->name,
                    'continents_id' => $city->continents_id,
                    'area_id' => $city->area_id,
                    'items' => json_encode([]),
                    'activity' => json_encode([]),
                    'status' => $tripStatus,
                    'created_at' => now(),
                    'updated_at' => now()
                ];

                TripDay::query()->insert($days);

                // 预约导游表增加行程ID
                $data->trip_id = $trip_id;
            }

            $data->save();

            DB::commit();
        } catch (\Exception $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
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
        $guide_id = $user->guide_id;

        $reserve = ReserveGuide::query()
            ->where('id', $id)
            ->where('guide_id', $guide_id)
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
        $guide_id = $user->guide_id;

        $reserve = ReserveGuide::query()
            ->where('id', $id)
            ->where('guide_id', $guide_id)
            ->first();
        if (!$reserve) {
            throw new ApiException(__('res.data_not'));
        }
        try {
            $reserve->guide_del = 1;
            $reserve->save();
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }
}
