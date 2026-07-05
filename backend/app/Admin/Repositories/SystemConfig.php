<?php

namespace App\Admin\Repositories;

use App\Models\SystemConfig as Model;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemConfig extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;

    public function edit(Form $form): array
    {
        // 获取数据主键值
        $id = $form->getKey();

        $res = Model::find($id)->toArray();

        $res['value1'] = $res['type'] == 1 ? $res['value'] : '';
        $res['value2'] = $res['type'] == 2 ? $res['value'] : '';
        $res['value3'] = $res['type'] == 3 ? $res['value'] : '';
        $res['value4'] = $res['type'] == 4 ? $res['value'] : '';
        $res['value5'] = $res['type'] == 5 ? json_decode($res['value'], true) : [];
        $res['value6'] = $res['type'] == 6 ? $res['value'] : '';

        return $res;
    }
}
