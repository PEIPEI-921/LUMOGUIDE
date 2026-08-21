<?php

namespace App\Admin\Repositories;

use App\Jobs\VipExpiredJob;
use App\Models\City;
use App\Models\Guide as Model;
use App\Models\GuideEdit;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;
use Illuminate\Support\Facades\DB;

class Guide extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;


    public function edit(Form $form)
    {
        // 获取数据主键值
        $id = $form->getKey();

        $res = Model::with(['type'])->find($id);

        // 存在待审核数据
        $edit_content = GuideEdit::with(['type'])->where('guide_id', $res->id)->where('audit_status', 0)->first();
        if ($edit_content) {
            $res = $edit_content;
        }
//        if ($res->audit_status == 0) {
//
//        }

        return $res->toArray();
    }


    public function update(Form $form)
    {
        // 获取待编辑的数据
        $attributes = $form->updates();

        $res = Model::find($form->getKey());

        // 首次通过不会二次处理 (即第一次申请并且通过 不会下发二次奖励)
        $is_finish = 0;
        if ($res->is_finish == 0 && isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
            $res->is_finish = 1;
            $res->audit_time = date('Y-m-d H:i:s');
            $is_finish = 1;
        }

        DB::beginTransaction();
        try {
//            if ($is_finish == 1) {
//                $res->audit_time = date('Y-m-d H:i:s');
//            }

            if (isset($attributes['audit_status'])) {
                // 审核状态 修改审核记录表
                $edit_info = GuideEdit::query()->where('guide_id', $res->id)->where('audit_status', 0)->first();
                if ($edit_info && $attributes['audit_status'] > 0) {
                    $edit_info = $edit_info->toArray();
                    $edit_info_id = $edit_info['id'];
                    unset($edit_info['id'], $edit_info['guide_id'], $edit_info['audit_status'], $edit_info['audit_feedback'], $edit_info['created_at'], $edit_info['updated_at']);

                    // 审核通过 覆盖导游表资料
                    if ($attributes['audit_status'] == 1) {
                        foreach ($edit_info as $key => $value) {
                            $res->{$key} = $value;
                        }
                    }

                    // 审核记录表修改状态
                    GuideEdit::query()->where('id', $edit_info_id)->update([
                        'audit_status' => $attributes['audit_status'],
                        'audit_feedback' => $attributes['audit_feedback']
                    ]);
                }

                // 首次创建 没有修改记录表
                if (!$edit_info && $attributes['audit_status'] > 0) {
                    $res->audit_status = $attributes['audit_status'];
                    $res->audit_feedback = $attributes['audit_feedback'];
                }

                // 审核通过 二次通过 修改回显身份
                if ($is_finish == 0 && $attributes['audit_status'] == 1) {
                    // 修改回显身份
                    \App\Models\User::query()->where('id', $res->user_id)->update([
                        'identity_str' => \App\Models\GuideType::where('id', $res->identity_type)->value('name'),
                    ]);
                }
            }

            // --- 审核通过：常駐城市同步到导游主表（否则导游不会出现在所选城市的导游列表） ---
            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 1
                && !empty($res->resident_city_id)
                && (int)$res->city_id !== (int)$res->resident_city_id) {
                $residentCity = City::query()->find($res->resident_city_id);
                if ($residentCity) {
                    $res->city_id = $residentCity->id;
                    $res->city_name = $residentCity->name;
                    $res->continents_id = $residentCity->continents_id ?? 0;
                    $res->area_id = $residentCity->area_id ?? 0;
                    // 常駐城市与导游建立归属（城市管理/推荐联动）
                    if (empty($residentCity->guide_id)) {
                        City::query()->where('id', $residentCity->id)->update(['guide_id' => $res->id]);
                    }
                }
            }

            $res->save();

            // --- 常駐城市審核聯動 ---
            if (isset($attributes['audit_status']) && $res->is_new_city == 1 && $res->linked_city_id) {
                $city_audit_status = $attributes['audit_status'];
                City::query()->where('id', $res->linked_city_id)->update([
                    'audit_status' => $city_audit_status,
                ]);
            }

            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
                $city_name = City::query()->where('id', $res->city_id)->value('name_en');
                $identity_str = \App\Models\GuideType::where('id', $res->identity_type)->value('name');

                // 认证通过后昵称由 LUMOGUIDE 后端展示，无需再同步 IM（LUMO-Chat 不存用户资料）
            }

            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 2) {
                SystemMessage::saveData($res->user_id, '導遊認證', '導遊認證失败', "很抱歉,您提交的資料沒有通過,原因是:{$attributes['audit_feedback']},請重新填寫資料");
            }

            if ($is_finish == 1) {
                // 完成首次认证 增加积分
                SystemIntegralConfig::saveData($res->user_id, 'auth');

                SystemMessage::saveData($res->user_id, '導遊認證', '導遊認證通過審核', "恭喜您,提交的導遊資料通過認證");

                \App\Models\User::query()->where('id', $res->user_id)->update([
                    'identity_str' => \App\Models\GuideType::where('id', $res->identity_type)->value('name'),
                    'vip_type' => \App\Enums\Vip::OrderVipTypeGuide,
                    'vip_id' => 1,
                    'vip_expiration_time' => time() + (30 * 86400),
                    'vip_free' => \App\Enums\User::VipFreeYes,
                    'identity' => \App\Enums\User::identityGuide,
                    'guide_id' => $res->id
                ]);

                // 增加会员到期
                VipExpiredJob::dispatch($res->user_id)->delay(now()->addDays(30));
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }

        return true;
    }
}
