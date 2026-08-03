<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateSchServiceBookingInfosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_service_booking_infos', function (Blueprint $table) {
            $table->id();
            $table->date('booking_date');
            $table->decimal('total_amount',18,2);
            $table->decimal('paid_amount',18,2);
            $table->decimal('due_amount',18,2)->default(0);
            $table->string('coupon_code',128)->nullable();
            $table->decimal('coupon_discount',18,2)->default(0);
            $table->tinyInteger('is_due_paid')->default(0);
            $table->string('remarks',500)->nullable();
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
        });
        $today = (new Carbon())->format('Y-m-d');
        DB::table('sch_service_booking_infos')->insert([
            ['id'=>1,'booking_date' =>$today, 'total_amount' => 0,'paid_amount'=>0,'due_amount'=>0,'is_due_paid'=>1,'remarks'=>null]
        ]);
        Schema::table('sch_service_bookings', function (Blueprint $table) {
            $table->foreignId('sch_service_booking_info_id')->default(1);
            $table->foreign('sch_service_booking_info_id',"fk_sch_service_booking_sch_service_booking_info_id")->references('id')->on('sch_service_booking_infos');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_service_booking_infos');
        Schema::table('sch_service_bookings', function (Blueprint $table) {
            $table->dropForeign('fk_sch_service_booking_sch_service_booking_info_id');
            $table->dropColumn('sch_service_booking_info_id');
        });
    }
}
