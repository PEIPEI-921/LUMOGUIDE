<?php

namespace App\Models;

use App\Enums\Integral;
use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class SystemIntegralConfig extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'system_integral_config';


    /**
     * 处理积分
     * @param int $user_id
     * @param string $mark
     * @return void
     */
    static public function saveData(int $user_id, string $mark)
    {
        $data = (new self())->query()->where('mark', $mark)->first();

        $user = User::find($user_id);
        // 会员必须在有效期 才能获取积分
        if ($data && $user->vip_expiration_time > time()) {
            // 积分日志
            $logModel = new UserIntegralLog();
            $logModel->user_id = $user_id;
            $logModel->type = Integral::LogTypeTwo;
            $logModel->title = $data->name . '获得积分';
            $logModel->before = $user->integral;
            $logModel->amount = $data->value;
            $logModel->after = $user->integral + $data->value;
            $logModel->save();

            // 用户积分变动
            $user->integral = $logModel->after;
            $user->save();
        }
    }

}
