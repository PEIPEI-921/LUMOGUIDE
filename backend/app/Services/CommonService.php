<?php

namespace App\Services;

use App\Enums\System;
use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContent;
use App\Models\CityType;
use App\Models\CityTypeClass;
use App\Models\ContentEvaluate;
use App\Models\Guide;
use App\Models\GuideType;
use App\Models\Information;
use App\Models\InformationClass;
use App\Models\SystemContinents;
use App\Models\SystemArea;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Str;

class CommonService
{

    /**
     * 系统配置
     * @return array
     */
    public function config(): array
    {
        return [
            'system_logo' => systemConfig('system_logo'),
            'system_welcome_zh' => systemConfig('system_welcome_zh'),
            'system_welcome_en' => systemConfig('system_welcome_en'),
            'user_protocol' => env('APP_URL') . '/protocol/user_protocol',
            'privacy_protocol' => env('APP_URL') . '/protocol/privacy_protocol',
            'vip_user_protocol' => env('APP_URL') . '/protocol/vip_user_protocol',
            'vip_user_subscribe' => env('APP_URL') . '/protocol/vip_user_subscribe',
            'contact_us' => systemConfig('contact_us'),
            'integral_rule' => systemConfig('integral_rule'),
            'business_type' => json_decode(systemConfig('business_type'), true),
            'languages' => json_decode(systemConfig('languages'), true),
            'invite_rule' => systemConfig('invite_rule'),
            'stripe_key' => env('STRIPE_KEY'),
            'transport_type' => json_decode(systemConfig('transport_type'), true),
        ];
    }

