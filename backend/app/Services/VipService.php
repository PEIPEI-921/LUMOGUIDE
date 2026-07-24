<?php

namespace App\Services;

use App\Enums\Integral;
use App\Enums\System;
use App\Enums\Vip;
use App\Exceptions\ApiException;
use App\Jobs\EmailRemindJob;
use App\Jobs\VipExpiredJob;
use App\Models\CityContent;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\VipCompany;
use App\Models\VipGuide;
use App\Models\VipOrder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Mockery\Exception;
use Stripe\PaymentIntent;
use Stripe\Stripe;

class VipService
{
    /**
     * 會員權益
     * @return array
     */
    public function ability()
    {
        $guide = systemConfig('vip_guide_ability');
        $company = systemConfig('vip_company_ability');

        $guide_arr = explode("\r\n", $guide);

        $company_arr = explode("\r\n", $company);
        foreach ($company_arr as $k => $v) {
            $company_arr[$k] = explode('||', $v);
        }
        return [
            'guide' => $guide_arr,
            'company' => $company_arr,
        ];
    }


    /**
     * 導遊會員
     * @return array
     */
    public function guide()
    {
        $data = VipGuide::query()->orderBy('time_type', 'asc')->select(['id', 'name', 'time_type', 'buy_type', 'price'])->get()->toArray();

        foreach ($data as $k => &$v) {
            $v['time_type_str'] = \App\Enums\Vip::TimeType[$v['time_type']];
            $v['icon'] = '';
            if ($v['buy_type'] == \App\Enums\Vip::BuyTypePrice) {
                $v['icon'] = "€";
            }
            unset($v);
        }
        return $data;
    }


    /**
     * 企業會員
     * @return array
     */
    public function company()
    {
        $data = VipCompany::query()->orderBy('time_type', 'asc')->select(['id', 'name', 'time_type', 'buy_type', 'price'])->get()->toArray();

        foreach ($data as $k => &$v) {
            $v['time_type_str'] = \App\Enums\Vip::TimeType[$v['time_type']];
            $v['icon'] = "€";
            unset($v);
        }
        return $data;
    }


    /**
     * 訂閱導遊會員
     * @param int $vip_id
     * @return array
     * @throws ApiException
     */
    public function subscriptionGuide(int $vip_id)
    {
        $vip = VipGuide::find($vip_id);
        if (!$vip) {
            throw new ApiException(__('res.vip_not'));
        }

        $user = User::find(auth('api')->id());
        if ($user->guide_id == 0) {
            throw new ApiException(__('res.guide_auth_error'));
        }

        // 積分購買情況下
        $is_integral = 0;
        if ($vip->buy_type == Vip::BuyTypeIntegral) {
            $is_integral = 1;
            if ($user->integral < $vip->price) {
                throw new ApiException(__('res.integral_not_enough'));
            }
        }

        $payData = [];

        DB::beginTransaction();
        try {
            $orderModel = new VipOrder();
            $orderModel->order_sn = createOrderSn('V');
            $orderModel->user_id = $user->id;
            $orderModel->vip_type = Vip::OrderVipTypeGuide;
            $orderModel->vip_id = $vip_id;
            $orderModel->time_type = $vip->time_type;
            $orderModel->buy_type = $vip->buy_type;
            $orderModel->price = $vip->price;

            if ($is_integral == 1) {
                $orderModel->pay_time = time();
                $orderModel->pay_status = Vip::PayStatusPay;

                // 積分日誌
                $logModel = new UserIntegralLog();
                $logModel->user_id = $user->id;
                $logModel->type = Integral::LogTypeOne;
                $logModel->title = '購買導遊會員積分兌換';
                $logModel->before = $user->integral;
                $logModel->amount = $vip->price;
                $logModel->after = $user->integral - $vip->price;
                $logModel->save();

                // 扣除用戶積分 增加會員數據
                $user->integral = $logModel->after;
                $user->vip_type = Vip::OrderVipTypeGuide;
                $user->vip_id = $vip_id;
                $user->vip_name = '';
                if ($user->vip_expiration_time == 0) {
                    $user->vip_expiration_time = time() + Vip::TimeTypeDay[$vip->time_type];
                } else {
                    $user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
                }
                $user->vip_free = 0;
                $user->save();

                $day = 1;
                if ($vip->time_type == Vip::TimeTypeMonth) {
                    $day = 30;
                    // 到期10天前发送邮箱
                    EmailRemindJob::dispatch($user->id, 10)->delay(now()->addDays(20));
                }
                if ($vip->time_type == Vip::TimeTypeYear) {
                    $day = 365;
                    // 到期30天前
                    EmailRemindJob::dispatch($user->id, 30)->delay(now()->addDays(335));
                    // 到期10天前
                    EmailRemindJob::dispatch($user->id, 10)->delay(now()->addDays(355));
                }

                // 訂閱導遊會員給邀請人增加積分
                SystemIntegralConfig::saveData($user->inviter_id, 'invite_guide');

                // 增加会员到期任务
                VipExpiredJob::dispatch($user->id)->delay(now()->addDays($day));
            } else {
                Stripe::setApiKey(config('services.stripe.secret'));

                try {
                    $paymentIntent = PaymentIntent::create([
                        'amount' => $vip->price * 100,
                        'currency' => 'eur',
                        'metadata' => [
                            'order_id' => $orderModel->order_sn
                        ],
                        'automatic_payment_methods' => [
                            'enabled' => true,
                        ],
                    ]);
                    $payData = [
                        'order_sn' => $orderModel->order_sn,
                        'client_secret' => $paymentIntent->client_secret,
                    ];
                } catch (\Exception $e) {
                    Log::error('Stripe createPaymentIntent error: ' . $e->getMessage());
                    throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
                }
            }
            $orderModel->save();
            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }

        return $payData;
    }


