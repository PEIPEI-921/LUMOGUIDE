<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Dcat\Admin\Traits\ModelTree;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;
use Spatie\EloquentSortable\Sortable;

class CityTypeClass extends Model implements Sortable
{
    use ModelTree, HasDateTimeFormatter;

    protected $table = 'city_type_class';

    protected $parentColumn = 'parent_id';

    protected $orderColumn = 'order';

    protected $titleColumn = 'name';


    /**
     * 选项
     * @return array
     */
    static public function options()
    {
        return Cache::remember("city_type_class", 86400, function () {
            return (new self)::query()->pluck('name', 'id')->toArray();
        });
    }

}
