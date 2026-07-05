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
        // 积分商品分类
        Schema::create('integral_goods_class', function (Blueprint $table) {
            $table->id();
            $table->string('name', 50)->comment('名称');
            $table->bigInteger('parent_id')->default(0);
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // 积分商品
        Schema::create('integral_goods', function (Blueprint $table) {
            $table->id();
            $table->integer('class_id')->default(0)->comment('分类ID');
            $table->string('picture', 255)->nullable()->comment('图片');
            $table->string('pictures', 1000)->nullable()->comment('图片组');
            $table->string('name', 50)->comment('名称');
            $table->boolean('goods_type')->default(1)->comment('商品类型');
            $table->integer('price')->default(0)->comment('积分金额');
            $table->boolean('free_shipping')->default(0)->comment('是否包邮');
            $table->integer('sales')->default(0)->comment('销量');
            $table->text('content')->nullable()->comment('商品详情');
            $table->boolean('recommend')->default(0)->comment('推荐');
            $table->integer('order')->default(0);
            $table->integer('stock')->default(0);
            $table->boolean('status')->default(0);
            $table->timestamps();
        });

        // 用户积分明细
        Schema::create('user_integral_log', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->boolean('type')->default(1)->comment('类型 1支出/2收入');
            $table->string('title', 50)->comment('标题');
            $table->integer('before')->default(0)->comment('变动金额之前');
            $table->integer('amount')->default(0)->comment('变动金额');
            $table->integer('after')->default(0)->comment('变动金额之后');
            $table->timestamps();
        });

        // 用户积分订单
        Schema::create('user_integral_order', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->string('order_sn', 32)->comment('订单编号');
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('user_address_id')->default(0)->comment('用户地址ID');
            $table->integer('integral_goods_id')->default(0)->comment('积分商品ID');
            $table->json('integral_goods_info')->nullable()->comment('积分商品信息');
            $table->integer('price')->default(0)->comment('消费积分');
            $table->boolean('free_shipping')->default(0)->comment('是否包邮');
            $table->timestamp('pay_time')->comment('支付时间');
            $table->boolean('status')->default(0)->comment('状态');
            $table->string('express_delivery_company', 30)->nullable()->comment('快递公司');
            $table->string('express_delivery_number', 30)->nullable()->comment('快递单号');
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
        Schema::dropIfExists('integral_goods_class');
        Schema::dropIfExists('integral_goods');
        Schema::dropIfExists('user_integral_log');
        Schema::dropIfExists('user_integral_order');
    }
};
