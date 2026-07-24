<?php

namespace App\Services;

use App\Enums\City;
use App\Enums\Vip;
use App\Exceptions\ApiException;
use App\Models\ContentEvaluate;
use App\Models\Information;
use App\Enums\System;
use App\Models\SystemIntegralConfig;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Throwable;

class InformationService
{

    /**
     * 资讯列表
     * @param int $class_id
     * @param int $limit
     * @return array
     */
    public function lists(int $class_id, int $limit)
    {
        $user = auth('api')->user();
        $guide_id = $user ? $user->guide_id : 0;

        $query = Information::with(['user', 'guide'])->where('audit_status', 1);

        // 没有认证导游 只能看全部 (未登录与商家同理
        if ($guide_id == 0) {
            $query->where('look', 2);
        }

        if ($class_id > 0) {
            $query->where('class_id', $class_id);
        }

        $res = $query->orderBy('id', 'desc')
            ->orderBy('top', 'desc')
            ->orderBy('top_order', 'desc')
            ->paginate($limit, ['id', 'title', 'guide_id', 'user_id', 'guide_type_id', 'first_picture', 'pictures', 'desc', 'created_at'])->toArray();

        $data = [];
        foreach ($res['data'] as $v) {
            $data[] = [
                'id' => $v['id'],
                'title' => $v['title'],
                'desc' => $v['desc'],
                'first_picture' => $v['first_picture'],
                'pictures' => json_decode($v['pictures'], true) ?? [],
                'created_at' => $v['created_at'],
                'user' => [
                    'name' => $v['guide']['name'],
                    'guide_id' => $v['guide']['id'],
                    'photo' => $v['guide']['photo'],
                    'city_id' => $v['guide']['city_id'],
                    'identity_type' => $v['user']['identity_str'] ?? '',
                ],
                'evaluate_count' => ContentEvaluate::query()->where('content_type', \App\Enums\City::ContentTypeInformation)->where('content_id', $v['id'])->count(),
            ];
        }

        return ['total' => $res['total'], 'list' => $data];
    }


    /**
     * 资讯详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function info(int $id)
    {
        $user = auth('api')->user();

        // 导游 不过期
        $is_evaluate = 0;
        // 导游身份可以评价 不过期
        if ($user && $user->identity == \App\Enums\User::identityGuide && $user->vip_type == Vip::OrderVipTypeGuide) {
            $is_evaluate = 1;
        }

        $data = Information::with(['user', 'guide'])->find($id);
        if (!$data) {
            throw new ApiException(__('res.information_not'));
        }
        $data->view = $data->view + 1;
        $data->save();

        $data = $data->toArray();
        return [
            'id' => $data['id'],
            'title' => $data['title'],
            'desc' => $data['content'],
            'created_at' => $data['created_at'],
            'pictures' => json_decode($data['pictures'], true) ?? [],
            'view' => $data['view'],
            'is_evaluate' => $is_evaluate,
            'user' => [
                'name' => $data['guide']['name'],
                'city_name' => $data['guide']['city_name'],
                'photo' => $data['guide']['photo'],
                'guide_id' => $data['guide']['id'],
                'city_id' => $data['guide']['city_id'],
                'identity_type' => $data['user']['identity_str'] ?? '',
            ],
        ];
    }


    /**
     * 评价
     * @param int $id
     * @param int $limit
     * @return array
     */
    public function evaluate(int $id, int $limit)
    {
        $res = ContentEvaluate::with(['user'])
            ->where('content_type', City::ContentTypeInformation)
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
     * 添加评价
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function addEvaluate(array $data)
    {
        $user = auth('api')->user();
        handleGuideVip($user);

        $content = Information::query()->where('id', $data['content_id'])->first();
        if (!$content) {
            throw new ApiException(__('res.information_not'));
        }

        if ($user->identity !== \App\Enums\User::identityGuide) {
            throw new ApiException(__('res.auth_error'));
        }

        DB::beginTransaction();
        try {
            $model = new ContentEvaluate();
            $model->user_id = $user->id;
            $model->user_type = 'guide';
            $model->content_type = City::ContentTypeInformation;
            $model->content_id = $data['content_id'];
            $model->content_name = $content->title;
            $model->content_user_id = $content->user_id;
            $model->content = $data['content'];
            if (isset($data['pictures'])) {
                $model->pictures = json_encode($data['pictures']);
            }
            $model->star = $data['star'];
            $model->save();

            // 添加评论增加积分
            SystemIntegralConfig::saveData($user->id, 'evaluate');

            // 评价我的
            $count = Redis::hGet("message_list:{$content->user_id}", 'evaluate_my') ?? 0;
            Redis::hSet("message_list:{$content->user_id}", 'evaluate_my', $count + 1);

            DB::commit();
        } catch (Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }

}
