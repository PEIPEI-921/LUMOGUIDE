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

class CityContentExpiredJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $content_id;
    protected $field;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct(int $content_id, string $field)
    {
        $this->content_id = $content_id;
        $this->field = $field;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        $content = CityContent::find($this->content_id);
        if ($content) {
            $time = $content->{$this->field};

            // 推荐时间小于当前时间 代表过期
            if ($time < time()) {
                $field_str = str_replace('_time', '', $this->field);

                $content->{$field_str} = 0;
                $content->{$this->field} = 0;
                $content->save();
            }
        }
    }
}