    /**
     * 文件上传
     * @param Request $request
     * @return string[]
     * @throws ApiException
     */
    public function upload(Request $request)
    {
        Log::debug('Files-' . $request->file('file'));
        // 保存上传文件
        try {
            $randomName = Str::random(20);
            $extension = strtolower($request->file('file')->getClientOriginalExtension());

            // Whitelist allowed extensions (defense-in-depth)
            $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
            if (!in_array($extension, $allowed)) {
                throw new ApiException(__('res.file_mimes'));
            }

            // 拼接随机文件名和扩展名
            $fileName = $randomName . '.' . $extension;
            $request->file('file')->storeAs('public/uploads/' . date('Ymd') . '/', $fileName);

            $filePath = '/storage/uploads/' . date('Ymd') . '/' . $fileName;

            // 压缩图片
            $savePath = public_path($filePath);
            compressImage($savePath, $savePath, 78);

            return [
                'url' => env('APP_URL') . $filePath,
            ];
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 获取地区
     * @param int $parent_id
     * @return array
     */
    public function getArea(int $parent_id = 0): array
    {
        $areas = Cache::remember('areas_' . $parent_id, 60, function () use ($parent_id) {
            return SystemArea::query()->where('parent_id', $parent_id)->orderBy('order', 'asc')->get(['id', 'name']);
        });
        return $areas->toArray();
    }


    /**
     * 获取大洲
     * @param int $parent_id
     * @param int $type (1带推荐/2不带推荐)
     * @return array
     */
    public function getContinents(int $parent_id = 0, int $type = 1): array
    {
        $model = SystemContinents::query()->where('parent_id', $parent_id);

        $is_recommend = true;
        if ($parent_id == 0) {
            $continents_id = City::query()->where('audit_status', 1)->groupBy('continents_id')->pluck('continents_id')->toArray();
            $model = $model->whereIn('id', $continents_id);
        } else {
            if ($parent_id < 10000) {
                $area_id = City::query()->where('continents_id', $parent_id)->where('audit_status', 1)->groupBy('area_id')->pluck('area_id')->toArray();
                $model = $model->whereIn('id', $area_id);

                $is_recommend = City::query()->where('continents_id', $parent_id)->where('audit_status', 1)->where('recommend', 1)->exists();
            }
        }

        $data = $model->orderBy('order', 'asc')->get(['id', 'name'])->toArray();

        if ($type == 1 && !empty($data)) {
            array_unshift($data, ['id' => 10001, 'name' => '全部']);
            if ($is_recommend) {
                array_unshift($data, ['id' => 10000, 'name' => '推薦']);
            }
        }
        return $data;
    }


    /**
     * 大洲地区
     * @param int $parent_id
     * @return array
     */
    public function getContinentsList(int $parent_id = 0)
    {
        return SystemContinents::query()->where('parent_id', $parent_id)->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
    }


    /**
     * 获取类型
     * @return array
     */
    public function getType()
    {
        return Cache::remember("city_type_arr", 86400, function () {
            return CityType::query()->get(['id', 'icon', 'name'])->toArray();
        });
    }

    /**
     * 类型分类
     * @param int $type_id
     * @return array
     */
    public function getTypeClass(int $type_id)
    {
        return Cache::remember("city_type_class_$type_id", 3600, function () use ($type_id) {
            return CityTypeClass::query()->where('type_id', $type_id)->get(['id', 'name'])->toArray();
        });
    }


    /**
     * 资讯分类
     * @return array
     */
    public function getInformationClass()
    {
        $user = auth('api')->user();
        $guide_id = $user ? $user->guide_id : 0;

        // 非导游只能查看全部
        $type_class_id = [];
        if ($guide_id == 0) {
            $type_class_id = Information::query()->where('audit_status', 1)->where('look', 2)->groupBy('class_id')->pluck('class_id')->toArray();
        }

        $data = InformationClass::query()->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
        foreach ($data as &$item) {
            $count = 0;
            // 导游
            if ($guide_id > 0) {
                $count = Information::query()->where('class_id', $item['id'])->where('audit_status', 1)->count();
            }
            // 非导游
            if (!empty($type_class_id) && in_array($item['id'], $type_class_id)) {
                $count = Information::query()->where('class_id', $item['id'])->where('audit_status', 1)->count();
            }
            $item['count'] = $count;
            unset($item);
        }
        return $data;
    }

    /**
     * 导游分类
     * @return array
     */
    public function getGuideType()
    {
        return GuideType::query()->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
    }


    /**
     * 获取推荐城市
     * @param string $longitude
     * @param string $latitude
     * @return array
     */
    public function location(string $longitude, string $latitude)
    {
        $city = DB::selectOne(
            "
    SELECT id,name,latitude,longitude,
    (
      6371 * ACOS(
        LEAST(
          1,
          GREATEST(
            -1,
            COS(RADIANS(?)) *
            COS(RADIANS(latitude)) *
            COS(RADIANS(longitude) - RADIANS(?)) +
            SIN(RADIANS(?)) *
            SIN(RADIANS(latitude))
          )
        )
      )
    ) AS distance
    FROM city
    WHERE latitude IS NOT NULL
      AND longitude IS NOT NULL
    ORDER BY distance ASC
    LIMIT 1
    ",
            [$latitude, $longitude, $latitude]
        );

        if ($city) {
            $data = collect($city)->toArray();
        } else {
            $data = City::query()->where('default_recommend', 1)->first(['id', 'name', 'name_en'])->toArray();
        }
        if ($data) {
            $data['city_id'] = $data['id'];
            return $data;
        } else {
            return [];
        }
    }


    /**
     * 首页接口
     * @return array
     */
    public function homeData()
    {
        $user = auth('api')->user();
        $guide_id = $user ? $user->guide_id : 0;

        $city = City::query()->where('home_recommend', 1)
            ->where('audit_status', 1)
            ->orderBy('order', 'desc')
            ->get(['id', 'name', 'name_en', 'first_picture'])
            ->toArray();

        $guideType = $this->getGuideType();
        $guide = [];
        foreach ($guideType as $value) {
            $data = Guide::query()->where('identity_type', $value['id'])
                ->where('home_recommend', 1)
                ->where('audit_status', 1)
                ->orderBy('order', 'asc')
                ->get(['id', 'name', 'city_name', 'photo', 'language'])
                ->toArray();
            if (!empty($data)) {
                foreach ($data as &$v) {
                    $v['language'] = json_decode($v['language'], true);
                    unset($v);
                }
                $value['list'] = $data;
                $guide[] = $value;
            }
        }

        // 处理首页推荐
        $home_recommend = Redis::hGetAll('home_recommend');

        $type_class_id = CityContent::query()->where('audit_status', 1)
            ->where(function ($query) {
                $query->where('home_recommend', 1)->orWhere('banner_recommend', 1);
            })->groupBy('type_class_id')->pluck('type_class_id')->toArray();

        $city_type_class = CityTypeClass::query()->whereIn('id', $type_class_id)->select(['id', 'type_id', 'name'])->get()->toArray();
        $shop = [];
        foreach ($city_type_class as $key => $value) {
            $banner = CityContent::with(['city'])
                ->where('audit_status', 1)
                ->where('type_class_id', $value['id'])
                ->where('banner_recommend', 1)
                ->where(function ($query) {
                    $query->where('banner_recommend_time', '=', 999999999)->orWhere('banner_recommend_time', '>', time());
                })
                ->orderBy('order', 'desc')
                ->get(['id', 'city_id', 'type_id', 'name', 'first_picture', 'phone'])->toArray();

            $data = CityContent::with(['city'])
                ->where('audit_status', 1)
                ->where('type_class_id', $value['id'])
                ->where('home_recommend', 1)
                ->where(function ($query) {
                    $query->where('home_recommend_time', '=', 999999999)->orWhere('home_recommend_time', '>', time());
                })
                ->orderBy('order', 'desc')
                ->get(['id', 'city_id', 'type_id', 'name', 'first_picture', 'phone'])->toArray();

            if (empty($banner) && empty($data)) {
                continue;
            }
            foreach ($banner as &$v) {
                if (isset($v['city'])) {
                    $v['city_name'] = $v['city']['name'] ?? '';
                    unset($v['city']);
                }
                unset($v);
            }
            foreach ($data as &$v) {
                if (isset($v['city'])) {
                    $v['city_name'] = $v['city']['name'] ?? '';
                    unset($v['city']);
                }
                unset($v);
            }
            $value['banner'] = $banner;
            $value['list'] = $data;
            if (array_key_exists($value['id'], $home_recommend)) {
                $order = $home_recommend[$value['id']];
            } else {
                $order = 0;
            }
            $value['order'] = $order;
            $shop[] = $value;
        }
        $shop = collect($shop)->sortByDesc('order')->values()->all();

        // 首页资讯
        $information_id = Information::query()->where('audit_status', 1)
            ->where('home_recommend', 1)
            ->where(function ($query) use ($guide_id) {
                if ($guide_id == 0) {
                    $query->where('look', 2);
                }
            })
            ->groupBy('class_id')
            ->pluck('class_id')->toArray();

        $information = InformationClass::query()->whereIn('id', $information_id)->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
        $information_list = [];
        foreach ($information as $key => $value) {
            $query = Information::with(['user', 'guide'])
                ->where('class_id', $value['id'])
                ->where('audit_status', 1)
                ->where('home_recommend', 1)
                ->where(function ($query) use ($guide_id) {
                    if ($guide_id == 0) {
                        $query->where('look', 2);
                    }
                })
                ->select(['id', 'user_id', 'guide_id', 'title', 'desc', 'first_picture', 'pictures', 'created_at']);

            $data = $query->orderBy('id', 'desc')->get()->toArray();

            if (!empty($data)) {
                foreach ($data as &$v) {
                    $v['pictures'] = json_decode($v['pictures'], true) ?? [];
                    $v['guide_type'] = $v['user']['identity_str'] ?? '';
                    $v['user_nickname'] = $v['guide']['name'] ?? '';
                    $v['user_avatar'] = $v['guide']['photo'] ?? '';
                    $v['evaluate_count'] = ContentEvaluate::query()->where('content_type', \App\Enums\City::ContentTypeInformation)->where('content_id', $v['id'])->count();
                    unset($v['user'], $v['guide'], $v['user_id'], $v);
                }
                $value['list'] = $data;
                $information_list[] = $value;
            }
        }

        return [
            'city' => $city,
            'guide' => $guide,
            'shop' => $shop,
            'information' => $information_list,
        ];
    }


    /**
     * 首页搜索
     * @param string $name
     * @return array
     */
    public function homeSearch(string $name)
    {
        $city = City::query()->where('audit_status', 1)->where(function ($query) use ($name) {
            $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
        })->orderBy('order', 'desc')->take(2)->get(['id', 'name', 'name_en', 'first_picture'])->toArray();

        $guide = Guide::query()->where('audit_status', 1)
            ->where('city_id', '>', 0)
            ->where('name', 'like', '%' . escapeLike($name) . '%')
            ->orderBy('order', 'desc')->take(2)->get(['id', 'photo as first_picture', 'city_name', 'identity_type', 'name', 'language'])->toArray();

        $city_content = CityContent::with(['city'])
            ->where('audit_status', 1)
            ->where('name', 'like', '%' . escapeLike($name) . '%')
            ->orderBy('order', 'desc')
            ->take(2)
            ->get(['id', 'city_id', 'type_id', 'type_class_id', 'name', 'first_picture'])->toArray();

        $guide_type = GuideType::query()->pluck('name', 'id')->toArray();

        $city_type = CityType::options();

        $data = [];
        foreach ($city as $key => $value) {
            $data[] = [
                'data_type' => 1,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => $value['name_en'],
                'first_picture' => $value['first_picture'],
                'tag' => '城市'
            ];
        }
        foreach ($guide as $key => $value) {
            $type_name = $guide_type[$value['identity_type']] ?? '';
            $data[] = [
                'data_type' => 2,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => '',
                'first_picture' => $value['first_picture'],
                'city_name' => $value['city_name'],
                'type_name' => $type_name,
                'language' => json_decode($value['language'], true) ?? [],
                'tag' => '導遊'
            ];
        }
        foreach ($city_content as $key => $value) {
            $data[] = [
                'data_type' => 3,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => '',
                'city_id' => $value['city_id'],
                'city_name' => $value['city']['name'],
                'type_id' => $value['type_id'],
                'type_class_id' => $value['type_class_id'],
                'first_picture' => $value['first_picture'],
                'tag' => $city_type[$value['type_id']]
            ];
        }

        return $data;
    }


    /**
     * 搜索页
     * @param string $name
     * @param string $type
     * @param int $type_id
     * @return array
     */
    public function searchData(string $name, string $type, int $type_id)
    {
        $data = [];
        switch ($type) {
            case 'all':
                $continents_id = Cache::remember("continents_search_{$name}", 60, function () use ($name) {
                    $city_continents_id = City::query()->where('audit_status', 1)->where(function ($query) use ($name) {
                        $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
                    })->groupBy('continents_id')->pluck('continents_id')->toArray();

                    $guide_continents_id = Guide::query()->where('audit_status', 1)->where('city_id', '>', 0)
                        ->where('name', 'like', '%' . escapeLike($name) . '%')
                        ->groupBy('continents_id')->pluck('continents_id')->toArray();

                    $city_content_continents_id = CityContent::query()->where('audit_status', 1)->where('name', 'like', '%' . escapeLike($name) . '%')
                        ->groupBy('continents_id')->pluck('continents_id')->toArray();

                    return array_unique(array_merge($city_continents_id, $guide_continents_id, $city_content_continents_id));
                });
                $continents = SystemContinents::query()->whereIn('id', $continents_id)->get(['id', 'name'])->toArray();

                foreach ($continents as $key => $value) {
                    $data = handleSearchData(['continents_id' => $value['id']], $name, 'all');
                    $continents[$key]['data'] = $data;
                }
                $data = $continents;
                break;
            case 'city':
                $city_continents_id = City::query()->where('audit_status', 1)->where(function ($query) use ($name) {
                    $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
                })->groupBy('continents_id')->pluck('continents_id')->toArray();
                $continents = SystemContinents::query()->whereIn('id', $city_continents_id)->get(['id', 'name'])->toArray();
                foreach ($continents as $key => $value) {
                    $city = City::query()->where('continents_id', $value['id'])->where(function ($query) use ($name) {
                        $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
                    })->orderBy('order', 'desc')->get(['id', 'name', 'name_en', 'is_capital', 'first_picture'])->toArray();

                    $continents[$key]['data'] = $city;
                }
                $data = $continents;
                break;
            case 'guide':
                $guide_continents_id_query = Guide::query()->where('audit_status', 1)->where('city_id', '>', 0);
                if ($name) {
                    $guide_continents_id_query->where('name', 'like', '%' . escapeLike($name) . '%');
                }
                $guide_continents_id = $guide_continents_id_query->groupBy('continents_id')->pluck('continents_id')->toArray();

                $continents = SystemContinents::query()->whereIn('id', $guide_continents_id)->get(['id', 'name'])->toArray();

                $guide_type = GuideType::query()->pluck('name', 'id')->toArray();

                foreach ($continents as $key => $value) {
                    $guide = Guide::query()->where('continents_id', $value['id'])
                        ->where('name', 'like', '%' . escapeLike($name) . '%')
                        ->orderBy('order', 'desc')
                        ->get(['id', 'photo as first_picture', 'city_name', 'identity_type', 'name', 'language'])
                        ->toArray();

                    foreach ($guide as &$item) {
                        $item['language'] = json_decode($item['language'], true) ?? [];
                        $item['type_name'] = $guide_type[$item['identity_type']] ?? '';
                        unset($item['identity_type'], $item);
                    }
                    $continents[$key]['data'] = $guide;
                }
                $data = $continents;
                break;
            case 'city_content':
                $city_content_continents_id = CityContent::query()
                    ->where('audit_status', 1)
                    ->where('type_id', $type_id)
                    ->where(function ($query) use ($name) {
                        if ($name) {
                            $query->where('name', 'like', '%' . escapeLike($name) . '%');
                        }
                    })
                    ->groupBy('continents_id')
                    ->pluck('continents_id')
                    ->toArray();

                $continents = SystemContinents::query()->whereIn('id', $city_content_continents_id)->get(['id', 'name'])->toArray();
                foreach ($continents as $key => $value) {
                    $city_content = CityContent::query()->where('continents_id', $value['id'])
                        ->where(function ($query) use ($name) {
                            if ($name) {
                                $query->where('name', 'like', '%' . escapeLike($name) . '%');
                            }
                        })
                        ->where('type_id', $type_id)
                        ->orderBy('order', 'desc')
                        ->get(['id', 'city_id', 'type_id', 'type_class_id', 'name', 'first_picture', 'start_time', 'end_time', 'tickets_free', 'phone', 'address'])
                        ->toArray();

                    foreach ($city_content as &$item) {
                        $item['evaluate_count'] = ContentEvaluate::query()
                            ->where('content_type', \App\Enums\City::ContentTypeCity)
                            ->where('content_id', $item['id'])->count();

                        if (isset($item['tickets_free'])) {
                            $item['tickets_free'] = \App\Enums\City::TicketsFree[$item['tickets_free']];
                        }
                        unset($item);
                    }
                    $continents[$key]['data'] = $city_content;
                }
                $data = $continents;
                break;
        }

        return $data;
    }
}
