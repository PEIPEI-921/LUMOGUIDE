<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddViewCountToCityContentTable extends Migration
{
    public function up()
    {
        Schema::table('city_content', function (Blueprint $table) {
            $table->integer('view_count')->default(0)->after('order')->comment('瀏覽次數');
        });
    }

    public function down()
    {
        Schema::table('city_content', function (Blueprint $table) {
            $table->dropColumn('view_count');
        });
    }
}
