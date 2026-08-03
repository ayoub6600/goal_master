<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchServiceBookingFeedbackTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_service_booking_feedback', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sch_service_booking_id');
            $table->foreignId('user_id')->nullable();
            $table->string('hash_code')->nullable();
            $table->decimal('rating',3,1)->default(0);
            $table->text('feedback')->nullable();
            $table->tinyInteger('status')->default(0);
            $table->timestamps();
            $table->foreign('sch_service_booking_id','sch_sb_id')->references('id')->on('sch_service_bookings');
            $table->foreign('user_id')->references('id')->on('users');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_service_booking_feedback');
    }
}
