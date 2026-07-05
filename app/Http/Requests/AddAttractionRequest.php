<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddAttractionRequest extends FormRequest
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
            'tickets_free' => 'sometimes|in:0,1',
            'price' => 'sometimes',
            'phone' => ['nullable', 'sometimes', new PhoneWithCountryCode],
            'email' => 'nullable|sometimes|email',
            'website' => 'sometimes|max:50',
            'address' => 'required|max:255',
            'longitude' => 'sometimes',
            'latitude' => 'sometimes',
            'how_arrive' => 'sometimes',
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
//            'start_time.required' => '开放时间不能为空',
//            'tickets_free.required' => '门票免费状态不能为空',
            'tickets_free.in' => __('res.tickets_free_in'),
//            'price.required' => '价格不能为空',
//            'phone.required' => '电话不能为空',
//            'email.required' => '邮箱不能为空',
//            'website.required' => '网址不能为空',
            'email.email' => __('res.email_format'),
            'website.max' => __('res.website_max'),
            'address.required' => __('res.address_required'),
            'address.max' => __('res.address_max'),
//            'longitude.required' => '经度不能为空',
//            'latitude.required' => '纬度不能为空',
//            'how_arrive.required' => '如何到达不能为空',
//            'introduce.required' => '相关介绍不能为空',
            'pictures.required' => __('res.pictures_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
