<?php

namespace App\Console\Commands;

use App\Models\MemberNotification;
use App\Models\SystemMessage;
use App\Models\User;
use App\Mail\MemberExpiryReminder;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class MemberExpiryRemind extends Command
{
    protected $signature = 'member:expiry-remind';
    protected $description = 'Send membership expiry reminders at 30/10/3/1 days before expiration';

    private const STAGES = [
        '30d' => 30,
        '10d' => 10,
        '3d'  => 3,
        '1d'  => 1,
    ];

    public function handle(): void
    {
        $today = now()->startOfDay();

        foreach (self::STAGES as $stage => $days) {
            $targetDate = $today->copy()->addDays($days);
            $targetTs = $targetDate->timestamp;
            $endTs = $targetDate->copy()->endOfDay()->timestamp;

            $users = User::whereBetween('vip_expiration_time', [$targetTs, $endTs])
                ->where('vip_type', '>', 0)
                ->get();

            foreach ($users as $user) {
                $this->processUser($user, $stage, $targetDate);
            }
        }

        $this->info('Member expiry reminders sent.');
    }

    private function processUser(User $user, string $stage, $targetDate): void
    {
        // Deduplication check
        $alreadySent = MemberNotification::where('user_id', $user->id)
            ->where('expire_date', $targetDate->toDateString())
            ->where('stage', $stage)
            ->where('channel', 'system')
            ->exists();

        if ($alreadySent) {
            return;
        }

        $data = $this->buildMessageData($user, $stage, $targetDate);

        // 1. System message
        SystemMessage::saveDataWithType(
            $user->id,
            $data['title'],
            $data['desc'],
            $data['content'],
            'membership'
        );

        MemberNotification::create([
            'user_id'     => $user->id,
            'expire_date' => $targetDate->toDateString(),
            'stage'       => $stage,
            'channel'     => 'system',
            'sent_at'     => now(),
        ]);

        // 2. Email
        try {
            Mail::to($user->email)->send(
                new MemberExpiryReminder($user, $stage, $targetDate, $data)
            );

            MemberNotification::create([
                'user_id'     => $user->id,
                'expire_date' => $targetDate->toDateString(),
                'stage'       => $stage,
                'channel'     => 'email',
                'sent_at'     => now(),
            ]);
        } catch (\Throwable $e) {
            Log::error("MemberExpiryRemind: Failed to send email to {$user->email}: {$e->getMessage()}");
        }
    }

    private function buildMessageData(User $user, string $stage, $targetDate): array
    {
        $zhDate = $targetDate->format('Y年n月j日');
        $enDate = $targetDate->format('F j, Y');
        $name = $user->nickname ?: ($user->name ?: 'User');

        $templates = $this->stageTemplates();
        $tpl = $templates[$stage];

        $replace = fn(string $text) => str_replace(
            ['{user_name}', '{expire_date_zh}', '{expire_date_en}', '{contact_email}'],
            [$name, $zhDate, $enDate, config('mail.from.address')],
            $text
        );

        return [
            'title'   => $replace($tpl['title']),
            'desc'    => $replace($tpl['desc']),
            'content' => $replace($tpl['content']),
        ];
    }

    private function stageTemplates(): array
    {
        return [
            '30d' => [
                'title'   => '您的 LUMOGUIDE 會員將於 30 天後到期 / Your LUMOGUIDE Membership Expires in 30 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，還剩 30 天。請提前前往會員中心延長資格。',
                'content' => "{user_name} 您好，您的會員資格將於 {expire_date_zh} 到期，還剩 30 天。建議您提前前往 會員中心 延長資格，持續享受會員專屬權益。\n\nDear {user_name}, your LUMOGUIDE membership will expire on {expire_date_en}, with 30 days remaining. Please visit the Membership Center to renew and continue enjoying your exclusive benefits.",
            ],
            '10d' => [
                'title'   => '您的 LUMOGUIDE 會員將於 10 天後到期 / Your LUMOGUIDE Membership Expires in 10 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，僅剩 10 天。到期後部分功能將受限，請盡快延長資格。',
                'content' => "{user_name} 您好，您的會員資格將於 {expire_date_zh} 到期，僅剩 10 天。到期後部分會員功能將受限，請前往 會員中心 盡快延長資格。\n\nDear {user_name}, your LUMOGUIDE membership will expire on {expire_date_en}, with only 10 days left. Some features will be restricted after expiration. Please visit the Membership Center to renew as soon as possible.",
            ],
            '3d' => [
                'title'   => '⚠️ 您的 LUMOGUIDE 會員將於 3 天後到期 / ⚠️ Your Membership Expires in 3 Days',
                'desc'    => '您的會員資格將於 {expire_date_zh} 到期，僅剩 3 天！請立即前往會員中心延長資格。',
                'content' => "{user_name} 您好，您的會員資格將於 {expire_date_zh} 到期，僅剩 3 天！到期後會員功能將暫停，請立即前往 會員中心 延長資格，以免影響使用。\n\nDear {user_name}, your LUMOGUIDE membership will expire on {expire_date_en} — only 3 days left! Membership features will be suspended after expiration. Please visit the Membership Center now to renew and avoid any disruption.",
            ],
            '1d' => [
                'title'   => '🔴 您的 LUMOGUIDE 會員將於明天到期 / 🔴 Your Membership Expires Tomorrow',
                'desc'    => '您的會員資格將於明天（{expire_date_zh}）到期！請把握最後機會，立即前往會員中心延長資格。',
                'content' => "{user_name} 您好，您的會員資格將於明天（{expire_date_zh}）到期！明天起會員功能將暫停。請把握最後機會，立即前往 會員中心 延長資格。如有疑問請聯繫客服。\n\nDear {user_name}, your LUMOGUIDE membership expires tomorrow ({expire_date_en})! Membership features will be suspended starting tomorrow. Please seize this final opportunity — visit the Membership Center now to renew. Contact customer service if you have any questions.",
            ],
        ];
    }
}
