<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return response()->file(base_path('frontend/index.html'));
});


Route::get('/protocol/{type}', function ($type) {
    return view('protocol', [
        'content' => systemConfig($type)
    ]);
});
