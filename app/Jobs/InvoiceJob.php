<?php

namespace App\Jobs;

use App\Enums\Vip;
use App\Mail\InvoiceMail;
use App\Models\CityContent;
use App\Models\Company;
use App\Models\Guide;
use App\Models\User;
use App\Models\VipCompany;
use App\Models\VipGuide;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class InvoiceJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $order_id;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct(int $order_id)
    {
        $this->order_id = $order_id;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {

        try {
            $order = \App\Models\VipOrder::find($this->order_id);

            $user_number = User::where('id', $order->id)->value('number');

            if ($order->vip_type == Vip::OrderVipTypeGuide) {
                $vip = VipGuide::find($order->vip_id);
                $user_info = Guide::query()->where('user_id', $order->user_id)->first(['name', 'email', 'bill_address as address']);
            } else {
                $vip = VipCompany::find($order->vip_id);
                $user_info = Company::query()->where('user_id', $order->user_id)->first(['name', 'email', 'address']);
            }

            if ($vip->time_type == 1) {
                $time_str_cn = '一個月';
                $time_str_en = 'one month';
                $time_str = "1 Mond";
            } else {
                $time_str_cn = '一年';
                $time_str_en = 'one year';
                $time_str = "1 Jahr";
            }

            $vip_name = $vip->name;
            $price = $order->price;

            $data = [
                "customer_id" => $user_number,
                "invoice_no" => (string)$order->id,
                "customer_name" => $user_info->name,
                "address" => $user_info->address,
                "date" => date('d.m.Y', strtotime($order->created_at)),
                "items" => [
                    [
                        "pos" => "1",
                        "qty" => "1",
                        "description" => "Vip: $vip_name<br/>Verlängerung 1 $time_str",
                        "unit_price" => "EUR $price",
                        "total_price" => "EUR $price",
                        "vat_rate" => "0%"
                    ]
                ],
                "total_net" => "EUR $price",
                "total_vat" => "EUR 0",
                "total_gross" => "EUR $price",
                "balance" => "EUR 0,00",
                "payment_status" => "Sie müssen diese Rechnung nicht bezahlen - sie wurde bereits bezahlt."
            ];


            $res = Http::post('http://127.0.0.1:8000/generate-pdf', $data);
            $file_data = $res->json();

            Log::debug(json_encode($file_data));

            if (isset($file_data['path'])) {
                Mail::to($user_info->email)->queue((new InvoiceMail($file_data['path'], [$time_str_cn, $time_str_en]))->onQueue('emails'));
            }
        } catch (\Exception $exception) {
            Log::debug($exception->getMessage());
        }
    }
}
