<?php

namespace App\Admin\RowActions;

use App\Enums\Integral;
use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\UserIntegralOrder;
use Dcat\Admin\Grid\RowAction;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class ReturnOrder extends RowAction
{

    public function __construct($title = null)
    {
        parent::__construct($title);
    }


    public function confirm()
    {
        return [
            "是否操作退款",
        ];
    }

    public function handle(Request $request)
    {
        $id = $this->getKey();

        $order = UserIntegralOrder::find($id);
        $user = User::find($order->user_id);

        DB::beginTransaction();
        try {
            // 积分日志
            $logModel = new UserIntegralLog();
            $logModel->user_id = $user->id;
            $logModel->type = Integral::LogTypeTwo;
            $logModel->title = '兑换订单退款归还积分';
            $logModel->before = $user->integral;
            $logModel->amount = $order->price;
            $logModel->after = $user->integral + $order->price;
            $logModel->save();

            // 扣除用户积分
            $user->integral = $logModel->after;
            $user->save();

            $order->status = Integral::StatusThree;
            $order->save();
            DB::commit();
        } catch (\Throwable $exception) {
            DB::rollBack();
            return $this->response()->error($exception->getMessage())->refresh();
        }

        return $this->response()->success("退款成功")->refresh();
    }

    public function parameters()
    {
        return [
            'id' => $this->row->id,
        ];
    }
}
