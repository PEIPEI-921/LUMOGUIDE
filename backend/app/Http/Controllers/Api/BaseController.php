<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

class BaseController extends Controller
{
    /**
     * 成功
     * @param string $message
     * @param array $data
     * @param int $code
     * @return \Illuminate\Http\JsonResponse
     */
    public function success(string $message = 'success', array $data = [], int $code = 200)
    {
        $res_data = [
            'code' => $code,
            'message' => $message,
            'data' => $data
        ];
        return response()->json($res_data);
    }

    /**
     * 失败
     * @param string $message
     * @param int $code
     * @return \Illuminate\Http\JsonResponse
     */
    public function error(string $message = 'error', int $code = 400)
    {
        $data = [
            'code' => $code,
            'message' => $message,
            'data' => []
        ];
        return response()->json($data);
    }
}
