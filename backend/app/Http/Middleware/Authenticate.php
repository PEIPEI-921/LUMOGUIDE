<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        if (! $request->expectsJson()) {
            return null;
            return route('login');
        }
    }

    /**
     * Authenticate the user against the given guards.
     *
     * 在走默认 JWT guard 之前，先识别「已过期」的 Bearer token：
     * tymon/jwt-auth 的 JWTGuard::user() 里 getToken() 会把 TokenExpiredException
     * 连同其它 JWTException 一起吞掉并返回 false，导致过期 token 与缺失/invalid token
     * 一样返回笼统的「未認證或登錄狀態已失效」，App 端无法区分「请重新登录」。
     * 这里仅对「exp 已过期的合法格式 token」显式抛出 TokenExpiredException，
     * 由 Handler 映射为「Token 已過期」（code=401）；其余情况全部走原逻辑，行为不变。
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  array  $guards
     * @return void
     *
     * @throws \Illuminate\Auth\AuthenticationException
     * @throws \Tymon\JWTAuth\Exceptions\TokenExpiredException
     */
    protected function authenticate($request, array $guards)
    {
        $this->rejectExpiredToken($request);

        parent::authenticate($request, $guards);
    }

    /**
     * 若请求携带格式合法且 exp 已过期的 Bearer token，抛出 TokenExpiredException。
     *
     * @param  \Illuminate\Http\Request  $request
     * @return void
     */
    protected function rejectExpiredToken($request)
    {
        $header = (string) $request->header('Authorization', '');
        if (! preg_match('/^Bearer\s+(\S+)$/i', $header, $m)) {
            return;
        }

        $parts = explode('.', $m[1]);
        if (count($parts) !== 3) {
            return;
        }

        $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/'), true), true);
        if (! is_array($payload) || ! isset($payload['exp']) || ! is_numeric($payload['exp'])) {
            return;
        }

        if (time() >= (int) $payload['exp']) {
            throw new TokenExpiredException('Token has expired');
        }
    }
}
