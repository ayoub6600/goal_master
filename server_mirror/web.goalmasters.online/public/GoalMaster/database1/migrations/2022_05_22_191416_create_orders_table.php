<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrdersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_orders', function (Blueprint $table) {
            $table->id();
            $table->string('code',20)->nullable();
            $table->foreignId('user_id');
            $table->decimal('amount',12,2);
            $table->decimal('discount_amount',12,2)->default(0);
            $table->decimal('shipping_amount',12,2)->default(0);
            $table->text('shipping_details')->nullable();
            $table->foreignId('cmn_coupon_id')->nullable();
            $table->decimal('coupon_amount',12,2)->default(0);
            $table->string('payment_status')->default('unpaid');
            $table->string('shipping_status')->default('on_process');
            $table->integer('updated_by')->nullable();
            $table->tinyInteger('status')->default(1);
            $table->timestamps();
            $table->foreign('user_id')->references('id')->on('users');
            $table->foreign('cmn_coupon_id')->references('id')->on('cmn_coupons');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('orders');
    }
}
