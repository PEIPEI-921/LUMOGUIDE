<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class UserIntegralLog extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'user_integral_log';
}
