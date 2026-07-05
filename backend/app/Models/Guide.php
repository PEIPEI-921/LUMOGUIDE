<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class Guide extends Model
{
    use HasDateTimeFormatter;

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id');
    }

    public function city()
    {
        return $this->hasOne(City::class, 'id', 'city_id')->select(['id', 'name']);
    }

    public function type()
    {
        return $this->hasOne(GuideType::class, 'id', 'identity_type')->select(['id', 'name']);
    }

    public function edit_data()
    {
        return $this->hasOne(GuideEdit::class, 'guide_id', 'id')->where('audit_status', 0)->select(['id', 'guide_id']);
    }

}
