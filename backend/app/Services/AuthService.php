<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Mail\SendCodeMail;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Enums\System;
use App\Models\UserInviteLog;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Redis;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthService
{

    /**
     * 登录
     * @param array $data
     * @return array
     * @throws ApiException
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

        Redis::set("user_last_token:{$data['email']}", $token);

        // 换取 LUMO-Chat access_token（失败不阻断登录，客户端聊天功能自动降级）
        $chatToken = $this->exchangeChatToken($user->number);

        return [
            'token' => $token,
            'user_number' => $user->number,
            'lumo_chat_token' => $chatToken,
        ];
    }

    /**
     * 为用户换取 LUMO-Chat access_token；未配置/失败返回空串（不抛异常）。
     */
    private function exchangeChatToken(string $userNumber): string
    {
        try {
            $res = app(LumoChatService::class)->createToken($userNumber, (string) config('lumochat.device_id', 'lumoguide'));
            return $res['access_token'] ?? '';
        } catch (\Throwable $e) {
            Log::warning('AuthService exchangeChatToken error: ' . $e->getMessage());
            return '';
        }
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
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new ApiException(__('res.email_required'));
        }

        if ($type == 'reg') {
            if (DB::table('users')->where('email', $email)->whereNull('deleted_at')->exists()) {
                throw new ApiException(__('res.account_in'));
            }
        }

        try {
            $code = rand(100000, 999999);
            Mail::to($email)->queue((new SendCodeMail($code))->onQueue('emails'));
            Cache::put("verification_email_{$email}", $code, 600);
            Log::info("sendCode: code generated and queued for {$email}, type={$type}");
        } catch (\Throwable $exception) {
            Log::error('sendCode error: ' . $exception->getMessage() . "\n" . $exception->getTraceAsString());
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
            Log::error('sendSmsCode error: ' . $exception->getMessage() . "\n" . $exception->getTraceAsString());
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
            // 事务内原子性检查：防止并发注册同一邮箱（忽略已注销的软删除记录）
            if (DB::table('users')->where('email', $data['email'])->whereNull('deleted_at')->exists()) {
                throw new ApiException(__('res.email_unique'));
            }

            // 清理已注销账号的残留记录，释放邮箱（email 有唯一索引）
            DB::table('users')->where('email', $data['email'])->whereNotNull('deleted_at')->delete();

            $model = new User();
            $model->email = $data['email'];
            $model->avatar = config('app.url') . "/storage/avatar/default.jpg";
            $model->password = Hash::make($data['password']);
            $model->inviter_id = $inviter_id;
            $model->inviter_code = generateUniqueInviteCode();
            $model->save();

            // 新用户标识
            Redis::hSet('new_user', $model->id, 1);

            $number = str_pad($model->id, 6, '0', STR_PAD_LEFT);
            $user_number = "LuMo{$date}{$number}";

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
            Log::error('register error: ' . $exception->getMessage() . "\n" . $exception->getTraceAsString());
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }

        $token = auth('api')->login($model);

        // 换取 LUMO-Chat access_token（失败不阻断注册）
        $chatToken = $this->exchangeChatToken($user_number);

        return [
            'token' => $token,
            'user_number' => $user_number,
            'lumo_chat_token' => $chatToken,
        ];
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
            Log::error('resetPassword error: ' . $exception->getMessage() . "\n" . $exception->getTraceAsString());
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }
}
