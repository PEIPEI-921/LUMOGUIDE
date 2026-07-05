<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // 预约导游
        Schema::create('reserve_guide', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('guide_id')->default(0)->comment('导游ID');
            $table->integer('city_id')->default(0)->comment('预约城市ID');
            $table->string('arrival_time', 20)->nullable()->comment('到达时间');
            $table->string('number', 10)->nullable()->comment('人数/入驻人数');
            $table->string('remark', 255)->nullable()->comment('备注/其他要求');
            $table->string('contact', 20)->nullable()->comment('联系人');
            $table->string('email', 20)->nullable()->comment('邮箱');
            $table->string('phone', 20)->nullable()->comment('电话');
            $table->string('other', 20)->nullable()->comment('其他联系方式');
            $table->boolean('status')->default(1)->comment('预约状态');
            $table->string('reason', 255)->nullable()->comment('原因');
            $table->boolean('is_read')->default(1)->comment('是否已读');
            $table->boolean('user_del')->default(0)->comment('预约人删除');
            $table->boolean('guide_del')->default(0)->comment('被预约人删除');
            $table->timestamps();
        });

        // 预约
        Schema::create('reserves', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('company_id')->default(0)->comment('企业ID');
            $table->integer('city_id')->default(0)->comment('预约城市ID');
            $table->tinyInteger('content_type')->default(0)->comment('预约内容类型');
            $table->integer('content_id')->default(0)->comment('预约内容ID');
            $table->string('tickets_type', 20)->nullable()->comment('门票类型');
            $table->string('arrival_time', 20)->nullable()->comment('到达时间');
            $table->string('leave_time', 20)->nullable()->comment('离开时间');
            $table->string('number', 10)->nullable()->comment('人数');
            $table->string('room_number', 10)->nullable()->comment('房间数');
            $table->string('remark', 255)->nullable()->comment('备注');
            $table->string('file', 255)->nullable()->comment('购物客户名单');
            $table->string('contact', 20)->nullable()->comment('联系人');
            $table->string('email', 20)->nullable()->comment('邮箱');
            $table->string('phone', 20)->nullable()->comment('电话');
            $table->string('other', 20)->nullable()->comment('其他联系方式');
            $table->boolean('status')->default(1)->comment('预约状态');
            $table->string('reason', 255)->nullable()->comment('原因');
            $table->boolean('is_read')->default(1)->comment('是否已读');
            $table->boolean('user_del')->default(0)->comment('预约人删除');
            $table->boolean('company_del')->default(0)->comment('被预约人删除');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('reserve_guide');
        Schema::dropIfExists('reserves');
    }
};
