<?php

use App\Enums\PayCommissionBasedOn;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddColumnSchEmployeeTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_employees', function (Blueprint $table) {
            $table->decimal('target_service_amount',12,2)->default(0)->after('note');
            $table->tinyInteger('pay_commission_based_on')->default(PayCommissionBasedOn::BasicSalary)->after('note');
		});
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_employees', function (Blueprint $table) {
            $table->dropColumn('target_service_amount');
            $table->dropColumn('pay_commission_based_on');
		});
    }
}
