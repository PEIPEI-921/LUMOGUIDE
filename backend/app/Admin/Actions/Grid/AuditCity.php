<?php

namespace App\Admin\Actions\Grid;

use App\Admin\Forms\AuditCityForm;
use Dcat\Admin\Widgets\Modal;
use Dcat\Admin\Grid\RowAction;

class AuditCity extends RowAction
{
    protected $title = '<i class="fa fa-edit">審核</i>';

    public function render()
    {
        $form = AuditCityForm::make()->payload(['id' => $this->getKey()]);

        return Modal::make()
            ->xl()
            ->title('審核')
            ->body($form)
            ->button($this->title);
    }
}
