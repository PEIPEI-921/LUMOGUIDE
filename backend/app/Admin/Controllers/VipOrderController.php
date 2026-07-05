<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\VipOrder;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class VipOrderController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new VipOrder(['guide_vip', 'company_vip']), function (Grid $grid) {
            $grid->disableCreateButton();
            $grid->model()->where('pay_status', \App\Enums\Vip::PayStatusPay)->orderBy('id', 'desc');

            $grid->column('id')->sortable();
            $grid->column('order_sn');
            $grid->column('user_id');
            $grid->column('vip_type')->using(\App\Enums\Vip::VipOrderType);
            $grid->column('vip_name', '购买会员')->display(function () {
                if ($this->vip_type == \App\Enums\Vip::OrderVipTypeGuide) {
                    return $this->guide_vip->name;
                } else {
                    return $this->company_vip->name;
                }
            });
            $grid->column('price');
            $grid->column('time_type')->using(\App\Enums\Vip::TimeType)->label();
            $grid->column('buy_type')->using(\App\Enums\Vip::BuyType)->label();
            $grid->column('pay_time')->display(function ($value) {
                return $value ? date('Y-m-d H:i:s', $value) : '';
            });
            $grid->column('pay_status')->using(\App\Enums\Vip::PayStatusArr)->label();
            $grid->column('created_at');

            $grid->disableActions();

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('order_sn')->width(3);
                $filter->equal('user_id')->width(3);
            });
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
        return Show::make($id, new VipOrder(), function (Show $show) {
            $show->field('id');
            $show->field('order_sn');
            $show->field('user_id');
            $show->field('vip_type');
            $show->field('vip_id');
            $show->field('price');
            $show->field('time_type');
            $show->field('buy_type');
            $show->field('pay_time');
            $show->field('pay_status');
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
        return Form::make(new VipOrder(), function (Form $form) {
            $form->display('id');
            $form->text('order_sn');
            $form->text('user_id');
            $form->text('vip_type');
            $form->text('vip_id');
            $form->text('price');
            $form->text('time_type');
            $form->text('buy_type');
            $form->text('pay_time');
            $form->text('pay_status');

            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
