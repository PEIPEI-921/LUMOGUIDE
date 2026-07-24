<?php

use App\Enums\System;
use App\Enums\Vip;
use App\Exceptions\ApiException;
use App\Models\City;
use App\Models\CityContent;
use App\Models\CityType;
use App\Models\Guide;
use App\Models\GuideType;
use App\Models\User;
use Illuminate\Support\Arr;
use App\Models\SystemConfig;
use Illuminate\Support\Facades\Redis;

if (!function_exists('user_admin_config')) {
    function user_admin_config($key = null, $value = null)
    {
        $session = session();


        if (!$config = $session->get('admin.config')) {
            $config = config('admin');

            $config['lang'] = config('app.locale');
        }

        if (is_array($key)) {
            // 保存
            foreach ($key as $k => $v) {
                Arr::set($config, $k, $v);
            }

            $session->put('admin.config', $config);
            return;
        }

        if ($key === null) {
            return $config;
        }

        return Arr::get($config, $key, $value);
    }
}


if (!function_exists('escapeLike')) {
    /**
     * Escape LIKE wildcard characters to prevent wildcard injection.
     * @param string $value
     * @return string
     */
    function escapeLike(string $value): string
    {
        return addcslashes($value, '%_');
    }
}

if (!function_exists('generateUniqueInviteCode')) {
    /**
     * 获取邀请码
     * @return string
     */
    function generateUniqueInviteCode(): string
    {
        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 排除易混淆字符 (0/O, 1/I)
        $code = '';
        for ($i = 0; $i < 7; $i++) {
            $code .= $chars[random_int(0, strlen($chars) - 1)];
        }
        return $code;
    }
}


if (!function_exists('systemConfig')) {
    /**
     * 获取系统配置
     * @param string $mark
     * @return mixed
     */
    function systemConfig(string $mark)
    {
        try {
            if (Redis::hExists('system_config', $mark)) {
                return Redis::hGet('system_config', $mark);
            }
        } catch (\Exception $e) {
            // Redis unavailable, fall through to database
        }

        $config = SystemConfig::where('mark', $mark)->first(['value']);
        if ($config) {
            try {
                Redis::hSet('system_config', $mark, $config->value);
            } catch (\Exception $e) {
                // Silent — cache write failure should not block reads
            }
            return $config->value;
        }
        return null;
    }
}

if (!function_exists('createOrderSn')) {
    /**
     * 创建code
     * @param string $type
     * @return string
     */
    function createOrderSn(string $type = 'T')
    {
        return $type . date('YmdHis') . str_pad(mt_rand(0, 99999), 5, "0", STR_PAD_BOTH);
    }
}


if (!function_exists('timeAgo')) {
    /**
     * 处理时间
     * @param string $time
     * @return string
     */
    function timeAgo(string $time): string
    {
        $time = strtotime($time);
        $diff = time() - $time;

        if ($diff < 60) {
            return $diff . ' 秒前';
        } elseif ($diff < 3600) {
            return floor($diff / 60) . ' 分鐘前';
        } elseif ($diff < 86400) {
            return floor($diff / 3600) . ' 小時前';
        } elseif ($diff < 604800) {
            return floor($diff / 86400) . ' 天前';
        } elseif ($diff < 2592000) {
            return floor($diff / 604800) . ' 周前';
        } elseif ($diff < 31536000) {
            return floor($diff / 2592000) . ' 月前';
        } else {
            return floor($diff / 31536000) . ' 年前';
        }
    }
}

if (!function_exists('arrayEqual')) {
    /**
     * 比较两个数组是否完全一致
     *
     * @param array $a 第一个数组
     * @param array $b 第二个数组
     * @param bool $strict 是否严格比较顺序（默认 true）
     * @return bool
     */
    function arrayEqual(array $a, array $b, bool $strict = true): bool
    {
        if ($strict) {
            // 严格模式：顺序 + 键值都必须一致
            return $a === $b;
        }

        // 非严格模式：只要元素相同，顺序无所谓
        // 1. 数量不同 → 直接 false
        if (count($a) !== count($b)) {
            return false;
        }

        // 2. 排序后比较（保持键顺序从0开始）
        $aSorted = array_values($a);
        $bSorted = array_values($b);

        sort($aSorted);
        sort($bSorted);

        return $aSorted === $bSorted;
    }
}


