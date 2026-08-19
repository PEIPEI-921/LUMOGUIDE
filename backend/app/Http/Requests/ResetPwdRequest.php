<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ResetPwdRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email' => 'required',
            'verify_code' => 'required',
            'password' => 'required|confirmed',
            'password_confirmation' => 'required'
        ];
    }

    public function messages()
    {
        return [
            'email.required' => __('res.email_required'),
            'verify_code.required' => __('res.code_required'),
            'password.required' => __('res.password_required'),
            'password.confirmed' => __('res.password_confirmed'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
