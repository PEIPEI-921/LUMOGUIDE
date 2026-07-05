<?php

namespace App\Admin\Forms;

use App\Models\City;
use App\Models\CityContent;
use App\Models\CityContentEdit;
use App\Models\SystemIntegralConfig;
use App\Models\SystemMessage;
use Dcat\Admin\Models\Administrator;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Dcat\Admin\Contracts\LazyRenderable;

class AuditCityContentForm extends Form implements LazyRenderable
{
    use LazyWidget;

    // 处理请求
    public function handle(array $input)
    {
        // 获取外部传递参数
        $id = $this->payload['id'] ?? null;
        $res = CityContent::find($id);

        if (!$res) {
            return $this->response()->error('審核内容不存在');
        }

        // 获取最近一次的修改审核
        $edit_info = CityContentEdit::query()->where('city_content_id', $id)
            ->where('audit_status', 0)
            ->orderBy('id', 'desc')->first();
        if ($edit_info && $input['audit_status'] > 0) {
            $edit_info = $edit_info->toArray();
            $edit_info_id = $edit_info['id'];

            unset($edit_info['id'], $edit_info['city_content_id'], $edit_info['audit_status'], $edit_info['audit_feedback'], $edit_info['created_at'], $edit_info['updated_at']);

            // 审核通过 覆盖城市内容表资料
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

            CityContentEdit::query()->where('id', $edit_info_id)->update([
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
                SystemMessage::saveData($res->user_id, '城市內容發布', '城市內容發布失败', "很抱歉,您提交的城市内容沒有通過发布,原因是:{$input['audit_feedback']},請重新填寫資料");
            }

            // 发布内容给用户增加积分
            if ($is_finish == 1 && $res->user_id > 0) {
                SystemMessage::saveData($res->user_id, '城市內容發布', '城市內容發布通過審核', "恭喜您,已成功發布城市內容");

                SystemIntegralConfig::saveData($res->user_id, 'city_content');
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

        $res = CityContent::with(['user', 'city', 'type_class'])->find($id)->toArray();

        $content_edit = CityContentEdit::query()->where('city_content_id', $id)->where('audit_status', 0)->first();
        if ($content_edit) {
            $content_edit = $content_edit->toArray();
        }

        $form->display('user.number', '發布者編號')->value($res['user']['number'] ?? '');
        $form->radio('publisher_type', '發布人類型')->value($res['publisher_type'])->options(['admin' => '管理', 'company' => '企业', 'guide' => '导游'])->disable();

        $city = City::options();
        if (!empty($content_edit) && $content_edit['city_id'] !== $res['city_id']) {
            $form->select('city_id')
                ->options($city)
                ->value($content_edit['city_id'])
                ->help("修改前內容【<span style='color:red;'>{$city[$res['city_id']]}</span>】")
                ->disable();
        } else {
            $form->select('city_id')->options($city)->value($res['city_id'])->disable();
        }

        $type_id = \App\Models\CityType::options();
        if (!empty($content_edit) && $content_edit['type_id'] !== $res['type_id']) {
            $form->select('type_id')->options($type_id)->value($content_edit['type_id'])
                ->help("修改前內容【<span style='color:red;'>{$type_id[$res['type_id']]}</span>】")
                ->disable();
        } else {
            $form->select('type_id')->options($type_id)->value($res['type_id'])->disable();
        }

        $type_class_id = \App\Models\CityTypeClass::options();
        if (!empty($content_edit) && $content_edit['type_class_id'] !== $res['type_class_id']) {
            $form->select('type_class_id')->options($type_class_id)->value($content_edit['type_class_id'])
                ->help("修改前內容【<span style='color:red;'>{$type_class_id[$res['type_class_id']]}</span>】")
                ->disable();
        } else {
            $form->select('type_class_id')->options($type_class_id)->value($res['type_class_id'])->disable();
        }

        if (!empty($content_edit) && $content_edit['name'] !== $res['name']) {
            $form->display('name')
                ->help("修改前內容【<span style='color:red;'>{$res['name']}</span>】")
                ->value($content_edit['name']);
        } else {
            $form->display('name')->value($res['name']);
        }

        $keyArr = [
            1 => ['start_time', 'tickets_free', 'price', 'phone', 'email', 'website', 'address', 'how_arrive', 'introduce'],
            2 => ['start_time', 'capacity', 'order_food', 'phone', 'email', 'website', 'address', 'introduce'],
            3 => ['start_time', 'phone', 'email', 'website', 'address', 'introduce'],
            4 => ['phone', 'email', 'website', 'address', 'introduce'],
            5 => ['phone', 'address', 'introduce'],
            6 => ['phone', 'address', 'introduce'],
            7 => ['start_time', 'end_time', 'website', 'address', 'introduce'],
            8 => ['phone', 'email', 'website', 'other_phone', 'address', 'price', 'introduce'],
        ];

        $form->divider();
        $dataArr = $keyArr[$res['type_id']];
        foreach ($dataArr as $k => $v) {
            if ($v == 'tickets_free') {
                $form->radio('tickets_free')->options(\App\Enums\City::TicketsFree)->value($res['tickets_free'])->disable();
            } elseif ($v == 'order_food') {
                $form->radio('order_food')->options(\App\Enums\City::ContentOrderFood)->value($res['order_food'])->disable();
            } else {
                $form->display($v)->value($res[$v]);
            }
        }
        $pictures = json_decode($res['pictures'], true);
        $form->multipleImage('pictures')->customFormat(function () use ($pictures) {
            return $pictures;
        })->disable();

        if (!empty($content_edit)) {
            $form->divider('修改後內容');

            $newDataArr = $keyArr[$content_edit['type_id']];
            foreach ($newDataArr as $k => $v) {
                if ($v == 'tickets_free') {
                    $form->radio('tickets_free')->options(\App\Enums\City::TicketsFree)->value($content_edit['tickets_free'])->disable();
                } elseif ($v == 'order_food') {
                    $form->radio('order_food')->options(\App\Enums\City::ContentOrderFood)->value($content_edit['order_food'])->disable();
                } else {
                    $form->display($v)->value($content_edit[$v]);
                }
            }

            $new_pictures = json_decode($content_edit['pictures'], true);
            $form->multipleImage('new_pictures', '圖片組')->customFormat(function () use ($new_pictures) {
                return $new_pictures;
            })->disable();
        }

        $form->radio('audit_status')->value(1)->options(\App\Enums\City::AuditStatusArr);
        $form->textarea('audit_feedback');
    }
}
