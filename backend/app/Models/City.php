<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class City extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'city';


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


    public function edit_data()
    {
        return $this->hasOne(CityEdit::class, 'city_id', 'id')
            ->orderBy('id', 'desc')
            ->select(['id', 'city_id', 'audit_status', 'audit_feedback']);
    }

    /**
     * @return array
     */
    static public function options()
    {
        return (new self())::query()->pluck('name', 'id')->toArray();
    }

    static public function admin_options()
    {
        $data = (new self())::with(['area'])->where('audit_status', 1)
            ->get(['name', 'id', 'area_id'])->toArray();

        $arr = [];
        foreach ($data as $k => $v) {
            $arr[$v['id']] = $v['name'] . '（' . $v['area']['name'] . '）';
        }
        return $arr;
    }

}
