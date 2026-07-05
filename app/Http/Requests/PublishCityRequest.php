<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class PublishCityRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'id' => 'sometimes|required',
            'name' => 'required',
            'name_en' => 'required',
            'continents_id' => 'required',
            'area_id' => 'required',
            'country_id' => 'required',
            'longitude' => 'sometimes',
            'latitude' => 'sometimes',
            'is_capital' => 'required',
            'currency' => 'required',
            'language' => 'required',
            'population' => 'required',
            'race' => 'required',
            'overview' => 'required',
            'history' => 'required',
            'pictures' => 'required'
        ];
    }

    public function messages()
    {
        return [
            'id.required' => __('res.id_required'),
            'name.required' => __('res.city_name_required'),
            'name_en.required' => __('res.city_name_en_required'),
            'continents_id.required' => __('res.continents_id_required'),
            'area_id.required' => __('res.area_id_required'),
            'country_id.required' => __('res.country_id_required'),
//            'longitude.required' => '请设置经度',
//            'latitude.required' => '请设置经度',
            'is_capital.required' => __('res.is_capital_required'),
            'currency.required' => __('res.currency_required'),
            'language.required' => __('res.language_required'),
            'population.required' => __('res.population_required'),
            'race.required' => __('res.race_required'),
            'overview.required' => __('res.overview_required'),
            'history.required' => __('res.history_required'),
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
