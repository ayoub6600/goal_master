<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnBranchesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_branches', function (Blueprint $table) {
            $table->id();
            $table->string('name', 190)->unique();
            $table->string('phone', 20)->unique()->nullable();
            $table->string('email', 190)->unique()->nullable();
            $table->string('address', 300)->nullable();
            $table->integer('order')->default(0);
            $table->tinyInteger('status');
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
        Schema::dropIfExists('cmn_branches');
    }
}
