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
        Schema::create('city', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('guide_id')->default(0)->comment('导游ID');
            $table->string('name', 2)->comment('城市名称');
            $table->string('name_en', 30)->comment('城市名称英文');
            $table->integer('continents_id')->default(0)->comment('所属大洲ID');
            $table->integer('area_id')->default(0)->comment('所属地区ID');
            $table->integer('country_id')->default(0)->comment('國家ID');
            $table->string('longitude', 30)->nullable()->comment('经度');
            $table->string('latitude', 30)->nullable()->comment('纬度');
            $table->boolean('is_capital')->default(0)->comment('是否首都');
            $table->string('currency', 30)->comment('货币');
            $table->string('language', 30)->comment('官方语言');
            $table->string('population', 30)->comment('人口数量');
            $table->string('race', 30)->comment('种族');
            $table->string('overview', 255)->nullable()->comment('概览');
            $table->string('history', 255)->nullable()->comment('历史');
            $table->string('first_picture', 255)->nullable()->comment('首张封面');
            $table->string('pictures', 1000)->nullable()->comment('封面');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->boolean('status')->default(0)->comment('状态');
            $table->boolean('recommend')->default(0)->comment('推荐');
            $table->boolean('home_recommend')->default(0)->comment('首页推荐');
            $table->integer('order')->default(0);
            $table->boolean('is_finish')->default(0)->comment('是否完成');
            $table->boolean('is_read')->default(1)->comment('是否已读');
            $table->boolean('status')->default(1)->comment('状态');
            $table->timestamps();
        });

        // 资讯分类
        Schema::create('information_class', function (Blueprint $table) {
            $table->id();
            $table->string('name', 30)->comment('名称');
            $table->bigInteger('parent_id')->default(0);
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // 资讯
        Schema::create('information', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('guide_id')->default(0)->comment('导游ID');
            $table->integer('guide_type_id')->default(0)->comment('导游身份ID');
            $table->integer('class_id')->default(0)->comment('分类ID');
            $table->string('title', 30)->comment('标题');
            $table->string('title', 255)->nullable()->comment('简介');
            $table->text('content')->comment('内容');
            $table->string('first_picture', 255)->nullable()->comment('首张封面');
            $table->string('pictures', 1000)->nullable()->comment('图片');
            $table->boolean('look')->default(1)->comment('仅谁可看');
            $table->integer('view')->default(0)->comment('浏览量');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核驳回原因');
            $table->boolean('top')->default(0)->comment('置顶');
            $table->integer('top_order')->default(0)->comment('置顶排序');
            $table->boolean('home_recommend')->default(0)->comment('首页推荐');
            $table->boolean('is_finish')->default(0)->comment('是否完成');
            $table->timestamps();
        });

        // 资讯评价
        Schema::create('information_evaluate', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->string('user_type', 10)->comment('用户类型');
            $table->integer('information_id')->default(0)->comment('资讯ID');
            $table->integer('information_user_id')->default(0)->comment('发布资讯用户ID');
            $table->string('content', 255)->comment('内容');
            $table->string('pictures', 1000)->nullable()->comment('图片');
            $table->boolean('star')->default(0)->comment('星');
            $table->boolean('recommend')->default(0)->comment('推荐');
            $table->timestamps();
        });

        // 城市类型
        Schema::create('city_type', function (Blueprint $table) {
            $table->id();
            $table->string('icon', 255)->nullable()->comment('ICON');
            $table->string('name', 30)->comment('名称');
            $table->string('key', 10)->comment('key');
            $table->timestamps();
        });

        // 城市类型分类
        Schema::create('city_type_class', function (Blueprint $table) {
            $table->id();
            $table->tinyInteger('type_id')->default(0)->comment('类型');
            $table->string('name', 30)->comment('名称');
            $table->bigInteger('parent_id')->default(0);
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // 城市内容
        Schema::create('city_content', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('city_id')->default(0)->comment('城市ID');
            $table->integer('continents_id')->default(0)->comment('所属大洲ID');
            $table->integer('area_id')->default(0)->comment('所属地区ID');
            $table->tinyInteger('type_id')->default(0)->comment('类型');
            $table->integer('type_class_id')->default(0)->comment('分类ID');
            $table->integer('user_id')->default(0)->comment('用户ID');
            $table->integer('publisher_id')->default(0)->comment('发布人ID');
            $table->string('publisher_type', 10)->comment('发布人类型');
            $table->string('name', 255)->comment('名称/标题');
            $table->string('start_time', 255)->nullable()->comment('开放时间/营业时间');
            $table->string('end_time', 255)->nullable()->comment('结束时间');
            $table->boolean('tickets_free')->default(0)->comment('门票免费');
            $table->string('capacity', 10)->nullable()->comment('餐厅容纳人数');
            $table->boolean('order_food')->default(0)->comment('是否接受团餐预订');
            $table->string('price', 10)->nullable()->comment('价格');
            $table->string('phone', 50)->nullable()->comment('电话');
            $table->string('other_phone', 50)->nullable()->comment('其他联系方式');
            $table->string('email', 50)->nullable()->comment('邮箱');
            $table->string('website', 50)->nullable()->comment('网址');
            $table->string('address', 255)->comment('地址');
            $table->string('longitude', 30)->nullable()->comment('经度');
            $table->string('latitude', 30)->nullable()->comment('纬度');
            $table->string('how_arrive', 1000)->nullable()->comment('如何到达');
            $table->string('introduce', 1000)->nullable()->comment('相关介绍');
            $table->string('first_picture', 255)->nullable()->comment('图片');
            $table->string('pictures', 1000)->nullable()->comment('图片组');
            $table->boolean('audit_status')->default(0)->comment('审核状态');
            $table->string('audit_feedback', 255)->nullable()->comment('审核反馈');
            $table->boolean('recommend')->default(0)->comment('城市推荐');
            $table->boolean('banner_recommend')->default(0)->comment('轮播推荐');
            $table->boolean('home_recommend')->default(0)->comment('首页推荐');
            $table->integer('recommend_time')->default(0)->comment('城市推荐过期时间');
            $table->integer('banner_recommend_time')->default(0)->comment('轮播推荐过期时间');
            $table->integer('home_recommend_time')->default(0)->comment('首页推荐过期时间');
            $table->integer('order')->default(0);
            $table->boolean('is_finish')->default(0)->comment('是否完成');
            $table->boolean('is_read')->default(1)->comment('是否已读');
            $table->timestamps();
        });

        // 城市内容评价
        Schema::create('content_evaluate', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';

            $table->id();
            $table->integer('user_id')->default(0)->comment('发布用户ID');
            $table->string('user_type', 10)->comment('发布用户类型');
            $table->boolean('content_type')->default(1)->comment('内容详情 1城市/2资讯');
            $table->integer('content_id')->default(0)->comment('内容ID');
            $table->string('content_name')->nullable()->comment('评价内容');
            $table->integer('content_user_id')->default(0)->comment('内容发布用户ID');
            $table->string('content', 255)->comment('内容');
            $table->json('pictures')->nullable()->comment('图片');
            $table->boolean('star')->default(0)->comment('星');
            $table->boolean('recommend')->default(0)->comment('推荐');
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
        Schema::dropIfExists('city');
        Schema::dropIfExists('information_class');
        Schema::dropIfExists('information');
        Schema::dropIfExists('information_evaluate');
        Schema::dropIfExists('city_types');
        Schema::dropIfExists('city_type_class');
        Schema::dropIfExists('city_content');
        Schema::dropIfExists('content_evaluate');
    }
};
