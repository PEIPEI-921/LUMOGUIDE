<?php

namespace App\Admin\Repositories;

use App\Models\IntegralGoods as Model;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;

class IntegralGoods extends EloquentRepository
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

        $model = new Model;
        foreach ($attributes as $key => $value) {
            $model->{$key} = $value;
        }
        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            $model->picture = $attributes['pictures'][0];
            $model->pictures = json_encode($attributes['pictures']);
        }
        $model->save();
        return true;
    }

    public function update(Form $form)
    {
        $attributes = $form->updates();

        $res = Model::find($form->getKey());
        foreach ($attributes as $key => $value) {
            $res->{$key} = $value;
        }

        if (isset($attributes['pictures']) && is_array($attributes['pictures'])) {
            if (count($attributes['pictures']) > 0) {
                $res->picture = $attributes['pictures'][0];
            }
            $res->pictures = json_encode($attributes['pictures']);
        }
        $res->save();
        return true;
    }

}
