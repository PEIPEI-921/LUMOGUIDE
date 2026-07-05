<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class UserAddressRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'id' => 'sometimes|required',
            'name' => 'required|string|max:30',
            'phone' => ['required', 'string', new PhoneWithCountryCode],
//            'country_id' => 'required',
//            'city' => 'required',
            'address' => 'required',
//            'street' => 'required',
            'post_code' => 'required',
            'default' => 'sometimes',
        ];
    }

    public function messages()
    {
        return [
            'id.required' => __('res.id_required'),
            'name.required' => __('res.address_name_required'),
            'phone.required' => __('res.phone_required'),
//            'country_id.required' => '請選擇國家',
//            'city.required' => '請填寫城市',
            'address.required' => __('res.address_required'),
//            'street.required' => '請填寫街道地址',
            'post_code.required' => __('res.post_code_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
