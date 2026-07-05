<?php

namespace App\Admin\Repositories;

use App\Models\GuideType as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class GuideType extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
