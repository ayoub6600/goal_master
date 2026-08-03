<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnBusinessHolidaysTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_business_holidays', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cmn_branch_id');
            $table->string('title', 200);
            $table->date('start_date');
            $table->date('end_date');
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
        Schema::dropIfExists('cmn_business_holidays');
    }
}
