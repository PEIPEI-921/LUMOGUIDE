<?php

namespace App\Admin\Repositories;

use App\Models\SystemFeedback as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemFeedback extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
