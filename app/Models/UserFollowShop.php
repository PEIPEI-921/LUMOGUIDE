<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class UserFollowShop extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'user_follow_shop';


    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id');
    }

    public function guide()
    {
        return $this->hasOne(Guide::class, 'id', 'user_identity_id');
    }

    public function content()
    {
        return $this->hasOne(CityContent::class, 'id', 'followed_id');
    }

}
