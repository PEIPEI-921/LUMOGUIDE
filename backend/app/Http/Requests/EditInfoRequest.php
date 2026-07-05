<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class EditInfoRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'avatar' => 'sometimes|required',
            'nickname' => 'sometimes|required',
            'birthday' => 'sometimes|required',
        ];
    }

    public function messages()
    {
        return [
            'avatar.required' => __('res.avatar_required'),
            'nickname.required' => __('res.nickname_required'),
            'birthday.required' => __('res.birthday_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
