<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_products', function (Blueprint $table) {
            $table->id();
            $table->string('name',255);
            $table->foreignId('cmn_type_id');
            $table->foreignId('cmn_category_id');
            $table->double('price',12,2);
            $table->string('thumbnail');
            $table->text('images');
            $table->text('description')->nullable();
            $table->string('unit');
            $table->decimal('discount',5,2)->default(0);
            $table->integer('discount_type')->default(1);
            $table->integer('quantity')->default(1);
            $table->tinyInteger('is_featured')->default(0);
            $table->tinyInteger('is_hotdeal')->default(0);
            $table->tinyInteger('is_new')->default(0);
            $table->string('meta_title')->nullable();
            $table->string('meta_image')->nullable();
            $table->string('meta_content')->nullable();
            $table->tinyInteger('status')->default(1);
            $table->integer('created_by')->nullable();
            $table->integer('updated_by')->nullable();
            $table->timestamps();
            $table->foreign('cmn_type_id')->references('id')->on('cmn_types');
            $table->foreign('cmn_category_id')->references('id')->on('cmn_categories');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('products');
    }
}
