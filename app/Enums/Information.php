<?php

namespace App\Enums;

class Information
{

    // 查看权限
    const Look = [
        1 => '仅导游',
        2 => '所有人',
    ];


    const AuditStatusSubmit = 0;
    const AuditStatusPass = 1;
    const AuditStatusReject = 2;

    // 审核状态
    const AuditStatus = [
        self::AuditStatusSubmit => '提交认证',
        self::AuditStatusPass => '审核通过',
        self::AuditStatusReject => '审核驳回',
    ];

}
