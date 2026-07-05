<?php

namespace App\Admin\Forms;

use App\Models\City;
use App\Models\CityContent;
use App\Models\CityTypeClass;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Redis;

class DefaultRecommend extends Form implements LazyRenderable
{
    use LazyWidget;


    /**
     * 处理表单请求.
     *
     * @param array $input
     *
     * @return mixed
     */
    public function handle(array $input)
    {
        City::query()->where('default_recommend', 1)->update(['default_recommend' => 0]);
        City::query()->where('id', $input['default_recommend'])->update(['default_recommend' => 1]);

        return $this->response()->success('设置成功');
    }

    /**
     * 构建表单.
     */
    public function form()
    {
        $city = City::with(['continents', 'area', 'country'])->where('audit_status', 1)
            ->get(['id', 'name', 'continents_id', 'area_id', 'country_id', 'default_recommend'])->toArray();

        $options[0] = "不选择";
        $default_recommend_id = 0;
        foreach ($city as $k => $v) {
            if ($v['default_recommend'] == 1) {
                $default_recommend_id = $v['id'];
            }

            $country_name = $v['country']['name'] ?? '';
            $options[$v['id']] = "{$v['name']}【{$v['continents']['name']} - {$v['area']['name']} - {$country_name}】";
        }
        $this->select('default_recommend', '默认')->options($options)->value($default_recommend_id)->required();
    }

    /**
     * 设置接口保存成功后的回调JS代码.
     *
     * 1.2秒后刷新整个页面.
     *
     * @return string|void
     */
    public function savedScript()
    {
        return <<<'JS'
    if (data.status) {
        setTimeout(function () {
          location.reload()
        }, 500);
    }
JS;
    }

    /**
     * 返回表单数据.
     *
     * @return array
     */
    public function default()
    {
//        return user_admin_config();
    }

    /**
     * 更新配置.
     *
     * @param string $key
     * @param string $value
     */
    protected function update($key, $value)
    {
//        user_admin_config([$key => $value]);
    }
}
