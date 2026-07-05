<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddEvaluateRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'content_id' => 'required',
            'content' => 'required|max:255',
            'pictures' => 'sometimes|array',
            'star' => 'required|in:1,5',
        ];
    }

    public function messages()
    {
        return [
            'content_id.required' => __('res.content_id_required'),
            'content.required' => __('res.content_required'),
            'content.max' => __('res.content_max'),
            'pictures.array' => __('res.pictures_array'),
            'star.required' => __('res.start_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
