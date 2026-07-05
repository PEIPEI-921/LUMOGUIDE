<?php

namespace App\Admin\Repositories;

use App\Models\UserInviteLog as Model;
use Dcat\Admin\Repositories\EloquentRepository;

class UserInviteLog extends EloquentRepository
{
    /**
     * Model.
     *
     * @var string
     */
    protected $eloquentClass = Model::class;
}
