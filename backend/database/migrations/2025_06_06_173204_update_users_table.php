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
        // 修改用户表
        Schema::table('users', function (Blueprint $table) {
            $table->string('number', 50)->comment('编号')->nullable();
            $table->string('avatar', 255)->comment('头像')->nullable();
            $table->string('nickname', 50)->comment('昵称')->nullable();
            $table->string('phone', 15)->comment('手机号')->nullable();
            $table->string('birthday', 20)->comment('生日')->nullable();
            $table->integer('inviter_id')->default(0)->comment('我的邀请人ID');
            $table->string('inviter_code', 10)->comment('邀请码');
            $table->integer('integral')->default(0)->comment('积分');
            $table->boolean('identity')->default(1)->comment('身份');
            $table->string('identity_str', 30)->nullable()->comment('身份');
            $table->integer('continents_id')->default(0)->comment('所属大洲ID');
            $table->integer('area_id')->default(0)->comment('所属地区ID');
            $table->integer('city')->default(0)->comment('所在城市');
            $table->string('city_name')->comment('所在城市')->nullable();
            $table->boolean('vip_type')->default(0)->comment('会员类型');
            $table->integer('vip_id')->default(0)->comment('会员ID');
            $table->string('vip_name')->comment('会员')->nullable();
            $table->integer('vip_expiration_time')->default(0)->comment('会员到期时间');
            $table->boolean('vip_free')->default(0)->comment('会员是否免费');
            $table->json('vip_company_auth')->nullable()->comment('企业会员权限');
            $table->bigInteger('guide_id')->default(0)->comment('导游ID');
            $table->bigInteger('company_id')->default(0)->comment('企业ID');
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
    }
};
