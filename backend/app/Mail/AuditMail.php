<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class AuditMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $tries = 1;

    public $timeout = 120;

    public $content;

    public function __construct($content)
    {
        $this->content = $content;
    }

    public function build()
    {
        return $this->view('email')
            ->from(env('MAIL_USERNAME'), 'LUMO GUIDE')
            ->with(['title' => '待審核通知', 'content' => $this->content])
            ->subject('LUMO GUIDE：新的待審核內容');
    }
}
