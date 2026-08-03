<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSecResourcesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sec_resources', function (Blueprint $table) {
            $table->id();
            $table->string('name', 250);
            $table->string('display_name', 250);
            $table->integer('sec_resource_id')->nullable();
            $table->integer('sec_module_id')->nullable();
            $table->tinyInteger('status');
            $table->integer('serial');
            $table->integer('level')->nullable();
            $table->string('method', 300);
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
        Schema::dropIfExists('sec_resources');
    }
}
