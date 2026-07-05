<?php

namespace App\Admin\Renderable;

use App\Admin\Repositories\ContentEvaluate;
use Dcat\Admin\Grid;
use Dcat\Admin\Grid\LazyRenderable;

class ContentEvaluateTable extends LazyRenderable
{
    public function grid(): Grid
    {
        $content_id = $this->payload['key'] ?? 0;

        return Grid::make(new ContentEvaluate(['user', 'contents']), function (Grid $grid) use ($content_id) {
            $grid->model()->where('content_id', $content_id)->where('content_type', 1);

            $grid->disableRowSelector();
            $grid->column('user.nickname', '评价用户');
            $grid->column('content_name', '评价标题');
            $grid->column('content', '评价内容');
            $grid->column('star', '星级')->display(function ($value) {
                return $value . '星';
            });
            $grid->column('pictures')->display(function ($value) {
                return $value ? json_decode($value, true) : '';
            })->image();
            $grid->column('created_at');
            $grid->disableEditButton();
//            $grid->disableActions();
        });
    }
}
