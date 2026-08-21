<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * 行程（预约行程）——预约确认时由 GuideService::confirmReserve 生成。
 */
class Trip extends Model
{
    protected $table = 'trips';

    protected $fillable = [
        'user_id',
        'guide_id',
        'title',
        'start_time',
        'end_time',
        'member_count',
        'start_city_id',
        'arrival_transport_type',
        'arrival_time',
        'arrival_place',
        'start_desc',
        'end_city_id',
        'leave_transport_type',
        'leave_time',
        'leave_place',
        'end_desc',
        'vehicle_option',
        'vehicle_remark',
        'status',
        'reserve_guide_id',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'member_count' => 'integer',
        'status' => 'integer',
    ];

    public function guide()
    {
        return $this->belongsTo(Guide::class, 'guide_id', 'id');
    }

    public function days()
    {
        return $this->hasMany(TripDay::class, 'trip_id', 'id');
    }
}
