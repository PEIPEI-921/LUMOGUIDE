<?php

namespace App\Enums;

class City
{

    // 是否首都
    const Capital = [
        0 => '否',
        1 => '是'
    ];


    // 审核状态
    const AuditStatusSubmit = 0;
    const AuditStatusPass = 1;
    const AuditStatusReject = 2;

    // 审核状态
    const AuditStatus = [
        self::AuditStatusSubmit => '提交认证',
        self::AuditStatusPass => '审核通过',
        self::AuditStatusReject => '审核驳回',
    ];

    const AuditStatusArr = [
        self::AuditStatusPass => '审核通过',
        self::AuditStatusReject => '审核驳回',
    ];

    // 城市发布 类型
//    const ContentType = [
//        1 => '景点',
//        2 => '交通',
//        3 => '设施',
//        4 => '活动'
//    ];


    // 城市发布 门票是否免费
    const TicketsFree = [
        0 => '收费',
        1 => '免费'
    ];


    // 是否接受团餐
    const ContentOrderFood = [
        0 => '不接受',
        1 => '接受'
    ];


    // 城市
    const ContentTypeCity = 1;
    // 资讯
    const ContentTypeInformation = 2;

    const ContentType = [
        self::ContentTypeCity => '城市内容',
        self::ContentTypeInformation => '资讯',
    ];
}
