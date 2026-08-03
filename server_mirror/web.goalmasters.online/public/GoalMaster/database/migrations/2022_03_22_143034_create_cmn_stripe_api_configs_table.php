<?php

use App\Enums\PaymentType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateCmnStripeApiConfigsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_stripe_api_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cmn_payment_type_id');
            $table->string('api_key', 1000);
            $table->string('api_secret', 1000);
            $table->tinyInteger('charge_type')->comment('1=addition, 2=deduction');
            $table->decimal('charge_percentage', 4, 2)->default(0);
            $table->timestamps();
            $table->foreign("cmn_payment_type_id")->references("id")->on("cmn_payment_types");
        });
        DB::table('cmn_payment_types')->insert([
            ['name' => 'Stripe', 'type' => PaymentType::Stripe, 'order' => 3, 'created_by' => 1, 'status' => 1]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_stripe_api_configs');
    }
}
