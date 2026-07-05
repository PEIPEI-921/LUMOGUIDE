<?php

namespace App\Admin\Forms;

use App\Models\Company;
use App\Models\User;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;

class CompanyVipSet extends Form implements LazyRenderable
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
        $company = Company::find($this->payload['key']);
        $user_id = $company->user_id;

        $user = User::find($user_id);
        if (!$user || $user->identity !== 3) {
            throw new \Exception('错误商家');
        }

        try {
            $user->vip_company_auth = json_encode($input);
            $user->save();
        } catch (\Exception $e) {
            return $this->response()->error($e->getMessage());
        }

        return $this->response()->success('权益设置成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $form = $this;
        $form->width(8, 3);

        $company = Company::find($this->payload['key']);
        $user = User::query()->where('id', $company->user_id)->first(['vip_name', 'vip_company_auth']);
        $vip_company_auth_arr = json_decode($user->vip_company_auth, true);

        $form->html("会员名称【{$user->vip_name}】");
        $form->number('shop_number', '店鋪數量')->default($vip_company_auth_arr['shop_number']);
        $form->radio('shop_type', '店铺类型')->options([1 => '同类型', 2 => '多类型'])->value($vip_company_auth_arr['shop_type']);
        $form->number('city_content_recommend', '城市内容推荐天数')->value($vip_company_auth_arr['city_content_recommend']);
        $form->number('home_list_recommend', '首页列表推荐天数')->value($vip_company_auth_arr['home_list_recommend']);
        $form->number('home_banner_recommend', '首页banner推荐天数')->value($vip_company_auth_arr['home_banner_recommend']);
    }

    /**
     * The data of the form.
     *
     * @return array
     */
    public function default()
    {
    }
}
