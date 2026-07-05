<?php

namespace App\Exceptions;

use App\Enums\System;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Exceptions\JWTException;
use Illuminate\Auth\AuthenticationException;

class Handler extends ExceptionHandler
{
    /**
     * A list of exception types with their corresponding custom log levels.
     *
     * @var array<class-string<\Throwable>, \Psr\Log\LogLevel::*>
     */
    protected $levels = [
        //
    ];

    /**
     * A list of the exception types that are not reported.
     *
     * @var array<int, class-string<\Throwable>>
     */
    protected $dontReport = [
        //
    ];

    /**
     * A list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     *
     * @return void
     */
    public function register()
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }


    protected function unauthenticated($request, AuthenticationException $exception)
    {
        return response()->json([
            'code' => System::AUTH_ERROR,
            'message' => __('res.token_required'),
            'data' => []
        ]);
    }

    public function render($request, Throwable $e)
    {
        // 业务异常优先
        if ($e instanceof ApiException) {
            return $e->render($request);
        }

        // token 相关异常
        if ($e instanceof TokenExpiredException) {
            return response()->json([
                'code' => System::AUTH_ERROR,
                'message' => __('res.token_expired'),
                'data' => []
            ]);
        }

        if ($e instanceof TokenInvalidException) {
            return response()->json([
                'code' => System::AUTH_ERROR,
                'message' => __('res.token_invalid'),
                'data' => []
            ]);
        }

        if ($e instanceof JWTException) {
            return response()->json([
                'code' => System::AUTH_ERROR,
                'message' => __('res.token_error'),
                'data' => []
            ]);
        }

        // Laravel 默认 auth 校验失败
        if ($e instanceof AuthenticationException) {
            return response()->json([
                'code' => System::AUTH_ERROR,
                'message' => __('res.token_auth'),
                'data' => []
            ]);
        }

        return parent::render($request, $e);
    }
}
