<?php

use App\Enums\MessageType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class InsertDataOtpMessageTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::table('st_otp_messages')->insert([
            ['message_type' => MessageType::ServiceCancel, 'message_for' => 'Service Cancel','tags'=>'{booking_number}','message'=>'Your booking has been cancelled booking no is: {booking_number}','status'=>0],
            ['message_type' => MessageType::ServiceStatus, 'message_for' => 'Service Status','tags'=>'{booking_number},{service_status},{service_date},{service_start},{service_end}','message'=>'Your service request is {service_status}, booking no# {booking_number}, booking date# {service_date} and service start# {service_start} - {service_end}','status'=>0],
            ['message_type' => MessageType::ServiceConfirm, 'message_for' => 'Service Confirm','tags'=>'{booking_number},{service_date},{service_start},{service_end}','message'=>'Your booking is confirmed, booking no# {booking_number}, booking date# {service_date} and service start# {service_start} - {service_end}','status'=>0]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
    }
}
