<?php

namespace App\Admin\Repositories;

use App\Models\SystemIntegralConfig as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemIntegralConfig extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
