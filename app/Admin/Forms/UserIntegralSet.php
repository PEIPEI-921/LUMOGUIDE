<?php

namespace App\Admin\Forms;

use App\Enums\Integral;
use App\Enums\Vip;
use App\Models\User;
use App\Models\UserIntegralLog;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Facades\DB;

class UserIntegralSet extends Form implements LazyRenderable
{
    use LazyWidget;

    /**
     * Handle the form request.
     *
     * @param array $input
     *
     * @return mixed
     */
    public function handle(array $input)
    {
        $user_id = $input['user_id'];
        $user = User::find($input['user_id']);

        $type = $input['type'];
        $number = $input['number'];

        DB::beginTransaction();
        try {
            // 积分日志
            $logModel = new UserIntegralLog();
            $logModel->user_id = $user_id;
            $logModel->type = $type;
            $logModel->title = '后台管理操作';
            $logModel->before = $user->integral;
            $logModel->amount = $number;
            $logModel->after = $type == 1 ? ($user->integral - $number) : ($user->integral + $number);
            $logModel->save();

            // 扣除用户积分
            $user->integral = $logModel->after;
            $user->save();

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->response()->error($e->getMessage());
        }


        return $this->response()->success('积分设置成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $this->hidden('user_id');
        $this->radio('type', '类型')->options([1 => '减少', 2 => '增加'])->default(2)->required();
        $this->number('number', '金额')->required();
    }

    /**
     * The data of the form.
     *
     * @return array
     */
    public function default()
    {
        return [
            'user_id' => $this->payload['key'],
        ];
    }
}
