<?php

namespace App\Admin\Controllers;

use App\Admin\Forms\CompanyVipSet;
use App\Admin\Repositories\Company;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class CompanyController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new Company(['user', 'edit_data']), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('user.number', '用戶ID');
            $grid->column('name');
            $grid->column('name_en');
            $grid->column('city_name');
            $grid->column('address');
            $grid->column('business_type');
            $grid->column('email');
            $grid->column('phone');
            $grid->column('website');
            $grid->column('documents_picture')->image('', 100, 100);
            $grid->column('audit_status')->using(\App\Enums\Company::AuditStatus)->label([
                'default' => 'primary',
                0 => 'primary',
                1 => 'success',
                2 => 'danger',
            ])->sortable();
            $grid->column('audit_feedback');

            $grid->column('vipSet', '权益設置')->display(function ($value) {
                return $this->audit_status == 1 ? '设置' : '';
            })->modal(function (Grid\Displayers\Modal $modal) {
                $modal->icon('');
                $modal->title('权益設置');
                return CompanyVipSet::make();
            });

            $grid->column('reserve', '预约')->display(function () {
                return '查看';
            })->link(function () {
                return admin_url('reserve?company_id=' . $this->id);
            });
            $grid->column('created_at')->sortable();

            $grid->disableEditButton();
            $grid->disableDeleteButton();
            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                if ($actions->row->edit_data || $actions->row->audit_status == 0) {
                    $actions->quickEdit();
                }
            });

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('name')->width(3);
                $filter->like('address')->width(3);

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
        return Show::make($id, new Company(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('name');
            $show->field('city_id');
            $show->field('city_name');
            $show->field('address');
            $show->field('tax_id');
            $show->field('business_type');
            $show->field('introduction');
            $show->field('email');
            $show->field('phone');
            $show->field('website');
            $show->field('other_contact');
            $show->field('documents_picture');
            $show->field('picture');
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
        return Form::make(new Company(), function (Form $form) {
            $form->display('name');
            $form->display('name_en');
            $form->display('city_name');
            $form->display('address');
            $form->display('tax_id');
            $form->display('business_type');
            $form->display('introduction');
            $form->display('email');
            $form->display('phone');
            $form->display('website');
            $form->display('other_contact');
            $form->display('wechat');
            $form->display('whats_app');
            $form->display('line');
            $form->image('documents_picture')->disable();
            $form->multipleImage('picture')->disable();
            $form->radio('audit_status')->options(\App\Enums\Company::AuditStatus)
                ->when(\App\Enums\Company::StatusReject, function (Form $form) {
                    $form->textarea('audit_feedback');
                })->customFormat(function () {
                    return 1;
                })->required();
//            $form->switch('recommend');
        });
    }
}
