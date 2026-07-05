<?php

namespace App\Admin\Repositories;

use App\Models\SystemContactUs as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class SystemContactUs extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
