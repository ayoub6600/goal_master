<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddNewColumnSchEmployeeTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('sch_employees', function (Blueprint $table) {
            $table->decimal('salary',9,2)->default(0)->after('note');
            $table->decimal('commission',3,2)->default(0)->after('note');
            $table->string('id_card',1500)->nullable()->after('note');
            $table->string('passport',1500)->nullable()->after('note');
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
			$table->dropColumn('salary');
			$table->dropColumn('commission');
			$table->dropColumn('id_card');
			$table->dropColumn('passport');
		});
    }
}
