<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class Reserve extends Model
{
    use HasDateTimeFormatter;

    public function content()
    {
        return $this->hasOne(CityContent::class, 'id', 'content_id');
    }

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'nickname', 'number', 'avatar']);
    }

    public function company()
    {
        return $this->hasOne(Company::class, 'id', 'company_id');
    }

    public function city()
    {
        return $this->hasOne(City::class, 'id', 'city_id');
    }

}