if (!function_exists('handleGuideVip')) {
    /**
     * 处理会员Vip
     * @param User $user
     * @return void
     * @throws ApiException
     */
    function handleGuideVip(User $user)
    {
        if ($user->guide_id == 0) {
            throw new ApiException(__('res.guide_auth_error'));
        }

        if ($user->vip_type !== Vip::OrderVipTypeGuide) {
            throw new ApiException(__('res.vip_not_buy'), System::VIP_EXPIRED);
        }
        if ($user->vip_expiration_time <= time()) {
            throw new ApiException(__('res.vip_expired'), System::VIP_EXPIRED);
        }
    }
}


if (!function_exists('handleUserVip')) {
    /**
     * 处理用户Vip
     * @param User $user
     * @return void
     * @throws ApiException
     */
    function handleUserVip(User $user)
    {
        if ($user->vip_type == 0) {
            throw new ApiException(__('res.vip_not_buy'), System::VIP_EXPIRED);
        }
        if ($user->vip_expiration_time <= time()) {
            throw new ApiException(__('res.vip_expired'), System::VIP_EXPIRED);
        }
    }
}
if (!function_exists('handleSearchData')) {
    /**
     * 处理搜索数据
     * @param array $where
     * @param string $name
     * @param string $type
     * @return array
     */
    function handleSearchData(array $where, string $name, string $type)
    {
        $city = [];
        $guide = [];
        $city_content = [];
        if ($type == 'all') {
            $city = City::query()->where($where)->where(function ($query) use ($name) {
                $query->where('name', 'like', '%' . escapeLike($name) . '%')->orWhere('name_en', 'like', '%' . escapeLike($name) . '%');
            })->orderBy('order', 'desc')->get(['id', 'name', 'name_en', 'first_picture'])->toArray();

            $guide = Guide::query()->where($where)->where('name', 'like', '%' . escapeLike($name) . '%')
                ->where('city_id', '>', 0)
                ->orderBy('order', 'desc')->get(['id', 'photo as first_picture', 'city_name', 'identity_type', 'name', 'language'])->toArray();

            $city_content = CityContent::with(['city'])
                ->where($where)
                ->where('name', 'like', '%' . escapeLike($name) . '%')
                ->orderBy('order', 'desc')
                ->get(['id', 'city_id', 'type_id', 'type_class_id', 'name', 'first_picture'])->toArray();
        }

        $guide_type = GuideType::query()->pluck('name', 'id')->toArray();

        $city_type = CityType::options();

        $data = [];
        foreach ($city as $key => $value) {
            $data[] = [
                'data_type' => 1,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => $value['name_en'],
                'first_picture' => $value['first_picture'],
                'tag' => '城市'
            ];
        }
        foreach ($guide as $key => $value) {
            $type_name = $guide_type[$value['identity_type']] ?? '';
            $data[] = [
                'data_type' => 2,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => '',
                'first_picture' => $value['first_picture'],
                'city_name' => $value['city_name'],
                'type_name' => $type_name,
                'language' => json_decode($value['language'], true) ?? [],
                'tag' => '導遊'
            ];
        }
        foreach ($city_content as $key => $value) {
            $data[] = [
                'data_type' => 3,
                'id' => $value['id'],
                'name' => $value['name'],
                'name_en' => '',
                'city_id' => $value['city_id'],
                'city_name' => $value['city']['name'],
                'type_id' => $value['type_id'],
                'type_class_id' => $value['type_class_id'],
                'first_picture' => $value['first_picture'],
                'tag' => $city_type[$value['type_id']]
            ];
        }

        return $data;
    }
}

if (!function_exists('handleIsRead')) {
    /**
     * 处理已读未读
     * @param $model
     * @return void
     */
    function handleIsRead($model)
    {
        if ($model->is_read == 0) {
            $model->is_read = 1;
            $model->save();
        }
    }

    /**
     * Batch mark items as read (avoids N+1 in loops)
     * @param string $modelClass
     * @param array $ids
     * @return void
     */
    function handleIsReadBatch(string $modelClass, array $ids)
    {
        if (empty($ids)) return;
        $modelClass::whereIn('id', $ids)->where('is_read', 0)->update(['is_read' => 1]);
    }
}

if (!function_exists('isWithinDays')) {
    /**
     * 判断未来时间是否在指定天数以内
     *
     * @param int $futureTime 未来时间
     * @param int $days 限制天数（例如 10、30）
     * @return bool
     */
    function isWithinDays(int $futureTime, int $days): bool
    {
        $now = time();
        $diff = $futureTime - $now;

        // 小于等于0 表示已过期
        if ($diff <= 0) return false;

        // 转换为天
        $daysDiff = $diff / 86400; // 一天 = 86400 秒

        return $daysDiff <= $days;
    }
}

