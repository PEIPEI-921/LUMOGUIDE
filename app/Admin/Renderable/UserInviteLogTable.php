<?php

namespace App\Admin\Renderable;

use App\Admin\Repositories\UserIntegralLog;
use App\Admin\Repositories\UserInviteLog;
use Dcat\Admin\Grid;
use Dcat\Admin\Grid\LazyRenderable;

class UserInviteLogTable extends LazyRenderable
{
    public function grid(): Grid
    {
        $user_id = $this->payload['key'] ?? 0;

        return Grid::make(new UserInviteLog(['invitees']), function (Grid $grid) use ($user_id) {
            $grid->model()->where('user_id', $user_id);
            $grid->disableRowSelector();
            $grid->column('invitees.nickname', '被邀請人');
            $grid->column('invitees.email', '被邀請人郵箱');
            $grid->column('invitees.number', '被邀請人編號');
            $grid->disableActions();
        });
    }
}
