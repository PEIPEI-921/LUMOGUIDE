<?php

namespace App\Admin\Repositories;

use App\Enums\Integral;
use App\Models\Information as Model;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Models\UserIntegralLog;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;
use Illuminate\Support\Facades\DB;

class Information extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;

    public function update(Form $form)
    {
        // 获取待编辑的数据
        $attributes = $form->updates();

        $res = Model::find($form->getKey());

        foreach ($attributes as $key => $value) {
            if (in_array($key, ['home_recommend', 'audit_status', 'audit_feedback'])) {
                $res->{$key} = $value;
            }
        }

        // 首次通过不会二次处理
        $is_finish = 0;
        if ($res->is_finish == 0 && isset($attributes['audit_status']) && $attributes['audit_status'] == 1) {
            $res->is_finish = 1;
            $is_finish = 1;
        }

        DB::beginTransaction();
        try {
            $res->save();

            // 审核通过 增加积分
            if ($is_finish == 1) {
                SystemIntegralConfig::saveData($res->user_id, 'add_information');
            }
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }

        return true;
    }

}
