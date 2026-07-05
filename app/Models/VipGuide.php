<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class VipGuide extends Model
{
	use HasDateTimeFormatter;
    protected $table = 'vip_guide';
    
}
