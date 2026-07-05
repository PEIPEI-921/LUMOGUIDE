<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class ExchangeRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'goods_id' => 'required',
            'address_id' => 'required',
        ];
    }

    public function messages()
    {
        return [
            'goods_id.required' => __('res.goods_id_required'),
            'address_id.required' => __('res.address_id_required'),
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        if ($error_msg = $validator->errors()->first()) {
            throw new ApiException($error_msg);
        }
    }
}
