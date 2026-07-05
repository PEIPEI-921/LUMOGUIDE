<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\CityType;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class CityTypeController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new CityType(), function (Grid $grid) {
            $grid->disableCreateButton();

            $grid->column('id')->sortable();
            $grid->column('icon')->image('', 50, 50);
            $grid->column('name');
            $grid->column('key');
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->showQuickEditButton();
            $grid->disableEditButton();
            $grid->disableDeleteButton();

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
        return Show::make($id, new CityType(), function (Show $show) {
            $show->field('id');
            $show->field('icon');
            $show->field('name');
            $show->field('key');
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
        return Form::make(new CityType(), function (Form $form) {
            $form->image('icon')->uniqueName()->saveFullUrl()->autoUpload()->required();
            $form->text('name')->required();
            $form->text('key');
        });
    }
}
