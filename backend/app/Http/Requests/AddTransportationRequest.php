<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddTransportationRequest extends FormRequest
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
            'id.required' => 'ID必須',
            'city_id.required' => '請選擇城市',
            'type_class_id.required' => '請選擇交通類型',
            'name.required' => '請填寫交通名稱',
//            'phone.required' => '電話不能為空',
            'address.required' => __('res.address_required'),
            'address.max' => __('res.address_max'),
//            'longitude.required' => '經度不能為空',
//            'latitude.required' => '緯度不能為空',
//            'introduce.required' => '交通介紹不能為空',
            'pictures.required' => '封面不能為空',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
