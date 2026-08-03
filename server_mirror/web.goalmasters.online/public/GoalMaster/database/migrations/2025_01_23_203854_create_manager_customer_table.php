<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Stripe\Customer;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('manager_customer', function (Blueprint $table) {
            $table->id();
            $table->string('full_name');
            $table->foreignId('manager_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('customer_id')->constrained('cmn_customers')->onDelete('cascade');
            $table->unique(['manager_id', 'customer_id']);
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
        Schema::dropIfExists('manager_customer');
    }
};
