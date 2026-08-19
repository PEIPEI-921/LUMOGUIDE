<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('deferred_deep_links', function (Blueprint $table) {
            $table->id();
            $table->string('token', 32)->unique()->comment('隨機 token，用於剪貼板/InstallReferrer 匹配');
            $table->string('inviter_code', 10)->default('')->comment('邀請碼');
            $table->string('content_type', 20)->comment('內容類型：guide/city/content/trip/invite');
            $table->integer('content_id')->default(0)->comment('內容 ID');
            $table->string('ip_address', 45)->default('')->comment('IP 地址，用於備用匹配');
            $table->string('user_agent', 500)->default('');
            $table->unsignedTinyInteger('consumed')->default(0)->comment('是否已消費');
            $table->timestamp('created_at')->useCurrent();
            $table->index(['ip_address', 'created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('deferred_deep_links');
    }
};
