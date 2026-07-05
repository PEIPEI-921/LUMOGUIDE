<?php

namespace App\Admin\Controllers;

use App\Admin\Forms\AdminSet;
use App\Admin\Forms\UserIntegralSet;
use App\Admin\Forms\UserVipSet;
use App\Admin\Renderable\UserIntegralLogTable;
use App\Admin\Renderable\UserInviteLogTable;
use App\Admin\Repositories\User;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Dcat\Admin\Widgets\Card;
use Illuminate\Support\Facades\Hash;

class UserController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new User(['inviter_user']), function (Grid $grid) {
            $grid->model()->orderBy('id', 'desc');
            $grid->column('number')->sortable();
            $grid->column('avatar')->image('', 100, 100);

            $grid->column('info', '用戶信息')->display('')->expand(function () {
                $nickname = $this->inviter_user->nickname ?? '';
                $card = new Card(null, "暱稱:{$this->nickname}，郵箱:{$this->email}，邀請人:{$nickname}");
                return "<div style='padding:10px 10px 0'>$card</div>";
            });

//            $grid->column('nickname');
//            $grid->column('email');
            $grid->column('inviter_code')->copyable();
//            $grid->column('inviter_user.nickname', '邀請人');
            $grid->column('integral');
            $grid->column('identity')->using(\App\Enums\User::IdentityArr)->sortable();
            $grid->column('city_name');
            $grid->column('vip_type')->using(\App\Enums\User::VipType);
            $grid->column('vip_name');
            $grid->column('vip_expiration_time')->display(function ($value) {
                return $value == 0 ? '' : date('Y-m-d H:i:s', $value);
            });

//            $grid->column('integralSet', '积分设置')->display('设置')->modal(function (Grid\Displayers\Modal $modal) {
//                $modal->title('积分设置');
//                return UserIntegralSet::make();
//            });
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
            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                if ($actions->row->id == 1) {
                    $actions->disableEdit();
                }
            });

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('number')->width(3);
                $filter->like('nickname')->width(3);
                $filter->like('phone')->width(3);
                $filter->like('email')->width(3);
                $filter->date('birthday')->width(3);
                $filter->like('inviter_code')->width(3);
                $filter->like('inviter_user.nickname', '我的邀請人')->width(3);
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
        return Show::make($id, new User(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('email');
            $show->field('email_verified_at');
            $show->field('password');
            $show->field('remember_token');
            $show->field('avatar');
            $show->field('nickname');
            $show->field('phone');
            $show->field('birthday');
            $show->field('inviter_code');
            $show->field('integral');
            $show->field('identity');
            $show->field('continents_id');
            $show->field('area_id');
            $show->field('city');
            $show->field('city_name');
            $show->field('vip_type');
            $show->field('vip_id');
            $show->field('vip_name');
            $show->field('vip_expiration_time');
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
