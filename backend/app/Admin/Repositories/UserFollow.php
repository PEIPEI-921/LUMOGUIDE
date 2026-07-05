<?php

namespace App\Admin\Repositories;

use App\Models\UserFollow as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class UserFollow extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
