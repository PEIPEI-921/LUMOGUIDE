<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemIntegralConfig;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class SystemIntegralConfigController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemIntegralConfig(), function (Grid $grid) {
            $grid->disableCreateButton();

            $grid->column('id')->sortable();
            $grid->column('name');
            $grid->column('mark');
            $grid->column('value');

            $grid->showQuickEditButton();
            $grid->disableEditButton();
            $grid->disableDeleteButton();
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
        return Show::make($id, new SystemIntegralConfig(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('mark');
            $show->field('value');
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
        return Form::make(new SystemIntegralConfig(), function (Form $form) {
            $form->text('name')->required();
            if ($form->isEditing()) {
                $form->display('mark');
            } else {
                $form->text('mark')->required();
            }
            $form->number('value')->default(0);
        });
    }
}
