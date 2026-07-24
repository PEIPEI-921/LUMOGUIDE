<?php

namespace App\Services;

use App\Enums\City;
use App\Enums\System;
use App\Exceptions\ApiException;
use App\Models\CityType;
use App\Models\Company;
use App\Models\ContentEvaluate;
use App\Models\Guide;
use App\Models\Reserve;
use App\Models\ReserveGuide;
use App\Models\SystemContinents;
use App\Models\SystemMessage;
use App\Models\User;
use App\Models\UserFollow;
use App\Models\UserFollowShop;
use Carbon\Carbon;
use Illuminate\Support\Facades\Redis;
use Throwable;

class MessageService
{

    /**
     * 消息列表
     * @return array
     */
    public function lists()
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        $list_data = Redis::hGetAll("message_list:$user_id") ?? [];

        // 关注信息
        $last_follow = UserFollow::with(['user'])->where('followed_id', $user_id)->orderBy('id', 'desc')->first(['user_id', 'created_at']);
        $follow_message = (object)[];
        if ($last_follow) {
            $follow_message = [
                'text' => "[{$last_follow->user->nickname}] 关注了你",
                'time' => $last_follow->created_at->toDateTimeString(),
            ];
        }

        // 评价消息
        $last_evaluate = ContentEvaluate::with(['user'])->where('content_user_id', $user_id)->orderBy('id', 'desc')->first(['user_id', 'created_at', 'content']);
        $evaluate_message = (object)[];
        if ($last_evaluate) {
            $evaluate_message = [
                'text' => "[{$last_evaluate->user->nickname}] 评价了你: {$last_evaluate->content}",
                'time' => $last_evaluate->created_at->toDateTimeString(),
            ];
        }

        // 预约消息
        $follow_my_count = 0;
        $reserve_message = (object)[];
        if ($user->guide_id > 0) {
            $last_reserve = ReserveGuide::with(['user'])->where('guide_id', $user->guide_id)
                ->orderBy('id', 'desc')
                ->first(['user_id', 'status', 'updated_at']);
            if ($last_reserve) {
                $text = reserveMessage($last_reserve->user->nickname, $last_reserve->status);

                $reserve_message = [
                    'text' => $text,
                    'time' => $last_reserve->updated_at->toDateTimeString(),
                ];
            }

            $follow_my_count = $list_data['follow_my'] ?? 0;
        }

        if ($user->company_id > 0) {
            $last_reserve = Reserve::with(['user'])->where('company_id', $user->company_id)
                ->orderBy('id', 'desc')
                ->first(['user_id', 'status', 'updated_at']);
            if ($last_reserve) {
                $text = reserveMessage($last_reserve->user->nickname, $last_reserve->status);

                $reserve_message = [
                    'text' => $text,
                    'time' => $last_reserve->updated_at->toDateTimeString(),
                ];
            }
            $follow_my_count = $list_data['follow_my_shop'] ?? 0;
        }

        $my_reserve_message = (object)[];

        $last_reserve_guide = ReserveGuide::query()->where('user_id', $user_id)
            ->where('status', '>', 1)
            ->orderBy('id', 'desc')
            ->first(['reason', 'status', 'updated_at']);
        $last_reserve_company = Reserve::query()->where('user_id', $user_id)
            ->where('status', '>', 1)
            ->orderBy('id', 'desc')
            ->first(['reason', 'status', 'updated_at']);

        if ($last_reserve_guide && !$last_reserve_company) {
            $text = reserveUserMessage($last_reserve_guide->reason, $last_reserve_guide->status);

            $my_reserve_message = [
                'text' => $text,
                'time' => $last_reserve_guide->updated_at->toDateTimeString(),
            ];
        }
        if (!$last_reserve_guide && $last_reserve_company) {
            $text = reserveUserMessage($last_reserve_company->reason, $last_reserve_company->status);

            $my_reserve_message = [
                'text' => $text,
                'time' => $last_reserve_company->updated_at->toDateTimeString(),
            ];
        }
        if ($last_reserve_guide && $last_reserve_company) {
            if ($last_reserve_guide->updated_at > $last_reserve_company->updated_at) {
                $text = reserveUserMessage($last_reserve_guide->reason, $last_reserve_guide->status);
            } else {
                $text = reserveUserMessage($last_reserve_company->reason, $last_reserve_company->status);
            }
            $my_reserve_message = [
                'text' => $text,
                'time' => $last_reserve_company->updated_at->toDateTimeString(),
            ];
        }


