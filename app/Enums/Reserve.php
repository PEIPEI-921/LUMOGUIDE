<?php

namespace App\Enums;

class Reserve
{

    // 预约的用户类型
    const ReserveUserType = [
        1 => '导游',
        2 => '商家',
    ];


    /**
     * Status 状态
     */
    const StatusNew = 1;
    const StatusConfirm = 2;
    const StatusFinish = 3;
    const StatusCancel = 4;
    const StatusReject = 5;
    const StatusExpired = 6;

    // 预约状态
    const Status = [
        self::StatusNew => '新预约',
        self::StatusConfirm => '已确认',
        self::StatusFinish => '已完成',
        self::StatusCancel => '已取消',
        self::StatusReject => '已拒绝',
        self::StatusExpired => '已过期',
    ];

}
