<?php

namespace App\Enums;

class User
{

    const identityUser = 1;
    const identityGuide = 2;
    const identityCompany = 3;

    // 用户身份
    const IdentityArr = [
        self::identityUser => '普通用户',
        self::identityGuide => '导游',
        self::identityCompany => '企业',
    ];


    // 用户表会员类型
    const VipType = [
        0 => '非会员',
        1 => '导游',
        2 => '企业',
    ];


    // 地址表默认状态
    const AddressDefault = [
        0 => '否',
        1 => '是'
    ];


    // 会员是否免费
    const VipFreeNo = 0;
    const VipFreeYes = 1;

}
