<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\Guide;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class GuideController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new Guide(['type', 'user', 'edit_data']), function (Grid $grid) {
            $grid->disableCreateButton();

            $grid->column('id')->sortable();
            $grid->column('user.number', '用戶ID');
            $grid->column('name');
            $grid->column('name_en');
            $grid->column('city_name');
            $grid->column('phone');
            $grid->column('email');
            $grid->column('photo')->image('', 100, 100);
            $grid->column('year');
            $grid->column('industry_type')->label();
            $grid->column('type.name', '展示身份類型')->label();
            $grid->column('audit_status')->using(\App\Enums\Guide::AuditStatus)->label([
                'default' => 'primary',
                0 => 'primary',
                1 => 'success',
                2 => 'danger',
            ])->sortable();
            $grid->column('audit_feedback');
            $grid->column('recommend')->switch()->display(function ($value) {
                return $this->city_id > 0 && $this->audit_status == 1 ? $value : '';
            });
            $grid->column('home_recommend')->switch()->display(function ($value) {
                return $this->city_id > 0 && $this->audit_status == 1 ? $value : '';
            });
            $grid->column('order')->editable(true)->sortable()->help('排序从大至小');
//            $grid->column('edit', '修改')->display(function () {
//                return $this->edit_data ? '需审核' : '';
//            })->label();
            $grid->column('updated_at')->sortable();

//            $grid->showQuickEditButton();
            $grid->disableEditButton();
            $grid->disableDeleteButton();

            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                if ($actions->row->edit_data || $actions->row->audit_status == 0) {
                    $actions->quickEdit();
                }
            });

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('user_id')->width(3);
                $filter->like('name')->width(3);
                $filter->like('phone')->width(3);
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
        return Show::make($id, new Guide(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('city_id');
            $show->field('photo');
            $show->field('name');
            $show->field('phone');
            $show->field('email');
            $show->field('bill_address');
            $show->field('other_contact');
            $show->field('language');
            $show->field('year');
            $show->field('inviter_ucode');
            $show->field('inviter_uid');
            $show->field('industry_type');
            $show->field('identity_type');
            $show->field('introduction');
            $show->field('business_contact');
            $show->field('have_vehicle');
            $show->field('vehicle_info');
            $show->field('vehicle_rent');
            $show->field('certificate_picture');
            $show->field('passport_picture');
            $show->field('driver_license_front');
            $show->field('driver_license_back');
            $show->field('car_pictures');
            $show->field('audit_status');
            $show->field('audit_feedback');
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
        return Form::make(new Guide(), function (Form $form) {
//            $form->display('id');
//            $form->text('user_id');
//            $form->text('city_id');
            $form->image('photo')->disable();
            $form->display('name');
            $form->display('name_en');
            $form->display('phone');
            $form->display('email');
            $form->display('bill_address');
            $form->display('other_contact');
            $form->display('wechat');
            $form->display('whats_app');
            $form->display('line');
            $form->tags('language')->disable();
            $form->display('year');
            $form->tags('industry_type')->disable();
            $form->display('type.name', '展示身份類型')->disable();
            $form->textarea('introduction')->disable();
            $form->display('business_contact');
            $form->radio('have_vehicle')->options(\App\Enums\Guide::HaveVehicle)->disable();
            $form->display('vehicle_info');
            $form->radio('vehicle_rent')->options(\App\Enums\Guide::VehicleRent)->disable();
            $form->image('certificate_picture')->disable();
            $form->image('passport_picture')->disable();
            $form->image('driver_license_front')->disable();
            $form->image('driver_license_back')->disable();
            $form->multipleImage('car_pictures')->disable();
            $form->radio('audit_status')->options(\App\Enums\Guide::AuditStatusArr)
                ->when(\App\Enums\Guide::StatusReject, function (Form $form) {
                    $form->textarea('audit_feedback');
                })->customFormat(function (){
                    return 1;
                })->required();
//            $form->switch('recommend');
//            $form->switch('home_recommend');

//            $form->display('created_at');
//            $form->display('updated_at');
        });
    }
}
