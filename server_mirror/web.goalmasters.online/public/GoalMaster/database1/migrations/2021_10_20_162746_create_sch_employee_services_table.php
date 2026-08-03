<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchEmployeeServicesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_employee_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sch_employee_id');
            $table->foreignId('sch_service_id');
            $table->decimal('fees', 18, 2)->default(0);
            $table->tinyInteger('status')->default(0);
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->unique(['sch_employee_id', 'sch_service_id']);
            $table->foreign('sch_employee_id')->references('id')->on('sch_employees');
            $table->foreign('sch_service_id')->references('id')->on('sch_services');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_employee_services');
    }
}
