<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\VipCompany;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class VipCompanyController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new VipCompany(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('name');
            $grid->column('time_type')->using(\App\Enums\Vip::TimeType)->label();
            $grid->column('price');
            $grid->column('number');
            $grid->column('shop_type')->using([1 => '同类型', 2 => '多类型']);
            $grid->column('city_content_recommend');
            $grid->column('home_list_recommend');
            $grid->column('home_banner_recommend');
//            $grid->column('created_at');
//            $grid->column('updated_at')->sortable();
        });
    }

    /**
     * Make a show builder.
     *
     * @param mixed $id
     *
     * @return Show
     */
    protected function detail($id)
    {
        return Show::make($id, new VipCompany(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('time_type');
            $show->field('price');
            $show->field('number');
            $show->field('created_at');
            $show->field('updated_at');
        });
    }

    /**
     * Make a form builder.
     *
     * @return Form
     */
    protected function form()
    {
        return Form::make(new VipCompany(), function (Form $form) {
            $form->text('name')->required();
            $form->radio('time_type')->options(\App\Enums\Vip::TimeType)->default(1);
            $form->currency('price')->symbol('€');
            $form->number('number')->default(1);
            $form->radio('shop_type')->options([1 => '同类型', 2 => '多类型'])->default(1);
            $form->number('city_content_recommend')->default(1);
            $form->number('home_list_recommend')->default(1);
            $form->number('home_banner_recommend')->default(1);
        });
    }
}