if (!function_exists('reserveMessage')) {
    /**
     * 处理预约信息
     * @param string $user_nickname
     * @param int $status
     * @return string
     */
    function reserveMessage(string $user_nickname, int $status)
    {
        switch ($status) {
            case 1:
                $text = "[$user_nickname] 提交了预约消息";
                break;
            case 2:
                $text = "您确认了 [$user_nickname] 提交的预约消息";
                break;
            case 3:
                $text = "[$user_nickname] 预约消息已完成";
                break;
            case 4:
                $text = "[$user_nickname] 取消了预约";
                break;
            case 5:
                $text = "您已拒绝 [$user_nickname] 的预约";
                break;
            default:
                $text = '';
                break;
        }
        return $text;
    }
}
if (!function_exists('reserveUserMessage')) {
    /**
     * 处理预约信息
     * @param string $str
     * @param int $status
     * @return string
     */
    function reserveUserMessage(string $str, int $status)
    {
        switch ($status) {
            case 2:
                $text = "预约消息已确认";
                break;
            case 3:
                $text = "预约消息已完成";
                break;
            case 4:
                $text = "您取消了预约";
                break;
            case 5:
                $text = "您的预约被拒绝:[$str]";
                break;
            default:
                $text = '';
                break;
        }
        return $text;
    }
}

if (!function_exists('compressImage')) {
    /**
     * @param $source_url
     * @param $destination_url
     * @param $quality
     * @return false|mixed
     */
    function compressImage($source_url, $destination_url, $quality)
    {
        // Download remote files to temp path (bypass allow_url_fopen dependency)
        $localPath = $source_url;
        $isRemote = preg_match('/^https?:\/\//', $source_url);
        if ($isRemote) {
            $tmpPath = tempnam(sys_get_temp_dir(), 'img_');
            $ch = curl_init($source_url);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_TIMEOUT => 15,
            ]);
            $data = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            if ($httpCode !== 200 || empty($data)) return false;
            file_put_contents($tmpPath, $data);
            $localPath = $tmpPath;
        }

        $info = getimagesize($localPath);
        if (!$info) {
            if ($isRemote && isset($tmpPath)) @unlink($tmpPath);
            return false;
        }

        if ($info['mime'] == 'image/jpeg') {
            $image = imagecreatefromjpeg($localPath);
        } elseif ($info['mime'] == 'image/gif') {
            $image = imagecreatefromgif($localPath);
        } elseif ($info['mime'] == 'image/png') {
            $image = imagecreatefrompng($localPath);
        } else {
            if ($isRemote && isset($tmpPath)) @unlink($tmpPath);
            return false;
        }

        // Rotate image based on EXIF data (JPEG only)
        if ($info['mime'] == 'image/jpeg') {
            $exif = @exif_read_data($localPath);
            if (!empty($exif['Orientation'])) {
                switch ($exif['Orientation']) {
                    case 8:
                        $image = imagerotate($image, 90, 0);
                        break;
                    case 3:
                        $image = imagerotate($image, 180, 0);
                        break;
                    case 6:
                        $image = imagerotate($image, -90, 0);
                        break;
                }
            }
        }

        // Output in original format
        if ($info['mime'] == 'image/png') {
            imagesavealpha($image, true);
            imagepng($image, $destination_url, round(9 - $quality / 11.11));
        } elseif ($info['mime'] == 'image/gif') {
            imagegif($image, $destination_url);
        } else {
            imagejpeg($image, $destination_url, $quality);
        }

        imagedestroy($image);
        if ($isRemote && isset($tmpPath)) @unlink($tmpPath);
        return $destination_url;
    }
}

if (!function_exists('imApiLog')) {
    /**
     * Im 日志
     * @param string $serverName
     * @param string $command
     * @param array $params
     * @param array $res
     * @return void
     */
    function imApiLog(string $serverName, string $command, array $params = [], array $res = [])
    {
        $log = [
            'serverName' => $serverName,
            'command' => $command,
            'params' => $params,
            'res' => $res,
        ];
        Log::stack(['im_api'])->debug(json_encode($log, JSON_UNESCAPED_UNICODE));
    }
}
