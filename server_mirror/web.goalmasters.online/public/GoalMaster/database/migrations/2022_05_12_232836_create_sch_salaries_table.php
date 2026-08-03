<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSchSalariesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sch_salaries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sch_employee_id');
            $table->integer('year');
            $table->string('month',2);
            $table->decimal('basic_salary',12,2);
            $table->integer('total_service');
            $table->decimal('commission',12,2);
            $table->decimal('addition',12,2);
            $table->decimal('deduction',12,2);
            $table->tinyInteger('is_paid')->default(0);
            $table->dateTime('paid_at')->nullable();
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sch_salaries');
    }
}
