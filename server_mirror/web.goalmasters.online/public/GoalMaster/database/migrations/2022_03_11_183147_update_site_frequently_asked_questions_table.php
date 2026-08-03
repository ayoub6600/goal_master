<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateSiteFrequentlyAskedQuestionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('site_frequently_asked_questions', function (Blueprint $table) {
			$table->dropColumn('image_url');
		});
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('site_frequently_asked_questions', function (Blueprint $table) {
			$table->string('image_url',1500)->nullable();
		});
        
    }
}
