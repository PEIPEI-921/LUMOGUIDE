<?php

namespace App\Jobs;

use App\Mail\VipExpiredMail;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class EmailRemindJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $user_id;
    protected $expired_day;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct($user_id, $expired_day)
    {
        $this->user_id = $user_id;
        $this->expired_day = $expired_day;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        $user = User::find($this->user_id);
        if ($user && $user->vip_expiration_time > 0) {

            if (isWithinDays($user->vip_expiration_time, $this->expired_day)) {
                $content = "Your subscription will expire in $this->expired_day days. Please renew as soon as possible.";

                Mail::to($user->email)->queue((new VipExpiredMail($content))->onQueue('emails'));
            }
        }
    }
}
