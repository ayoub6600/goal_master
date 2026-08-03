<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AlterCmnBusinessHoursTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('cmn_business_hours', function (Blueprint $table) {
            $table->unique(['day','cmn_branch_id'],'uk_cmn_business_hours_day_cmn_branch_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('cmn_business_hours', function (Blueprint $table) {
            $table->dropUnique('uk_cmn_business_hours_day_cmn_branch_id');
        });
    }
}
