<?php

namespace App\Admin\Repositories;

use App\Models\IntegralGoodsClass as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class IntegralGoodsClass extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
