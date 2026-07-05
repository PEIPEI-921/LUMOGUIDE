<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendCodeMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $code;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($code)
    {
        $this->code = $code;
    }

    public function build()
    {
        $content = "
此郵件為LUMO GUIGE自動送出。<br>
-------------------------<br>
您的信箱驗證碼: 【{$this->code}】<br>
10分鐘內不使用,驗證碼將失效<br><br><br>
This email was automatically sent by LUMO GUIGE.<br>
------------------------- <br>
Your email verification code: 【{$this->code}】 <br>
The verification code will expire if not used within 10 minutes.<br>";

        return $this->view('email')
            ->from(config('mail.from.address'), 'LUMO GUIDE')
            ->with(['title' => 'Verify email messages', 'content' => $content])
            ->subject("【{$this->code}】LUMO GUIGE：Verify email messages");
    }

}
