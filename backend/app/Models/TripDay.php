<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * 行程日（预约行程按天拆分）。
 */
class TripDay extends Model
{
    protected $table = 'trip_days';

    protected $fillable = [
        'trip_id',
        'user_id',
        'guide_id',
        'day_index',
        'date',
        'city_id',
        'city_name',
        'continents_id',
        'area_id',
        'items',
        'activity',
        'status',
    ];

    protected $casts = [
        'day_index' => 'integer',
        'city_id' => 'integer',
        'status' => 'integer',
        'items' => 'array',
        'activity' => 'array',
    ];

    public function trip()
    {
        return $this->belongsTo(Trip::class, 'trip_id', 'id');
    }
}
