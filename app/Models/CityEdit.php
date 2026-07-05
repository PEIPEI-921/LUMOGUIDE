<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Illuminate\Database\Eloquent\Model;

class CityEdit extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'city_edit';


    public function guide()
    {
        return $this->hasOne(Guide::class, 'id', 'guide_id');
    }

    public function country()
    {
        return $this->hasOne(SystemContinents::class, 'id', 'country_id')->select(['id', 'name']);
    }

    public function continents()
    {
        return $this->hasOne(SystemContinents::class, 'id', 'continents_id')->select(['id', 'name']);
    }

    public function area()
    {
        return $this->hasOne(SystemContinents::class, 'id', 'area_id')->select(['id', 'name']);
    }

}
