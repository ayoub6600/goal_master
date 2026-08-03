<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSecRolePermissionInfosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sec_role_permission_infos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sec_resource_id');
            $table->string('permission_name', 150);
            $table->tinyInteger('status');
            $table->integer('created_by');
            $table->timestamps();
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
        Schema::dropIfExists('sec_role_permission_infos');
    }
}
