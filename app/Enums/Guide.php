<?php

namespace App\Enums;

class Guide
{
    // 是否有车
    const HaveVehicle = [
        0 => '否',
        1 => '是',
    ];

    // 车辆是否出租
    const VehicleRent = [
        0 => '否',
        1 => '是'
    ];


    const StatusSubmit = 0;
    const StatusPass = 1;
    const StatusReject = 2;

    // 审核状态
    const AuditStatus = [
        self::StatusSubmit => '提交认证',
        self::StatusPass => '审核通过',
        self::StatusReject => '审核驳回',
    ];

    const AuditStatusArr = [
        self::StatusPass => '审核通过',
        self::StatusReject => '审核驳回',
    ];


}
