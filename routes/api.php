<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\CommonController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\GuideController;
use App\Http\Controllers\Api\InformationController;
use App\Http\Controllers\Api\IntegralController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\VipController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('sendCode', [AuthController::class, 'sendCode']);
    Route::post('sendSmsCode', [AuthController::class, 'sendSmsCode']);
    Route::post('verifyCode', [AuthController::class, 'verifyCode']);
    Route::post('register', [AuthController::class, 'register']);
    Route::post('resetPassword', [AuthController::class, 'resetPassword']);
});

Route::prefix('common')->group(function () {
    Route::get('test', [CommonController::class, 'test']);
    Route::get('config', [CommonController::class, 'config']);
    Route::post('fileUpload', [CommonController::class, 'fileUpload'])->middleware('auth:api');
    Route::get('getArea', [CommonController::class, 'getArea']);
    Route::get('getContinents', [CommonController::class, 'getContinents']);
    Route::get('getContinentsList', [CommonController::class, 'getContinentsList']);
    Route::get('getType', [CommonController::class, 'getType']);
    Route::get('getTypeClass', [CommonController::class, 'getTypeClass']);
    Route::get('getInformationClass', [CommonController::class, 'getInformationClass']);
    Route::get('getGuideType', [CommonController::class, 'getGuideType']);

    Route::get('location', [CommonController::class, 'location']);
    Route::get('home', [CommonController::class, 'homeData']);
    Route::get('homeSearch', [CommonController::class, 'homeSearch']);
    Route::get('search', [CommonController::class, 'search']);
});

Route::prefix('payment')->group(function () {
    Route::any('webhook', [PaymentController::class, 'webhook']);
});

Route::middleware('auth:api')->prefix('user')->group(function () {
    Route::get('loginRecord', [UserController::class, 'loginRecord']);
    Route::get('numberInfo', [UserController::class, 'numberInfo']);
    Route::get('index', [UserController::class, 'index']);
    Route::post('editInfo', [UserController::class, 'editInfo']);
    Route::post('delAccount', [UserController::class, 'delAccount']);
    Route::post('bindPhone', [UserController::class, 'bindPhone']);
    Route::post('contactUs', [UserController::class, 'contactUs']);
    Route::post('feedback', [UserController::class, 'feedback']);
    Route::get('inviteLog', [UserController::class, 'inviteLog']);

    Route::get('reserveGuide', [UserController::class, 'reserveGuide']);
    Route::get('reserveGuideInfo', [UserController::class, 'reserveGuideInfo']);
    Route::post('reserveGuideEdit', [UserController::class, 'reserveGuideEdit']);
    Route::post('reserveGuideDel', [UserController::class, 'reserveGuideDel']);
    Route::post('reserveGuideCancel', [UserController::class, 'reserveGuideCancel']);

    Route::get('reserveCompany', [UserController::class, 'reserveCompany']);
    Route::get('reserveCompanyInfo', [UserController::class, 'reserveCompanyInfo']);
    Route::post('reserveCompanyEdit', [UserController::class, 'reserveCompanyEdit']);
    Route::post('reserveCompanyDel', [UserController::class, 'reserveCompanyDel']);
    Route::post('reserveCompanyCancel', [UserController::class, 'reserveCompanyCancel']);

    Route::get('address', [UserController::class, 'addressLists']);
    Route::post('addressAdd', [UserController::class, 'addressAdd']);
    Route::post('addressEdit', [UserController::class, 'addressEdit']);
    Route::post('addressDelete', [UserController::class, 'addressDelete']);

    Route::post('applyGuide', [UserController::class, 'applyGuide']);
    Route::get('applyGuideInfo', [UserController::class, 'applyGuideInfo']);
//    Route::post('editApplyGuide', [UserController::class, 'editApplyGuide']);

    Route::post('applyCompany', [UserController::class, 'applyCompany']);
    Route::get('applyCompanyInfo', [UserController::class, 'applyCompanyInfo']);
//    Route::post('editApplyCompany', [UserController::class, 'editApplyCompany']);
});


