<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddNewColumnSecServiceBookingInfoTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_service_booking_infos', function (Blueprint $table) {
            $table->foreignId('cmn_customer_id')->nullable();
            $table->decimal('payable_amount')->default(0);
            $table->foreign('cmn_customer_id')->references('id')->on('cmn_customers');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_service_bookings', function (Blueprint $table) {
            $table->dropConstrainedForeignId('cmn_customer_id');
        });
    }
}
