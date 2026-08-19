<?php

namespace App\Admin\Forms;

use App\Jobs\CityContentExpiredJob;
use App\Models\CityContent;
use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\VipCompany;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Facades\DB;

class CityContentRecommendSet extends Form implements LazyRenderable
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
        $id = $this->payload['key'];
        $res = CityContent::find($id);

        $company_auth = [];
        if ($res->publisher_type == 'company') {
            $company_user = User::find($res->user_id);
            $company_auth = json_decode($company_user->vip_company_auth, true) ?? [];
        }

        DB::beginTransaction();
        try {
            $res->banner_recommend = $input['banner_recommend'];
            $res->home_recommend = $input['home_recommend'];

            // 不能同时设置
            if ($input['banner_recommend'] == 1) {
                $res->banner_recommend = 1;
                $res->home_recommend = 0;
                $res->home_recommend_time = 0;
            }
            if ($input['home_recommend'] == 1) {
                $res->home_recommend = 1;
                $res->banner_recommend = 0;
                $res->banner_recommend_time = 0;
            }
            $res->recommend = $input['recommend'];
            $res->status = $input['status'];

            if (!empty($company_auth)) {
                // 首页推荐
                if ($res->home_recommend == 1) {
                    $res->home_recommend_time = time() + ($company_auth['home_list_recommend'] * 86400);

                    // 增加过期时间
                    CityContentExpiredJob::dispatch($id, 'home_recommend_time')->delay(now()->addDays($company_auth['home_list_recommend']));
                }
                // 轮播推荐
                if ($res->banner_recommend == 1) {
                    $res->banner_recommend_time = time() + ($company_auth['home_banner_recommend'] * 86400);

                    // 增加过期时间
                    CityContentExpiredJob::dispatch($id, 'banner_recommend_time')->delay(now()->addDays($company_auth['home_banner_recommend']));
                }
                // 城市推荐
                if ($res->recommend == 1) {
                    $res->recommend_time = time() + ($company_auth['city_content_recommend'] * 86400);

                    // 增加过期时间
                    CityContentExpiredJob::dispatch($id, 'recommend_time')->delay(now()->addDays($company_auth['city_content_recommend']));
                }
            } else {
                if ($res->home_recommend == 1) {
                    $res->home_recommend_time = 999999999;
                }
                if ($res->banner_recommend == 1) {
                    $res->banner_recommend_time = 999999999;
                }
                if ($res->recommend == 1) {
                    $res->recommend_time = 999999999;
                }
            }

            $res->save();

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->response()->error($e->getMessage());
        }
        return $this->response()->success('設置成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $form = $this;
        $content = CityContent::find($this->payload['key']);

        $recommend_time = $content->recommend_time;
        $banner_recommend_time = $content->banner_recommend_time;
        $home_recommend_time = $content->home_recommend_time;

        $form->switch('recommend')->value($content->recommend)->help($this->handleTime($recommend_time));
        $form->switch('banner_recommend')->value($content->banner_recommend)->help($this->handleTime($banner_recommend_time));
        $form->switch('home_recommend')->value($content->home_recommend)->help($this->handleTime($home_recommend_time));
        $form->switch('status')->value($content->status);
    }


    protected function handleTime(int $recommend_time)
    {
        $time_str = '';
        if ($recommend_time > 0) {
            if ($recommend_time == 999999999) {
                $time_str = '到期時間：永久';
            } else {
                $time_str = '到期時間：' . date('Y-m-d H:i:s', $recommend_time);
            }
        }
        return $time_str;
    }

    /**
     * The data of the form.
     *
     * @return array
     */
    public function default()
    {
        return [
            'id' => $this->payload['key'],
        ];
    }
}
