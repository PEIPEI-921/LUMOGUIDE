<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class CompanyEdit extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'company_edit';

}
