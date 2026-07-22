<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContent;
use App\Models\CityType;
use App\Models\SystemContinents;
use App\Models\Trip;
use App\Models\TripDay;
use App\Enums\City as CityCode;
use App\Enums\Trip as TripCode;
use App\Enums\System;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class TripService
{

    /**
     * 选项
     * @return array
     */
    public function options(int $status)
    {
        $user = auth('api')->user();

        $guide_id = $user->guide_id;
        $user_id = $user->id;
        $where['user_id'] = $user_id;
        $where['guide_id'] = $guide_id;
        if ($status >= 0) {
            $where['status'] = $status;
        }

        $continents_id = TripDay::query()->where($where)->groupBy('continents_id')->pluck('continents_id')->toArray();
        $continents = SystemContinents::query()->whereIn('id', $continents_id)->get(['id', 'name'])->toArray();

        $status = [];
        foreach (TripCode::Status as $k => $v) {
            $status[] = [
                'id' => $k,
                'name' => $v,
            ];
        }

        return [
            'continents' => $continents,
            'status' => $status,
            'transport_type' => json_decode(systemConfig('transport_type'), true)
        ];
    }


    /**
     * 日期数据
     * @param int $continents_id
     * @param int $status
     * @return array
     */
    public function dates(int $continents_id, int $status)
    {
        $user = auth('api')->user();

        $guide_id = $user->guide_id;
        $user_id = $user->id;
        $where['user_id'] = $user_id;
        $where['guide_id'] = $guide_id;
        if ($continents_id > 0) {
            $where['continents_id'] = $continents_id;
        }
        if ($status >= 0) {
            $where['status'] = $status;
        }

        $res = TripDay::query()->where($where)
            ->groupBy('date')
            ->pluck('date')
            ->toArray();
        $dates = [];
        foreach ($res as $key => $value) {
            $days = TripDay::query()->where($where)->where('date', $value)->get(['date', 'status'])->toArray();
            $dates[] = [
                'date' => $value,
                'days' => $days,
            ];
        }
        return $dates;
    }

    /**
     * 分页数据
     * @param int $limit
     * @param int $continents_id
     * @param int $status
     * @param string $date
     * @return array
     */
    public function pageLists(int $limit, int $continents_id, int $status, string $date)
    {
        $user = auth('api')->user();

        $guide_id = $user->guide_id;
        $user_id = $user->id;
        $where['user_id'] = $user_id;
        $where['guide_id'] = $guide_id;

        if ($continents_id > 0) {
            $where['continents_id'] = $continents_id;
        }
        if ($status >= 0) {
            $where['status'] = $status;
        }
        if ($date) {
            $where['date'] = $date;
        }

        $trip_id_arr = TripDay::query()
            ->where($where)
            ->groupBy('trip_id')
            ->pluck('trip_id')->toArray();

        $res = Trip::with(['city_name'])->whereIn('id', $trip_id_arr)
            ->paginate($limit, ['id', 'start_time', 'end_time', 'title', 'member_count', 'status'])
            ->toArray();

        $data = [];
        foreach ($res['data'] as $item) {
            $startTime = Carbon::parse($item['start_time'])->rawFormat('m/d');
            $endTime = Carbon::parse($item['end_time'])->rawFormat('m/d日');

            $city_name_arr = array_column($item['city_name'], 'city_name');

            $trip_day = TripDay::with(['continents'])
                ->where('user_id', $user_id)
                ->where('guide_id', $guide_id)
                ->where('day_index', 1)
                ->first(['id', 'continents_id'])
                ->toArray();

            $data[] = [
                'continents_name' => $trip_day['continents']['name'] ?? '',
                'trip_id' => $item['id'],
                'trip_title' => $item['title'],
                'trip_member_count' => $item['member_count'],
                'trip_date' => "$startTime - {$endTime}",
                'city_name' => implode('.', $city_name_arr),
                'status' => $item['status']
            ];
        }
        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 获取城市下选项
     * @param int $city_id
     * @param string $date
     * @return array
     */
    public function cityItems(int $city_id, string $date)
    {
        City::query()->where('id', $city_id)->firstOrFail();

        $data = [];
        $type = CityType::query()->pluck('key', 'id')->toArray();
        foreach ($type as $k => $v) {
            if ($k == 'activity') {
                $activity = [];
                if ($date) {
                    $activity = CityContent::query()
                        ->where(function ($query) use ($date) {
                            $query->where('start_time', '<', $date)->where('end_time', '>', $date);
                        })
                        ->where('city_id', $city_id)
                        ->where('type_id', $k)
                        ->where('audit_status', CityCode::AuditStatusPass)
                        //                        ->where('recommend', 1)
                        ->get(['id', 'name'])->toArray();
                }

                $data[$k] = $activity;
            } else {
                $data[$k] = CityContent::query()
                    ->where('city_id', $city_id)
                    ->where('type_id', $k)
                    ->where('audit_status', CityCode::AuditStatusPass)
                    //                    ->where('recommend', 1)
                    ->get(['id', 'name'])->toArray();
            }
        }
        return $data;
    }


    /**
     * 添加行程
     * @param array $post
     * @return void
     * @throws ApiException
     * @throws \Throwable
     */
    public function add(array $post)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $guide_id = $user->guide_id;
        $user_id = $user->id;

        $this->validateTripData($post);

        $startTime = Carbon::parse($post['start_time']);
        $endTime = Carbon::parse($post['end_time']);
        $now = now();

        // 待出发
        $status = TripCode::StatusWait;
        if ($startTime->toDateString() == $now->toDateString()) {
            // 开始日期 等于 当前日期 代表进行中
            $status = TripCode::StatusNow;
        }
        if ($endTime->lt($now)) {
            // 结束时间小于当前时间代表已结束
            $status = TripCode::StatusClose;
        }

        // 判断日期是否重复
        //        $is_trip = TripDay::query()
        //            ->where('date', $startTime->toDateString())
        //            ->whereIn('status', [TripCode::StatusWait, TripCode::StatusNow])
        //            ->exists();
        //        if ($is_trip) {
        //            throw new ApiException(__('res.trip_days_repeat'));
        //        }

        DB::beginTransaction();
        try {
            $tripModel = new Trip();
            $tripModel->user_id = $user_id;
            $tripModel->guide_id = $guide_id;
            $tripModel->title = $post['title'];
            $tripModel->start_time = $post['start_time'];
            $tripModel->end_time = $post['end_time'];
            $tripModel->member_count = $post['member_count'];
            $tripModel->start_city_id = $post['start_city_id'];
            $tripModel->arrival_transport_type = $post['arrival_transport_type'] ?? '';
            $tripModel->arrival_time = $post['arrival_time'] ?? '';
            $tripModel->arrival_place = $post['arrival_place'] ?? '';
            $tripModel->start_desc = $post['start_desc'] ?? '';
            $tripModel->end_city_id = $post['end_city_id'];
            $tripModel->leave_transport_type = $post['leave_transport_type'] ?? '';
            $tripModel->leave_time = $post['leave_time'] ?? '';
            $tripModel->leave_place = $post['leave_place'] ?? '';
            $tripModel->end_desc = $post['end_desc'] ?? '';
            $tripModel->vehicle_option = $post['vehicle_option'];
            $tripModel->vehicle_remark = $post['vehicle_remark'];
            $tripModel->status = $status;
            $tripModel->save();
            $trip_id = $tripModel->id;

            $startTime = Carbon::parse($post['start_time']);

            // 处理添加时间
            $days = [];
            foreach ($post['days'] as $k => $value) {
                $index = $k + 1;
                foreach ($value['items'] as $key => $day) {
                    $city = City::query()->where('id', $day['city_id'])->first(['name', 'continents_id', 'area_id']);
                    $date = $startTime->copy()->addDays($k)->toDateString();

                    $items = $day['items'] ?? [];
                    $activity = $day['activity'] ?? [];

                    $days[] = [
                        'trip_id' => $trip_id,
                        'user_id' => $user_id,
                        'guide_id' => $guide_id,
                        'day_index' => $index,
                        'date' => $date,
                        'city_id' => $day['city_id'],
                        'city_name' => $city->name,
                        'continents_id' => $city->continents_id,
                        'area_id' => $city->area_id,
                        'items' => json_encode($items),
                        'activity' => json_encode($activity),
                        'status' => $status,
                        'created_at' => now(),
                        'updated_at' => now()
                    ];
                }
            }
            TripDay::query()->insert($days);

            DB::commit();
        } catch (\Exception $exception) {
            DB::rollBack();
            throw new ApiException($exception->getMessage(), System::SYSTEM_ERROR);
        }
    }


    /**
     * 验证规则
     * @param array $data
     * @return true
     * @throws ApiException
     */
    public function validateTripData(array $data)
    {
        $startTime = Carbon::parse($data['start_time'])->startOfDay();
        $endTime = Carbon::parse($data['end_time'])->startOfDay();

        if ($startTime->gt($endTime)) {
            throw new ApiException('开始时间不能大于结束时间');
        }

        // 2. 计算总天数 (例如: 15号到16号，算2天)
        $diffInDays = $startTime->diffInDays($endTime) + 1;
        $daysData = $data['days'] ?? [];

        // 3. 验证 Days 数组长度是否与时间跨度匹配
        if (count($daysData) !== $diffInDays) {
            throw new ApiException("行程天数不匹配：根据起止时间一共是 {$diffInDays} 天，但传入了 " . count($daysData) . " 天的数据");
        }

        //        $types = CityType::query()->pluck('name', 'id')->toArray();

        // 4. 遍历每天的数据进行深度验证
        foreach ($daysData as $dayIndex => $dayValue) {
            $currentDay = $dayIndex + 1; // 给人看的第几天

            if (empty($dayValue) || !is_array($dayValue)) {
                // 如果允许某一天没有任何行程，可以注释掉下面这行
                throw new ApiException("第 {$currentDay} 天缺少行程数据");
            }

            foreach ($dayValue['items'] as $cityIndex => $city) {
                $currentNode = $cityIndex + 1;
                $errorPrefix = "第{$currentDay}天的第{$currentNode}个行程节点";

                // 必填字段检查
                $requiredFields = [
                    'city_id' => '城市ID',
                    'items' => '日程',
                    'activity' => '活动提醒',
                ];

                foreach ($requiredFields as $field => $fieldName) {
                    if (!array_key_exists($field, $city) || $city[$field] === '' || $city[$field] === null) {
                        throw new ApiException("{$errorPrefix} 请填写：{$fieldName}");
                    }
                }

                foreach ($city['items'] as $item) {
                    if ($item['type'] == 1) {
                    }
                    if ($item['type'] == 2) {
                    }
                    if ($item['type'] == 3) {
                    }
                    if ($item['type'] == 4) {
                    }
                }
            }
        }
        return true;
    }


    /**
     * 详情接口
     * @param int $id
     * @return array
     */
    public function info(int $id)
    {
        $trip = Trip::with(['days'])->where('id', $id)->firstOrFail()->toArray();
        $trip_days = $trip['days'];

        $startTime = Carbon::parse($trip['start_time'])->startOfDay();
        $endTime = Carbon::parse($trip['end_time'])->startOfDay();

        $diffInDays = $startTime->diffInDays($endTime) + 1;

        //        $types = CityType::query()->pluck('name', 'id')->toArray();

        $days = [];
        for ($i = 0; $i < $diffInDays; $i++) {
            $date = $startTime->copy()->addDays($i)->toDateString();

            $day = [];
            foreach ($trip_days as $key => $value) {
                if ($value['date'] === $date) {
                    $day[] = [
                        'city_id' => $value['city_id'],
                        'city_name' => $value['city_name'],
                        'items' => json_decode($value['items'], true),
                        'activity' => json_decode($value['activity'], true)
                    ];
                }
            }

            $days[] = [
                'day' => $date,
                'items' => $day
            ];
        }

        return [
            'id' => $trip['id'],
            'title' => $trip['title'],
            'start_time' => $trip['start_time'],
            'end_time' => $trip['end_time'],
            'member_count' => $trip['member_count'],
            'start_city_id' => $trip['start_city_id'],
            'arrival_transport_type' => $trip['arrival_transport_type'],
            'arrival_time' => $trip['arrival_time'],
            'arrival_place' => $trip['arrival_place'],
            'start_desc' => $trip['start_desc'],
            'end_city_id' => $trip['end_city_id'],
            'leave_transport_type' => $trip['leave_transport_type'],
            'leave_time' => $trip['leave_time'],
            'leave_place' => $trip['leave_place'],
            'end_desc' => $trip['end_desc'],
            'vehicle_option' => $trip['vehicle_option'],
            'vehicle_remark' => $trip['vehicle_remark'],
            'days' => $days,
            'reserve_id' => $trip['reserve_guide_id'], // 预约导游ID
        ];
    }


    /**
     * 编辑行程
     * @param array $post
     * @return void
     * @throws ApiException
     * @throws \Throwable
     */
    public function edit(array $post)
    {
        if (!array_key_exists('id', $post)) {
            throw new ApiException(__('res.id_required'));
        }

        $user = auth('api')->user();
        handleGuideVip($user);

        $guide_id = $user->guide_id;
        $user_id = $user->id;

        $trip = Trip::query()->findOrFail($post['id']);

        $this->validateTripData($post);
        $startTime = Carbon::parse($post['start_time']);
        $endTime = Carbon::parse($post['end_time']);
        $now = now();

        // 待出发
        $status = TripCode::StatusWait;
        if ($startTime->toDateString() == $now->toDateString()) {
            // 开始日期 等于 当前日期 代表进行中
            $status = TripCode::StatusNow;
        }
        if ($endTime->lt($now)) {
            // 结束时间小于当前时间代表已结束
            $status = TripCode::StatusClose;
        }

        // 判断日期是否重复 去除本身
        //        $is_trip = TripDay::query()
        //            ->where('trip_id', '<>', $trip->id)
        //            ->where('date', $startTime->toDateString())
        //            ->whereIn('status', [TripCode::StatusWait, TripCode::StatusNow])
        //            ->exists();
        //        if ($is_trip) {
        //            throw new ApiException(__('res.trip_days_repeat'));
        //        }

        DB::beginTransaction();
        try {
            $trip->title = $post['title'];
            $trip->start_time = $post['start_time'];
            $trip->end_time = $post['end_time'];
            $trip->member_count = $post['member_count'];
            $trip->start_city_id = $post['start_city_id'];
            $trip->arrival_transport_type = $post['arrival_transport_type'] ?? '';
            $trip->arrival_time = $post['arrival_time'] ?? '';
            $trip->arrival_place = $post['arrival_place'] ?? '';
            $trip->start_desc = $post['start_desc'] ?? '';
            $trip->end_city_id = $post['end_city_id'];
            $trip->leave_transport_type = $post['leave_transport_type'] ?? '';
            $trip->leave_time = $post['leave_time'] ?? '';
            $trip->leave_place = $post['leave_place'] ?? '';
            $trip->end_desc = $post['end_desc'] ?? '';
            $trip->vehicle_option = $post['vehicle_option'];
            $trip->vehicle_remark = $post['vehicle_remark'];
            $trip->status = $status;
            $trip->save();

            $startTime = Carbon::parse($post['start_time']);

            // 处理添加时间
            $days = [];

            foreach ($post['days'] as $k => $value) {
                $index = $k + 1;
                foreach ($value['items'] as $key => $day) {
                    $city = City::query()->where('id', $day['city_id'])->first(['name', 'continents_id', 'area_id']);
                    $date = $startTime->copy()->addDays($k)->toDateString();

                    $items = $day['items'] ?? [];
                    $activity = $day['activity'] ?? [];

                    $days[] = [
                        'user_id' => $user_id,
                        'guide_id' => $guide_id,
                        'trip_id' => $trip->id,
                        'day_index' => $index,
                        'date' => $date,
                        'city_id' => $day['city_id'],
                        'city_name' => $city->name,
                        'continents_id' => $city->continents_id,
                        'area_id' => $city->area_id,
                        'items' => json_encode($items),
                        'activity' => json_encode($activity),
                        'status' => $status,
                        'created_at' => now(),
                        'updated_at' => now()
                    ];
                }
            }

            // 清空插入
            TripDay::query()->where('trip_id', $trip->id)->delete();
            TripDay::query()->insert($days);

            DB::commit();
        } catch (\Exception $exception) {
            DB::rollBack();
            throw new ApiException($exception->getMessage(), System::SYSTEM_ERROR);
        }
    }


    /**
     * @param int $id
     * @return void
     * @throws ApiException
     * @throws \Throwable
     */
    public function delete(int $id)
    {
        $trip = Trip::query()->where('id', $id)->firstOrFail();

        DB::beginTransaction();
        try {
            $trip->delete();
            TripDay::query()->where('trip_id', $id)->delete();
            DB::commit();
        } catch (\Throwable $exception) {
            DB::rollBack();
            throw new ApiException($exception->getMessage(), System::SYSTEM_ERROR);
        }
    }
}
