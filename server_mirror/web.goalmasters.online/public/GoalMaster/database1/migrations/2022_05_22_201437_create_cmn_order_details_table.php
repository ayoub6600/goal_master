<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnOrderDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_order_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cmn_order_id');
            $table->foreignId('cmn_product_id');
            $table->decimal('product_price',12,2);
            $table->integer('product_quantity');
            $table->decimal('total_price',12,2);
            $table->decimal('discount_amount',12,2)->default(0);
            $table->decimal('shipping_amount',12,2)->default(0);
            $table->decimal('paid_amount',12,2)->default(0);
            $table->foreign('cmn_order_id')->references('id')->on('cmn_orders');
            $table->foreign('cmn_product_id')->references('id')->on('cmn_products');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_order_details');
    }
}
