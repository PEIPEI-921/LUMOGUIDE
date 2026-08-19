<?php

namespace App\Admin\Controllers;

use App\Admin\Metrics\Examples;
use App\Http\Controllers\Controller;
use App\Models\CityTypeClass;
use App\Models\SystemContinents;
use Dcat\Admin\Admin;
use Dcat\Admin\Http\Controllers\Dashboard;
use Dcat\Admin\Layout\Column;
use Dcat\Admin\Layout\Content;
use Dcat\Admin\Layout\Row;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HomeController extends Controller
{
    public function index(Content $content)
    {
        $city_id = Admin::user()->city_id;
        if ($city_id > 0) {
            $route = env('ADMIN_ROUTE_PREFIX', 'admin');
            return redirect("$route/cityContent");
        }
        return $content
            ->header('系統首頁')
            ->description('系統數據展示')
            ->body(function (Row $row) {
                $row->column(6, function (Column $column) {
                    $column->row(DashboardController::user());
                    $column->row(DashboardController::login());
                });

                $row->column(6, function (Column $column) {
                    $column->row(DashboardController::guide());
                    $column->row(DashboardController::company());
                });
            });
    }


    /**
     * 获取类型分类
     * @param Request $request
     * @return array
     */
    public function getTypeClass(Request $request)
    {
        $id = $request->get('q');
        return CityTypeClass::query()->where('type_id', $id)->get(['id', 'name as text'])->toArray();
    }

    /**
     * 获取地区
     * @param Request $request
     * @return array
     */
    public function getArea(Request $request)
    {
        $id = $request->get('q');
        return SystemContinents::query()->where('parent_id', $id)->get(['id', 'name as text'])->toArray();
    }


    public function getData(string $table, array $where, int $day, string $time_field = 'created_at')
    {
        $number = [];
        $dates = [];

        switch ($day) {
            case 180:
                for ($i = $day; $i >= 0; $i -= 30) {
                    $dates[] = date('Y-m-d', strtotime("-$i days"));
                }
                break;
            case 30:
                for ($i = $day; $i >= 0; $i -= 5) {
                    $dates[] = date('Y-m-d', strtotime("-$i days"));
                }
                break;
            case 7:
                for ($i = 6; $i >= 0; $i--) {
                    $dates[] = date('Y-m-d', strtotime("-$i days"));
                }
                break;
        }

        if ($day == 7) {
            $orders = DB::table($table)
                ->where($where)
                ->select(DB::raw("DATE($time_field) as date"), DB::raw('COUNT(*) as number'))
                ->whereIn(DB::raw("DATE($time_field)"), $dates)
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
        } else {
            foreach ($dates as $k => $v) {
                if ($k == 0) {
                    $users = DB::table($table)
                        ->where($where)
                        ->whereDate($time_field, '<=', $v)
                        ->count();
                    $number[] = $users;
                } else {
                    $users = DB::table($table)
                        ->where($where)
                        ->whereBetween($time_field, [$dates[$k - 1], $v])
                        ->count();
                    $number[] = $users;
                }
            }
        }
        return [$dates, $number];
    }

    /**
     * 获取用户数据
     * @param Request $request
     * @return array
     */
    public function getUserData(Request $request)
    {
        $day = $request->get('days');
        [$dates, $number] = $this->getData('users', [], $day);

        return compact('dates', 'number');
    }


    /**
     * 导游数据
     * @param Request $request
     * @return array
     */
    public function getGuideData(Request $request)
    {
        $day = $request->get('days');
        [$dates, $number] = $this->getData('guides', ['audit_status' => 1], $day, 'audit_time');

        return compact('dates', 'number');
    }


    /**
     * 企业数据
     * @param Request $request
     * @return array
     */
    public function getCompanyData(Request $request)
    {
        $day = $request->get('days');
        [$dates, $number] = $this->getData('company', ['audit_status' => 1], $day, 'audit_time');

        return compact('dates', 'number');
    }


    /**
     * 登录数据
     * @param Request $request
     * @return array
     */
    public function getLoginData(Request $request)
    {
        $day = $request->get('days');
        [$dates, $number] = $this->getData('user_login', [], $day);

        return compact('dates', 'number');
    }


}
