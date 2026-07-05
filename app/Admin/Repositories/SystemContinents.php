<?php

namespace App\Admin\Repositories;

use App\Models\SystemContinents as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemContinents extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
