<?php

namespace App\Admin\Controllers;

use App\Http\Controllers\Controller;
use Dcat\Admin\Admin;
use Dcat\Admin\Widgets\Dropdown;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public static function user()
    {
        $days = Dropdown::make()
            ->options([7 => '近7天', 30 => '近30天', 180 => '近半年'], '註冊日期')
            ->click('近7天')
            ->buttonClass('btn btn-sm btn-light')
            ->map(function ($v, $k) {
                return "<a class='user' data-id='$k', data-value='{$v}' href='javascript:void(0)'> $v</a>";
            });

        $number = [];
        $dates = [];
        for ($i = 6; $i >= 0; $i--) {
            $dates[] = date('Y-m-d', strtotime("-$i days"));
        }

        $orders = DB::table('users')
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('COUNT(*) as number'))
            ->whereIn(DB::raw('DATE(created_at)'), $dates)
            ->groupBy(DB::raw('date'))
            ->get()->toArray();

        $order_data = [];
        foreach ($orders as $v) {
            $v = collect($v)->toArray();
            $order_data[$v['date']] = $v['number'];
        }

        foreach ($dates as $k => $v) {
            $number[] = $order_data[$v] ?? 0;
        }

        $admin = env('ADMIN_ROUTE_PREFIX', 'admin');
        return view('data.user', compact('days', 'dates', 'number', 'admin'));
    }


    public static function guide()
    {
        $days = Dropdown::make()
            ->options([7 => '近7天', 30 => '近30天', 180 => '近半年'], '註冊日期')
            ->click('近7天')
            ->buttonClass('btn btn-sm btn-light')
            ->map(function ($v, $k) {
                return "<a class='guide' data-id='$k', data-value='{$v}' href='javascript:void(0)'> $v</a>";
            });

        $number = [];
        $dates = [];
        for ($i = 6; $i >= 0; $i--) {
            $dates[] = date('Y-m-d', strtotime("-$i days"));
        }

        $orders = DB::table('guides')
            ->select(DB::raw('DATE(audit_time) as date'), DB::raw('COUNT(*) as number'))
            ->whereIn(DB::raw('DATE(audit_time)'), $dates)
            ->groupBy(DB::raw('date'))
            ->get()->toArray();

        $order_data = [];
        foreach ($orders as $v) {
            $v = collect($v)->toArray();
            $order_data[$v['date']] = $v['number'];
        }

        foreach ($dates as $k => $v) {
            $number[] = $order_data[$v] ?? 0;
        }

        $admin = env('ADMIN_ROUTE_PREFIX', 'admin');
        return view('data.guide', compact('days', 'dates', 'number', 'admin'));
    }


    public static function company()
    {
        $days = Dropdown::make()
            ->options([7 => '近7天', 30 => '近30天', 180 => '近半年'], '註冊日期')
            ->click('近7天')
            ->buttonClass('btn btn-sm btn-light')
            ->map(function ($v, $k) {
                return "<a class='company' data-id='$k', data-value='{$v}' href='javascript:void(0)'> $v</a>";
            });

        $number = [];
        $dates = [];
        for ($i = 6; $i >= 0; $i--) {
            $dates[] = date('Y-m-d', strtotime("-$i days"));
        }

        $orders = DB::table('company')
            ->select(DB::raw('DATE(audit_time) as date'), DB::raw('COUNT(*) as number'))
            ->whereIn(DB::raw('DATE(audit_time)'), $dates)
            ->groupBy(DB::raw('date'))
            ->get()->toArray();

        $order_data = [];
        foreach ($orders as $v) {
            $v = collect($v)->toArray();
            $order_data[$v['date']] = $v['number'];
        }

        foreach ($dates as $k => $v) {
            $number[] = $order_data[$v] ?? 0;
        }

        $admin = env('ADMIN_ROUTE_PREFIX', 'admin');
        return view('data.company', compact('days', 'dates', 'number', 'admin'));
    }

    public static function login()
    {
        $days = Dropdown::make()
            ->options([7 => '近7天', 30 => '近30天', 180 => '近半年'], '註冊日期')
            ->click('近7天')
            ->buttonClass('btn btn-sm btn-light')
            ->map(function ($v, $k) {
                return "<a class='logins' data-id='$k', data-value='{$v}' href='javascript:void(0)'> $v</a>";
            });

        $number = [];
        $dates = [];
        for ($i = 6; $i >= 0; $i--) {
            $dates[] = date('Y-m-d', strtotime("-$i days"));
        }

        $orders = DB::table('user_login')
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('COUNT(*) as number'))
            ->whereIn(DB::raw('DATE(created_at)'), $dates)
            ->groupBy(DB::raw('date'))
            ->get()->toArray();

        $order_data = [];
        foreach ($orders as $v) {
            $v = collect($v)->toArray();
            $order_data[$v['date']] = $v['number'];
        }

        foreach ($dates as $k => $v) {
            $number[] = $order_data[$v] ?? 0;
        }

        $admin = env('ADMIN_ROUTE_PREFIX', 'admin');
        return view('data.login', compact('days', 'dates', 'number', 'admin'));
    }


}
