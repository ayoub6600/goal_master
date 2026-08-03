<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchServicesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_services', function (Blueprint $table) {
            $table->id();
            $table->string('title', 300);
            $table->string('image', 1500)->nullable();
            $table->foreignId("sch_service_category_id");
            $table->tinyInteger("visibility")->default(1);
            $table->decimal('price', 18, 2);
            $table->integer('duration_in_days')->default(0);
            $table->time('duration_in_time')->default('00:00:00');
            $table->time('time_slot_in_time');
            $table->time('padding_time_before')->default('00:00:00');
            $table->time('padding_time_after')->default('00:00:00');
            $table->integer('appoinntment_limit_type')->default(0);
            $table->integer('appoinntment_limit')->default(0);
            $table->integer('minimum_time_required_to_booking_in_days')->default(0);
            $table->time('minimum_time_required_to_booking_in_time')->default('00:00:00');
            $table->integer('minimum_time_required_to_cancel_in_days')->default(0);
            $table->time('minimum_time_required_to_cancel_in_time')->default("00:00:00");
            $table->string('remarks')->nullable();
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();

            $table->foreign('sch_service_category_id')->references('id')->on('sch_service_categories');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_services');
    }
}