    /**
     * 訂閱企業會員
     * @param int $vip_id
     * @return array
     * @throws ApiException
     */
    public function subscriptionCompany(int $vip_id)
    {
        $vip = VipCompany::find($vip_id);
        if (!$vip) {
            throw new ApiException(__('res.vip_not'));
        }

        $user = User::find(auth('api')->id());
        if ($user->company_id == 0) {
            throw new ApiException(__('res.company_auth_error'));
        }

        // 積分購買情況下
        $is_integral = 0;
        if ($vip->buy_type == Vip::BuyTypeIntegral) {
            $is_integral = 1;
            if ($user->integral < $vip->price) {
                throw new ApiException(__('res.integral_not_enough'));
            }
        }

        $payData = [];

        DB::beginTransaction();
        try {
            $orderModel = new VipOrder();
            $orderModel->order_sn = createOrderSn('V');
            $orderModel->user_id = $user->id;
            $orderModel->vip_type = Vip::OrderVipTypeCompany;
            $orderModel->vip_id = $vip_id;
            $orderModel->time_type = $vip->time_type;
            $orderModel->buy_type = $vip->buy_type;
            $orderModel->price = $vip->price;

            if ($is_integral == 1) {
                throw new ApiException('企业会员请订阅');
                $orderModel->pay_time = time();
                $orderModel->pay_status = Vip::PayStatusPay;

                // 積分日誌
                $logModel = new UserIntegralLog();
                $logModel->user_id = $user->id;
                $logModel->type = Integral::LogTypeOne;
                $logModel->title = '購買商家會員積分兌換';
                $logModel->before = $user->integral;
                $logModel->amount = $vip->price;
                $logModel->after = $user->integral - $vip->price;
                $logModel->save();

                // 扣除用戶積分 增加會員數據
                $user->integral = $logModel->after;
                $user->vip_type = Vip::OrderVipTypeCompany;
                $user->vip_id = $vip_id;
                $user->vip_name = $vip->name;
                if ($user->vip_expiration_time == 0) {
                    $user->vip_expiration_time = time() + Vip::TimeTypeDay[$vip->time_type];
                } else {
                    $user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
                }
                $user->vip_free = 0;
                $user->save();

                // 訂閱企业會員給邀請人增加積分
                SystemIntegralConfig::saveData($user->inviter_id, 'invite_company');
            } else {
                Stripe::setApiKey(config('services.stripe.secret'));

                try {
                    $paymentIntent = PaymentIntent::create([
                        'amount' => $vip->price * 100,
                        'currency' => 'eur',
                        'metadata' => [
                            'order_id' => $orderModel->order_sn
                        ],
                        'automatic_payment_methods' => [
                            'enabled' => true,
                        ]
                    ]);
                    $payData = [
                        'order_sn' => $orderModel->order_sn,
                        'client_secret' => $paymentIntent->client_secret,
                    ];
                } catch (\Exception $e) {
                    Log::error('Stripe createPaymentIntent error: ' . $e->getMessage());
                    throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
                }
            }
            $orderModel->save();
            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }

        return $payData;
    }


    /**
     * 查询支付状态
     * @param string $order_sn
     * @return array
     * @throws ApiException
     */
    public function payStatus(string $order_sn)
    {
        $pay_status = VipOrder::query()->where('order_sn', $order_sn)->value('pay_status') ?? null;
        if (!$pay_status) {
            throw new ApiException(__('res.data_not'));
        }
        return ['pay_status' => $pay_status];
    }

}
