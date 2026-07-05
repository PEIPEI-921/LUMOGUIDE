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

// Root route
Route::get('/', function () {
    return response()->file(base_path('frontend/index.html'));
});

// Protocol pages (Blade views) — must be before SPA catch-all
Route::get('/protocol/{type}', function ($type) {
    return view('protocol', [
        'content' => systemConfig($type)
    ]);
});

// SPA catch-all: serve index.html for all non-API, non-admin frontend routes.
// The Vue SPA handles routing via hash fragments (#/path).
// /api/* → mobile app endpoints (unchanged)
// /manage* → Dcat Admin panel (unchanged)
Route::get('/{any}', function () {
    return response()->file(base_path('frontend/index.html'));
})->where('any', '^(?!api|manage)[^.]*$');
