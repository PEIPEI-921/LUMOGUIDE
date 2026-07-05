<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'company';

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'user_id');
    }

    public function edit_data()
    {
        return $this->hasOne(CompanyEdit::class, 'company_id', 'id')
            ->where('audit_status', 0)->select(['id', 'company_id']);
    }

}
