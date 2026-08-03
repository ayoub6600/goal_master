<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChangeCmnCouponsTableAddExtra extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('cmn_coupons', function (Blueprint $table) {
            $table->decimal('min_order_value',12,2)->default(0)->after('use_limit');
            $table->decimal('max_discount_value',12,2);
            $table->tinyInteger('is_fixed')->default(1);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('cmn_coupons', function (Blueprint $table) {
            $table->dropColumn('min_order_value');
            $table->dropColumn('max_discount_value');
            $table->dropColumn('is_fixed');
        });
    }
}
