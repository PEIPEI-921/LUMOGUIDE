<?php

namespace App\Admin\Forms;

use App\Models\City;
use App\Models\CityEdit;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Dcat\Admin\Contracts\LazyRenderable;

class AuditCityForm extends Form implements LazyRenderable
{
    use LazyWidget;

    // 处理请求
    public function handle(array $input)
    {
        // 获取外部传递参数
        $id = $this->payload['id'] ?? null;
        $res = City::find($id);

        if (!$res) {
            return $this->response()->error('審核内容不存在');
        }

        // 获取最近一次的修改审核
        $edit_info = CityEdit::query()->where('city_id', $id)
            ->where('audit_status', 0)
            ->orderBy('id', 'desc')->first();

        if ($edit_info && $input['audit_status'] > 0) {
            $edit_info = $edit_info->toArray();
            $edit_info_id = $edit_info['id'];

            unset($edit_info['id'], $edit_info['city_id'], $edit_info['audit_status'], $edit_info['audit_feedback'], $edit_info['created_at'], $edit_info['updated_at']);

            // 审核通过 覆盖城市表资料
            if ($input['audit_status'] == 1) {
                foreach ($edit_info as $key => $value) {
                    $res->{$key} = $value;
                }

                $res->audit_status = $input['audit_status'];
                $res->audit_feedback = null;
            } else {
                // 审核不通过 增加未读
                $res->is_read = 0;
            }

            CityEdit::query()->where('id', $edit_info_id)->update([
                'audit_status' => $input['audit_status'],
                'audit_feedback' => $input['audit_feedback']
            ]);
        }

        // 首次创建 没有修改记录表
        if (!$edit_info && $input['audit_status'] > 0) {

            // 首次通过不会二次处理
            $is_finish = 0;
            if ($res->is_finish == 0 && $input['audit_status'] == 1) {
                $res->is_finish = 1;
                $is_finish = 1;
            }

            if ($input['audit_status'] == 2) {
                SystemMessage::saveData($res->user_id, '發布城市', '發布城市失败', "很抱歉,您提交的城市沒有通過,原因是:{$input['audit_feedback']},請重新填寫資料");
            }

            // 发布城市给用户增加积分
            if ($is_finish == 1 && $res->user_id > 0) {
                SystemMessage::saveData($res->user_id, '發布城市', '發布城市通過審核', "恭喜您,發布的城市{$res->name}已通過審核,快去看看吧");
                SystemIntegralConfig::saveData($res->user_id, 'add_city');
            }

            $res->audit_status = $input['audit_status'];
            $res->audit_feedback = $input['audit_feedback'];
        }

        $res->save();

        return $this->response()->success('審核完成')->refresh();
    }

    public function form()
    {
        $form = $this;
        // 获取外部传递参数
        $id = $this->payload['id'] ?? null;

        $res = City::with(['continents', 'area'])->find($id)->toArray();

        $content_edit = CityEdit::with(['continents', 'area'])->where('city_id', $id)->where('audit_status', 0)->first();
        if ($content_edit) {
            $content_edit = $content_edit->toArray();
        }

        if (!empty($content_edit) && $content_edit['name'] !== $res['name']) {
            $form->display('name')
                ->help("修改前內容【<span style='color:red;'>{$res['name']}</span>】")
                ->value($content_edit['name']);
        } else {
            $form->display('name')->value($res['name']);
        }

        if (!empty($content_edit) && $content_edit['name_en'] !== $res['name_en']) {
            $form->display('name_en')
                ->help("修改前內容【<span style='color:red;'>{$res['name_en']}</span>】")
                ->value($content_edit['name_en']);
        } else {
            $form->display('name_en')->value($res['name_en']);
        }

        if (!empty($content_edit) && $content_edit['continents_id'] !== $res['continents_id']) {
            $form->display('continents_id')
                ->help("修改前內容【<span style='color:red;'>{$res['continents']['name']}</span>】")
                ->value($content_edit['continents']['name']);
        } else {
            $form->display('continents_id')->value($res['continents']['name']);
        }

        if (!empty($content_edit) && $content_edit['area_id'] !== $res['area_id']) {
            $form->display('area_id')
                ->help("修改前內容【<span style='color:red;'>{$res['area']['name']}</span>】")
                ->value($content_edit['area']['name']);
        } else {
            $form->display('area_id')->value($res['area']['name']);
        }

        $capital = \App\Enums\City::Capital;

        if (!empty($content_edit) && $content_edit['is_capital'] !== $res['is_capital']) {
            $form->display('is_capital')
                ->help("修改前內容【<span style='color:red;'>{$capital[$res['is_capital']]}</span>】")
                ->value($capital[$content_edit['is_capital']]);

        } else {
            $form->radio('is_capital')->options(\App\Enums\City::Capital)->value($res['is_capital']);
        }

        if (!empty($content_edit) && $content_edit['currency'] !== $res['currency']) {
            $form->display('currency')
                ->help("修改前內容【<span style='color:red;'>{$res['currency']}</span>】")
                ->value($content_edit['currency']);
        } else {
            $form->display('currency')->value($res['currency']);
        }

        if (!empty($content_edit) && $content_edit['language'] !== $res['language']) {
            $form->display('language')
                ->help("修改前內容【<span style='color:red;'>{$res['language']}</span>】")
                ->value($content_edit['language']);
        } else {
            $form->display('language')->value($res['language']);
        }

        if (!empty($content_edit) && $content_edit['population'] !== $res['population']) {
            $form->display('population')
                ->help("修改前內容【<span style='color:red;'>{$res['population']}</span>】")
                ->value($content_edit['population']);
        } else {
            $form->display('population')->value($res['population']);
        }

        if (!empty($content_edit) && $content_edit['race'] !== $res['race']) {
            $form->display('race')
                ->help("修改前內容【<span style='color:red;'>{$res['race']}</span>】")
                ->value($content_edit['race']);
        } else {
            $form->display('race')->value($res['race']);
        }

        if (!empty($content_edit) && $content_edit['overview'] !== $res['overview']) {
            $form->divider();
            $form->textarea('overview')->value($content_edit['overview'])->readOnly();
            $form->textarea('overview_after', '修改前內容')->value($res['overview'])->readOnly();
            $form->divider();
        } else {
            $form->textarea('overview')->value($res['overview'])->readOnly();
        }

        if (!empty($content_edit) && $content_edit['history'] !== $res['history']) {
            $form->divider();
            $form->textarea('history')->value($content_edit['history'])->readOnly();
            $form->textarea('history_after', '修改前內容')->value($res['history'])->readOnly();
            $form->divider();
        } else {
            $form->textarea('history')->value($res['history'])->readOnly();
        }

        $form->radio('audit_status')->value(1)->options(\App\Enums\City::AuditStatusArr);
        $form->textarea('audit_feedback');
    }
}
