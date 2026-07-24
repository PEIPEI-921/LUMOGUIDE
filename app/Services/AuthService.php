<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Mail\SendCodeMail;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Enums\System;
use App\Models\UserInviteLog;
use Hedeqiang\TenIM\Facades\IM;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Redis;
use Tencent\TLSSigAPIv2;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthService
{

    /**
     * 登录
     * @param array $data
     * @return array
     * @throws ApiException
     * @throws \Hedeqiang\TenIM\Exceptions\HttpException
     * @throws \Hedeqiang\TenIM\Exceptions\TenIMException
     */
    public function login(array $data): array
    {
        $user = User::query()->where('email', $data['email'])->first();
        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw new ApiException(__('res.login_invalid'));
        }

        $token = auth('api')->login($user);
        if (!$token) {
            throw new ApiException(__('res.login_fail'));
        }

        if ($user->im_login == 0) {
            // 创建用户
            $account_body = [
                'Identifier' => $user->number,
                'Nick' => $user->nickname,
                'FaceUrl' => $user->avatar,
            ];
            $im_res = IM::im()->send('im_open_login_svc', 'account_import', $account_body);
            imApiLog('im_open_login_svc', 'account_import', $account_body, $im_res);

            $user->im_login = 1;
            $user->save();
        }

        $api = new TLSSigAPIv2(env('SDK_APP_ID'), env('SECRET_KEY'));
        $user_sig = $api->genUserSig($user->number);

        Redis::set("user_last_token:{$data['email']}", $token);
        return ['token' => $token, 'user_sig' => $user_sig, 'user_number' => $user->number];
    }


    /**
     * 下发邮箱
     * @param string $email
     * @param string $type
     * @return void
     * @throws ApiException
     */
    public function sendCode(string $email, string $type): void
    {
        if ($type == 'reg') {
            if (User::query()->where("email", $email)->exists()) {
                throw new ApiException(__('res.account_in'));
            }
        }

        try {
            $code = rand(100000, 999999);
            Mail::to($email)->queue((new SendCodeMail($code))->onQueue('emails'));
            Cache::put("verification_email_{$email}", $code, 600);
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 发送短信验证码
     * @param string $phone
     * @return void
     * @throws ApiException
     */
    public function sendSmsCode(string $phone): void
    {
        try {
            $code = rand(1000, 9999);
            Cache::put("verification_phone_{$phone}", $code, 600);
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 验证邮箱验证码
     * @param string $email
     * @param string $code
     * @return void
     * @throws ApiException
     */
    public function verifyCode(string $email, string $code): void
    {
        $cacheCode = Cache::get("verification_email_{$email}");
        if ($cacheCode != $code) {
            throw new ApiException(__('res.code_error'));
        }
    }


    /**
     * 注册
     * @param array $data
     * @return array
     * @throws ApiException
     */
    public function register(array $data): array
    {
        $inviter_id = User::query()->where('inviter_code', $data['inviter_code'])->value('id') ?? 0;
        if (!$inviter_id || $inviter_id == 0) {
            throw new ApiException(__('res.inviter_error'));
        }
        $date = date('Ym');

        DB::beginTransaction();
        try {
            $model = new User();
            $model->email = $data['email'];
            $model->avatar = env('APP_URL') . "/storage/avatar/default.jpg";
            $model->password = Hash::make($data['password']);
            $model->inviter_id = $inviter_id;
            $model->inviter_code = generateUniqueInviteCode();
            $model->save();

            // 新用户标识
            Redis::hSet('new_user', $model->id, 1);

            $number = str_pad($model->id, 6, '0', STR_PAD_LEFT);
            $user_number = "LuMo{$date}{$number}";

            // 创建IM用户
            $account_body = [
                'Identifier' => $user_number,
                'Nick' => $user_number,
                'FaceUrl' => $model->avatar,
            ];
            $im_res = IM::im()->send('im_open_login_svc', 'account_import', $account_body);
            imApiLog('im_open_login_svc', 'account_import', $account_body, $im_res);

            User::query()->where('id', $model->id)->update([
                'number' => $user_number,
                'nickname' => $user_number,
                'im_login' => 1,
            ]);

            $inviteLog = new UserInviteLog();
            $inviteLog->user_id = $inviter_id;
            $inviteLog->invitees_uid = $model->id;
            $inviteLog->save();

            Cache::forget("verification_email_{$data['email']}");

            // 给用户增加积分
            SystemIntegralConfig::saveData($model->id, 'register');

            // 给邀请人增加积分
            SystemIntegralConfig::saveData($inviter_id, 'invite_user');

            DB::commit();
        } catch (\Throwable $exception) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }

        $token = auth('api')->login($model);
        $api = new TLSSigAPIv2(env('SDK_APP_ID'), env('SECRET_KEY'));
        $user_sig = $api->genUserSig($user_number);

        return ['token' => $token, 'user_sig' => $user_sig, 'user_number' => $user_number];
    }


    /**
     * 重置密码
     * @param array $data
     * @return void
     * @throws ApiException
     */
    public function resetPassword(array $data): void
    {
        $user = User::query()->where('email', $data['email'])->first();
        if (!$user) {
            throw new ApiException(__('res.user_not'));
        }

        $this->verifyCode($data['email'], $data['verify_code']);

        try {
            $user->password = Hash::make($data['password']);
            $user->save();

            Cache::forget("verification_email_{$data['email']}");
        } catch (\Throwable $exception) {
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }
}
