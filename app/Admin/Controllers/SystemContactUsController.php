<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemContactUs;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemContactUsController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemContactUs(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('user_id');
            $grid->column('title');
            $grid->column('email');
            $grid->column('content');
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
        return Show::make($id, new SystemContactUs(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('title');
            $show->field('email');
            $show->field('content');
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
        return Form::make(new SystemContactUs(), function (Form $form) {
            $form->display('id');
            $form->text('user_id');
            $form->text('title');
            $form->text('email');
            $form->text('content');
        
            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
