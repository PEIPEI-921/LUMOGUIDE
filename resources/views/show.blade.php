<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>支付凭证</title>
    <style>
        body { font-family: sans-serif; background: #f5f6fa; padding: 40px; }
        .card {
            background: white; padding: 30px; max-width: 500px; margin: auto;
            border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .title { font-size: 22px; font-weight: 700; margin-bottom: 20px; }
        .row { margin-bottom: 12px; font-size: 16px; }
        .label { color: #666; }
        .value { font-weight: 600; }
    </style>
</head>
<body>

<div class="card">
    <div class="title">💳 支付凭证</div>

    <div class="row"><span class="label">订单号：</span><span class="value">{{ $order->order_sn }}</span></div>

    <div class="row"><span class="label">会员套餐：</span><span class="value">{{ $vip_name }}</span></div>

    <div class="row"><span class="label">支付金额：</span><span class="value">€{{ $order->price.'/'.\App\Enums\Vip::TimeType[$order->time_type] }}</span></div>

    <div class="row"><span class="label">支付方式：</span><span class="value">{{ \App\Enums\Vip::BuyType[$order->buy_type] }}</span></div>

    <div class="row"><span class="label">支付时间：</span><span class="value">{{ date('Y-m-d H:i:s',$order->pay_time) }}</span></div>

    <hr style="margin: 20px 0;">

    <p>如需帮助，请联系客户支持：</p>
    <p>📧 Email：{{env('MAIL_FROM_ADDRESS')}}</p>
</div>

</body>
</html>
