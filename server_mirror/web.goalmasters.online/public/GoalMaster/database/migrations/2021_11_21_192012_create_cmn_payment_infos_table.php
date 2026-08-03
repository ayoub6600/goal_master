<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnPaymentInfosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_payment_infos', function (Blueprint $table) {
            $table->id();
            $table->integer('paymentable_id');
            $table->string('paymentable_type',500);
            $table->integer('payment_type')->comment('1=local,2=paypal');
            $table->decimal('payment_amount',18,2);
            $table->decimal('payment_fee',18,2);
            $table->string('currency_code',50)->nullable();
            $table->string('order_id',100)->nullable();
            $table->string('payee_email_address',300)->nullable();
            $table->string('payee_crd_no',50)->nullable();
            $table->string('payment_create_time',50)->nullable();
            $table->string('payment_details',2000)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_payment_infos');
    }
}
