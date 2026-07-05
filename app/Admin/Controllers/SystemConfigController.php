<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\SystemConfig;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Illuminate\Support\Facades\Redis;

class SystemConfigController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new SystemConfig(), function (Grid $grid) {
            $grid->column('id')->sortable();
            $grid->column('name');
            $grid->column('mark');

            $grid->column('value')->display(function ($title) {
                switch ($this->type) {
                    case 3:
                        return '<img data-action="preview-img" src="' . $title . '" style="max-width:70px;max-height:70px;cursor:pointer" class="img img-thumbnail">';
                    case 2:
                        return '<span style="color: red;">编辑查询详情</span>';
                    case 5:
                        return implode('，', json_decode($title));
                    default:
                        return $title;
                }
            });

            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->disableDeleteButton();
            $grid->disableBatchDelete();

//            $grid->filter(function (Grid\Filter $filter) {
//                $filter->equal('id');
//            });
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
        return Show::make($id, new SystemConfig(), function (Show $show) {
            $show->field('id');
            $show->field('name');
            $show->field('mark');
            $show->field('value');
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
        return Form::make(new SystemConfig(), function (Form $form) {
            $form->display('id');

            $form->text('name')->required();
            $form->text('mark')->required();

            $form->radio('type')
                ->required()
                ->options([1 => '文字', 2 => '富文本', 3 => '图片', 4 => '大段文本', 5 => '列表', 6 => '文件'])
                ->when(1, function (Form $form) {
                    $form->text('value1', '文字');
                })
                ->when(2, function (Form $form) {
                    $form->editor('value2', '富文本');
                })
                ->when(3, function (Form $form) {
                    $form->image('value3', '图片')->uniqueName()->saveFullUrl()->autoUpload();
                })
                ->when(4, function (Form $form) {
                    $form->textarea('value4', '大段文本');
                })
                ->when(5, function (Form $form) {
                    $form->list('value5', '列表');
                })
                ->when(6, function (Form $form) {
                    $form->file('value6', '文件');
                })
                ->default(1);
            $form->hidden('value');

            $form->saving(function (Form $form) {
                switch ($form->type) {
                    case 1:
                        $form->value = $form->value1;
                        break;
                    case 2:
                        $form->value = $form->value2;
                        break;
                    case 3:
                        $form->value = $form->value3;
                        break;
                    case 4:
                        $form->value = $form->value4;
                        break;
                    case 5:
                        $values = $form->value5['values'];
                        $arr = [];
                        foreach ($values as $value) {
                            if ($value) {
                                $arr[] = $value;
                            }
                        }
                        $form->value = json_encode($arr, true);
                        break;
                    case 6:
                        $form->value = $form->value6;
                        break;
                }
                $form->deleteInput(['value1', 'value2', 'value3', 'value4', 'value5', 'value6']);
            });
            $form->saved(function (Form $form) {
                Redis::hSet('system_config', $form->mark, $form->value);
            });
            $form->disableDeleteButton();
            $form->disableViewButton();
            $form->disableEditingCheck();
            $form->disableCreatingCheck();
        });
    }
}
