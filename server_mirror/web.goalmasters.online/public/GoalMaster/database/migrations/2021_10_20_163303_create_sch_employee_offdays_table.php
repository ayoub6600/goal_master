<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchEmployeeOffdaysTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_employee_offdays', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sch_employee_id');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('title', 200);
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
        Schema::dropIfExists('sch_employee_offdays');
    }
}
