<?php

namespace App\Admin\Controllers;

use App\Admin\Repositories\IntegralGoods;
use App\Enums\Integral;
use App\Models\IntegralGoodsClass;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;

class IntegralGoodsController extends AdminController
{
    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $class = IntegralGoodsClass::getOptions();

        return Grid::make(new IntegralGoods(), function (Grid $grid) use ($class) {
            $grid->model()->orderBy('id', 'desc');

            $grid->column('id')->sortable();
            $grid->column('class_id')->using($class)->label();
            $grid->column('picture')->image('', 100, 100);
            $grid->column('pictures')->display(function ($value) {
                return json_decode($value, true);
            })->image('', 100, 100);
            $grid->column('name');
            $grid->column('goods_type')->using(Integral::GoodsType)->label();
            $grid->column('price');
            $grid->column('free_shipping')->display(function ($value) {
                return $this->goods_type == 1 ? $value : '';
            })->using(Integral::FreeShipping)->label();
            $grid->column('sales');
            $grid->column('recommend')->switch(true);
            $grid->column('order')->editable(true)->sortable()->help('排序从大至小');
            $grid->column('stock')->editable(true);
            $grid->column('status')->switch(true);

//            $grid->column('content');
            $grid->column('created_at');
            $grid->column('updated_at')->sortable();

            $grid->filter(function (Grid\Filter $filter) {
                $filter->equal('id');

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
        return Show::make($id, new IntegralGoods(), function (Show $show) {
            $show->field('id');
            $show->field('class_id');
            $show->field('picture');
            $show->field('pictures');
            $show->field('name');
            $show->field('price');
            $show->field('free_shipping');
            $show->field('sales');
            $show->field('content');
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
        return Form::make(new IntegralGoods(), function (Form $form) {
            $form->radio('class_id')->options(IntegralGoodsClass::getOptions())->required();
            $form->multipleImage('pictures')->sortable()->uniqueName()->saveFullUrl()->autoUpload()->required()
                ->compress([
                    'width' => 600,
                    'height' => 600,
                    'quality' => 90,
                    'allowMagnify' => true,
                    'crop' => true,
                    'preserveHeaders' => true,
                    'noCompressIfLarger' => false,
                    'compressSize' => 0
                ])->help('限製5M,會自動裁剪600*600');;
            $form->text('name')->required();
            $form->radio('goods_type')->options(Integral::GoodsType)->default(1)->required()
                ->when(1, function (Form $form) {
                    $form->radio('free_shipping')->options(Integral::FreeShipping)->default(1);
                });
            $form->number('price')->required()->default(100);
            $form->number('sales')->default(1);
            $form->number('stock')->default(1);
            $form->editor('content');
            $form->switch('recommend');
            $form->switch('status')->default(1);
        });
    }
}
