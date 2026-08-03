<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_service_categories', function (Blueprint $table) {
            //
            $table->foreignId('cmn_branch_id')->nullable()->constrained()->onDelete('cascade');

        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_service_categories', function (Blueprint $table) {
            //
            $table->dropForeign(['cmn_branch_id']);

        });
    }
};
