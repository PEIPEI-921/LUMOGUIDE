<?php

namespace App\Enums;

class Company
{

    const StatusSubmit = 0;
    const StatusPass = 1;
    const StatusReject = 2;

    // 审核状态
    const AuditStatus = [
        self::StatusSubmit => '提交认证',
        self::StatusPass => '审核通过',
        self::StatusReject => '审核驳回',
    ];


}
