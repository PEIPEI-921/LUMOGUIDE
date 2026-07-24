<?php

namespace App\Http\Controllers\Api;

use App\Enums\Integral;
use App\Enums\Vip;
use App\Jobs\EmailRemindJob;
use App\Jobs\InvoiceJob;
use App\Jobs\VipExpiredJob;
use App\Models\CityContent;
use App\Models\SystemIntegralConfig;
use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\VipCompany;
use App\Models\VipGuide;
use App\Models\VipOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Stripe\Webhook;

class PaymentController extends BaseController
{
    public function webhook(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $webhookSecret = config('services.stripe.webhook_secret');
//        Log::debug('webhook-' . $payload);

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $webhookSecret);
        } catch (\UnexpectedValueException $e) {
            // 无效 payload
            return response()->json(['error' => 'Invalid payload'], 400);
        } catch (\Stripe\Exception\SignatureVerificationException $e) {
            // 签名校验失败
            return response()->json(['error' => 'Invalid signature'], 400);
        }

        // 处理不同类型事件
        switch ($event->type) {
            case 'payment_intent.succeeded':
                $pi = $event->data->object;  // PaymentIntent 对象
                $orderId = $pi->metadata->order_id ?? null;

                if ($orderId) {
                    $order = VipOrder::query()->where('order_sn', $orderId)->first();
                    if ($order) {
                        // Idempotency: skip if already processed (Stripe may retry webhooks)
                        if ($order->pay_status == Vip::PayStatusPay) {
                            Log::info("Payment already processed for order: {$orderId}");
                            return response()->json(['received' => true]);
                        }

                        DB::beginTransaction();
                        try {
                            $order->pay_time = time();
                            $order->pay_status = Vip::PayStatusPay;
                            $order->save();

                            $vip_company_auth = [];
                            if ($order->vip_type == Vip::OrderVipTypeGuide) {
                                $vip = VipGuide::find($order->vip_id);
                                $vip_type = Vip::OrderVipTypeGuide;
                                $mark = 'invite_guide';
                            } else {
                                $vip = VipCompany::find($order->vip_id);
                                $vip_type = Vip::OrderVipTypeCompany;
                                $mark = 'invite_company';

                                $vip_company_auth = [
                                    'shop_number' => $vip->number,
                                    'shop_type' => $vip->shop_type,
                                    'city_content_recommend' => $vip->city_content_recommend,
                                    'home_list_recommend' => $vip->home_list_recommend,
                                    'home_banner_recommend' => $vip->home_banner_recommend
                                ];
                            }

                            // 处理用户会员
                            $user = User::find($order->user_id);
                            $user->vip_type = $vip_type;
                            $user->vip_id = $order->vip_id;
                            $user->vip_name = $vip->name;
                            if ($user->vip_expiration_time == 0) {
                                $user->vip_expiration_time = time() + Vip::TimeTypeDay[$vip->time_type];
                            } else {
                                $user->vip_expiration_time = $user->vip_expiration_time + Vip::TimeTypeDay[$vip->time_type];
                            }
                            // 企业会员权限
                            if (!empty($vip_company_auth)) {
                                $user->vip_company_auth = json_encode($vip_company_auth);
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

                            // 訂閱會員給邀請人增加積分
                            SystemIntegralConfig::saveData($user->inviter_id, $mark);

                            // 增加会员到期任务
                            VipExpiredJob::dispatch($user->id)->delay(now()->addDays($day));

                            // 商家续费会员 把状态下架的上架
                            if ($order->vip_type == Vip::OrderVipTypeCompany) {
                                CityContent::query()->where('user_id', $user->id)
                                    ->where('publisher_id', $user->company_id)
                                    ->where('publisher_type', 'company')
                                    ->where('status', 0)
                                    ->update(['status' => 1]);
                            }

                            // 下发付款凭证
                            InvoiceJob::dispatch($order->id);

                            // 下发付款凭证
//                            Mail::to($user->email)->send(new OrderBill($order->id));

                            DB::commit();
                        } catch (\Throwable $th) {
                            DB::rollBack();
                            Log::debug('SystemError' . $th->getMessage());
                        }
                    }
                }

                Log::info("Payment succeeded for order: {$orderId}");
                break;

            case 'payment_intent.payment_failed':
                // 支付失败
                $pi = $event->data->object;
                $orderId = $pi->metadata->order_id ?? null;

                if ($orderId) {
                    $order = VipOrder::query()->where('order_sn', $orderId)->first();
                    if ($order) {
                        $order->pay_status = 2;
                        $order->save();
                    }
                }

                Log::info("Payment failed for order: {$orderId}");
                break;
            default:
                Log::info('Received unknown event type ' . $event->type);
        }

        return response()->json(['received' => true]);
    }

}
