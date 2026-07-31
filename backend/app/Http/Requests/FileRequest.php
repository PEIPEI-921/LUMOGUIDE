<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Log;

class FileRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'file' => 'required_without:image|file|mimes:jpg,jpeg,png,gif,webp|max:10240',
            'image' => 'required_without:file|file|mimes:jpg,jpeg,png,gif,webp|max:10240',
        ];
    }

    public function messages()
    {
        return [
            'file.required_without' => __('res.file_required'),
            'file.file' => __('res.file_file'),
            'file.mimes' => __('res.file_mimes'),
            'file.max' => __('res.file_max'),
            'image.required_without' => __('res.file_required'),
            'image.file' => __('res.file_file'),
            'image.mimes' => __('res.file_mimes'),
            'image.max' => __('res.file_max'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
