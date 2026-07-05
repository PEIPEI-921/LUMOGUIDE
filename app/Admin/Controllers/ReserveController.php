<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\Reserve;
use App\Models\CityType;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class ReserveController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $city_type = CityType::options();

        return Grid::make(new Reserve(['user', 'content', 'company', 'city']), function (Grid $grid) use ($city_type) {
            $grid->disableCreateButton();
            $grid->model()->orderBy('id', 'desc');
            $grid->column('id')->sortable();
            $grid->column('user.number', '預約用戶');
            $grid->column('company.name', '預約企業')->display(function ($value) {
                return $this->company_id == 0 ? '管理' : $value;
            });
            $grid->column('city.name', '預約城市');
            $grid->column('content_type')->using($city_type)->label();
            $grid->column('content.name', '預約名稱');
            $grid->column('contact');
            $grid->column('email');
            $grid->column('phone');
            $grid->column('other');
            $grid->column('status')->using(\App\Enums\Reserve::Status)->label([
                'default' => 'primary',
                1 => 'info',
                2 => 'success',
                3 => 'danger',
                4 => 'danger',
            ])->sortable();
            $grid->column('created_at');

            $grid->disableDeleteButton();
            $grid->disableEditButton();
            $grid->showQuickEditButton();

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('user.number', '預約用戶')->width(3);
                $filter->equal('company_id')->width(3);
                $filter->equal('city.name', '預約城市')->width(3);
                $filter->equal('status')->select(\App\Enums\Reserve::Status)->width(3);
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
        return Show::make($id, new Reserve(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('company_id');
            $show->field('city_id');
            $show->field('content_type');
            $show->field('content_id');
            $show->field('tickets_type');
            $show->field('arrival_time');
            $show->field('leave_time');
            $show->field('number');
            $show->field('room_number');
            $show->field('remark');
            $show->field('file');
            $show->field('contact');
            $show->field('email');
            $show->field('phone');
            $show->field('other');
            $show->field('status');
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
        $city_type = CityType::options();

        return Form::make(new Reserve(['user', 'content', 'company', 'city']), function (Form $form) use ($city_type) {
            $company_name = $form->model()->company->name ?? '管理';

            $form->display('user.number', '預約用戶');
            $form->display('company.name', '預約企業')->value($company_name);
            $form->radio('content_type')->options($city_type)->disable();
            $form->display('content.name', '預約名稱');

            $type = $form->model()->content_type;

            switch ($type) {
                case 1:
                    $form->display('arrival_time');
                    $form->display('number');
                    $form->display('tickets_type');
                    $form->display('remark');
                    break;
                case 2:
                    $form->display('arrival_time');
                    $form->display('number');
                    $form->display('remark');
                    break;
                case 3:
                    $form->display('arrival_time');
                    $form->display('number');
                    $form->display('remark');
                    $form->textarea('file')->disable();
                    break;
                case 4:
                    $form->display('arrival_time');
                    $form->text('leave_time');
                    $form->display('number');
                    $form->text('room_number');
                    $form->display('remark');
                    break;
                case 8:
                    $form->display('number');
                    $form->display('remark');
                    break;
            }

            $form->display('contact');
            $form->display('email');
            $form->display('phone');
            $form->display('other');
            $form->radio('status')->options(\App\Enums\Reserve::Status);
        });
    }
}
