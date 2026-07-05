<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\VipGuide;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class VipGuideController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new VipGuide(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('name');
            $grid->column('time_type')->using(\App\Enums\Vip::TimeType)->label();
            $grid->column('buy_type')->using(\App\Enums\Vip::BuyType)->label();
            $grid->column('price');
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->disableEditButton();
            $grid->showQuickEditButton();
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
        return Show::make($id, new VipGuide(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('time_type');
            $show->field('buy_type');
            $show->field('price');
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
        return Form::make(new VipGuide(), function (Form $form) {
            $form->text('name')->required();
            $form->radio('time_type')->options(\App\Enums\Vip::TimeType)->default(1);
            $form->radio('buy_type')->options(\App\Enums\Vip::BuyType)->default(1);
            $form->currency('price');
        });
    }
}
