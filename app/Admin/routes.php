<?php

use Illuminate\Routing\Router;
use Illuminate\Support\Facades\Route;
use Dcat\Admin\Admin;

Admin::routes();

Route::group([
    'prefix' => config('admin.route.prefix'),
    'namespace' => config('admin.route.namespace'),
    'middleware' => config('admin.route.middleware'),
], function (Router $router) {

    $router->get('/', 'HomeController@index');
    $router->get('/api/getTypeClass', 'HomeController@getTypeClass');
    $router->get('/api/getArea', 'HomeController@getArea');
    $router->get('api/getUserData', 'HomeController@getUserData');
    $router->get('api/getGuideData', 'HomeController@getGuideData');
    $router->get('api/getCompanyData', 'HomeController@getCompanyData');
    $router->get('api/getLoginData', 'HomeController@getLoginData');


    $router->resource('cityContent', 'CityContentController');
    $router->resource('cityContentEvaluate', 'ContentEvaluateController');
    $router->resource('city', 'CityController');
    $router->resource('cityTypeClass', 'CityTypeClassController');
    $router->resource('cityType', 'CityTypeController');
    $router->resource('company', 'CompanyController');
    $router->resource('guideType', 'GuideTypeController');
    $router->resource('guide', 'GuideController');
    $router->resource('informationClass', 'InformationClassController');
    $router->resource('information', 'InformationController');
    $router->resource('integralGoodsClass', 'IntegralGoodsClassController');
    $router->resource('integralGoods', 'IntegralGoodsController');
    $router->resource('reserve', 'ReserveController');
    $router->resource('systemArea', 'SystemAreaController');
    $router->resource('systemConfig', 'SystemConfigController');
    $router->resource('systemContinents', 'SystemContinentsController');
    $router->resource('systemCountry', 'SystemCountryController');
    $router->resource('systemIntegralConfig', 'SystemIntegralConfigController');
    $router->resource('users', 'UserController');
    $router->resource('userIntegralOrder', 'UserIntegralOrderController');
    $router->resource('vipCompany', 'VipCompanyController');
    $router->resource('vipGuide', 'VipGuideController');
    $router->resource('vipOrder', 'VipOrderController');

});
