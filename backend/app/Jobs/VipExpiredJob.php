<?php

namespace App\Jobs;

use App\Enums\Vip;
use App\Models\CityContent;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class VipExpiredJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $user_id;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct(int $user_id)
    {
        $this->user_id = $user_id;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        $user = User::find($this->user_id);
        if ($user->vip_type > 0) {
            // 会员过期时间还有很长 就不能操作
            if ($user->vip_expiration_time <= time()) {
                // 商家身份下架所有店铺
                if ($user->vip_type == Vip::OrderVipTypeCompany) {
                    CityContent::query()->where('user_id', $this->user_id)
                        ->where('publisher_id', $user->company_id)
                        ->where('publisher_type', 'company')
                        ->update(['status' => 0]);
                }

                $user->vip_type = 0;
                $user->vip_id = 0;
                $user->vip_name = null;
                $user->vip_expiration_time = 0;
                $user->vip_free = 0;
                $user->save();
            }
        }
    }
}
