<?php

namespace App\Admin\Repositories;

use App\Models\VipOrder as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class VipOrder extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
