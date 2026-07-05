<?php

namespace App\Admin\Repositories;

use App\Models\InformationClass as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class InformationClass extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
