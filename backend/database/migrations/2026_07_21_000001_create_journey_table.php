<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        // 我的历程 — 工作日
        Schema::create('journey_work', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('title', 100)->nullable()->comment('标题（搜索用）');
            $table->tinyInteger('status')->default(1)->comment('状态 1草稿/2发布');
            $table->integer('area_id')->default(0)->comment('区域ID（筛选用）');
            $table->json('content')->comment('完整 JourneyWork JSON');
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('status');
            $table->index('area_id');
        });

        // 工作模板
        Schema::create('journey_template', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('title', 100)->nullable()->comment('模板标题');
            $table->json('content')->comment('完整模板 JSON');
            $table->timestamps();

            $table->index('user_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('journey_template');
        Schema::dropIfExists('journey_work');
    }
};
