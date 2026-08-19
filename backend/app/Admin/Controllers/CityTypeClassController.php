<?php

namespace App\Admin\Controllers;

use Dcat\Admin\Layout\Content;
use Dcat\Admin\Layout\Row;
use App\Admin\Repositories\CityTypeClass;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Widgets\Tab;
use Dcat\Admin\Http\Controllers\AdminController;

class CityTypeClassController extends AdminController
{

    public function index(Content $content)
    {
        return $content->header('類型分類')
            ->body(function (Row $row) {
                $tab = new Tab();
                $type_id = request()->get('type_id') ?? 1;
                foreach (\App\Models\CityType::options() as $k => $v) {
                    if ($type_id == $k) {
                        $tab->add($v, $this->grid($k), true);
                    } else {
                        $tab->addLink($v, request()->fullUrlWithQuery(['type_id' => $k]));
                    }
                }

                $row->column(12, $tab->withCard());
            });
    }


    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid(int $type_id)
    {
        return Grid::make(new CityTypeClass(), function (Grid $grid) use ($type_id) {
            $grid->model()->where('type_id', $type_id)->orderBy('order');
            $grid->column('id')->sortable();
//            $grid->column('type_id')->using(\App\Models\CityType::options());
            $grid->column('name');
            $grid->column('order')->orderable();
            $grid->column('updated_at')->sortable();

            $grid->showQuickEditButton();
            $grid->disableEditButton();

//            $grid->selector(function (Grid\Tools\Selector $selector) {
//                $selector->select('type_id', \App\Models\CityType::options());
//            });

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('name')->width(3);
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
        return Show::make($id, new CityTypeClass(), function (Show $show) {
            $show->field('id');
            $show->field('type_id');
            $show->field('name');
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
        return Form::make(new CityTypeClass(), function (Form $form) {
            $form->radio('type_id')->options(\App\Models\CityType::options())->default(1);
            $form->text('name')->required();

            $form->saved(function (Form $form) {
                return $form->response()->success('保存成功')->redirect('cityTypeClass?type_id=' . $form->type_id);
            });

        });
    }
}
