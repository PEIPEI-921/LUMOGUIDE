<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemCountry;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemCountryController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemCountry(), function (Grid $grid) {
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
        return Show::make($id, new SystemCountry(), function (Show $show) {
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
        return Form::make(new SystemCountry(), function (Form $form) {
            $form->display('id');
            $form->select('parent_id')->options(\App\Models\SystemCountry::selectOptions())->required();
            $form->text('name');
        });
    }
}
