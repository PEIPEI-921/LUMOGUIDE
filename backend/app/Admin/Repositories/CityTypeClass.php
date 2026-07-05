<?php

namespace App\Admin\Repositories;

use App\Models\CityTypeClass as Model;
use Dcat\Admin\Form;
use Dcat\Admin\Repositories\EloquentRepository;

class CityTypeClass extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;


    public function delete(Form $form, array $deletingData)
    {
        // 当批量删除时id为多个
        $id = explode(',', $form->getKey());

        if (\App\Models\CityContent::query()->whereIn('type_class_id', $id)->exists()) {
            throw new \Exception('当前分类存在内容,无法删除');
        }

        Model::destroy($id);

        return true;
    }

}
