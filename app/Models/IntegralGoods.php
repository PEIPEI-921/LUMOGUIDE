<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class IntegralGoods extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'integral_goods';

}
