<?php

namespace App\Admin\Controllers;

use App\Admin\Forms\CityContentRecommendSet;
use App\Admin\Forms\HomeRecommend;
use App\Admin\Renderable\ContentEvaluateTable;
use App\Admin\Repositories\CityContent;
use App\Models\City;
use Dcat\Admin\Admin;
use Dcat\Admin\Form;
use Dcat\Admin\Grid;
use Dcat\Admin\Layout\Content;
use Dcat\Admin\Layout\Row;
use Dcat\Admin\Show;
use Dcat\Admin\Http\Controllers\AdminController;
use Dcat\Admin\Widgets\Tab;
use App\Admin\Actions\Grid\AuditCityContent;
use Dcat\Admin\Widgets\Modal;

class CityContentController extends AdminController
{

    public function index(Content $content)
    {
        return $content->header('城市內容')
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
     * 首页推荐
     * @return Modal
     */
    protected function recommend_set()
    {
        return Modal::make()
            ->lg()
            ->title('首頁推薦排序(排序从大到小)')
            ->body(HomeRecommend::make())
            ->button("<span class='btn btn-success create-form'> 首頁推薦排序 </span>");
    }

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid(int $type_id)
    {
        $city_id = Admin::user()->city_id;

        return Grid::make(new CityContent(['user', 'city', 'type_class', 'edit_data']), function (Grid $grid) use ($type_id, $city_id) {
            $grid->tools($this->recommend_set());

            $grid->model()->setConstraints([
                'type_id' => $type_id,
            ]);

            $where['type_id'] = $type_id;
            if ($city_id > 0) {
                $where['city_id'] = $city_id;
            }

            $grid->model()->where($where)->orderBy('id', 'desc');
//            $grid->column('id')->sortable();
            $grid->column('city.name', '發布城市');
            $grid->column('user.number', '發布者編號')->display(function ($value) {
                return $this->user_id == 0 ? 'admin' : $value;
            });
//            $grid->column('type_id')->using(\App\Models\CityType::options());
            $grid->column('type_class.name', '分類名稱');
            $grid->column('name');
//            $grid->column('address');
            $grid->column('address')->limit(50);
            $grid->column('first_picture')->image('', 50, 50);
            $grid->column('audit_status')->using(\App\Enums\City::AuditStatus)->label([
                'default' => 'primary',
                0 => 'primary',
                1 => 'success',
                2 => 'danger',
            ])->sortable();
            $grid->column('audit_feedback');

            $grid->column('recommend', '推荐设置')->display(function () {
                return $this->audit_status == 1 ? '设置' : '';
            })->modal(function (Grid\Displayers\Modal $modal) {
                $modal->title("设置【{$this->name}】推荐");
                $modal->icon('');
                return CityContentRecommendSet::make();
            });

//            $grid->column('recommend')->switch('', true)->display(function ($value) {
//                return $this->audit_status == 1 ? $value : '';
//            });
//            $grid->column('banner_recommend')->switch('', true)->display(function ($value) {
//                return $this->audit_status == 1 ? $value : '';
//            });
//            $grid->column('home_recommend')->switch('', true)->display(function ($value) {
//                return $this->audit_status == 1 ? $value : '';
//            });
            $grid->column('order')->editable(true)->sortable()->help('排序從大至小');
            $grid->column('created_at');
//            $grid->column('updated_at')->sortable();

            $grid->disableDeleteButton();
            $grid->disableEditButton();

            $grid->actions(function (Grid\Displayers\Actions $actions) use ($grid) {
                // 存在待审核 或者初步提交
                if (($actions->row->edit_data && $actions->row->edit_data->audit_status == 0) || $actions->row->audit_status == 0) {
                    $actions->prepend(new AuditCityContent());
                } else {
                    if($actions->row->audit_status == 1){
                        $actions->edit();
                    }
                }
            });


            $grid->filter(function (Grid\Filter $filter) {
                $filter->like('name')->width(3);
                $filter->like('city.name', '發布城市')->width(3);
                $filter->like('type_class.name', '分類名稱')->width(3);
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
        return Show::make($id, new CityContent(), function (Show $show) {
            $show->field('id');
            $show->field('city_id');
            $show->field('type_id');
            $show->field('type_class_id');
            $show->field('user_id');
            $show->field('publisher_id');
            $show->field('publisher_type');
            $show->field('name');
            $show->field('start_time');
            $show->field('end_time');
            $show->field('tickets_free');
            $show->field('capacity');
            $show->field('order_food');
            $show->field('price');
            $show->field('phone');
            $show->field('email');
            $show->field('website');
            $show->field('address');
            $show->field('longitude');
            $show->field('latitude');
            $show->field('how_arrive');
            $show->field('introduce');
            $show->field('first_picture');
            $show->field('pictures');
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
        $type_id = request()->get('type_id') ?? 1;

        return Form::make(new CityContent(['user', 'city', 'type_class']), function (Form $form) use ($type_id) {
            if ($form->isEditing()) {
                $form->display('user.number', '發布者編號');
                $form->radio('publisher_type', '發布人類型')->options(['admin' => '管理', 'company' => '企业', 'guide' => '导游'])->disable();
                $type_id = $form->model()->type_id;
            }

            $form->select('city_id')->options(City::options())->required();
            $form->select('type_id')
                ->value($type_id)
                ->options(\App\Models\CityType::options())->load('type_class_id', '/api/getTypeClass')->disable();
            $form->select('type_class_id');

            $form->text('name')->required();

            switch ($type_id) {
                case 1:
                    $form->text('start_time');
                    $form->radio('tickets_free')->options(\App\Enums\City::TicketsFree)->default(0);
                    $form->text('price');
                    $form->text('phone');
                    $form->text('email');
                    $form->text('website');
                    $form->text('address');
                    $form->textarea('how_arrive');
                    $form->textarea('introduce');
                    break;
                case 2:
                    // 餐厅
                    $form->text('start_time');
                    $form->text('capacity');
                    $form->radio('order_food')->options(\App\Enums\City::ContentOrderFood)->default(0);
                    $form->text('phone');
                    $form->text('email');
                    $form->text('website');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 3:
                    // 购物
                    $form->text('start_time');
                    $form->text('phone');
                    $form->text('email');
                    $form->text('website');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 4:
                    // 住宿
                    $form->text('phone');
                    $form->text('email');
                    $form->text('website');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 5:
                    // 交通
                    $form->text('phone');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 6:
                    // 设施
                    $form->text('phone');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 7:
                    // 活动
                    $form->text('start_time');
                    $form->text('end_time');
                    $form->text('website');
                    $form->text('address');
                    $form->textarea('introduce');
                    break;
                case 8:
                    // 票务
                    $form->text('phone');
                    $form->text('email');
                    $form->text('website');
                    $form->text('other_phone');
                    $form->text('address');
                    $form->text('price');
                    $form->textarea('introduce');
                    break;
            }

            $form->multipleImage('pictures')->saveFullUrl()->uniqueName()->autoUpload()->sortable()
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
                ])->help('限製5M,會自動裁剪800*600')->required();

            $form->radio('audit_status')
                ->value(0)
                ->options(\App\Enums\City::AuditStatusArr)
                ->when(\App\Enums\City::AuditStatusReject, function (Form $form) {
                    $form->textarea('audit_feedback');
                });
//            $form->switch('recommend');
//            $form->switch('banner_recommend');
//            $form->switch('home_recommend');
            $form->number('order')->default(0);

            $form->saved(function (Form $form, $result) use ($type_id) {
                return $form->response()->success('操作成功')->redirect('cityContent?type_id=' . $type_id);
            });
        });
    }
}
