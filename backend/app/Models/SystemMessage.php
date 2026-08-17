<?php

namespace App\Models;

use Dcat\Admin\Traits\HasDateTimeFormatter;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Redis;

class SystemMessage extends Model
{
    use HasDateTimeFormatter;

    protected $table = 'system_message';


    /**
     * 添加系统消息
     * @param int $user_id
     * @param string $title
     * @param string $desc
     * @param string $content
     * @return void
     */
    static public function saveData(int $user_id, string $title, string $desc, string $content)
    {
        $model = new self();
        $model->user_id = $user_id;
        $model->title = $title;
        $model->desc = $desc;
        $model->content = $content;
        $model->save();

        // 系统消息
        $count = Redis::hGet("message_list:$user_id", 'system') ?? 0;
        Redis::hSet("message_list:$user_id", 'system', $count + 1);
    }

    /**
     * 添加系统消息（含 content_type，用于会员到期等特定类型消息）
     */
    static public function saveDataWithType(int $user_id, string $title, string $desc, string $content, string $content_type, int $city_id = 0, int $content_id = 0, int $city_content_type = 0)
    {
        $model = new self();
        $model->user_id = $user_id;
        $model->title = $title;
        $model->desc = $desc;
        $model->content = $content;
        $model->content_type = $content_type;
        if ($city_id > 0) $model->city_id = $city_id;
        if ($content_id > 0) $model->content_id = $content_id;
        if ($city_content_type > 0) $model->city_content_type = $city_content_type;
        $model->save();

        $count = Redis::hGet("message_list:$user_id", 'system') ?? 0;
        Redis::hSet("message_list:$user_id", 'system', $count + 1);
    }

}
