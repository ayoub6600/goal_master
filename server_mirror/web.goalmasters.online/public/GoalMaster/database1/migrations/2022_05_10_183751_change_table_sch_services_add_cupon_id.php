<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChangeTableSchServicesAddCuponId extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_services', function (Blueprint $table) {
            $table->foreignId('cmn_coupon_id')->nullable()->after('price');
            $table->foreignId('cmn_coupon_amount')->nullable()->after('cmn_coupon_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_services', function (Blueprint $table) {
            $table->dropColumn('cmn_coupon_id');
            $table->dropColumn('cmn_coupon_amount');
        });
    }
}