        return [
            'evaluate_my_count' => isset($list_data['evaluate_my']) ? (int)$list_data['evaluate_my'] : 0,
            'follow_my_count' => (int)$follow_my_count,
            'system_count' => isset($list_data['system']) ? (int)$list_data['system'] : 0,
            'follow_message' => $follow_message,
            'evaluate_message' => $evaluate_message,
            'reserve_message' => $reserve_message,
            'my_reserve_message' => $my_reserve_message,
        ];
    }


    /**
     * 好友关注大洲分类
     * @param int $parent_id
     * @param int $type (1我的关注/2关注我的)
     * @return array
     */
    public function followClass(int $parent_id, int $type)
    {
        $data = SystemContinents::query()->where('parent_id', $parent_id)->orderBy('order', 'asc')->get(['id', 'name'])->toArray();
        if (!empty($data)) {
            array_unshift($data, ['id' => 10001, 'name' => '全部']);
        }
        return $data;
    }


    /**
     * 我的评价
     * @param int $limit
     * @return array
     */
    public function myEvaluate(int $limit)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        // 查询我评价的
        $data = ContentEvaluate::with(['contents', 'content_user'])
            ->where('user_id', $user_id)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'content_type', 'content_id', 'content_name', 'content_user_id', 'content', 'created_at'])->toArray();

        $list = [];
        foreach ($data['data'] as $v) {
            $content_info = $v['content_type'] == City::ContentTypeCity ? [
                'id' => $v['contents']['id'],
                'city_id' => $v['contents']['city_id'],
                'type_id' => $v['contents']['type_id'],
            ] : (object)[];

            $list[] = [
                'id' => $v['id'],
                'my_avatar' => $user->avatar,
                'my_nickname' => $user->nickname,
                'content' => $v['content'],
                'content_id' => $v['content_id'],
                'title' => $v['content_name'],
                'content_type' => $v['content_type'],
                'content_picture' => $v['content_type'] == City::ContentTypeCity ? $v['contents']['first_picture'] : '',
                'content_user' => $v['content_user']['nickname'] ?? '',
                'content_info' => $content_info,
                'time' => $v['created_at'],
            ];
        }
        return ['total' => $data['total'], 'list' => $list];
    }


    /**
     * 评价我的
     * @param int $limit
     * @return array
     */
    public function evaluateMy(int $limit)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        // 查询评价我的
        $data = ContentEvaluate::with(['contents', 'user'])
            ->where('content_user_id', $user_id)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'user_id', 'content_id', 'content_type', 'content', 'created_at'])->toArray();


        $list = [];
        foreach ($data['data'] as $v) {
            $title = $v['content_type'] == City::ContentTypeCity ? '發布內容' : '資訊';

            $content_info = $v['content_type'] == City::ContentTypeCity ? [
                'id' => $v['contents']['id'],
                'city_id' => $v['contents']['city_id'],
                'type_id' => $v['contents']['type_id'],
            ] : (object)[];

            $list[] = [
                'id' => $v['id'],
                'user_avatar' => $v['user']['avatar'],
                'user_nickname' => $v['user']['nickname'],
                'title' => "评论您的$title",
                'content' => $v['content'],
                'content_id' => $v['content_id'],
                'content_type' => $v['content_type'],
                'content_picture' => $v['content_type'] == City::ContentTypeCity ? $v['contents']['first_picture'] : '',
                'content_info' => $content_info,
                'time' => $v['created_at'],
            ];
        }

        // 清空未读
        Redis::hSet("message_list:$user_id", 'evaluate_my', 0);

        return ['total' => $data['total'], 'list' => $list];
    }


    /**
     * 我的关注
     * @param int $limit
     * @param int $continents_id
     * @param int $area_id
     * @return array
     */
    public function myFollow(int $limit, int $continents_id, int $area_id)
    {
        $user_id = auth('api')->id();

        $where['user_id'] = $user_id;
        if ($continents_id > 0 && $continents_id < 10000) {
            $where['followed_continents_id'] = $continents_id;
        }
        if ($area_id > 0 && $area_id < 10000) {
            $where['followed_area_id'] = $area_id;
        }

        $data = UserFollow::with(['user'])->where($where)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'followed_id as user_id', 'followed_identity', 'followed_identity_id', 'followed_identity_tag', 'followed_city_name', 'created_at'])
            ->toArray();

        $list = [];
        foreach ($data['data'] as $v) {
            //            $is_follow = UserFollow::query()->where('user_id', $user_id)->where('followed_id', $v['user_id'])->exists();

            $list[] = [
                'id' => $v['id'],
                'user_id' => $v['user_id'],
                'user_nickname' => $v['user']['nickname'],
                'user_avatar' => $v['user']['avatar'],
                'user_identity' => $v['followed_identity'],
                'user_identity_id' => $v['followed_identity_id'],
                'user_identity_tag' => $v['followed_identity_tag'],
                'user_city_name' => $v['followed_city_name'],
                'is_follow' => 1,
            ];
        }

        $city_type = CityType::options();
        $shop_data = UserFollowShop::with(['content'])->where($where)->orderBy('id', 'desc')->paginate($limit)->toArray();
        foreach ($shop_data['data'] as $v) {
            $list[] = [
                'id' => $v['id'],
                'user_id' => $v['followed_user_id'],
                'user_nickname' => $v['followed_name'],
                'user_avatar' => $v['content']['first_picture'],
                'user_identity' => 4,
                'user_identity_id' => $v['followed_id'],
                'user_identity_tag' => $city_type[$v['content']['type_id']],
                'user_city_name' => $v['followed_city_name'],
                'shop_info' => [
                    'id' => $v['content']['id'],
                    'city_id' => $v['content']['city_id'],
                    'type_id' => $v['content']['type_id'],
                ],
                'is_follow' => 1,
            ];
        }

        return ['total' => $data['total'], 'list' => $list];
    }

    /**
     * 关注我的
     * @param int $limit
     * @param int $continents_id
     * @param int $area_id
     * @return array
     */
    public function followMy(int $limit, int $continents_id, int $area_id)
    {
        $user_id = auth('api')->id();

        $where['followed_id'] = $user_id;
        if ($continents_id > 0 && $continents_id < 10000) {
            $where['user_continents_id'] = $continents_id;
        }
        if ($area_id > 0 && $area_id < 10000) {
            $where['user_area_id'] = $area_id;
        }

        $data = UserFollow::with(['user'])->where($where)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'user_id', 'user_identity', 'user_identity_id', 'user_identity_tag', 'user_city_name', 'created_at'])
            ->toArray();

        $list = [];
        foreach ($data['data'] as $v) {
            // 是否关注
            $is_follow = UserFollow::query()->where('user_id', $user_id)->where('followed_id', $v['user_id'])->exists();

            $list[] = [
                'id' => $v['id'],
                'user_id' => $v['user_id'],
                'user_number' => $v['user']['number'],
                'user_nickname' => $v['user']['nickname'],
                'user_avatar' => $v['user']['avatar'],
                'user_identity' => $v['user_identity'],
                'user_identity_id' => $v['user_identity_id'],
                'user_identity_tag' => $v['user_identity_tag'],
                'user_city_name' => $v['user_city_name'],
                'is_follow' => $is_follow ? 1 : 0,
            ];
        }

        // 清空未读
        Redis::hSet("message_list:$user_id", 'follow_my', 0);

        return ['total' => $data['total'], 'list' => $list];
    }


    /**
     * 关注我的店铺
     * @param int $limit
     * @param int $continents_id
     * @param int $area_id
     * @return array
     */
    public function followMyShop(int $limit, int $continents_id, int $area_id)
    {
        $user_id = auth('api')->id();

        $where['followed_user_id'] = $user_id;
        if ($continents_id > 0 && $continents_id < 10000) {
            $where['user_continents_id'] = $continents_id;
        }
        if ($area_id > 0 && $area_id < 10000) {
            $where['user_area_id'] = $area_id;
        }

        // 第一步：每个 user_id 取最新一条 id
        $ids = UserFollowShop::query()->where($where)
            ->groupBy('user_id')
            ->selectRaw('MAX(id) as id')
            ->pluck('id');

        $data = UserFollowShop::with(['user', 'content'])->whereIn('id', $ids)
            ->orderBy('id', 'desc')
            ->paginate($limit, ['id', 'user_id', 'user_identity', 'user_identity_id', 'user_identity_tag', 'followed_id'])
            ->toArray();

        $list = [];
        foreach ($data['data'] as $v) {
            $is_follow = UserFollow::query()->where('user_id', $user_id)->where('followed_id', $v['user_id'])->exists();

            // 关注的店铺
            $shops_name = UserFollowShop::query()->where('user_id', $v['user_id'])->where('followed_user_id', $user_id)->pluck('followed_name')->toArray();

            $list[] = [
                'id' => $v['id'],
                'user_id' => $v['user_id'],
                'user_number' => $v['user']['number'],
                'user_avatar' => $v['user']['avatar'],
                'user_name' => $v['user']['nickname'],
                'user_identity' => $v['user_identity'],
                'user_identity_id' => $v['user_identity_id'],
                'user_identity_tag' => $v['user_identity_tag'],
                'title' => '',
                'shops_name' => $shops_name,
                'shop_info' => [
                    'id' => $v['followed_id'],
                    'name' => $v['content']['name'],
                    'first_picture' => $v['content']['first_picture'],
                ],
                'is_follow' => $is_follow ? 1 : 0,
            ];
        }

        // 清空未读
        Redis::hSet("message_list:$user_id", 'follow_my_shop', 0);

        return ['total' => $data['total'], 'list' => $list];
    }


    /**
     * 关注/取关
     * @param int $followed_id
     * @return void
     * @throws ApiException
     */
    public function follow(int $followed_id)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        if ($user_id == $followed_id) {
            throw new ApiException(__('res.follow_self_error'));
        }

        $follow = UserFollow::query()->where('user_id', $user_id)->where('followed_id', $followed_id)->first();
        if ($follow) {
            $follow->delete();
        } else {
            $follow_user = User::find($followed_id);
            if (!$follow_user) {
                throw new ApiException(__('res.user_not'));
            }

            // 当前用户角色
            $user_identity_id = 0;
            $user_city_name = '';
            if ($user->identity == \App\Enums\User::identityGuide) {
                $user_identity_id = $user->guide_id;
                $user_city_name = Guide::query()->where('id', $user->guide_id)->value('city_name');
            }
            if ($user->identity == \App\Enums\User::identityCompany) {
                $user_identity_id = $user->company_id;
                $user_city_name = Company::query()->where('id', $user->company_id)->value('city_name');
            }

            // 被关注者信息
            $followed_identity_id = 0;
            $followed_city_name = '';
            if ($follow_user->identity == \App\Enums\User::identityGuide) {
                $followed_identity_id = $follow_user->guide_id;
                $followed_city_name = Guide::query()->where('id', $follow_user->guide_id)->value('city_name');
            }
            if ($follow_user->identity == \App\Enums\User::identityCompany) {
                $followed_identity_id = $follow_user->company_id;
                $followed_city_name = Company::query()->where('id', $follow_user->guide_id)->value('city_name');
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
                $model->followed_id = $followed_id;
                $model->followed_continents_id = $follow_user->continents_id;
                $model->followed_area_id = $follow_user->area_id;
                $model->followed_identity = \App\Enums\User::identityGuide;
                $model->followed_identity_id = $followed_identity_id;
                $model->followed_identity_tag = $follow_user->identity_str;
                $model->followed_city_name = $followed_city_name;
                $model->save();

                // 关注我的
                $count = Redis::hGet("message_list:$followed_id", 'follow_my') ?? 0;
                Redis::hSet("message_list:$followed_id", 'follow_my', $count + 1);
            } catch (Throwable $exception) {
                throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
            }
        }
    }

    /**
     * 取关店铺
     * @param int $shop_id
     * @return void
     * @throws ApiException
     */
    public function unFollowShop(int $shop_id)
    {
        $user = auth('api')->user();
        $user_id = $user->id;

        $follow = UserFollowShop::query()->where('user_id', $user_id)->where('followed_id', $shop_id)->first();
        if (!$follow) {
            throw new ApiException(__('res.follow_no_error'));
        }
        $follow->delete();
    }


    /**
     * 系统消息
     * @param int $limit
     * @return array
     */
    public function systemList(int $limit)
    {
        $user_id = auth('api')->id();
        $data = SystemMessage::query()->where('user_id', $user_id)->orderBy('id', 'desc')
            ->paginate($limit, ['title', 'content as desc', 'content', 'content_type', 'city_id', 'content_id', 'city_content_type', 'created_at as time'])->toArray();

        // 清空未读
        Redis::hSet("message_list:$user_id", 'system', 0);

        return ['total' => $data['total'], 'list' => $data['data']];
    }
}
