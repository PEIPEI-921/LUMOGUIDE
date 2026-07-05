<?php

namespace App\Admin\Repositories;

use App\Models\Reserve as Model;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;

class Reserve extends EloquentRepository
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
            if ($key == 'status') {
                $res->{$key} = $value;
            }
        }
        $res->save();
        return true;
    }
}
