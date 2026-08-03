<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddNewColumnSecResourcesAndSecRolePermInfo extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sec_resources', function (Blueprint $table) {
            $table->string('icon',400)->after('method')->nullable();
        });
        Schema::table('sec_role_permission_infos', function (Blueprint $table) {
            $table->string('route_name',250)->after('permission_name');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sec_resources', function (Blueprint $table) {
            $table->dropColumn('icon');
        });
        Schema::table('sec_role_permission_infos', function (Blueprint $table) {
            $table->dropColumn('route_name');
        });
    }
}
