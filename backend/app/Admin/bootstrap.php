<?php

use Dcat\Admin\Admin;
use Dcat\Admin\Grid;
use Dcat\Admin\Form;
use Dcat\Admin\Grid\Filter;
use Dcat\Admin\Show;
use Dcat\Admin\Layout\Navbar;

/**
 * Dcat-admin - admin builder based on Laravel.
 * @author jqh <https://github.com/jqhph>
 *
 * Bootstraper for Admin.
 *
 * Here you can remove builtin form field:
 *
 * extend custom field:
 * Dcat\Admin\Form::extend('php', PHPEditor::class);
 * Dcat\Admin\Grid\Column::extend('php', PHPEditor::class);
 * Dcat\Admin\Grid\Filter::extend('php', PHPEditor::class);
 *
 * Or require js and css assets:
 * Admin::css('/packages/prettydocs/css/styles.css');
 * Admin::js('/packages/prettydocs/js/main.js');
 *
 */

Grid::resolving(function (Grid $grid) {
//    $grid->model()->orderBy('id', 'desc');
    $grid->disableRowSelector();
    $grid->filter(function (Grid\Filter $filter) {
        $filter->panel();
    });
    $grid->disableViewButton();
});

Form::resolving(function (Form $form) {
    $form->disableDeleteButton();
    $form->disableViewButton();
    $form->disableViewCheck();
});

Admin::style(
    <<<CSS
.sidebar .badge {
    padding: .25em .4em !important;
    font-size: 10px !important;
    top: 7px !important;
}
CSS
);

$guideCount = \App\Models\GuideEdit::query()->where('audit_status', 0)->count();

$companyCount = \App\Models\CompanyEdit::query()->where('audit_status', 0)->count();
$reserveCount = \App\Models\Reserve::query()->where('status', 1)->count();
$companyAllCount = $reserveCount + $companyCount;

$cityCount = \App\Models\City::query()->where('audit_status', 0)->count();
$cityContentCount = \App\Models\CityContent::query()->where('audit_status', 0)->count();
$cityAllCount = $cityCount+$cityContentCount;

$informationCount = \App\Models\Information::query()->where('audit_status', 0)->count();

Admin::script(
    <<<JS
$(document).ready(function() {
     const badgeData = {
        14: $guideCount,
        26: $guideCount,
        16: $companyAllCount,
        33: $reserveCount,
        34: $companyCount,
        17: $cityAllCount,
        18: $cityCount,
        21: $cityContentCount,
        22: $informationCount,
        24: $informationCount,
    };

    $('.nav-sidebar a.nav-link').each(function() {
        const link = $(this);
        const dataId = link.data('id'); // 获取当前链接的data-id

        // 如果当前data-id在配置中存在，则添加角标
        if (badgeData.hasOwnProperty(dataId)) {
            const count = badgeData[dataId];
            if(count > 0){
                const p = link.find('p'); // 找到对应的p标签

                // 避免重复添加，先移除已存在的角标
                p.find('.badge').remove();

                // 添加新角标
                p.append(`
                    <span class="badge badge-danger">`+count+`</span>
                `);
            }
        }
    });
});
JS
);

Admin::js('/vendor/echarts.min.js');

//config(['admin' => user_admin_config()]);
//config(['app.locale' => config('admin.lang') ?: config('app.locale')]);
//
//
//Admin::navbar(function (Navbar $navbar) {
//    // 切换主题
//    $navbar->right(view('admin.switch-theme', [
//        'map' => [
//            'indigo' => Dcat\Admin\Admin::color()->indigo(),
//            'blue' => '#5686d4',
//            'blue-dark' => '#5686d4',
//        ],
//    ]));
//    $method = 'right';
//
//    // ajax请求不执行
//    if (!Dcat\Admin\Support\Helper::isAjaxRequest()) {
//        $navbar->$method(App\Admin\Actions\AdminSetting::make()->render());
//    }
//});
