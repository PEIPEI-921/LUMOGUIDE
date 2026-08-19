<?php

namespace App\Enums;

class Vip
{

    const TimeTypeMonth = 1;
    const TimeTypeYear = 2;

    // 时间类型
    const TimeType = [
        self::TimeTypeMonth => '月',
        self::TimeTypeYear => '年'
    ];


    // 时间
    const TimeTypeDay = [
        self::TimeTypeMonth => 30 * 86400,
        self::TimeTypeYear => 365 * 86400,
    ];


    // 购买类型
    const BuyTypePrice = 1;
    const BuyTypeIntegral = 2;

    // 支付方式
    const BuyType = [
        self::BuyTypePrice => '金额',
        self::BuyTypeIntegral => '积分'
    ];


    // 会员订单类型
    const OrderVipTypeGuide = 1;
    const OrderVipTypeCompany = 2;

    const VipOrderType = [
        self::OrderVipTypeGuide => '导游',
        self::OrderVipTypeCompany => '企业',
    ];


    // 支付状态
    const PayStatusSubmit = 0;
    const PayStatusPay = 1;

    const PayStatusArr = [
        self::PayStatusSubmit => '待支付',
        self::PayStatusPay => '支付成功',
    ];

}
