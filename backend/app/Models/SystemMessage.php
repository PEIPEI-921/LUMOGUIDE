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

        // 推送通知（失败静默，不影响主流程）
        self::pushSystemMessage($user_id, $title, $desc, $content);
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

        // 推送通知（失败静默，不影响主流程）
        self::pushSystemMessage($user_id, $title, $desc, $content, $content_type, $city_id, $content_id);
    }

    /**
     * 推送系统消息到 LUMO-Chat（经 admin push 接口即时投递，不走离线判断）。
     * @param int $user_id
     * @param string $title
     * @param string $desc
     * @param string $content
     * @param string $content_type
     * @return void
     */
    static private function pushSystemMessage(int $user_id, string $title, string $desc, string $content, string $content_type = '', int $city_id = 0, int $content_id = 0)
    {
        self::sendPush($user_id, $title, $desc, $content, [
            'type' => 'system_message',
            'content_type' => $content_type,
            'city_id' => $city_id,
            'content_id' => $content_id,
        ]);
    }

    /**
     * 通用推送：向指定用户推送通知（经 LUMO-Chat admin push 接口，即时投递）。
     * 预约消息、系统消息等均可调用；失败静默，不影响主流程。
     * @param int $user_id LUMOGUIDE 用户 ID
     * @param string $title
     * @param string $body
     * @param array $data 附加数据（type 区分消息类型）
     * @return void
     */
    static public function sendPush(int $user_id, string $title, string $body, array $data = [])
    {
        try {
            $chat_base = config('lumochat.base_url');
            $admin_token = config('lumochat.admin_token');
            $app_id = config('lumochat.app_id');
            if (!$chat_base || !$admin_token || !$app_id) return;

            $user = User::find($user_id);
            if (!$user || empty($user->number)) return;

            $payload = [
                'app_id' => $app_id,
                'user_id' => $user->number,
                'title' => $title,
                'body' => $body,
                'data' => $data,
            ];

            $http = new \GuzzleHttp\Client(['timeout' => 5]);
            $http->post(rtrim($chat_base, '/') . '/api/v1/admin/push', [
                'headers' => [
                    'Content-Type' => 'application/json',
                    'x-admin-token' => $admin_token,
                ],
                'json' => $payload,
            ]);
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error('SystemMessage push error: ' . $e->getMessage());
        }
    }

}
