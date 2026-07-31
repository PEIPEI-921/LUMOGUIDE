<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MemberNotification extends Model
{
    protected $table = 'member_notifications';

    protected $fillable = [
        'user_id',
        'expire_date',
        'stage',
        'channel',
        'sent_at',
    ];

    protected $casts = [
        'expire_date' => 'date',
        'sent_at' => 'datetime',
    ];
}
