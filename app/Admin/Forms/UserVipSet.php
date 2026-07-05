<?php

namespace App\Admin\Forms;

use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\VipCompany;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Facades\DB;

class UserVipSet extends Form implements LazyRenderable
{
    use LazyWidget;

    /**
     * Handle the form request.
     *
     * @param array $input
     *
     * @return mixed
     */
    public function handle(array $input)
    {
        $user_id = $input['user_id'];
        $user = User::find($input['user_id']);

        // 会员类型
        $vip_type = $user->identity == \App\Enums\User::identityGuide ? 1 : 2;
        $vip_id = $input['vip_id'] ?? 1;
        $vip_expiration_time = $input['vip_expiration_time'];

        DB::beginTransaction();
        try {
            $user->vip_type = $vip_type;
            if ($vip_type == 1) {
                $user->vip_id = 1;
            } else {
                // 企业会员权限
                $vip_company = \App\Models\VipCompany::find($vip_id);
                $vip_company_auth = [
                    'shop_number' => $vip_company->number,
                    'shop_type' => $vip_company->shop_type,
                    'city_content_recommend' => $vip_company->city_content_recommend,
                    'home_list_recommend' => $vip_company->home_list_recommend,
                    'home_banner_recommend' => $vip_company->home_banner_recommend
                ];

                $user->vip_id = $vip_id;
                $user->vip_name = $vip_company->name;
                $user->vip_company_auth = json_encode($vip_company_auth);
            }
            $user->vip_expiration_time = strtotime($vip_expiration_time);
            $user->save();

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->response()->error($e->getMessage());
        }

        return $this->response()->success('设置会员成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $user = User::find($this->payload['key']);

        $company_vip = VipCompany::all()->toArray();
        $company_vip_options = [];

        $shop_type = [1 => '同类型', 2 => '多类型'];

        foreach ($company_vip as $vip) {
            $shop_type_str = $shop_type[$vip['shop_type']];
            $company_vip_options[$vip['id']] = "【{$vip['name']}】店铺数量{$vip['number']}(发布$shop_type_str)";
        }

        $options_str = \App\Enums\User::IdentityArr[$user->identity];

        $this->hidden('user_id');
        $this->radio('vip_type', '会员类型')->options([$user->identity => $options_str])
            ->value($user->identity)
            ->when(3, function (Form $form) use ($company_vip_options) {
                $this->select('vip_id')->options($company_vip_options)->default(1);
            });
        $this->date('vip_expiration_time', '过期时间')->required();
    }

    /**
     * The data of the form.
     *
     * @return array
     */
    public function default()
    {
        return [
            'user_id' => $this->payload['key'],
        ];
    }
}
