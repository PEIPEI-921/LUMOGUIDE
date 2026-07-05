<?php

namespace App\Admin\Repositories;

use App\Jobs\VipExpiredJob;
use App\Models\City;
use App\Models\Company as Model;
use App\Models\CompanyEdit;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;
use Hedeqiang\TenIM\Facades\IM;
use Illuminate\Support\Facades\DB;

class Company extends EloquentRepository
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

        $res = Model::find($id);

        $edit_content = CompanyEdit::query()->where('company_id', $res->id)->where('audit_status', 0)->first();
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

//        foreach ($attributes as $key => $value) {
//            if (in_array($key, ['recommend', 'audit_status', 'audit_feedback'])) {
//                $res->{$key} = $value;
//            }
//        }

        // 首次通过不会二次处理
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
                $edit_info = CompanyEdit::query()->where('company_id', $res->id)->where('audit_status', 0)->first();
                if ($edit_info && $attributes['audit_status'] > 0) {
                    $edit_info = $edit_info->toArray();
                    $edit_info_id = $edit_info['id'];
                    unset($edit_info['id'], $edit_info['company_id'], $edit_info['audit_status'], $edit_info['audit_feedback'], $edit_info['created_at'], $edit_info['updated_at']);

                    // 审核通过 覆盖企业表资料
                    if ($attributes['audit_status'] == 1) {
                        foreach ($edit_info as $key => $value) {
                            $res->{$key} = $value;
                        }
                    }

                    // 审核记录表修改状态
                    CompanyEdit::query()->where('id', $edit_info_id)->update([
                        'audit_status' => $attributes['audit_status'],
                        'audit_feedback' => $attributes['audit_feedback']
                    ]);
                }

                // 首次创建 没有修改记录表
                if (!$edit_info && $attributes['audit_status'] > 0) {
                    $res->audit_status = $attributes['audit_status'];
                    $res->audit_feedback = $attributes['audit_feedback'];
                }
            }

            $res->save();

            // 更新腾讯云资料
            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
                $user = \App\Models\User::where('id', $res->user_id)->first(['identity_str', 'number']);
                $city_name = City::query()->where('id', $res->city_id)->value('name_en');

                $identity_str = $user->identity_str;
                $nickname = "$res->name_en($city_name)-$identity_str";

                $account_body = [
                    'Identifier' => $user->number,
                    'Nick' => $nickname,
                ];
                $im_res = IM::im()->send('im_open_login_svc', 'account_import', $account_body);
                imApiLog('im_open_login_svc', 'account_import', $account_body, $im_res);
            }

            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 2) {
                SystemMessage::saveData($res->user_id, '企業認證', '企業認證失败', "很抱歉,您提交的資料沒有通過,原因是:{$attributes['audit_feedback']},請重新填寫資料");
            }

            if ($is_finish == 1) {
                // 完成认证 增加积分
                SystemIntegralConfig::saveData($res->user_id, 'auth');

                SystemMessage::saveData($res->user_id, '企業認證', '企業認證通過審核', "恭喜您,提交的企業資料通過認證");

                // 企业会员权限
                $vip_company = \App\Models\VipCompany::find(1);
                $vip_company_auth = [
                    'shop_number' => $vip_company->number,
                    'shop_type' => $vip_company->shop_type,
                    'city_content_recommend' => $vip_company->city_content_recommend,
                    'home_list_recommend' => $vip_company->home_list_recommend,
                    'home_banner_recommend' => $vip_company->home_banner_recommend
                ];

                \App\Models\User::query()->where('id', $res->user_id)->update([
                    'vip_type' => \App\Enums\Vip::OrderVipTypeCompany,
                    'vip_id' => 1,
                    'vip_name' => $vip_company->name,
                    'vip_expiration_time' => time() + (30 * 86400),
                    'vip_free' => \App\Enums\User::VipFreeYes,
                    'vip_company_auth' => json_encode($vip_company_auth),
                    'identity' => \App\Enums\User::identityCompany,
                    'company_id' => $res->id
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
