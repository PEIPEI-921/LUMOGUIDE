<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\UserAddress;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class UserAddressController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new UserAddress(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('user_id');
            $grid->column('name');
            $grid->column('phone');
            $grid->column('country');
            $grid->column('country_id');
            $grid->column('city');
            $grid->column('city_id');
            $grid->column('street');
            $grid->column('post_code');
            $grid->column('default');
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();
        
            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('id');
        
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
        return Show::make($id, new UserAddress(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('name');
            $show->field('phone');
            $show->field('country');
            $show->field('country_id');
            $show->field('city');
            $show->field('city_id');
            $show->field('street');
            $show->field('post_code');
            $show->field('default');
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
        return Form::make(new UserAddress(), function (Form $form) {
            $form->display('id');
            $form->text('user_id');
            $form->text('name');
            $form->text('phone');
            $form->text('country');
            $form->text('country_id');
            $form->text('city');
            $form->text('city_id');
            $form->text('street');
            $form->text('post_code');
            $form->text('default');
        
            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
