<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JourneyTemplate extends Model
{
    protected $table = 'journey_template';

    protected $fillable = [
        'user_id', 'title', 'content',
    ];

    protected $casts = [
        'content' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}
