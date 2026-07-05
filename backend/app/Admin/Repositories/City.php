<?php

namespace App\Admin\Repositories;

use App\Models\City as Model;
use App\Models\CityEdit;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use App\Models\User;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;
use Illuminate\Support\Facades\DB;

class City extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;


    public function store(Form $form)
    {
        $attributes = $form->updates();

        $model = new Model();
        foreach ($attributes as $k => $v) {
            if ($k != 'pictures') {
                $model->{$k} = $v;
            }
        }
        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            $model->first_picture = $attributes['pictures'][0];
            $model->pictures = json_encode($attributes['pictures']);
        }
        // 经纬度处理
        $location = $attributes['location'];
        if ($location) {
            $locationArr = explode(',', $location);
            $model->longitude = trim($locationArr[1]);
            $model->latitude = trim($locationArr[0]);
        }

        $model->audit_status = \App\Enums\City::AuditStatusPass;
        $model->status = \App\Enums\City::AuditStatusPass;
        $model->save();
        return true;
    }


    public function edit(Form $form)
    {
        // 获取数据主键值
        $id = $form->getKey();

        $res = Model::with(['continents', 'area'])->find($id);

        // 存在待审核数据
        $edit_content = CityEdit::with(['continents', 'area'])->where('city_id', $res->id)->where('audit_status', 0)->first();
        if ($edit_content) {
            $res = $edit_content;
        }

        return $res->toArray();
    }


    public function update(Form $form)
    {
        // 获取待编辑的数据
        $attributes = $form->updates();

        $res = Model::find($form->getKey());

        foreach ($attributes as $k => $v) {
            if ($k != 'pictures') {
                $res->{$k} = $v;
            }
        }

        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            if (count($attributes['pictures']) > 0) {
                $res->first_picture = $attributes['pictures'][0];
            }
            $res->pictures = json_encode($attributes['pictures']);
        }

        // 经纬度处理
        if (isset($attributes['location'])) {
            $location = $attributes['location'];
            if ($location) {
                $locationArr = explode(',', $location);
                $res->longitude = trim($locationArr[1]);
                $res->latitude = trim($locationArr[0]);
            }
        }

        // 首次通过不会二次处理
        $is_finish = 0;
        if ($res->is_finish == 0 && isset($attributes['audit_status']) && $attributes['audit_status'] == \App\Enums\City::AuditStatusPass) {
            $res->is_finish = 1;
            $is_finish = 1;
        }

//        if (isset($attributes['audit_status']) && ($attributes['audit_status'] == \App\Enums\City::AuditStatusPass)) {
//            $res->status = 1;
//        }

        DB::beginTransaction();
        try {
            // 审核后状态增加未读
            if (isset($attributes['audit_status']) && $attributes['audit_status'] > 0) {
                $res->is_read = 0;
            }
            $res->save();

            if (isset($attributes['audit_status']) && $attributes['audit_status'] == \App\Enums\City::AuditStatusReject) {
                SystemMessage::saveData($res->user_id, '發布城市', '發布城市失败', "很抱歉,您提交的城市沒有通過,原因是:{$attributes['audit_feedback']},請重新填寫資料");
            }

//            // 修改导游的城市名称
//            if (isset($attributes['audit_status']) && ($attributes['audit_status'] == \App\Enums\City::AuditStatusPass)) {
//                \App\Models\Guide::query()->where('id', $res->guide_id)->update(['city_id' => $res->id, 'city_name' => $res->name]);
//            }

            // 添加增加积分
            if ($is_finish == 1 && $res->user_id > 0) {
                SystemMessage::saveData($res->user_id, '發布城市', '發布城市通過審核', "恭喜您,發布的城市{$res->name}已通過審核,快去看看吧");
                SystemIntegralConfig::saveData($res->user_id, 'add_city');
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }
        return true;
    }

}
