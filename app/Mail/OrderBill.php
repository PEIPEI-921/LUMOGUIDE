<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OrderBill extends Mailable
{
    use Queueable, SerializesModels;

    public $order_id;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($order_id)
    {
        $this->order_id = $order_id;
    }

    public function build()
    {
        $order = \App\Models\VipOrder::find($this->order_id);

        if ($order->vip_type == \App\Enums\Vip::OrderVipTypeGuide) {
            $vip = $order->guide_vip;
            $vip_name = "导游会员-" . $vip->name;
        } else {
            $vip = $order->company_vip;
            $vip_name = "企业会员-" . $vip->name;
        }

        return $this->view('show')
            ->from(env('MAIL_USERNAME'), '會員支付憑證')
            ->with(['order' => $order, 'vip_name' => $vip_name])
            ->subject("LuMo：Membership purchase billing records");
    }

}
