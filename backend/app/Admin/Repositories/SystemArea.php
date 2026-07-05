<?php

namespace App\Admin\Repositories;

use App\Models\SystemArea as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemArea extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
