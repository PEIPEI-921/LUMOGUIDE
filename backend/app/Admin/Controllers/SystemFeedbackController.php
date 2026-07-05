<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemFeedback;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemFeedbackController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemFeedback(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('user_id');
            $grid->column('title');
            $grid->column('content');
            $grid->column('pictures');
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
        return Show::make($id, new SystemFeedback(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('title');
            $show->field('content');
            $show->field('pictures');
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
        return Form::make(new SystemFeedback(), function (Form $form) {
            $form->display('id');
            $form->text('user_id');
            $form->text('title');
            $form->text('content');
            $form->text('pictures');
        
            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
