<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class VipExpiredMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $tries = 1;

    public $timeout = 120;

    public $content;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($content)
    {
        $this->content = $content;
    }

    public function build()
    {
        return $this->view('email')
            ->from(env('MAIL_USERNAME'), 'LUMO GUIDE')
            ->with(['title' => 'Vip Expired', 'content' => $this->content])
            ->subject("Subscription membership expiration reminder");
    }

}
