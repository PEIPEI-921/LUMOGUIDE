<?php

namespace App\Admin\Repositories;

use App\Models\CityType as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class CityType extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
