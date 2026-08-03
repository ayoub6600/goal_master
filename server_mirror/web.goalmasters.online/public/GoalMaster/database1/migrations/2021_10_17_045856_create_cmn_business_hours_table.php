<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnBusinessHoursTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_business_hours', function (Blueprint $table) {
            $table->id();
            $table->integer('day');
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_off_day')->default(0);
            $table->foreignId('cmn_branch_id');
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('cmn_branch_id')->references('id')->on('cmn_branches');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_business_hours');
    }
}
