<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnPaypalApiConfigsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_paypal_api_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cmn_payment_type_id');
            $table->string('client_id', 1000);
            $table->string('client_secret', 1000);
            $table->tinyInteger('sandbox');
            $table->tinyInteger('charge_type')->comment('1=addition, 2=deduction');
            $table->decimal('charge_percentage', 4,2)->default(0);
            $table->timestamps();
            $table->foreign("cmn_payment_type_id")->references("id")->on("cmn_payment_types");
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_paypal_api_configs');
    }
}
