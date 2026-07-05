<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class Information extends Model
{
    use HasDateTimeFormatter;


    public function guide()
    {
        return $this->hasOne(Guide::class, 'id', 'guide_id');
    }

    public function guide_type()
    {
        return $this->hasOne(GuideType::class, 'id', 'guide_type_id');
    }

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'name', 'nickname', 'avatar']);
    }

}
