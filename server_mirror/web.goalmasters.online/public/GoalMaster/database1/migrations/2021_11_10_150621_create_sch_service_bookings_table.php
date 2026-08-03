<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchServiceBookingsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_service_bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cmn_branch_id');
            $table->foreignId('cmn_customer_id');
            $table->foreignId('sch_employee_id');
            $table->date('date');
            $table->time('start_time');
            $table->time('end_time');
            $table->foreignId('sch_service_id');
            $table->tinyInteger('status');
            $table->decimal('service_amount',18,2);
            $table->decimal('paid_amount',18,2)->default(0);
            $table->tinyInteger('payment_status');
            $table->foreignId('cmn_payment_type_id');
            $table->decimal('canceled_paid_amount',18,2)->default(0);
            $table->tinyInteger('cancel_paid_status');
            $table->foreignId('cancel_cmn_payment_type_id')->nullable();
            $table->string('remarks',400)->nullable();
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('cmn_branch_id')->references('id')->on('cmn_branches');
            $table->foreign('cmn_customer_id')->references('id')->on('cmn_customers');
            $table->foreign('sch_employee_id')->references('id')->on('sch_employees');
            $table->foreign('sch_service_id')->references('id')->on('sch_services');
            $table->foreign('cmn_payment_type_id')->references('id')->on('cmn_payment_types');
            $table->foreign('cancel_cmn_payment_type_id')->references('id')->on('cmn_payment_types');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_service_bookings');
    }
}
