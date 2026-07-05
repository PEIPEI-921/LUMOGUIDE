<?php

namespace App\Enums;

class Integral
{

    // 訂單狀態
    const StatusOne = 1;
    const StatusTwo = 2;
    const StatusThree = 3;

    const OrderStatus = [
        self::StatusOne => '兌換成功，等待平臺確認處理',
        self::StatusTwo => '平臺已發貨',
        self::StatusThree => '平臺操作退貨'
    ];


    // 商品包郵
    const FreeShipping = [
        0 => '不包郵',
        1 => '包郵',
    ];


    const LogTypeOne = 1;
    const LogTypeTwo = 2;

    const LogType = [
        self::LogTypeOne => '支出',
        self::LogTypeTwo => '收入',
    ];


    // 商品類型
    const GoodsType = [
        1 => '實體',
        2 => '虛擬',
    ];

}
