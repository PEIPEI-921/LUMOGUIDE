<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class JourneyWork extends Model
{
    use SoftDeletes;

    protected $table = 'journey_work';

    protected $fillable = [
        'user_id', 'title', 'status', 'area_id', 'content',
    ];

    protected $casts = [
        'content' => 'array',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}
