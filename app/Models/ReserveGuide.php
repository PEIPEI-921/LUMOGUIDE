<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class ReserveGuide extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'reserve_guide';

    public function guide()
    {
        return $this->hasOne(Guide::class, 'id', 'guide_id');
    }

    public function city()
    {
        return $this->hasOne(City::class, 'id', 'city_id')->select(['id', 'name']);
    }

    public function content()
    {
        return $this->hasOne(CityContent::class, 'id', 'content_id')->select(['id', 'type_id', 'name', 'first_picture']);
    }

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'nickname', 'avatar']);
    }
}
