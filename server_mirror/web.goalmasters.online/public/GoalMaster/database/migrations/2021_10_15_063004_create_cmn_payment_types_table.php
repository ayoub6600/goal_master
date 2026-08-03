<?php

use App\Enums\PaymentType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateCmnPaymentTypesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_payment_types', function (Blueprint $table) {
            $table->id();
            $table->string('name', 190)->unique();
            $table->tinyInteger('type')->default(1);
            $table->integer('order')->default(0);
            $table->tinyInteger('status')->default(1);
            $table->integer('created_by')->nullable();
            $table->integer('modified_by')->nullable();
            $table->timestamps();
        });
        DB::table('cmn_payment_types')->insert([
            ['name' => 'Local Payment', 'type' => PaymentType::LocalPayment, 'order' => 1, 'created_by' => 1, 'status' => 1],
            ['name' => 'Paypal', 'type' => PaymentType::Paypal, 'order' => 2, 'created_by' => 1, 'status' => 1]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_payment_types');
    }
}
