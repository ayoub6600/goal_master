<?php

use App\Enums\SmsGateway;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AddColumnStOtpConfigurationTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('st_otp_configurations', function (Blueprint $table) {           
            $table->integer('sms_gateway');//enum
            
        });
        DB::table('st_otp_configurations')->insert([
            ['name' => 'Twilio', 'status' => '0','sms_gateway'=>SmsGateway::Twilio]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('st_otp_configurations', function (Blueprint $table) {           
            $table->dropColumn('sms_gateway');
        });
    }
}