Route::prefix('city')->group(function () {
    Route::get('lists', [CityController::class, 'lists']);
    Route::get('options', [CityController::class, 'options']);
    Route::get('class', [CityController::class, 'class']);
    Route::get('info', [CityController::class, 'info']);
    Route::get('guide', [CityController::class, 'guide']);
    Route::get('guideInfo', [CityController::class, 'guideInfo']);
    Route::post('guideFollow', [CityController::class, 'guideFollow'])->middleware('auth:api');
    Route::post('guideUnFollow', [CityController::class, 'guideUnFollow'])->middleware('auth:api');
    Route::post('reserveGuide', [CityController::class, 'reserveGuide'])->middleware('auth:api');

    Route::get('attraction', [CityController::class, 'attraction']);
    Route::get('restaurant', [CityController::class, 'restaurant']);
    Route::get('shopping', [CityController::class, 'shopping']);
    Route::get('accommodation', [CityController::class, 'accommodation']);
    Route::get('transportation', [CityController::class, 'transportation']);
    Route::get('facility', [CityController::class, 'facility']);
    Route::get('activity', [CityController::class, 'activity']);
    Route::get('ticket', [CityController::class, 'ticket']);

    Route::get('contentInfo', [CityController::class, 'contentInfo']);
    Route::get('contentEvaluate', [CityController::class, 'contentEvaluate']);

    Route::post('addContentEvaluate', [CityController::class, 'addContentEvaluate'])->middleware('auth:api');
    Route::post('companyFollow', [CityController::class, 'companyFollow'])->middleware('auth:api');
    Route::post('shopFollow', [CityController::class, 'shopFollow'])->middleware('auth:api');
    Route::post('addContentReserve', [CityController::class, 'addContentReserve'])->middleware('auth:api');
});

Route::prefix('information')->group(function () {
    Route::get('lists', [InformationController::class, 'lists']);
    Route::get('info', [InformationController::class, 'info']);
    Route::get('evaluate', [InformationController::class, 'evaluate']);
    Route::post('addEvaluate', [InformationController::class, 'addEvaluate'])->middleware('auth:api');
});


Route::middleware('auth:api')->prefix('message')->group(function () {
    Route::get('lists', [MessageController::class, 'lists']);
    Route::get('followClass', [MessageController::class, 'followClass']);
    Route::get('myEvaluate', [MessageController::class, 'myEvaluate']);
    Route::get('evaluateMy', [MessageController::class, 'evaluateMy']);
    Route::get('myFollow', [MessageController::class, 'myFollow']);
    Route::get('followMy', [MessageController::class, 'followMy']);
    Route::get('followMyShop', [MessageController::class, 'followMyShop']);
    Route::post('follow', [MessageController::class, 'follow']);
    Route::post('unFollowShop', [MessageController::class, 'unFollowShop']);

    Route::get('system', [MessageController::class, 'systemList']);
});

