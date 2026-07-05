<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class ContentEvaluate extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'content_evaluate';


    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'nickname', 'avatar']);
    }

    public function content_user()
    {
        return $this->hasOne(User::class, 'id', 'content_user_id')->select(['id', 'nickname', 'avatar']);
    }

    public function contents()
    {
        return $this->hasOne(CityContent::class, 'id', 'content_id')->select(['id', 'city_id', 'type_id', 'first_picture']);
    }

}
