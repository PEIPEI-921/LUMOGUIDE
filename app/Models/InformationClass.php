<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;

class InformationClass extends Model implements Sortable
{
    use SortableTrait, HasDateTimeFormatter;

    protected $table = 'information_class';

    protected $sortable = [
        // 设置排序字段名称
        'order_column_name' => 'order',
        // 是否在创建时自动排序，此参数建议设置为true
        'sort_when_creating' => true,
    ];

    /**
     * 后台选项
     * @return array
     */
    public static function options()
    {
        return InformationClass::query()->orderBy('order', 'asc')->pluck('name', 'id')->toArray();
    }


}
