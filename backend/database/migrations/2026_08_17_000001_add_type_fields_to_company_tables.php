<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 企业认证：持久化用户选择的经营类型 ID 与二级分类 ID，
     * 审核通过自动建店时优先使用用户实际选择的分类（此前只存 business_type 标题）。
     */
    public function up()
    {
        Schema::table('company', function (Blueprint $table) {
            $table->integer('type_id')->default(0)->comment('经营类型ID')->after('business_type');
            $table->integer('type_class_id')->default(0)->comment('经营类型二级分类ID')->after('type_id');
        });

        Schema::table('company_edit', function (Blueprint $table) {
            $table->integer('type_id')->default(0)->comment('经营类型ID')->after('business_type');
            $table->integer('type_class_id')->default(0)->comment('经营类型二级分类ID')->after('type_id');
        });
    }

    public function down()
    {
        Schema::table('company', function (Blueprint $table) {
            $table->dropColumn(['type_id', 'type_class_id']);
        });

        Schema::table('company_edit', function (Blueprint $table) {
            $table->dropColumn(['type_id', 'type_class_id']);
        });
    }
};
