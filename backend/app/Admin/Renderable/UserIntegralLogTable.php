<?php

namespace App\Admin\Renderable;

use App\Admin\Repositories\UserIntegralLog;
use Dcat\Admin\Grid;
use Dcat\Admin\Grid\LazyRenderable;

class UserIntegralLogTable extends LazyRenderable
{
    public function grid(): Grid
    {
        $user_id = $this->payload['key'] ?? 0;

        return Grid::make(new UserIntegralLog(), function (Grid $grid) use ($user_id) {
            $grid->model()->where('user_id', $user_id);
            $type = \App\Enums\Integral::LogType;

            $grid->disableRowSelector();
            $grid->column('type')->using($type);
            $grid->column('title', '標題');
            $grid->column('before', '變動金額之前');
            $grid->column('amount', '變動金額');
            $grid->column('after', '變動金額之後');
            $grid->disableActions();
        });
    }
}
