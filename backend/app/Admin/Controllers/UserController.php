<?php

namespace App\Admin\Controllers;

use App\Admin\Forms\AdminSet;
use App\Admin\Forms\CompanyVipSet;
use App\Admin\Forms\UserVipSet;
use App\Admin\Renderable\UserIntegralLogTable;
use App\Admin\Renderable\UserInviteLogTable;
use App\Admin\Repositories\User;
use App\Models\Company;
use App\Models\Guide;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Dcat\Admin\Widgets\Card;
use Illuminate\Support\Facades\Hash;

class UserController extends AdminController
{
    protected function grid()
    {
        $tab = request()->get('tab', 'all');

        if ($tab === 'guide') {
            return $this->guideGrid();
        } elseif ($tab === 'company') {
            return $this->companyGrid();
        }

        return $this->userGrid();
    }

    // ==================== Tab: 全部用户 ====================

    protected function userGrid()
    {
        return Grid::make(new User(['inviter_user', 'guide', 'company']), function (Grid $grid) {
            $grid->model()->orderBy('id', 'desc');
            $grid->column('number')->sortable();
            $grid->column('avatar')->image('', 100, 100);

            $grid->column('info', '用戶信息')->display('')->expand(function () {
                $nickname = $this->inviter_user->nickname ?? '';
                $card = new Card(null, "暱稱:{$this->nickname}，郵箱:{$this->email}，邀請人:{$nickname}");
                return "<div style='padding:10px 10px 0'>$card</div>";
            });

            $grid->column('inviter_code')->copyable();
            $grid->column('integral');
            $grid->column('identity')->using(\App\Enums\User::IdentityArr)->sortable();
            $grid->column('city_name');

            // 导游/企业认证状态快捷列
            $grid->column('guide_status', '導遊認證')->display(function () {
                if (!$this->guide) return '';
                $map = \App\Enums\Guide::AuditStatus;
                $v = $this->guide->audit_status;
                $labels = [0 => 'warning', 1 => 'success', 2 => 'danger'];
                $label = $labels[$v] ?? 'default';
                return "<span class='label bg-{$label}'>" . ($map[$v] ?? $v) . "</span>";
            });
            $grid->column('company_status', '企業認證')->display(function () {
                if (!$this->company) return '';
                $map = \App\Enums\Company::AuditStatus;
                $v = $this->company->audit_status;
                $labels = [0 => 'warning', 1 => 'success', 2 => 'danger'];
                $label = $labels[$v] ?? 'default';
                return "<span class='label bg-{$label}'>" . ($map[$v] ?? $v) . "</span>";
            });

            $grid->column('vip_type')->using(\App\Enums\User::VipType);
            $grid->column('vip_name');
            $grid->column('vip_expiration_time')->display(function ($value) {
                return $value == 0 ? '' : date('Y-m-d H:i:s', $value);
            });

            $grid->column('props', '用户积分')->display('查看')->modal(UserIntegralLogTable::make());
            $grid->column('invite_log', '邀请记录')->display('查看')->modal(UserInviteLogTable::make());
            $grid->column('vipSet', '會員設置')->display(function ($value) {
                return $this->identity > 1 ? '设置' : '';
            })->modal(function (Grid\Displayers\Modal $modal) {
                $modal->icon('');
                $modal->title('會員設置');
                return UserVipSet::make();
            });
            $grid->column('adminSet', '管理設置')->display(function ($value) {
                return $this->identity > 1 ? '设置' : '';
            })->modal(function (Grid\Displayers\Modal $modal) {
                $modal->icon('');
                $modal->title('管理設置');
                return AdminSet::make();
            });

            $grid->column('created_at')->sortable();

            $grid->disableDeleteButton();
            $grid->actions(function (Grid\Displayers\Actions $actions) {
                if ($actions->row->id == 1) {
                    $actions->disableEdit();
                }
            });

            // Tab switcher
            $this->addTabHeader($grid, 'all');

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('number')->width(3);
                $filter->like('nickname')->width(3);
                $filter->like('phone')->width(3);
                $filter->like('email')->width(3);
                $filter->equal('identity')->select(\App\Enums\User::IdentityArr)->width(3);
                $filter->date('birthday')->width(3);
                $filter->like('inviter_code')->width(3);
                $filter->like('inviter_user.nickname', '我的邀請人')->width(3);
            });
        });
    }

    // ==================== Tab: 导游 ====================

    protected function guideGrid()
    {
        return Grid::make(new \App\Admin\Repositories\Guide(['user', 'type', 'edit_data']), function (Grid $grid) {
            $grid->setResource('guide');
            $grid->model()->orderBy('id', 'desc');
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
                'default' => 'primary', 0 => 'primary', 1 => 'success', 2 => 'danger',
            ])->sortable();
            $grid->column('audit_feedback');

            $grid->column('recommend')->switch()->display(function ($value) {
                return $this->city_id > 0 && $this->audit_status == 1 ? $value : '';
            });
            $grid->column('home_recommend')->switch()->display(function ($value) {
                return $this->city_id > 0 && $this->audit_status == 1 ? $value : '';
            });

            $grid->column('order')->editable()->sortable()->help('排序从大至小');

            $grid->column('updated_at')->sortable();

            $grid->disableCreateButton();
            $grid->disableEditButton();
            $grid->disableDeleteButton();

            $grid->actions(function (Grid\Displayers\Actions $actions) {
                $row = $actions->row;
                $able = isset($row->edit_data->id) || $row->audit_status == 0;
                if ($able) {
                    $actions->quickEdit();
                }
            });

            $this->addTabHeader($grid, 'guide');

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('user_id')->width(3);
                $filter->like('name')->width(3);
                $filter->like('phone')->width(3);
                $filter->equal('audit_status')->select(\App\Enums\Guide::AuditStatusArr)->width(3);
            });
        });
    }

    // ==================== Tab: 企业 ====================

    protected function companyGrid()
    {
        return Grid::make(new \App\Admin\Repositories\Company(['user', 'edit_data']), function (Grid $grid) {
            $grid->setResource('company');
            $grid->model()->orderBy('id', 'desc');
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
                'default' => 'primary', 0 => 'primary', 1 => 'success', 2 => 'danger',
            ])->sortable();
            $grid->column('audit_feedback');

            $grid->column('vipSet', '權益設置')->display(function ($value) {
                return $this->audit_status == 1 ? '设置' : '';
            })->modal(function (Grid\Displayers\Modal $modal) {
                $modal->icon('');
                $modal->title('權益設置');
                return CompanyVipSet::make();
            });

            $grid->column('reserve', '預約')->display('查看')->link(function () {
                return admin_url('reserve?company_id=' . $this->id);
            });

            $grid->column('created_at')->sortable();

            $grid->disableEditButton();
            $grid->disableDeleteButton();

            $grid->actions(function (Grid\Displayers\Actions $actions) {
                $row = $actions->row;
                $able = isset($row->edit_data->id) || $row->audit_status == 0;
                if ($able) {
                    $actions->quickEdit();
                }
            });

            $this->addTabHeader($grid, 'company');

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('name')->width(3);
                $filter->like('address')->width(3);
                $filter->equal('audit_status')->select(\App\Enums\Company::AuditStatusArr)->width(3);
            });
        });
    }

    // ==================== Shared Tab Header ====================

    protected function addTabHeader($grid, $active)
    {
        $tabs = [
            'all'     => '全部用户',
            'guide'   => '導遊',
            'company' => '企業',
        ];
        $html = '<div style="margin-bottom:8px;display:flex;gap:4px">';
        foreach ($tabs as $key => $label) {
            $url = admin_url('users?tab=' . $key);
            $activeClass = $key === $active ? 'background:#666FFF;color:#fff;border-color:#666FFF' : 'background:#fff;color:#666;border-color:#d9d9d9';
            $html .= '<a href="' . $url . '" style="padding:6px 16px;border-radius:20px;font-size:13px;border:1px solid;text-decoration:none;' . $activeClass . '">' . $label . '</a>';
        }
        $html .= '</div>';
        $grid->header(function () use ($html) {
            return $html;
        });
    }

    /**
     * Make a show builder.
     */
    protected function detail($id)
    {
        return Show::make($id, new User(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('email');
            $show->field('avatar');
            $show->field('nickname');
            $show->field('phone');
            $show->field('birthday');
            $show->field('inviter_code');
            $show->field('integral');
            $show->field('identity');
            $show->field('city_name');
            $show->field('vip_type');
            $show->field('vip_name');
            $show->field('vip_expiration_time');
            $show->field('created_at');
            $show->field('updated_at');
        });
    }

    /**
     * Make a form builder.
     */
    protected function form()
    {
        return Form::make(new User(), function (Form $form) {
            $form->display('id');
            $form->display('email');
            if ($form->isEditing()) {
                $form->text('password')
                    ->customFormat(function () {
                        return '';
                    })
                    ->rules("nullable|min:6|regex:/^(?=.*[A-Za-z])(?=.*\d).+$/", [
                        'min' => '密碼長度必須至少6位',
                        'regex' => '密碼必須包含字母和數字'
                    ])
                    ->help('不修改請留空');
            } else {
                $form->text('password')->required();
            }

            $form->image('avatar')->uniqueName()->saveFullUrl()->autoUpload()->required();
            $form->text('nickname');
            $form->text('phone')->required();
            $form->date('birthday')->required();
            $form->hidden('inviter_code');

            $form->saving(function (Form $form) {
                if ($form->isCreating()) {
                    $form->inviter_code = generateUniqueInviteCode();
                }

                $password = $form->input('password');
                if ($form->isEditing() && !$password) {
                    $form->deleteInput('password');
                }
                if ($password) {
                    $form->password = Hash::make($password);
                }
            });

            $form->display('created_at');
            $form->display('updated_at');
        });
    }
}
