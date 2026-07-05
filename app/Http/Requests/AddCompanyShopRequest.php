<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class AddCompanyShopRequest extends FormRequest
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
            'type_id' => 'required',
            'type_class_id' => 'required',
            'name' => 'required',
            'start_time' => 'sometimes',
            'tickets_free' => 'sometimes',
            'price' => 'sometimes',
            'capacity' => 'sometimes',
            'order_food' => 'sometimes',
            'phone' => ['required', new PhoneWithCountryCode],
            'other_phone' => 'sometimes',
            'email' => 'nullable|sometimes|email',
            'website' => 'sometimes|max:30',
            'address' => 'required|max:255',
            'longitude' => 'sometimes',
            'latitude' => 'sometimes',
            'how_arrive' => 'sometimes|max:1000',
            'introduce' => 'sometimes|max:1000',
            'pictures' => 'required',
        ];
    }

    public function messages()
    {
        return [
            'id.required' => __('res.id_required'),
            'city_id.required' => __('res.city_id_required'),
            'type_id.required' => __('res.type_id_required'),
            'type_class_id.required' => __('res.type_class_id_required'),
            'name.required' => __('res.name_required'),
//            'phone.required' => '請填寫電話',
//            'email.required' => '請填寫郵箱',
//            'website.required' => '網址不能為空',
//            'website.max' => '網址不能超過30個字符',
            'email.email' => __('res.email_format'),
            'address.required' => __('res.address_required'),
            'phone.required' => __('res.phone_required'),
            'address.max' => __('res.address_max'),
            'how_arrive.max' => __('res.how_arrive_max'),
            'introduce.max' => __('res.introduce_max'),
//            'longitude.required' => '經度不能為空',
//            'latitude.required' => '緯度不能為空',
//            'introduce.required' => '介紹不能為空',
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
