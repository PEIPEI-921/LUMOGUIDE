<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Illuminate\Database\Eloquent\Model;

class CityContentEdit extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'city_content_edit';

}
