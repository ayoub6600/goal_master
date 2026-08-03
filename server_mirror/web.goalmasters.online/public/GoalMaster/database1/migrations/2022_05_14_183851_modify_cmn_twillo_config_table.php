<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ModifyCmnTwilloConfigTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('cmn_twillo_config', function (Blueprint $table) {
            $table->renameColumn('phoneNo','phone_no');
		});
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('cmn_twillo_config', function (Blueprint $table) {
            $table->renameColumn('phone_no','phoneNo');
		});
    }
}
