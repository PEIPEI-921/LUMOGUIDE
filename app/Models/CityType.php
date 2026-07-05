<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

class CityType extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'city_type';


    /**
     * 选项
     * @return array
     */
    static public function options()
    {
        return Cache::remember("city_type", 86400, function () {
            return (new self)::query()->pluck('name', 'id')->toArray();
        });
    }


    /**
     * 关联分类
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function child()
    {
        return $this->hasMany(CityTypeClass::class, 'type_id', 'id')->select(['id', 'type_id', 'name']);
    }


}