Route::middleware('auth:api')->prefix('guide')->group(function () {
    Route::post('publishCity', [GuideController::class, 'publishCity']);
    Route::post('changeCity', [GuideController::class, 'changeCity']);
    Route::get('cityList', [GuideController::class, 'cityLists']);
    Route::get('city', [GuideController::class, 'cityInfo']);
    Route::post('editCity', [GuideController::class, 'editCity']);
    Route::post('delCity', [GuideController::class, 'delCity']);

    Route::get('attraction', [GuideController::class, 'attraction']);
    Route::post('attractionAdd', [GuideController::class, 'attractionAdd']);
    Route::get('attractionInfo', [GuideController::class, 'attractionInfo']);
    Route::post('attractionEdit', [GuideController::class, 'attractionEdit']);
    Route::post('attractionDel', [GuideController::class, 'cityContentDel']);

    Route::get('transportation', [GuideController::class, 'transportation']);
    Route::post('transportationAdd', [GuideController::class, 'transportationAdd']);
    Route::get('transportationInfo', [GuideController::class, 'transportationInfo']);
    Route::post('transportationEdit', [GuideController::class, 'transportationEdit']);
    Route::post('transportationDel', [GuideController::class, 'cityContentDel']);

    Route::get('facility', [GuideController::class, 'facility']);
    Route::post('facilityAdd', [GuideController::class, 'facilityAdd']);
    Route::get('facilityInfo', [GuideController::class, 'facilityInfo']);
    Route::post('facilityEdit', [GuideController::class, 'facilityEdit']);
    Route::post('facilityDel', [GuideController::class, 'cityContentDel']);

    Route::get('activity', [GuideController::class, 'activity']);
    Route::post('activityAdd', [GuideController::class, 'activityAdd']);
    Route::get('activityInfo', [GuideController::class, 'activityInfo']);
    Route::post('activityEdit', [GuideController::class, 'activityEdit']);
    Route::post('activityDel', [GuideController::class, 'cityContentDel']);

    Route::get('information', [GuideController::class, 'information']);
    Route::post('informationAdd', [GuideController::class, 'informationAdd']);
    Route::get('informationInfo', [GuideController::class, 'informationInfo']);
    Route::post('informationEdit', [GuideController::class, 'informationEdit']);
    Route::post('informationDel', [GuideController::class, 'informationDel']);

    Route::get('reserve', [GuideController::class, 'reserve']);
    Route::get('reserveInfo', [GuideController::class, 'reserveInfo']);
    Route::post('confirmReserve', [GuideController::class, 'confirmReserve']);
    Route::post('rejectReserve', [GuideController::class, 'rejectReserve']);
    Route::post('delReserve', [GuideController::class, 'delReserve']);
});

Route::middleware('auth:api')->prefix('company')->group(function () {
    Route::get('info', [CompanyController::class, 'info']);
    Route::get('shop', [CompanyController::class, 'shop']);
    Route::post('shopAdd', [CompanyController::class, 'shopAdd']);
    Route::get('shopInfo', [CompanyController::class, 'shopInfo']);
    Route::post('shopEdit', [CompanyController::class, 'shopEdit']);
    Route::post('shopDel', [CompanyController::class, 'shopDel']);

    Route::get('reserve', [CompanyController::class, 'reserve']);
    Route::get('reserveInfo', [CompanyController::class, 'reserveInfo']);
    Route::post('confirmReserve', [CompanyController::class, 'confirmReserve']);
    Route::post('rejectReserve', [CompanyController::class, 'rejectReserve']);
    Route::post('delReserve', [CompanyController::class, 'delReserve']);
});

Route::middleware('auth:api')->prefix('integral')->group(function () {
    Route::get('userDetails', [IntegralController::class, 'userDetails']);
    Route::get('goodsClass', [IntegralController::class, 'goodsClassLists']);
    Route::get('goods', [IntegralController::class, 'goodsLists']);
    Route::get('goodsInfo', [IntegralController::class, 'goodsInfo']);
    Route::post('exchange', [IntegralController::class, 'exchange']);
    Route::get('exchangeOrders', [IntegralController::class, 'exchangeOrders']);
    Route::get('exchangeOrderInfo', [IntegralController::class, 'exchangeOrderInfo']);
});

Route::middleware('auth:api')->prefix('vip')->group(function () {
    Route::get('ability', [VipController::class, 'ability']);
    Route::get('guide', [VipController::class, 'guide']);
    Route::get('company', [VipController::class, 'company']);

    Route::post('subscriptionGuide', [VipController::class, 'subscriptionGuide']);
    Route::post('subscriptionCompany', [VipController::class, 'subscriptionCompany']);
    Route::get('payStatus', [VipController::class, 'payStatus']);
});
