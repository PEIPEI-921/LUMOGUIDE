<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddInformationRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'id' => 'sometimes|required',
            'class_id' => 'required|integer',
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'pictures' => 'sometimes|array',
            'look' => 'required|in:1,2',
        ];
    }

    public function messages()
    {
        return [
            'id.required' => __('res.id_required'),
            'class_id.required' => __('res.class_id_required'),
            'title.required' => __('res.name_required'),
            'title.max' => __('res.name_max'),
            'content.required' => __('res.content_required'),
//            'picture.required' => '图片不能为空',
            'pictures.array' => __('res.pictures_array'),
            'look.required' => __('res.look_required'),
            'look.in' => __('res.look_in'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
