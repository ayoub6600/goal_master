<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSecRolePermissionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sec_role_permissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sec_role_permission_info_id');
            $table->foreignId('sec_role_id');
            $table->tinyInteger('status');
            $table->integer('created_by');
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('sec_role_permission_info_id')->references('id')->on('sec_role_permission_infos');
            $table->foreign('sec_role_id')->references('id')->on('sec_roles');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('sec_role_permissions');
    }
}
