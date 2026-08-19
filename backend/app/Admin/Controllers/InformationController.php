<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\Information;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Dcat\Admin\Widgets\Card;

class InformationController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new Information(['guide']), function (Grid $grid) {
            $grid->model()->orderBy('id', 'desc');
            $grid->disableCreateButton();
            $grid->column('id')->sortable();
            $grid->column('guide.name', '导游名称');
            $grid->column('class_id')->using(\App\Models\InformationClass::options());
            $grid->column('title');
            $grid->column('desc');
            $grid->column('content')->display('')->expand(function () {
                $card = new Card(null, $this->content);
                return "<div style='padding:10px 10px 0'>$card</div>";
            });
            $grid->column('pictures')->display(function ($value) {
                return json_decode($value, true);
            })->image('', 100, 100);
            $grid->column('look')->using(\App\Enums\Information::Look)->label();
            $grid->column('audit_status')->using(\App\Enums\Information::AuditStatus)->label([
                'default' => 'primary',
                0 => 'primary',
                1 => 'success',
                2 => 'danger',
            ]);
            $grid->column('audit_feedback');
            $grid->column('top')->switch()->display(function ($value) {
                return $this->audit_status == 1 ? $value : '';
            });
            $grid->column('top_order')->editable(true)->sortable()->help('排序從大至小');
            $grid->column('home_recommend')->switch()->display(function ($value) {
                return $this->audit_status == 1 ? $value : '';
            });
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->disableEditButton();
            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                if ($actions->row->audit_status == \App\Enums\Information::AuditStatusSubmit) {
                    $actions->quickEdit();
                }
            });

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('guide.name', '导游名称')->width(3);
                $filter->equal('title')->width(3);
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
        return Show::make($id, new Information(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('guide_id');
            $show->field('class_id');
            $show->field('title');
            $show->field('desc');
            $show->field('content');
            $show->field('picture');
            $show->field('look');
            $show->field('audit_status');
            $show->field('audit_feedback');
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
        return Form::make(new Information(['guide']), function (Form $form) {
            $form->display('id');
            $form->display('guide.name', '导游名称');
            $form->radio('class_id')->options(\App\Models\InformationClass::options())->disable();
            $form->display('title');
            $form->display('desc');
            $form->display('content');
            $form->multipleImage('pictures')->disable();
            $form->radio('look')->options(\App\Enums\Information::Look)->disable();

            $form->radio('audit_status')->options(\App\Enums\Information::AuditStatus)
                ->when(\App\Enums\Information::AuditStatusReject, function (Form $form) {
                    $form->textarea('audit_feedback');
                });
            $form->switch('top');
            $form->number('top_order')->default(0);
            $form->switch('home_recommend');
        });
    }
}
