<?php

namespace App\Http\Controllers\Api;

use App\Models\City;
use App\Models\Company;
use App\Models\Guide;
use App\Http\Requests\FileRequest;
use App\Jobs\InvoiceJob;
use App\Mail\InvoiceMail;
use App\Mail\SendCodeMail;
use App\Mail\VipExpiredMail;
use App\Models\User;
use App\Services\CommonService;
use Hedeqiang\TenIM\Facades\IM;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Redis;
use App\Jobs\EmailRemindJob;
use App\Jobs\VipExpiredJob;

// use Illuminate\Support\Carbon;

class CommonController extends BaseController
{

    public function test()
    {
        // dd(1);
        $data = User::query()->where('id', '>', 1)->get()->toArray();
        // dd($data);

        foreach ($data as $k => $v) {
            if ($v['im_login'] == 0) {
                $account_body = [
                    'Identifier' => $v['number'],
                    'Nick' => $v['nickname'],
                    'FaceUrl' => $v['avatar'],
                ];
                $im_res = IM::im()->send('im_open_login_svc', 'account_import', $account_body);
                imApiLog('im_open_login_svc', 'account_import', $account_body, $im_res);

                User::query()->where('id', $v['id'])->update(['im_login' => 1]);
            } else {
                $nickname = $v['nickname'];
                $avatar = $v['avatar'];
                $city_id = 0;
                $identity_str = $v['identity_str'];

                if ($v['identity'] == 2) {
                    $guide = Guide::query()->where('id', $v['guide_id'])->first(['name', 'name_en', 'photo', 'city_id']);
                    $nickname = $guide->name;
                    if ($guide->name_en) {
                        $nickname = $guide->name_en;
                    }
                    $avatar = $guide->photo;
                    $city_id = $guide->city_id;
                }
                if ($v['identity'] == 3) {
                    $company = Company::query()->where('id', $v['company_id'])->first(['name', 'city_id']);
                    $nickname = $company->name;
                    $city_id = $guide->city_id;
                }

                if ($city_id > 0) {
                    $city_name = City::query()->where('id', $city_id)->value('name_en');
                    $nickname = $nickname . "($city_name)";
                }
                if($identity_str){
                    $nickname = $nickname . "-$identity_str";
                }


                // 修改资料
                $profile_body = [
                    "From_Account" => $v['number'],
                    "ProfileItem" => [
                        ['Tag' => 'Tag_Profile_IM_Nick', 'Value' => $nickname],
                        ['Tag' => 'Tag_Profile_IM_Image', 'Value' => $avatar]
                    ]
                ];

                // dd($profile_body);

                $profile_res = IM::im()->send('profile', 'portrait_set', $profile_body);
                imApiLog('profile', 'portrait_set', $profile_body, $profile_res);
            }
        }

        dd($data);


        // InvoiceJob::dispatch(13);

        dd(1);

        // EmailRemindJob::dispatch(100, 10)->delay(now()->setTimestamp(1768437600));

        // die;

        // 1. 配置你的 Redis Key (根据你的截图)
        // 如果你在 .env 设置了 REDIS_PREFIX，这里通常只需要填 'queues:default:delayed'
        // 如果没有读出来，请尝试换成全名 'lumo_database_queues:default:delayed'
        $key = 'queues:default:delayed';

        // 2. 获取数据
        try {
            // 获取 ZSET 所有数据
            $jobs = Redis::connection()->zrange($key, 0, -1);
        } catch (\Exception $e) {
            return "Redis 连接失败: " . $e->getMessage();
        }

        // 3. 构建 HTML 表格样式
        $html = '<style>
        table { border-collapse: collapse; width: 100%; font-family: sans-serif; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; vertical-align: top; }
        th { background-color: #f2f2f2; }
        pre { white-space: pre-wrap; word-wrap: break-word; background: #f4f4f4; padding: 5px; }
        .error { color: red; font-weight: bold; }
    </style>';

        $html .= "<h2>队列检查器: {$key}</h2>";
        $html .= "<table><thead><tr><th>ID</th><th>UUID</th><th>类名 (原)</th><th>解析出的关键数据</th><th>操作建议</th></tr></thead><tbody>";


        $handleArr = [];
        foreach ($jobs as $index => $jobJson) {
            $payload = json_decode($jobJson, true);
            $uuid = $payload['uuid'] ?? '-';
            $displayName = $payload['displayName'] ?? 'Unknown';

            // 解析序列化数据
            $dataHtml = '';
            if (isset($payload['data']['command'])) {
                // 尝试反序列化
                // 因为类不存在，这会生成一个 __PHP_Incomplete_Class 对象
                $obj = @unserialize($payload['data']['command']);

                if ($obj === false) {
                    $dataHtml = '<span class="error">反序列化失败 (格式损坏)</span>';
                } else {
                    // 将对象强制转为数组以查看内容
                    $arr = (array)$obj;
                    $cleanData = [];

                    // 清洗数组键名（处理 PHP 序列化产生的特殊字符）
                    foreach ($arr as $k => $v) {
                        // 移除类名乱码前缀，只保留属性名
                        $cleanKey = trim(str_replace([$displayName, '*', "\0"], '', $k));
                        if (!empty($cleanKey)) {
                            $cleanData[$cleanKey] = $v;
                        }
                    }

                    // 格式化输出
                    $dataHtml = '<pre>' . print_r($cleanData, true) . '</pre>';

                    $date = json_decode(json_encode($arr['delay']), true);

                    if ($displayName == "App\Jobs\EmailRemind") {
                        $handleArr[] = [
                            'user_id' => $cleanData['user_id'],
                            'expired_day' => $cleanData['expired_day'],
                            'uuid' => $uuid,
                            'date' => strtotime($date)
                        ];
                    }
                }
            }

            // 生成 PHP 代码建议
            $codeSuggestion = "App\Jobs\NewJobName::dispatch(...参数...);";

            $html .= "<tr>
            <td>" . ($index + 1) . "</td>
            <td>{$uuid}</td>
            <td>{$displayName}</td>
            <td>{$dataHtml}</td>
            <td><code style='color:blue'>请手动提取左侧数据<br>并在 Tinker 中执行新任务</code></td>
        </tr>";
        }

        // dd($handleArr);


        foreach ($handleArr as $v) {
            EmailRemindJob::dispatch($v['user_id'], $v['expired_day'])->delay(now()->setTimestamp($v['date']));
            // VipExpiredJob::dispatch($v['user_id'])->delay(now()->setTimestamp($v['date']));
        }

        dd(1);

        $html .= "</tbody></table>";

        return $html;

//        $content = (new VipExpiredMail("Your subscription will expire in 10 days."))->onQueue('emails');
//        Mail::to('2096037421@qq.com')->queue($content);

//        Mail::to('2096037421@qq.com')->queue((new SendCodeMail('12345'))->onQueue('emails'));

//        Mail::to('2096037421@qq.com')->queue((new InvoiceMail($file_data['path']))->queue('emails'));

//        InvoiceJob::dispatch(12);
    }


    /**
     * 系统配置
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function config(CommonService $service)
    {
        $data = $service->config();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 文件上传
     * @param CommonService $service
     * @param FileRequest $request
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function fileUpload(CommonService $service, FileRequest $request)
    {
        $data = $service->upload($request);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取地区
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getArea(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getArea($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取大洲
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getContinents(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getContinents($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 大洲列表
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getContinentsList(CommonService $service, Request $request)
    {
        $parent_id = $request->get('parent_id', 0) ?? 0;

        $data = $service->getContinentsList($parent_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取类型
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getType(CommonService $service)
    {
        $data = $service->getType();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取类型分类
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTypeClass(CommonService $service, Request $request)
    {
        $type_id = $request->get('type_id', 0) ?? 0;
        if (!$type_id) {
            return $this->error(__('res.type_id_required'));
        }
        $data = $service->getTypeClass($type_id);
        return $this->success(__('res.success'), $data);
    }


    /**
     * 资讯分类
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getInformationClass(CommonService $service)
    {
        $data = $service->getInformationClass();
        return $this->success(__('res.success'), $data);
    }

    /**
     * 导游分类
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function getGuideType(CommonService $service)
    {
        $data = $service->getGuideType();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 获取推荐城市
     * @param CommonService $service
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function location(CommonService $service, Request $request)
    {
        $longitude = $request->get('longitude', '') ?? '';
        $latitude = $request->get('latitude', '') ?? '';

        $user_id = auth('api')->id();
        Log::debug("{$user_id}:UserAddress-longitude: $longitude, UserAddress-latitude: $latitude");

        $data = [];
        if ($longitude && $latitude) {
            $data = $service->location($longitude, $latitude);
        }
        return $this->success(__('res.success'), $data);
    }


    /**
     * 首页数据
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function homeData(CommonService $service)
    {
        $data = $service->homeData();
        return $this->success(__('res.success'), $data);
    }


    /**
     * 首页搜索
     * @param Request $request
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function homeSearch(Request $request, CommonService $service)
    {
        $name = $request->get('name', '') ?? '';

        if (!$name) {
            $data = [];
        } else {
            $data = $service->homeSearch($name);
        }
        return $this->success(__('res.success'), $data);
    }


    /**
     * 搜索页接口
     * @param Request $request
     * @param CommonService $service
     * @return \Illuminate\Http\JsonResponse
     */
    public function search(Request $request, CommonService $service)
    {
        $name = $request->get('name', '') ?? '';
        $type = $request->get('type', '') ?? '';
        $type_id = $request->get('type_id', 1) ?? 1;

        if (!$name && !in_array($type, ['guide', 'city_content'])) {
            $data = [];
        } else {
            $data = $service->searchData($name, $type, $type_id);
        }
        return $this->success(__('res.success'), $data);
    }


}
