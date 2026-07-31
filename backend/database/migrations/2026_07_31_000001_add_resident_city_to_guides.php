<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // guides table
        Schema::table('guides', function (Blueprint $table) {
            $table->integer('resident_city_id')->nullable()->comment('常駐城市ID（現有城市）');
            $table->string('resident_city_name')->nullable()->comment('常駐城市名稱');
            $table->tinyInteger('is_new_city')->default(0)->comment('是否新增城市 0否1是');
            $table->string('new_city_name')->nullable()->comment('新城市中文名');
            $table->string('new_city_name_en')->nullable()->comment('新城市英文名');
            $table->integer('new_city_continents_id')->nullable()->comment('新城市大洲ID');
            $table->string('new_city_continents_name')->nullable();
            $table->integer('new_city_area_id')->nullable()->comment('新城市地區ID');
            $table->string('new_city_area_name')->nullable();
            $table->integer('new_city_country_id')->nullable()->comment('新城市國家ID');
            $table->string('new_city_country_name')->nullable();
            $table->integer('linked_city_id')->nullable()->comment('關聯的新增城市ID（審核聯動用）');
        });

        // guide_edit table — mirror all new fields for audit workflow
        Schema::table('guide_edit', function (Blueprint $table) {
            $table->integer('resident_city_id')->nullable()->comment('常駐城市ID');
            $table->string('resident_city_name')->nullable();
            $table->tinyInteger('is_new_city')->default(0)->comment('是否新增城市');
            $table->string('new_city_name')->nullable();
            $table->string('new_city_name_en')->nullable();
            $table->integer('new_city_continents_id')->nullable();
            $table->string('new_city_continents_name')->nullable();
            $table->integer('new_city_area_id')->nullable();
            $table->string('new_city_area_name')->nullable();
            $table->integer('new_city_country_id')->nullable();
            $table->string('new_city_country_name')->nullable();
            $table->integer('linked_city_id')->nullable()->comment('關聯的新增城市ID');
        });
    }

    public function down()
    {
        Schema::table('guides', function (Blueprint $table) {
            $table->dropColumn([
                'resident_city_id', 'resident_city_name',
                'is_new_city', 'new_city_name', 'new_city_name_en',
                'new_city_continents_id', 'new_city_continents_name',
                'new_city_area_id', 'new_city_area_name',
                'new_city_country_id', 'new_city_country_name',
                'linked_city_id',
            ]);
        });

        Schema::table('guide_edit', function (Blueprint $table) {
            $table->dropColumn([
                'resident_city_id', 'resident_city_name',
                'is_new_city', 'new_city_name', 'new_city_name_en',
                'new_city_continents_id', 'new_city_continents_name',
                'new_city_area_id', 'new_city_area_name',
                'new_city_country_id', 'new_city_country_name',
                'linked_city_id',
            ]);
        });
    }
};
