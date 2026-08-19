<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddFacilityRequest extends FormRequest
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
            'phone' => ['nullable', 'sometimes', new PhoneWithCountryCode],
            'address' => 'required|max:255',
            'longitude' => 'sometimes',
            'latitude' => 'sometimes',
            'introduce' => 'sometimes',
            'pictures' => 'required',
        ];
    }

    public function messages()
    {
        return [
            'id.integer' => __('res.id_required'),
            'city_id.required' => __('res.city_id_required'),
            'type_class_id.required' => __('res.type_class_id_required'),
            'name.required' => __('res.name_required'),
//            'phone.required' => '电话不能为空',
            'address.required' => __('res.address_required'),
            'address.max' => __('res.address_max'),
//            'longitude.required' => '经度不能为空',
//            'latitude.required' => '纬度不能为空',
//            'introduce.required' => '设施介绍不能为空',
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
