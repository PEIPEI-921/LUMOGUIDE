<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class InvoiceMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $file_path;
    public $str_arr;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($file_path, $str_arr)
    {
        $this->file_path = $file_path;
        $this->str_arr = $str_arr;
    }

    public function build()
    {
        [$time_str_cn, $time_str_en] = $this->str_arr;

        $date_str_cn = date('Y年m月d日');
        $date_str_en = date('Y-m-d');

        $content = "尊敬的LUMO GUIGE的用戶<br>
您在 $date_str_cn 購買了延長 {$time_str_cn} 的會員服務，附件中是您的付款收據，請查收。<br>
謝謝您對 LUMO GUIGE 的信任和支持， LUMO GUIDE 願繼續為您誠摯服務。<br><br>

Dear LUMO GUIGE User,<br>
We are writing to confirm that you have successfully purchased a <b>$time_str_en</b> membership extension on <b>$date_str_en</b>.<br>
Please find your payment receipt attached to this email for your records.<br>
Thank you for your continued trust and support in LUMO GUIGE. We look forward to serving you and providing you with the best possible experience.<br>
Best regards,<br>
<b>The LUMO GUIGE Team</b><br>
";

        return $this->view('email')
            ->from(env('MAIL_USERNAME'), 'LUMO GUIDE')
            ->with(['title' => 'Membership fee receipt', 'content' => $content])
            ->subject("LUMO GUIGE：Membership fee receipt")
            ->attach($this->file_path, [
                'as' => 'LUMO GUIDE_Receipt.pdf',
                'mime' => 'application/pdf',
            ]);
    }

}
