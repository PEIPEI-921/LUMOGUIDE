<?php

namespace App\Console\Commands;

use App\Models\City;
use App\Models\CityContent;
use App\Models\CityContentEdit;
use App\Models\CityEdit;
use App\Models\SystemMessage;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class CleanRejectedContent extends Command
{
    protected $signature = 'clean:rejected-content {--days=7 : Days until auto-delete}';
    protected $description = 'Notify users 3 days before auto-deleting rejected content, then delete at 7 days';

    public function handle()
    {
        $days = (int) $this->option('days');
        $cutoff = now()->subDays($days);
        $notifyCutoff = now()->subDays($days - 3); // Notify 3 days before deletion
        $totalDeleted = 0;
        $totalNotified = 0;

        // ========== City Content ==========

        // Step 1: Notify users for content approaching deletion (4 days after rejection)
        $notifyContent = CityContent::where('audit_status', 2)
            ->where('updated_at', '<', $notifyCutoff)
            ->whereNull('reject_notified_at')
            ->get();

        foreach ($notifyContent as $c) {
            $name = $c->name ?: '未命名內容';
            SystemMessage::saveData(
                $c->user_id,
                '內容即將刪除',
                "「{$name}」將於3天後自動刪除",
                "您提交的內容「{$name}」因審核未通過，將於3天後自動刪除。如需保留，請及時修改並重新提交審核。"
            );
            CityContent::where('id', $c->id)->update(['reject_notified_at' => now()]);
            $totalNotified++;
        }

        // Step 2: Delete expired content (7 days after rejection)
        $contents = CityContent::where('audit_status', 2)
            ->where('updated_at', '<', $cutoff)
            ->get();

        foreach ($contents as $c) {
            CityContentEdit::where('city_content_id', $c->id)->delete();
            $c->delete();
            $totalDeleted++;
        }

        // ========== Cities ==========

        // Step 1: Notify users for cities approaching deletion
        $notifyCities = City::where('audit_status', 2)
            ->where('updated_at', '<', $notifyCutoff)
            ->whereNull('reject_notified_at')
            ->get();

        foreach ($notifyCities as $c) {
            $name = $c->name ?: '未命名城市';
            SystemMessage::saveData(
                $c->user_id,
                '城市即將刪除',
                "「{$name}」將於3天後自動刪除",
                "您提交的城市「{$name}」因審核未通過，將於3天後自動刪除。如需保留，請及時修改並重新提交審核。"
            );
            City::where('id', $c->id)->update(['reject_notified_at' => now()]);
            $totalNotified++;
        }

        // Step 2: Delete expired cities
        $cities = City::where('audit_status', 2)
            ->where('updated_at', '<', $cutoff)
            ->get();

        foreach ($cities as $c) {
            CityEdit::where('city_id', $c->id)->delete();
            $c->delete();
            $totalDeleted++;
        }

        // Summary
        $this->info("Notified: {$totalNotified} users (>{$notifyCutoff->diffInDays(now())} days, 3 days before deletion).");
        $this->info("Deleted: {$totalDeleted} records (>{$days} days).");

        if ($totalNotified > 0 || $totalDeleted > 0) {
            Log::info("clean:rejected-content — notified {$totalNotified}, deleted {$totalDeleted}");
        }
    }
}
