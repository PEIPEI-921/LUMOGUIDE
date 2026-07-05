<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ApplyGuideRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'photo' => 'required',
            'name' => 'required',
            'name_en' => 'sometimes',
            'phone' => ['required', new PhoneWithCountryCode],
            'email' => 'required|email',
            'bill_address' => 'required',
            'other_contact' => 'nullable',
            'wechat' => 'nullable',
            'whats_app' => 'nullable',
            'line' => 'nullable',
            'language' => 'required',
            'year' => 'required',
            'industry_type' => 'required',
            'identity_type' => 'required',
            'other_type' => 'nullable',
            'introduction' => 'required',
            'business_contact' => 'required|max:20',
            'have_vehicle' => 'required',
            'vehicle_info' => 'sometimes',
            'vehicle_rent' => 'required',
            'certificate_picture' => 'required',
            'passport_picture' => 'sometimes',
            'driver_license_front' => 'sometimes',
            'driver_license_back' => 'sometimes',
            'car_pictures' => 'sometimes',
        ];
    }

    public function messages()
    {
        return [
            'photo.required' => __('res.photo_required'),
            'name.required' => __('res.guide_name_required'),
//            'name_en.required' => __('res.name_en_required'),
            'phone.required' => __('res.phone_required'),
            'email.required' => __('res.email_required'),
            'email.email' => __('res.email_format'),
            'bill_address.required' => __('res.address_required'),
//            'other_contact.required' => __('res.other_contact_required'),
//            'wechat.required' => __('res.wechat_required'),
//            'whats_app.required' => __('res.whats_app_required'),
//            'line.required' => __('res.line_required'),
            'language.required' => __('res.language_required'),
            'year.required' => __('res.year_required'),
            'industry_type.required' => __('res.industry_type_required'),
            'identity_type.required' => __('res.identity_type_required'),
            'introduction.required' => __('res.introduction_required'),
            'business_contact.required' => __('res.business_contact_required'),
            'have_vehicle.required' => __('res.have_vehicle_required'),
//            'vehicle_info.required' => '車輛信息不能為空',
            'vehicle_rent.required' => __('res.vehicle_rent_required'),
            'certificate_picture.required' => __('res.certificate_picture_required'),
//            'passport_picture.required' => '護照證件圖片不能為空',
//            'driver_license_front.required' => '駕照正面不能為空',
//            'driver_license_back.required' => '駕照背面不能為空',
//            'car_pictures.required' => '車輛照片不能為空',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
