<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\RegisterRequest;
use App\Http\Requests\ResetPwdRequest;
use App\Http\Requests\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\Request;

class AuthController extends BaseController
{

    /**
     * 登录
     * @param LoginRequest $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function login(LoginRequest $request, AuthService $service)
    {
        $data = $service->login($request->validated());
        return $this->success(__('res.login_success'), $data);
    }


    /**
     * 下发验证码
     * @param Request $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function sendCode(Request $request, AuthService $service)
    {
        $email = $request->post("email", '') ?? '';
        if (empty($email)) {
            return $this->error(__('res.email_required'));
        }

        $type = $request->post("type", '') ?? '';

        $service->sendCode($email, $type);
        return $this->success(__('res.success'));
    }


    /**
     * 下发短信
     * @param Request $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function sendSmsCode(Request $request, AuthService $service)
    {
        $phone = $request->post("phone", '') ?? '';
        if (empty($phone)) {
            return $this->error(__('res.phone_required'));
        }

        $service->sendSmsCode($phone);
        return $this->success(__('res.success'));
    }


    /**
     * 验证邮箱
     * @param Request $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function verifyCode(Request $request, AuthService $service)
    {
        $email = $request->post("email", '') ?? '';
        $code = $request->post("code", '') ?? '';
        if (empty($email)) {
            return $this->error(__('res.email_required'));
        }
        if (empty($code)) {
            return $this->error(__('res.code_required'));
        }

        $service->verifyCode($email, $code);
        return $this->success(__('res.success'));
    }


    /**
     * 注册
     * @param RegisterRequest $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function register(RegisterRequest $request, AuthService $service)
    {
        $data = $service->register($request->validated());
        return $this->success(__('res.register_success'), $data);
    }


    /**
     * 重置密码
     * @param ResetPwdRequest $request
     * @param AuthService $service
     * @return \Illuminate\Http\JsonResponse
     * @throws \App\Exceptions\ApiException
     */
    public function resetPassword(ResetPwdRequest $request, AuthService $service)
    {
        $service->resetPassword($request->validated());
        return $this->success(__('res.success'));
    }
}
