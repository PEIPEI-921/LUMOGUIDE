<?php

namespace App\Admin\Actions\Grid;

use App\Admin\Forms\AuditCityContentForm;
use Dcat\Admin\Widgets\Modal;
use Dcat\Admin\Grid\RowAction;

class AuditCityContent extends RowAction
{
    protected $title = '<i class="fa fa-edit">審核</i>';

    public function render()
    {
        $form = AuditCityContentForm::make()->payload(['id' => $this->getKey()]);

        return Modal::make()
            ->xl()
            ->title('審核')
            ->body($form)
            ->button($this->title);
    }
}
