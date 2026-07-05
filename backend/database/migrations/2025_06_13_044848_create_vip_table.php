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
        // 导游VIP
        Schema::create('vip_guide', function (Blueprint $table) {
            $table->id();
            $table->string('name')->comment('名称');
            $table->boolean('time_type')->default(1)->comment('时间类型');
            $table->boolean('buy_type')->default(1)->comment('购买类型');
            $table->decimal('price', 10, 2)->default(0)->comment('金额');
            $table->timestamps();
        });

        // 企业VIP
        Schema::create('vip_company', function (Blueprint $table) {
            $table->id();
            $table->string('name')->comment('名称');
            $table->boolean('time_type')->default(1)->comment('时间类型');
            $table->boolean('buy_type')->default(1)->comment('购买类型');
            $table->decimal('price', 10, 2)->default(0)->comment('金额');
            $table->tinyInteger('number')->default(1)->comment('可添加店铺数量');
            $table->boolean('shop_type')->default(1)->comment('添加店铺是否同类型');
            $table->tinyInteger('city_content_recommend')->default(1)->comment('城市内容推荐天数');
            $table->tinyInteger('home_list_recommend')->default(1)->comment('首页列表推荐');
            $table->tinyInteger('home_banner_recommend')->default(1)->comment('首页banner推荐');
            $table->timestamps();
        });


        // vip订单
        Schema::create('vip_order', function (Blueprint $table) {
            $table->id();
            $table->string('order_sn', 32)->comment('订单编号');
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->boolean('vip_type')->default(0)->comment('会员类型');
            $table->integer('vip_id')->default(0)->comment('会员ID');
            $table->decimal('price', 10, 2)->default(0)->comment('支付金额');
            $table->boolean('time_type')->default(1)->comment('时间类型');
            $table->boolean('buy_type')->default(1)->comment('支付方式 金额/积分');
            $table->integer('pay_time')->default(0)->comment('支付时间');
            $table->boolean('pay_status')->default(0)->comment('支付状态');
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
        Schema::dropIfExists('vip_guide');
        Schema::dropIfExists('vip_company');
        Schema::dropIfExists('vip_order');
    }
};
