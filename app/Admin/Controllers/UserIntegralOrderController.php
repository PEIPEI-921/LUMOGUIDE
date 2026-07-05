<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\UserIntegralOrder;
use App\Admin\RowActions\ReturnOrder;
use App\Enums\Integral;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class UserIntegralOrderController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new UserIntegralOrder(['user', 'user_address']), function (Grid $grid) {
            $grid->model()->orderBy('id', 'desc');
            $grid->disableCreateButton();

            $grid->column('id')->sortable();
            $grid->column('order_sn');
            $grid->column('user.nickname', '用户昵称');
            $grid->column('user_address.name', '收货人');
            $grid->column('user_address.phone', '收货人电话');
            $grid->column('integral_goods_info_name', '商品名称')->display(function () {
                $info = json_decode($this->integral_goods_info, true);
                return $info['name'];
            });
            $grid->column('integral_goods_info_image', '商品图片')->display(function () {
                $info = json_decode($this->integral_goods_info, true);
                return $info['picture'];
            })->image('', 100, 100);

            $grid->column('price');
            $grid->column('free_shipping')->using(Integral::FreeShipping)->label();
            $grid->column('pay_time');
            $grid->column('status')->using(Integral::OrderStatus)->label();
            $grid->column('express_delivery_company');
            $grid->column('express_delivery_number');
            $grid->column('created_at');

            $grid->disableEditButton();
            $grid->disableDeleteButton();
            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                if ($actions->row->status == Integral::StatusOne) {
                    $actions->quickEdit();
                }
                if ($actions->row->status == Integral::StatusTwo) {
                    $actions->append(new ReturnOrder('<i class="feather icon-check"></i>&nbsp;退款'));
                }
            });

            $grid->filter(function (Grid\Filter $filter) {
//                $filter->equal('id');
                $filter->equal('user.nickname', '用户昵称')->width(3);
                $filter->equal('user_address.name', '收货人')->width(3);
                $filter->equal('user_address.phone', '收货人电话')->width(3);
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
        return Show::make($id, new UserIntegralOrder(), function (Show $show) {
            $show->field('id');
            $show->field('order_sn');
            $show->field('user_id');
            $show->field('user_address_id');
            $show->field('integral_goods_id');
            $show->field('integral_goods_info');
            $show->field('price');
            $show->field('free_shipping');
            $show->field('pay_time');
            $show->field('status');
            $show->field('express_delivery_company');
            $show->field('express_delivery_number');
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
        return Form::make(new UserIntegralOrder(['user_address']), function (Form $form) {
            $form->display('id');
            $form->display('order_sn');
            $form->display('user_address.name', '收货姓名');
            $form->display('user_address.phone', '聯繫電話');
            $form->textarea('user_address.address','收货地址')->disable();
            $form->display('user_address.post_code','郵編');
//            $form->text('user_id');
//            $form->text('user_address_id');
//            $form->text('integral_goods_id');
//            $form->text('integral_goods_info');
//            $form->text('price');
//            $form->text('free_shipping');
//            $form->text('pay_time');
            $form->hidden('status');
            $form->text('express_delivery_company');
            $form->text('express_delivery_number');

//            $form->display('created_at');
//            $form->display('updated_at');
        });
    }
}
