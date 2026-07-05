<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Dcat\Admin\Traits\ModelTree;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;

class SystemContinents extends Model implements Sortable
{
    use ModelTree;

    use HasDateTimeFormatter;

    protected $table = 'system_continents';

    protected $parentColumn = 'parent_id';

    protected $orderColumn = 'order';

    protected $titleColumn = 'name';


    static public function options()
    {
        return (new self())::query()->where('parent_id', 0)->pluck('name', 'id')->toArray();
    }

}
