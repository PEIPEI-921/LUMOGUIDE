<?php

namespace App\Admin\Repositories;

use App\Models\UserIntegralLog as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class UserIntegralLog extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
