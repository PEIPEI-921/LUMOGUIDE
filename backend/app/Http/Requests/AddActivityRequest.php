<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddActivityRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'id' => 'sometimes|required',
            'city_id' => 'required',
            'type_class_id' => 'required',
            'name' => 'required',
            'start_time' => 'sometimes',
            'end_time' => 'sometimes',
            'website' => 'sometimes|max:50',
            'address' => 'required|max:255',
            'longitude' => 'sometimes',
            'latitude' => 'sometimes',
            'introduce' => 'sometimes',
            'pictures' => 'required|array',
        ];
    }

    public function messages()
    {
        return [
            'id.required' => __('res.id_required'),
            'city_id.required' => __('res.city_id_required'),
            'type_class_id.required' => __('res.type_class_id_required'),
            'name.required' => __('res.name_required'),
//            'start_time.required' => '请选择开始时间',
//            'end_time.required' => '请选择结束时间',
//            'website.required' => '网址不能为空',
            'website.max' => __('res.website_max'),
            'address.required' => __('res.address_required'),
            'address.max' => __('res.address_max'),
//            'longitude.required' => '经度不能为空',
//            'latitude.required' => '纬度不能为空',
//            'introduce.required' => '介绍不能为空',
//            'pictures.required' => '封面不能为空',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
