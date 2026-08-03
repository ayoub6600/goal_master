<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchEmployeeSchedulesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_employee_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sch_employee_id');
            $table->integer('day');
            $table->time('start_time');
            $table->time('end_time');
            $table->time('break_start_time');
            $table->time('break_end_time');
            $table->tinyInteger('is_off_day');
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('sch_employee_id')->references('id')->on('sch_employees');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_employee_schedules');
    }
}
