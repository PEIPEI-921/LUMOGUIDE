<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;
use Dcat\Admin\Traits\ModelTree;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;

class SystemArea extends Model implements Sortable
{
    use ModelTree {
        ModelTree::boot as treeBoot;
    }

    use HasDateTimeFormatter;

    protected $table = 'system_area';

    protected $parentColumn = 'parent_id';

    protected $orderColumn = 'order';

    protected $titleColumn = 'name';
}
