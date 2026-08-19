<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class VipOrder extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'vip_order';


    public function guide_vip()
    {
        return $this->hasOne(VipGuide::class, 'id', 'vip_id');
    }

    public function company_vip()
    {
        return $this->hasOne(VipCompany::class, 'id', 'vip_id');
    }

}
