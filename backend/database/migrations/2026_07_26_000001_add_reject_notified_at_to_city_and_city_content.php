<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddRejectNotifiedAtToCityAndCityContent extends Migration
{
    public function up()
    {
        Schema::table('city_content', function (Blueprint $table) {
            $table->timestamp('reject_notified_at')->nullable()->after('audit_feedback')->comment('駁回通知時間');
        });
        Schema::table('city', function (Blueprint $table) {
            $table->timestamp('reject_notified_at')->nullable()->after('audit_feedback')->comment('駁回通知時間');
        });
    }

    public function down()
    {
        Schema::table('city_content', function (Blueprint $table) {
            $table->dropColumn('reject_notified_at');
        });
        Schema::table('city', function (Blueprint $table) {
            $table->dropColumn('reject_notified_at');
        });
    }
}
