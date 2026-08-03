<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_service_booking_infos', function (Blueprint $table) {
            $table->boolean('is_monthly')->default(false);
            $table->boolean('is_monthly_active')->default(false);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_service_booking_infos', function (Blueprint $table) {
            $table->dropColumn('is_monthly');
            $table->dropColumn('is_monthly_active');
        });
    }
};
