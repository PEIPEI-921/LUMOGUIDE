<?php

namespace App\Admin\Forms;

use App\Jobs\CityContentExpiredJob;
use App\Models\CityContent;
use App\Models\User;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;

/**
 * 企業推薦設置 — 企業以商鋪(city_content)形式展示在首頁/城市頁，
 * 此表單編輯該企業首個商鋪的推薦與排序。
 */
class CompanyRecommendSet extends Form implements LazyRenderable
{
    use LazyWidget;

    protected function shop(): ?CityContent
    {
        return CityContent::query()
            ->where('publisher_type', 'company')
            ->where('publisher_id', (int) $this->payload['key'])
            ->orderBy('id', 'asc')
            ->first();
    }

    public function handle(array $input)
    {
        $res = $this->shop();
        if (!$res) {
            return $this->response()->error('該企業尚未開通商鋪，無法設置推薦');
        }

        $company_auth = [];
        if ($res->user_id > 0) {
            $company_user = User::find($res->user_id);
            $company_auth = json_decode($company_user->vip_company_auth ?? '', true) ?? [];
        }

        try {
            $res->banner_recommend = $input['banner_recommend'];
            $res->home_recommend = $input['home_recommend'];

            // 轮播推荐与首页推荐不能同时
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
            $res->order = $input['order'];

            if (!empty($company_auth)) {
                // 首页推荐
                if ($res->home_recommend == 1) {
                    $res->home_recommend_time = time() + ($company_auth['home_list_recommend'] * 86400);

                    CityContentExpiredJob::dispatch($res->id, 'home_recommend_time')->delay(now()->addDays($company_auth['home_list_recommend']));
                }
                // 轮播推荐
                if ($res->banner_recommend == 1) {
                    $res->banner_recommend_time = time() + ($company_auth['home_banner_recommend'] * 86400);

                    CityContentExpiredJob::dispatch($res->id, 'banner_recommend_time')->delay(now()->addDays($company_auth['home_banner_recommend']));
                }
                // 城市推荐
                if ($res->recommend == 1) {
                    $res->recommend_time = time() + ($company_auth['city_content_recommend'] * 86400);

                    CityContentExpiredJob::dispatch($res->id, 'recommend_time')->delay(now()->addDays($company_auth['city_content_recommend']));
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
        } catch (\Exception $e) {
            return $this->response()->error($e->getMessage());
        }
        return $this->response()->success('設置成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $shop = $this->shop();
        if (!$shop) {
            $this->text('notice', '提示')->value('該企業尚未開通商鋪，無法設置推薦')->disable();
            return;
        }

        $this->switch('recommend')->value($shop->recommend)->help($this->handleTime($shop->recommend_time));
        $this->switch('banner_recommend')->value($shop->banner_recommend)->help($this->handleTime($shop->banner_recommend_time));
        $this->switch('home_recommend')->value($shop->home_recommend)->help($this->handleTime($shop->home_recommend_time));
        $this->number('order')->value($shop->order)->help('排序從大至小（該企業首個商鋪「' . $shop->name . '」）');
        $this->switch('status')->value($shop->status);
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
