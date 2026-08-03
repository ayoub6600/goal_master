<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCmnTranslationsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignId("cmn_language_id");
            $table->string('lang_key','1500');
            $table->string('lang_value','1500');
            $table->foreign("cmn_language_id")->references('id')->on("cmn_languages");
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
        Schema::dropIfExists('cmn_translations');
    }
}
