<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSecResourcePermissionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sec_resource_permissions', function (Blueprint $table) {
            $table->id();
            $table->string('display_name', 250);
            $table->foreignId('sec_resource_id')->nullable();
            $table->foreignId('sec_role_id')->nullable();
            $table->tinyInteger('status');
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('sec_role_id')->references('id')->on('sec_roles');
            $table->foreign('sec_resource_id')->references('id')->on('sec_resources');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sec_resource_permissions');
    }
}
