<?php

namespace App\Admin\Repositories;

use App\Models\VipGuide as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class VipGuide extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
