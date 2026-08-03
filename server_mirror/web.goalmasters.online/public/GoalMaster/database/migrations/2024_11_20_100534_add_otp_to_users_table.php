<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone_number')->unique()->nullable()->after('username');

        });

        Schema::table('cmn_customers', function (Blueprint $table) {
            $table->boolean('is_phone_verified')->default(false)->after('phone_no');
            $table->string('otp', 6)->nullable()->after('is_phone_verified');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('phone_number');
        });

        Schema::table('cmn_customers', function (Blueprint $table) {
            $table->dropColumn(['is_phone_verified', 'otp']);
        });
    }
};
