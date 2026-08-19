<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ContactUsRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'title' => 'required',
            'email' => 'required|email',
            'content' => 'required',
        ];
    }

    public function messages()
    {
        return [
            'title.required' => __('res.name_required'),
            'email.required' => __('res.email_required'),
            'email.email' => __('res.email_format'),
            'content.required' => __('res.content_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
