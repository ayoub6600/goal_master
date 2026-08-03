<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchEmployeesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_employees', function (Blueprint $table) {
            $table->id();
            $table->string("full_name", 200);
            $table->string('image_url', 1000)->nullable();
            $table->string("employee_id", 20)->nullable()->unique();
            $table->foreignId("cmn_branch_id");
            $table->string("email_address", 200);
            $table->string("country_code", 10)->nullable();
            $table->string("contact_no", 20)->nullable();
            $table->foreignId("hrm_department_id")->nullable();
            $table->foreignId("hrm_designation_id")->nullable();
            $table->foreignId("user_id")->nullable();
            $table->tinyInteger("gender");
            $table->date("dob")->nullable();
            $table->string("specialist", 300)->nullable();
            $table->string("present_address", 500)->nullable();
            $table->string("permanent_address", 500)->nullable();
            $table->string("note")->nullable();
            $table->tinyInteger("status");
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('user_id')->references('id')->on('users');
            $table->foreign('cmn_branch_id')->references('id')->on('cmn_branches');
            $table->foreign('hrm_department_id')->references('id')->on('hrm_departments');
            $table->foreign('hrm_designation_id')->references('id')->on('hrm_designations');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_employees');
    }
}
