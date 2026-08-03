<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSiteFrequentlyAskedQuestionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('site_frequently_asked_questions', function (Blueprint $table) {
            $table->id();
            $table->string('question',200);
            $table->string('answer',1000);
            $table->string('image_url',1500)->nullable();
            $table->tinyInteger('status')->default(0);
            $table->integer('order')->default(0);
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
        Schema::dropIfExists('site_frequently_asked_questions');
    }
}
