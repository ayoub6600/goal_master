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
       if (!Schema::hasTable('booking_payment_tolerances')) {
           Schema::create('booking_payment_tolerances', function (Blueprint $table) {
               $table->id();
               $table->unsignedBigInteger('booking_id');
               $table->decimal('allowed_amount', 10, 2);
               $table->unsignedBigInteger('approved_by');
               $table->timestamps();

               $table->foreign('booking_id')->references('id')->on('sch_service_bookings')->onDelete('cascade');
               $table->foreign('approved_by')->references('id')->on('users')->onDelete('cascade');

           });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('booking_payment_tolerances');
    }
};
