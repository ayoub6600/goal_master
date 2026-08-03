<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class InsertUpdateVersionUpdatedDataDependency2 extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::unprepared("
        INSERT INTO `sec_resources` (`id`, `name`, `display_name`, `sec_resource_id`, `sec_module_id`, `status`, `serial`, `level`, `method`, `icon`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        (44, 'OTP', 'OTP', NULL, 1, 1, 8, 1, '', 'far fa-envelope', 1, 1, '2022-07-12 03:00:16', '2022-07-12 03:17:21'),
        (45, 'index.blade.php', 'Twilio Configuration', 44, 1, 1, 1, 2, 'sms.index', '', 1, NULL, '2022-07-12 03:05:41', '2022-07-12 03:05:41'),
        (46, 'otp.blade.php', 'OTP Customization', 44, 1, 1, 2, 2, 'sms.otp', '', 1, 1, '2022-07-12 03:11:19', '2022-07-12 03:13:57')");

        DB::unprepared("INSERT INTO `sec_resource_permissions` (`display_name`, `sec_resource_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ('OTP', 44, 1, 1, 1, NULL, '2022-07-12 03:15:50', NULL),
        ('Twilio Configuration', 45, 1, 1, 1, NULL, '2022-07-12 03:15:50', NULL),
        ('OTP Customization', 46, 1, 1, 1, NULL, '2022-07-12 03:15:50', NULL)");

        DB::unprepared("INSERT INTO `sec_role_permission_infos` (`sec_resource_id`, `permission_name`, `route_name`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
        (45, 'Save Change', 'sms.twilio', 1, 1, '2022-07-12 03:14:56', '2022-07-12 03:14:56'),
        (46, 'Save Change', 'sms.otp.update', 1, 1, '2022-07-12 03:15:14', '2022-07-12 03:15:14')");

        DB::unprepared("INSERT INTO `sec_role_permissions` (`sec_role_permission_info_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ((select id from sec_role_permission_infos where route_name='sms.twilio'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ((select id from sec_role_permission_infos where route_name='sms.otp.update'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL)");

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
    }
}
