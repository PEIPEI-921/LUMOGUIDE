<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('member_notifications', function (Blueprint $table) {
            $table->id();
            $table->bigInteger('user_id');
            $table->date('expire_date');
            $table->string('stage', 10)->comment('30d / 10d / 3d / 1d');
            $table->string('channel', 10)->comment('system / email');
            $table->timestamp('sent_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'expire_date', 'stage', 'channel'], 'uk_user_stage_channel');
            $table->index('expire_date');
        });
    }

    public function down()
    {
        Schema::dropIfExists('member_notifications');
    }
};
