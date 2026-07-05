<?php

namespace App\Admin\Repositories;

use App\Models\ContentEvaluate as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class ContentEvaluate extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
