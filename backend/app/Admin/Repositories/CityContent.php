<?php

namespace App\Admin\Repositories;

use App\Models\CityContent as Model;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;
use Illuminate\Support\Facades\DB;


class CityContent extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;


    public function edit(Form $form)
    {
        $id = $form->getKey();

        $content = Model::with(['user', 'city', 'type_class'])->find($id);
        $content->toArray();
        return $content;
    }


    public function store(Form $form)
    {
        // 获取待新增的数据
        $attributes = $form->updates();
        $attributes['type_id'] = \App\Models\CityTypeClass::where('id', $attributes['type_class_id'])->value('type_id');

        $model = new Model();
        $model->publisher_type = 'admin';
        foreach ($attributes as $k => $v) {
            if ($k != 'pictures') {
                $model->{$k} = $v;
            }
        }
        $model->longitude = '';
        $model->latitude = '';
        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            $model->first_picture = $attributes['pictures'][0];
            $model->pictures = json_encode($attributes['pictures']);
        }
        $model->save();

        return true;
    }

    public function update(Form $form)
    {
        // 获取待编辑的数据
        $attributes = $form->updates();
        unset($attributes['type_id'], $attributes['publisher_type']);

        $res = Model::find($form->getKey());

        foreach ($attributes as $key => $value) {
            if ($key != 'pictures') {
                $res->{$key} = $value;
            }
//            // 轮播推荐与首页推荐不能同时
//            if ($key == 'banner_recommend' && $value == 1) {
//                $res->home_recommend = 0;
//            }
//            if ($key == 'home_recommend' && $value == 1) {
//                $res->banner_recommend = 0;
//            }
        }

        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            if (count($attributes['pictures']) > 0) {
                $res->first_picture = $attributes['pictures'][0];
            }
            $res->pictures = json_encode($attributes['pictures']);
        }

        // 首次通过不会二次处理
        $is_finish = 0;
        if ($res->is_finish == 0 && isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
            $res->is_finish = 1;
            $is_finish = 1;
        }

        DB::beginTransaction();
        try {
            // 审核后状态增加未读
            if (isset($attributes['audit_status']) && $attributes['audit_status'] > 0 && $res->audit_status != $attributes['audit_status']) {
                $res->is_read = 0;
            }

            // 审核通过反馈未null
            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
                $res->audit_feedback = null;
            }

            $res->save();

            if (isset($attributes['audit_status']) && $attributes['audit_status'] == 2) {
                SystemMessage::saveData($res->user_id, '城市內容發布', '城市內容發布失败', "很抱歉,您提交的城市内容沒有通過发布,原因是:{$attributes['audit_feedback']},請重新填寫資料");
            }

            // 发布内容给用户增加积分
            if ($is_finish == 1 && $res->user_id > 0) {
                SystemMessage::saveData($res->user_id, '城市內容發布', '城市內容發布通過審核', "恭喜您,已成功發布城市內容");

                SystemIntegralConfig::saveData($res->user_id, 'city_content');
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }

        return true;
    }

}
