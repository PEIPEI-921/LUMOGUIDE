<?php

namespace App\Admin\Repositories;

use App\Models\SystemCountry as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemCountry extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
