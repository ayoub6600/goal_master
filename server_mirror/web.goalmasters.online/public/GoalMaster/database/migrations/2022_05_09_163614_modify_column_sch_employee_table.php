<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ModifyColumnSchEmployeeTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_employees', function (Blueprint $table) {
            $table->decimal('commission',5,2)->default(0)->after('note')->change();
		});
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('sch_employees', function (Blueprint $table) {
            $table->decimal('commission',3,2)->default(0)->after('note')->change();
		});
    }
}
