<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\ContentEvaluate;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class ContentEvaluateController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new ContentEvaluate(['user', 'contents']), function (Grid $grid) {
            $grid->model()->where('content_type', 1)->orderBy('id', 'desc');
            $grid->disableCreateButton();

            $grid->column('id')->sortable();
            $grid->column('user_id');
            $grid->column('user.nickname', '評價用戶');
            $grid->column('content_name', '評價標題');
            $grid->column('content');
            $grid->column('star', '星級')->display(function ($value) {
                return $value . '星';
            });
            $grid->column('pictures')->display(function ($value) {
                return $value ? json_decode($value, true) : '';
            })->image();
            $grid->column('recommend')->switch();
            $grid->column('created_at')->sortable();

            $grid->disableEditButton();

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('content_id')->width(3);
                $filter->like('content')->width(3);
                $filter->equal('user_id')->width(3);
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
        return Show::make($id, new ContentEvaluate(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('user_type');
            $show->field('content_type');
            $show->field('content_id');
            $show->field('content_name');
            $show->field('content_user_id');
            $show->field('content');
            $show->field('pictures');
            $show->field('star');
            $show->field('recommend');
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
        return Form::make(new ContentEvaluate(), function (Form $form) {
            $form->display('id');
            $form->text('user_id');
            $form->text('user_type');
            $form->text('content_type');
            $form->text('content_id');
            $form->text('content_name');
            $form->text('content_user_id');
            $form->text('content');
            $form->text('pictures');
            $form->text('star');
            $form->switch('recommend');

            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
