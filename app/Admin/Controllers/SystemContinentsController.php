<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemContinents;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemContinentsController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemContinents(), function (Grid $grid) {
            $grid->id('ID')->bold()->sortable();
            $grid->column('name')->tree();
            $grid->column('order')->orderable();
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->disableEditButton();
            $grid->enableDialogCreate();
            $grid->showQuickEditButton();
            $grid->disableBatchDelete();
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
        return Show::make($id, new SystemContinents(), function (Show $show) {
            $show->field('id');
            $show->field('parent_id');
            $show->field('name');
            $show->field('order');
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
        return Form::make(new SystemContinents(), function (Form $form) {
            $form->display('id');
            $form->select('parent_id')->options(\App\Models\SystemContinents::selectOptions())->value(0)->required();
            $form->text('name');
        });
    }
}
