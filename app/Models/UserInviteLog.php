<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class UserInviteLog extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'user_invite_log';


    public function invitees()
    {
        return $this->hasOne(User::class, 'id', 'invitees_uid')->select(['id', 'nickname', 'email', 'number', 'avatar']);
    }

}
