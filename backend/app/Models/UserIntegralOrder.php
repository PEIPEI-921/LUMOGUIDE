<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class UserIntegralOrder extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'user_integral_order';


    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id');
    }

    public function user_address()
    {
        return $this->hasOne(UserAddress::class, 'id', 'user_address_id');
    }

}
