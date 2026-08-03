<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChangeSchSalariesTableBasedOn extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_salaries', function (Blueprint $table) {
            $table->decimal('commission_amount',12,2)->default(0)->after('commission');
            $table->tinyInteger('pay_commission_based_on')->after('commission_amount');
            $table->decimal('total_service_amount')->after('total_service');
            $table->decimal('total_salary')->after('addition');
            $table->decimal('netpay')->after('deduction');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_salaries', function (Blueprint $table) {
            $table->dropColumn('commission_amount');
            $table->dropColumn('pay_commission_based_on');
            $table->dropColumn('total_service_amount');
            $table->dropColumn('total_salary');
            $table->dropColumn('netpay');
        });
    }
}
