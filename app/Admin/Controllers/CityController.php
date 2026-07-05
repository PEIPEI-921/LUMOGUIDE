<?php

namespace App\Admin\Controllers;

use App\Admin\Actions\Grid\AuditCity;
use App\Admin\Forms\DefaultRecommend;
use App\Admin\Repositories\City;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Dcat\Admin\Widgets\Card;
use Dcat\Admin\Widgets\Modal;
use Illuminate\Support\Facades\Cache;

class CityController extends AdminController
{

    protected function recommend_set()
    {
        return Modal::make()
            ->lg()
            ->title('经纬度默认推荐')
            ->body(DefaultRecommend::make())
            ->button("<span class='btn btn-success create-form'> 经纬度默认推荐 </span>");
    }

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        return Grid::make(new City(['guide', 'country', 'continents', 'area', 'edit_data']), function (Grid $grid) {
            $grid->tools($this->recommend_set());

            $grid->model()->orderBy('id', 'desc');

            $grid->column('guide.name', '導遊');
            $grid->column('name')->display(function ($value) {
                return "$value({$this->name_en})";
            });
            $grid->column('continents_name', '地区')->display(function ($value) {
                $country_name = $this->country->name ?? '';
                $area_name = $this->area->name ?? '';
                return "{$this->continents->name} - {$area_name} - {$country_name}";
            });
            $grid->column('is_capital')->using([0 => '否', 1 => '是'])->label();
            $grid->column('currency');
            $grid->column('language');
            $grid->column('population');
            $grid->column('race');
            $grid->column('overview')->display('查看')->expand(function () {
                $card = new Card(null, $this->overview);
                return "<div style='padding:10px 10px 0'>$card</div>";
            });
//            $grid->column('history');
            $grid->column('first_picture')->image('', 100, 100);
            $grid->column('audit_status')->using(\App\Enums\City::AuditStatus)->label([
                'default' => 'primary',
                0 => 'primary',
                1 => 'success',
                2 => 'danger',
            ]);
            $grid->column('audit_feedback');
            $grid->column('recommend')->switch()->display(function ($value) {
                return $this->audit_status == 1 ? $value : '';
            });
            $grid->column('home_recommend')->switch()->display(function ($value) {
                return $this->audit_status == 1 ? $value : '';
            });
            $grid->column('order')->editable(true)->sortable()->help('排序從大至小');
            $grid->column('updated_at')->sortable();

            $grid->disableDeleteButton();
            $grid->disableEditButton();

            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                // 存在待审核 或者初步提交
                if (($actions->row->edit_data && $actions->row->edit_data->audit_status == 0) || $actions->row->audit_status == 0) {
                    $actions->prepend(new AuditCity());
                } else {
                    if($actions->row->audit_status == 1){
                        $actions->edit();
                    }
                }
            });

//            $grid->disableDeleteButton();

            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('guide.name', '導遊名稱')->width(3);
                $filter->like('name')->width(3);
                $filter->like('name_en')->width(3);
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
        return Show::make($id, new City(), function (Show $show) {
            $show->field('id');
            $show->field('user_id');
            $show->field('guide_id');
            $show->field('name');
            $show->field('name_en');
            $show->field('continents_id');
            $show->field('area_id');
            $show->field('longitude');
            $show->field('latitude');
            $show->field('is_capital');
            $show->field('currency');
            $show->field('language');
            $show->field('population');
            $show->field('race');
            $show->field('overview');
            $show->field('history');
            $show->field('first_picture');
            $show->field('pictures');
            $show->field('audit_status');
            $show->field('audit_feedback');
            $show->field('status');
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
        return Form::make(new City(['continents', 'area']), function (Form $form) {
            $form->display('id');
            $form->text('name')->required();
            $form->text('name_en')->required();
            $form->select('continents_id')
                ->options(\App\Models\SystemContinents::options())
                ->load('area_id', '/api/getArea')
                ->required();
            $form->select('area_id')->load('country_id', '/api/getArea')->required();
            $form->select('country_id')->required();
            $form->text('location');
            $form->radio('is_capital')->options(\App\Enums\City::Capital)->required();
            $form->text('currency')->required();
            $form->text('language')->required();
            $form->text('population')->required();
            $form->text('race')->required();
            $form->textarea('overview');
            $form->textarea('history');
            $form->multipleImage('pictures')->sortable()->uniqueName()->saveFullUrl()->autoUpload()->required()
                ->maxSize(5120)
                ->compress([
                    'width' => 800,
                    'height' => 600,
                    'quality' => 90,
                    'allowMagnify' => true,
                    'crop' => true,
                    'preserveHeaders' => true,
                    'noCompressIfLarger' => false,
                    'compressSize' => 0
                ])->help('限製5M,會自動裁剪800*600');
            if ($form->isEditing()) {
                $form->radio('audit_status')->options(\App\Enums\City::AuditStatusArr)
                    ->required()
                    ->when(\App\Enums\City::AuditStatusReject, function (Form $form) {
                        $form->textarea('audit_feedback');
                    })->customFormat(function () {
                        return 1;
                    });
            }
            $form->switch('recommend');
            $form->switch('home_recommend');
            $form->number('order')->default(0);
        });
    }
}
