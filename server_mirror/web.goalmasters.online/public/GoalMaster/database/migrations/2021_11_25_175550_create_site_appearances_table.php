<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSiteAppearancesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('site_appearances', function (Blueprint $table) {
            $table->id();
            $table->string('app_name',50);
            $table->string('logo',1000);
            $table->string('icon',1000)->nullable();
            $table->string('motto',1000)->nullable();
            $table->string('theam_color',10);
            $table->string('theam_menu_color2',10);
            $table->string('theam_hover_color',10);
            $table->string('theam_active_color',10);
            $table->string('facebook_link',500)->nullable();
            $table->string('youtube_link',500)->nullable();
            $table->string('twitter_link',500)->nullable();
            $table->string('instagram_link',500)->nullable();
            $table->string('about_service',300)->nullable();
            $table->string('contact_email',150);
            $table->string('contact_phone',25);
            $table->string('contact_web',50);
            $table->string('address',300)->nullable();
            $table->string('background_image',1000);
            $table->string('login_background_image',1000)->nullable();
            $table->string('meta_title',200)->nullable();
            $table->string('meta_description',500)->nullable();
            $table->string('meta_keywords',500)->nullable();
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
        Schema::dropIfExists('site_appearances');
    }
}
