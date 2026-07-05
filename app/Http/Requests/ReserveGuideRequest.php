<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ReserveGuideRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'city_id' => 'required',
            'guide_id' => 'required',
            'arrival_time' => 'required',
            'number' => 'required',
            'remark' => 'required',
            'contact' => 'required|max:20',
            'email' => 'required|email',
            'phone' => ['required', new PhoneWithCountryCode],
            'other' => 'sometimes',
        ];
    }

    public function messages()
    {
        return [
            'city_id.required' => __('res.city_id_required'),
            'guide_id.required' => __('res.guide_id_required'),
            'arrival_time.required' => __('res.arrival_time_required'),
            'number.required' => __('res.number_required'),
            'remark.required' => __('res.remark_required'),
            'contact.required' => __('res.contact_required'),
            'email.required' => __('res.email_required'),
            'email.email' => __('res.email_format'),
            'phone.required' => __('res.phone_required'),
//            'other.required' => '请填写其他联系方式',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
