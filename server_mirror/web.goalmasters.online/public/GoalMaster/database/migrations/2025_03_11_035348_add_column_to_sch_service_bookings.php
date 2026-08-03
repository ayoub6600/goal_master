<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasTable('sch_service_bookings')) {
            Schema::table('sch_service_bookings', function (Blueprint $table) {
                $table->boolean('online_done')->default(false)->after('remarks');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_service_bookings', function (Blueprint $table) {
            $table->dropColumn('online_done');
        });
    }
    
};
