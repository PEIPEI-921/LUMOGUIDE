<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * 补充 users.im_login 列（历史环境为手动 ALTER 添加，未入迁移）
     * 带 hasColumn 保护：已存在该列的生产库不会重复添加。
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'im_login')) {
                $table->boolean('im_login')->default(0)->comment('IM 账号是否已导入');
            }
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'im_login')) {
                $table->dropColumn('im_login');
            }
        });
    }
};
