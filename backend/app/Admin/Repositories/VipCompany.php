<?php

namespace App\Admin\Repositories;

use App\Models\VipCompany as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class VipCompany extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
