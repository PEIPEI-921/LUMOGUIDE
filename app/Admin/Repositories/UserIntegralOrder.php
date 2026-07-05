<?php

namespace App\Admin\Repositories;

use App\Enums\Integral;
use App\Models\UserIntegralOrder as Model;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;

class UserIntegralOrder extends EloquentRepository
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

        foreach ($attributes as $k => $v) {
            $res->{$k} = $v;
        }
        if ($res->express_delivery_company && $res->express_delivery_number && $res->status == Integral::StatusOne) {
            $res->status = Integral::StatusTwo;
        }
        $res->save();
        return true;
    }

}
