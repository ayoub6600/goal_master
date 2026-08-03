<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSiteClientTestimonialsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('site_client_testimonials', function (Blueprint $table) {
            $table->id();
            $table->string('name',200);
            $table->string('description',500);
            $table->integer('rating');
            $table->string('image',1000)->nullable();
            $table->string('contact_phone',50)->nullable();
            $table->string('contact_email',150)->nullable();
            $table->string('client_ref',150)->nullable();
            $table->tinyInteger('status')->default(0);
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
        Schema::dropIfExists('site_client_testimonials');
    }
}
