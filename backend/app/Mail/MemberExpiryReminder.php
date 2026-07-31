<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class MemberExpiryReminder extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $tries = 1;
    public $timeout = 120;

    public function __construct(
        public User $user,
        public string $stage,
        public $targetDate,
        public array $data,
    ) {}

    public function build(): self
    {
        $name = $this->user->nickname ?: ($this->user->name ?: 'User');
        $zhDate = $this->targetDate->format('Y年n月j日');
        $enDate = $this->targetDate->format('F j, Y');

        $emailBody = $this->buildEmailBody($name, $zhDate, $enDate);

        return $this->view('emails.member_expiry_reminder')
            ->from(config('mail.from.address'), 'LUMO GUIDE')
            ->with([
                'title'      => $this->data['title'],
                'user_name'  => $name,
                'zh_date'    => $zhDate,
                'en_date'    => $enDate,
                'stage'      => $this->stage,
                'email_body' => $emailBody,
            ])
            ->subject($this->data['title']);
    }

    private function buildEmailBody(string $name, string $zhDate, string $enDate): array
    {
        $configs = [
            '30d' => [
                'zh_body' => "感謝您一直以來對 LUMOGUIDE 的支持！您的會員資格將於 {$zhDate} 到期，距離到期還有 30 天。為確保您的會員權益不受影響，歡迎您提前登入平台，前往「會員中心」延長會員資格。",
                'en_body' => "Thank you for your continued support of LUMOGUIDE! Your membership will expire on {$enDate}, with 30 days remaining. To ensure uninterrupted access to your membership benefits, we recommend renewing early by visiting the Membership Center.",
                'zh_close' => '如有任何疑問，歡迎聯繫我們。',
                'en_close' => 'If you have any questions, please feel free to contact us.',
            ],
            '10d' => [
                'zh_body' => "溫馨提醒，您的 LUMOGUIDE 會員資格將於 {$zhDate} 到期，僅剩 10 天。到期後部分會員功能將受到限制，建議您盡早登入平台，前往「會員中心」延長資格，確保功能不受影響。",
                'en_body' => "A friendly reminder — your LUMOGUIDE membership will expire on {$enDate}, with only 10 days left. Some membership features will be restricted after expiration. We recommend renewing soon by visiting the Membership Center to keep your account fully active.",
                'zh_close' => '',
                'en_close' => '',
            ],
            '3d' => [
                'zh_body' => "您的 LUMOGUIDE 會員資格將於 {$zhDate} 到期，僅剩 3 天。到期後您的會員功能將立即暫停，請盡快登入平台前往「會員中心」延長資格。",
                'en_body' => "Your LUMOGUIDE membership will expire on {$enDate} — only 3 days remaining. Your membership features will be suspended immediately upon expiration. Please log in and visit the Membership Center to renew as soon as possible.",
                'zh_close' => '',
                'en_close' => '',
            ],
            '1d' => [
                'zh_body' => "這是最後一次提醒——您的 LUMOGUIDE 會員資格將於明天（{$zhDate}）到期。明天起，您的會員功能將被暫停。現在是最後的續費時機！",
                'en_body' => "This is your final reminder — your LUMOGUIDE membership expires tomorrow ({$enDate}). Starting tomorrow, your membership features will be suspended. This is your last chance to renew!",
                'zh_close' => '如需協助，請隨時聯繫我們：' . config('mail.from.address'),
                'en_close' => 'If you need assistance, please contact us at: ' . config('mail.from.address'),
            ],
        ];

        return $configs[$this->stage] ?? $configs['30d'];
    }
}
