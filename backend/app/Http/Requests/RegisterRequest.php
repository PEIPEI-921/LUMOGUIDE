<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'inviter_code' => 'required',
            'email' => 'required|unique:users',
//            'verify_code' => 'required',
            'password' => 'required|confirmed',
            'password_confirmation' => 'required'
        ];
    }

    public function messages()
    {
        return [
            'inviter_code.required' => __('res.inviter_code_required'),
            'email.required' => __('res.email_required'),
            'email.unique' => __('res.email_unique'),
//            'verify_code.required' => '请填写验证码',
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
