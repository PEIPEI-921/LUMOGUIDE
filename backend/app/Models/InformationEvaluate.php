<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class InformationEvaluate extends Model
{

    use HasDateTimeFormatter;

    protected $table = 'information_evaluate';


    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id')->select(['id', 'nickname', 'avatar']);
    }
}
