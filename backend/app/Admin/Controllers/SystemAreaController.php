<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemArea;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemAreaController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemArea(), function (Grid $grid) {
//            $grid->column('id')->sortable();
            $grid->id('ID')->bold()->sortable();
//            $grid->column('pid');
            $grid->column('name')->tree();
            $grid->column('order')->orderable();
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->disableEditButton();
            $grid->enableDialogCreate();
            $grid->showQuickEditButton();
            $grid->disableBatchDelete();

//            $grid->filter(function (Grid\Filter $filter) {
//                $filter->equal('id');
//
//            });
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
        return Show::make($id, new SystemArea(), function (Show $show) {
            $show->field('id');
            $show->field('parent_id');
            $show->field('name');
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
        return Form::make(new SystemArea(), function (Form $form) {
            $form->display('id');
            $form->select('parent_id')->options(\App\Models\SystemArea::selectOptions())->required();
            $form->text('name');

//            $form->display('created_at');
//            $form->display('updated_at');
        });
    }
}
