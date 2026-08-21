<?php

namespace App\Enums;

/**
 * 行程（预约行程 trips 表）状态
 *
 * 由预约确认时生成（GuideService::confirmReserve），
 * TripService 过滤与展示使用。
 */
class Trip
{
    // 待出发
    const StatusWait = 0;

    // 进行中
    const StatusNow = 1;

    // 已结束
    const StatusClose = 2;

    const Status = [
        self::StatusWait => '待出发',
        self::StatusNow => '进行中',
        self::StatusClose => '已结束',
    ];
}
