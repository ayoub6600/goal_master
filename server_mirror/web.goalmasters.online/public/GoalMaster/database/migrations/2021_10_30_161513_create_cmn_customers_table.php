<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnCustomersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_customers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable();
            $table->string('full_name',50);
            $table->string('phone_no',20)->unique();
            $table->string('email',160)->nullable()->unique();
            $table->date('dob')->nullable();
            $table->string('country',100)->nullable();
            $table->string('state',120)->nullable();
            $table->string('postal_code',50)->nullable();
            $table->string('city',150)->nullable();
            $table->string('street_address',500)->nullable();
            $table->string('street_number',100)->nullable();
            $table->string('remarks',500)->nullable();
            $table->timestamps();
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
        Schema::dropIfExists('cmn_customers');
    }
}
