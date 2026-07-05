<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class CityContent extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'city_content';


    public function city()
    {
        return $this->hasOne(City::class, 'id', 'city_id')->select(['id', 'continents_id', 'area_id', 'name']);
    }

    public function type_class()
    {
        return $this->hasOne(CityTypeClass::class, 'id', 'type_class_id')->select(['id', 'name']);
    }

    public function evaluate()
    {
        return $this->hasMany(ContentEvaluate::class, 'content_id', 'id');
    }

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'number']);
    }

    public function edit_data()
    {
        return $this->hasOne(CityContentEdit::class, 'city_content_id', 'id')
            ->orderBy('id', 'desc')
            ->select(['id', 'city_content_id', 'audit_status', 'audit_feedback']);
    }
}
