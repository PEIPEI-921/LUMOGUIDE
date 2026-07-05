<?php

namespace App\Admin\Forms;

use App\Models\CityContent;
use App\Models\CityTypeClass;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Redis;

class HomeRecommend extends Form implements LazyRenderable
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
        foreach ($input as $key => $value) {
            Redis::hSet('home_recommend', $key, $value);
        }
        return $this->response()->success('设置成功');
    }

    /**
     * 构建表单.
     */
    public function form()
    {
        $type_class_id = CityContent::query()->where('audit_status', 1)
            ->where(function ($query) {
                $query->where('home_recommend', 1)->orWhere('banner_recommend', 1);
            })->pluck('type_class_id')->toArray();
        $type_class_id = array_unique($type_class_id);

        $data = CityTypeClass::query()->whereIn('id', $type_class_id)->pluck('name', 'id')->toArray();

        $cache = Redis::hGetAll('home_recommend');

        foreach ($data as $k => $v) {
            if (isset($cache[$k])) {
                $value = $cache[$k];
            } else {
                $value = 0;
            }
            $this->number($k, $v)->value($value);
        }

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
