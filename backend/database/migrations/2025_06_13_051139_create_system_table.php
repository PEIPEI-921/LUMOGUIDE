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
        // 系统配置表
        Schema::create('system_config', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->string('name', 30)->comment('配置名称');
            $table->boolean('type')->default(0)->comment('类型');
            $table->string('mark', 30)->comment('配置标识');
            $table->text('value')->comment('配置内容');
            $table->timestamps();
        });

        // 系统消息
        Schema::create('system_message', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('title', 30)->comment('标题');
            $table->string('desc', 255)->comment('描述');
            $table->string('content', 1000)->comment('内容');
            $table->boolean('is_read')->default(0)->comment('读取状态');
            $table->timestamps();
        });

        // 系统通知
        Schema::create('system_notify', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->string('type', 10)->comment('通知类型');
            $table->string('title', 30)->comment('通知标题');
            $table->integer('user_id')->default(0)->comment('接受用户ID');
            $table->integer('content_id')->comment('内容ID');
            $table->boolean('is_read')->default(0)->comment('读取状态');
            $table->timestamps();
        });

        // 联系我们
        Schema::create('system_contact_us', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('title', 30)->comment('标题');
            $table->string('email', 30)->comment('邮箱');
            $table->string('content', 255)->comment('内容');
            $table->timestamps();
        });

        // 意见反馈
        Schema::create('system_feedback', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('title', 30)->comment('标题');
            $table->string('content', 255)->comment('内容');
            $table->string('pictures', 1000)->nullable()->comment('上传图片');
            $table->timestamps();
        });


        // 大洲/地区 管理
        Schema::create('system_continents', function (Blueprint $table) {
            $table->id();
            $table->integer('parent_id')->default(0);
            $table->string('name', 30)->comment('名称');
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // 地区管理
        Schema::create('system_area', function (Blueprint $table) {
            $table->id();
            $table->bigInteger('parent_id')->default(0);
            $table->string('name', 30)->comment('名称');
            $table->integer('order')->default(0);
            $table->timestamps();
        });


        // 系统积分配置
        Schema::create('system_integral_config', function (Blueprint $table) {
            $table->id();
            $table->string('name', 30);
            $table->string('key', 30);
            $table->integer('value')->default(0);
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
        Schema::dropIfExists('system_config');
        Schema::dropIfExists('system_message');
        Schema::dropIfExists('system_notify');
        Schema::dropIfExists('system_contact_us');
        Schema::dropIfExists('system_feedback');
        Schema::dropIfExists('system_continents');
        Schema::dropIfExists('system_area');
        Schema::dropIfExists('system_integral_config');
    }
};
