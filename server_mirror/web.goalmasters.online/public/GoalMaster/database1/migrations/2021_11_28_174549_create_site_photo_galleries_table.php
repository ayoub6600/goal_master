<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSitePhotoGalleriesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('site_photo_galleries', function (Blueprint $table) {
            $table->id();
            $table->string('name',200)->nullable();
            $table->string('image_url',2000);
            $table->integer('order')->default(0);
            $table->tinyInteger('status')->default(0);
            $table->string('description',500)->nullable();
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
        Schema::dropIfExists('site_photo_galleries');
    }
}
