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

        // 导游类型
        Schema::create('guide_type', function (Blueprint $table) {
            $table->id();
            $table->bigInteger('parent_id')->default(0);
            $table->string('name', 30)->comment('名称');
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // 导游表
        Schema::create('guides', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('city_id')->default(0)->comment('城市ID');
            $table->integer('continents_id')->default(0)->comment('所属大洲ID');
            $table->integer('area_id')->default(0)->comment('所属地区ID');
            $table->string('city_name')->nullable()->comment('城市名称');
            $table->string('photo', 255)->nullable()->comment('照片/LOGO');
            $table->string('name', 50)->comment('真实姓名');
            $table->string('phone', 20)->comment('联系电话');
            $table->string('email', 50)->comment('邮箱地址');
            $table->string('bill_address', 50)->comment('账单地址');
            $table->string('other_contact', 50)->comment('其他联系方式');
            $table->json('language')->nullable()->comment('语言');
            $table->string('year', 10)->comment('从业年份');
//            $table->string('inviter_code', 10)->comment('邀请人的邀请码');
//            $table->integer('inviter_uid')->default(0)->comment('邀请人ID');
            $table->json('industry_type')->nullable()->comment('从事旅游行业类型');
            $table->integer('identity_type')->default(0)->comment('展示身份类型');
            $table->string('other_type')->nullable()->comment('其他类型');
            $table->string('wechat')->nullable()->comment('微信');
            $table->string('whats_app')->nullable()->comment('WhatsApp');
            $table->string('line')->nullable()->comment('LINE');
            $table->string('introduction', 255)->comment('简介');
            $table->string('business_contact', 20)->comment('从业联系人');
            $table->boolean('have_vehicle')->default(0)->comment('是否有车');
            $table->string('vehicle_info', 255)->nullable()->comment('车辆信息');
            $table->boolean('vehicle_rent')->default(0)->comment('车辆是否出租');
            $table->string('certificate_picture', 255)->nullable()->comment('资格证书图片');
            $table->string('passport_picture', 255)->nullable()->comment('护照证件图片');
            $table->string('driver_license_front', 255)->nullable()->comment('驾照正面');
            $table->string('driver_license_back', 255)->nullable()->comment('驾照背面');
            $table->json('car_pictures')->nullable()->comment('车辆照片');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->timestamp('audit_time')->nullable();
            $table->boolean('recommend')->default(0)->comment('推荐');
            $table->boolean('hot_recommend')->default(0)->comment('首页推荐');
            $table->integer('order')->default(0);
            $table->boolean('is_finish')->default(0)->comment('是否完成');
            $table->timestamps();
        });


        // 导游修改表
        Schema::create('guide_edit', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('guide_id')->default(0)->comment('导游ID');
            $table->string('photo', 255)->nullable()->comment('照片/LOGO');
            $table->string('name', 50)->comment('真实姓名');
            $table->string('phone', 20)->comment('联系电话');
            $table->string('email', 50)->comment('邮箱地址');
            $table->string('bill_address', 50)->comment('账单地址');
            $table->string('other_contact', 50)->comment('其他联系方式');
            $table->json('language')->nullable()->comment('语言');
            $table->string('year', 10)->comment('从业年份');
            $table->json('industry_type')->nullable()->comment('从事旅游行业类型');
            $table->integer('identity_type')->default(0)->comment('展示身份类型');
            $table->string('other_type')->nullable()->comment('其他类型');
            $table->string('wechat')->nullable()->comment('微信');
            $table->string('whats_app')->nullable()->comment('WhatsApp');
            $table->string('line')->nullable()->comment('LINE');
            $table->string('introduction', 255)->comment('简介');
            $table->string('business_contact', 20)->comment('从业联系人');
            $table->boolean('have_vehicle')->default(0)->comment('是否有车');
            $table->string('vehicle_info', 255)->nullable()->comment('车辆信息');
            $table->boolean('vehicle_rent')->default(0)->comment('车辆是否出租');
            $table->string('certificate_picture', 255)->nullable()->comment('资格证书图片');
            $table->string('passport_picture', 255)->nullable()->comment('护照证件图片');
            $table->string('driver_license_front', 255)->nullable()->comment('驾照正面');
            $table->string('driver_license_back', 255)->nullable()->comment('驾照背面');
            $table->json('car_pictures')->nullable()->comment('车辆照片');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->timestamps();
        });

        // 企业/商家表
        Schema::create('company', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('name', 255)->comment('公司名称');
            $table->integer('city_id')->default(0)->comment('所在城市');
            $table->string('city_name')->comment('所在城市')->nullable();
            $table->string('address', 255)->comment('公司地址');
            $table->string('tax_id', 255)->comment('公司税号');
            $table->string('business_type', 10)->comment('经营类型');
            $table->string('introduction', 255)->comment('简介');
            $table->string('email', 50)->comment('Email');
            $table->string('phone', 50)->comment('联系电话');
            $table->string('website', 50)->comment('公司网址');
            $table->string('other_contact', 50)->comment('其他联系方式');
            $table->string('wechat')->nullable()->comment('微信');
            $table->string('whats_app')->nullable()->comment('WhatsApp');
            $table->string('line')->nullable()->comment('LINE');
            $table->string('documents_picture', 255)->nullable()->comment('证件图片');
            $table->json('picture')->nullable()->comment('商家图片');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->timestamp('audit_time')->nullable();
            $table->boolean('recommend')->default(0)->comment('推荐');
            $table->boolean('is_finish')->default(0)->comment('是否完成');
            $table->timestamps();
        });

        // 企业修改表
        Schema::create('company_edit', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('company_id')->default(0)->comment('企业ID');
            $table->string('name', 255)->comment('公司名称');
            $table->integer('city_id')->default(0)->comment('所在城市');
            $table->string('city_name')->comment('所在城市')->nullable();
            $table->string('address', 255)->comment('公司地址');
            $table->string('tax_id', 255)->comment('公司税号');
            $table->string('business_type', 10)->comment('经营类型');
            $table->string('introduction', 255)->comment('简介');
            $table->string('email', 50)->comment('Email');
            $table->string('phone', 50)->comment('联系电话');
            $table->string('website', 50)->comment('公司网址');
            $table->string('other_contact', 50)->comment('其他联系方式');
            $table->string('wechat')->nullable()->comment('微信');
            $table->string('whats_app')->nullable()->comment('WhatsApp');
            $table->string('line')->nullable()->comment('LINE');
            $table->string('documents_picture', 255)->nullable()->comment('证件图片');
            $table->json('picture')->nullable()->comment('商家图片');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->timestamps();
        });


        // 邀请记录
        Schema::create('user_invite_log', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('邀请人用户ID');
            $table->integer('invitees_uid')->default(0)->comment('被邀请人用户ID');
            $table->timestamps();
        });


        // 用户地址
        Schema::create('user_address', function (Blueprint $table) {
            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('name', 30)->comment('姓名');
            $table->string('phone', 30)->comment('联系电话');
            $table->string('country', 30)->comment('國家');
            $table->integer('country_id')->default(0)->comment('國家ID');
            $table->string('city', 30)->comment('城市');
            $table->integer('city_id')->default(0)->comment('城市ID');
            $table->string('address', 255)->nullable()->comment('详细地址');
            $table->string('street', 30)->nullable()->comment('街道');
            $table->string('post_code', 10)->nullable()->comment('邮编');
            $table->boolean('default')->default(0)->comment('是否默认');
            $table->timestamps();
        });


        // 用户关注表
        Schema::create('user_follows', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('关注用户ID');
            $table->integer('user_continents_id')->default(0)->comment('关注用户大洲ID');
            $table->integer('user_area_id')->default(0)->comment('关注用户地区ID');
            $table->boolean('user_identity')->default(0)->comment('用户身份');
            $table->integer('user_identity_id')->default(0)->comment('用户身份ID');
            $table->string('user_identity_tag', 30)->nullable()->comment('用户身份');
            $table->string('user_city_name', 100)->nullable();
            $table->integer('followed_id')->default(0)->comment('被关注用户ID');
            $table->integer('followed_continents_id')->default(0)->comment('被关注用户大洲ID');
            $table->integer('followed_area_id')->default(0)->comment('被关注用户地区ID');
            $table->boolean('followed_identity')->default(0)->comment('被关注用户身份');
            $table->integer('followed_identity_id')->default(0)->comment('被关注用户身份ID');
            $table->string('followed_identity_tag', 30)->nullable()->comment('被关注用户身份');
            $table->string('followed_city_name', 100)->nullable();
            $table->timestamps();
        });

        // 用户关注店铺
        Schema::create('user_follow_shop', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('关注用户ID');
            $table->integer('user_continents_id')->default(0)->comment('关注用户大洲ID');
            $table->integer('user_area_id')->default(0)->comment('关注用户地区ID');
            $table->boolean('user_identity')->default(0)->comment('用户身份');
            $table->integer('user_identity_id')->default(0)->comment('用户身份ID');
            $table->string('user_identity_tag', 30)->nullable()->comment('用户身份');
            $table->string('user_city_name', 100)->nullable();
            $table->integer('followed_id')->default(0)->comment('被关注店铺ID');
            $table->integer('followed_continents_id')->default(0)->comment('被关注店铺大洲ID');
            $table->integer('followed_area_id')->default(0)->comment('被关注店铺地区ID');
            $table->integer('followed_user_id')->default(0)->comment('被关注店铺用户ID');
            $table->string('followed_name', 50)->nullable()->comment('店铺名称');
            $table->string('followed_city_name', 100)->nullable();
            $table->timestamps();
        });


        // 登录记录
        Schema::create('user_login', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0);
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
        Schema::dropIfExists('guide_type');
        Schema::dropIfExists('guides');
        Schema::dropIfExists('guide_edit');
        Schema::dropIfExists('company');
        Schema::dropIfExists('company_edit');
        Schema::dropIfExists('enterprise');
        Schema::dropIfExists('user_invite_log');
        Schema::dropIfExists('user_address');
        Schema::dropIfExists('user_follows');
        Schema::dropIfExists('user_follow_shop');
        Schema::dropIfExists('user_login');
    }
};
