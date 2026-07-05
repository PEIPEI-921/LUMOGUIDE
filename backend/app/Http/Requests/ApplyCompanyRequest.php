<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use App\Rules\PhoneWithCountryCode;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ApplyCompanyRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'required|max:255',
            'name_en' => 'sometimes',
            'city_id' => 'required',
            'address' => 'required|max:255',
            'tax_id' => 'required|max:255',
            'business_type' => 'required',
            'introduction' => 'required|max:255',
            'email' => 'required|email',
            'phone' => ['required', 'max:50', new PhoneWithCountryCode],
            'website' => 'required|max:50',
            'other_contact' => 'nullable|max:255',
            'wechat' => 'nullable|max:255',
            'whats_app' => 'nullable|max:255',
            'line' => 'nullable|max:255',
            'documents_picture' => 'required',
            'picture' => 'sometimes',
        ];
    }

    public function messages()
    {
        return [
            'name.required' => __('res.company_name_required'),
//            'name_en.required' => __('res.name_en_required'),
            'name.max' => __('res.company_name_max'),
            'city_id.required' => __('res.city_id_required'),
            'address.required' => __('res.address_required'),
            'address.max' => __('res.address_max'),
            'tax_id.required' => __('res.tax_id_required'),
            'tax_id.max' => __('res.tax_id_max'),
            'business_type.required' => __('res.business_type_required'),
            'introduction.required' => __('res.introduction_required'),
            'introduction.max' => __('res.introduction_max'),
            'email.required' => __('res.email_required'),
            'email.email' => __('res.email_format'),
            'phone.required' => __('res.phone_required'),
            'website.required' => __('res.website_required'),
            'website.max' => __('res.website_max'),
//            'other_contact.required' => __('res.other_contact_required'),
//            'wechat.required' => __('res.wechat_required'),
//            'whats_app.required' => __('res.whats_app_required'),
//            'line.required' => __('res.line_required'),
            'documents_picture.required' => __('res.documents_picture_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
