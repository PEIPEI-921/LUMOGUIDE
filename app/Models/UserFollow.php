<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class UserFollow extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'user_follows';

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'nickname', 'avatar']);
    }

    public function guide()
    {
        return $this->hasOne(Guide::class, 'id', 'followed_guide_id')->select(['id', 'name', 'photo', 'identity_type']);
    }
}
