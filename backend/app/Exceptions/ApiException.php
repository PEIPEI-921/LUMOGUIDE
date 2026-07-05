<?php

namespace App\Exceptions;

use App\Enums\System;
use Exception;
use Illuminate\Support\Facades\Log;

class ApiException extends Exception
{
    protected array $data;

    public function __construct(string $message = '', int $code = System::ERROR, array $data = [])
    {
        parent::__construct($message, $code);
        $this->data = $data;
    }

    public function report(): void
    {
        if ($this->code === System::SYSTEM_ERROR) {
            Log::error('API异常：' . $this->message, [
                'code' => $this->code,
                'file' => $this->file,
                'line' => $this->line,
                'data' => $this->data,
            ]);
        }
    }

    public function render($request)
    {
        return response()->json([
            'code' => $this->code,
            'message' => $this->message,
            'data' => $this->data,
        ], 200);
    }
}
