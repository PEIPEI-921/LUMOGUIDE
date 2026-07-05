<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\GuideType;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class GuideTypeController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new GuideType(), function (Grid $grid) {
            $grid->model()->orderBy('order');
            $grid->column('id')->sortable();
            $grid->column('name');
            $grid->column('order')->orderable();
            $grid->column('updated_at')->sortable();
            $grid->showQuickEditButton();
            $grid->disableEditButton();
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
        return Show::make($id, new GuideType(), function (Show $show) {
            $show->field('id');
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
        return Form::make(new GuideType(), function (Form $form) {
            $form->text('name')->required();
        });
    }
}
