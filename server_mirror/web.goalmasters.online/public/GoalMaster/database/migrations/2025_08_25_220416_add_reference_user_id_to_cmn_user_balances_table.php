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
        Schema::table('cmn_user_balances', function (Blueprint $table) {
            $table->unsignedBigInteger('reference_user_id')->nullable()->after('user_id');
            $table->foreign('reference_user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::table('cmn_user_balances', function (Blueprint $table) {
            $table->dropForeign(['reference_user_id']);
            $table->dropColumn('reference_user_id');
        });
    }

};
