<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateCmnLanguagesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cmn_languages', function (Blueprint $table) {
            $table->id();
            $table->string('name',50);
            $table->string('code', 5)->unique();
            $table->tinyInteger('rtl')->default(0);
            $table->timestamps();
        });
        DB::table('cmn_languages')->insert([
            ['name' => 'English', 'code'=>'en','rtl'=>0]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cmn_languages');
    }
}
