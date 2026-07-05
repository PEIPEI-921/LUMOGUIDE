<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Illuminate\Database\Eloquent\Model;

class GuideEdit extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'guide_edit';

    public function type()
    {
        return $this->hasOne(GuideType::class, 'id', 'identity_type')->select(['id', 'name']);
    }

}
