<?php

use Illuminate\Database\Migrations\Migration;
use App\Enums\PaymentType;
use Illuminate\Support\Facades\DB;

class InsertUpdateVersionUpdatedDataDependency extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {

        DB::unprepared("INSERT INTO `sec_resources` (`id`, `name`, `display_name`, `sec_resource_id`, `sec_module_id`, `status`, `serial`, `level`, `method`, `icon`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        (38, 'language.blade.php', 'Language', 7, 1, 1, 7, 2, 'language', '', 1, 1, '2022-03-23 11:09:59', '2022-03-23 11:12:34')");

        DB::unprepared("INSERT INTO `sec_resource_permissions` (`display_name`, `sec_resource_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ('Language', 38, 1, 1, 1, NULL, '2022-03-23 11:13:11', NULL)");

        DB::unprepared("INSERT INTO `sec_role_permission_infos` (`sec_resource_id`, `permission_name`, `route_name`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
        ( 38, 'Save Change', 'save.language', 1, 1, '2022-03-24 23:12:28', '2022-03-24 23:12:28'),
        ( 38, 'Update', 'update.language', 1, 1, '2022-03-24 23:13:03', '2022-03-24 23:13:03'),
        ( 38, 'Delete', 'delete.language', 1, 1, '2022-03-24 23:13:19', '2022-03-24 23:13:19'),
        ( 38, 'Save Translated Language', 'save.translated.language', 1, 1, '2022-03-24 23:14:17', '2022-03-24 23:14:17'),
        (38, 'Update RTL', 'update.rtl.status', 1, 1, '2022-03-25 00:30:34', '2022-03-25 00:30:34'),
        (34, 'Enable Stripe Payment', 'enable.or.disable.stripe.payment', 1, 1, '2022-04-14 01:04:14', '2022-04-14 01:04:14'),
        (34, 'Save Stripe API', 'save.or.update.stripe.config', 1, 1, '2022-04-14 02:00:41', '2022-04-14 02:00:41')");

        DB::unprepared("INSERT INTO `sec_role_permissions` (`sec_role_permission_info_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ((select id from sec_role_permission_infos where route_name='save.language'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ((select id from sec_role_permission_infos where route_name='update.language'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='delete.language'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='save.translated.language'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='update.rtl.status'), 1, 1, 1, NULL, '2022-03-25 00:30:54', NULL),
        (  (select id from sec_role_permission_infos where route_name='enable.or.disable.stripe.payment'), 1, 1, 1, NULL, '2022-04-14 01:04:39', NULL),
        ( (select id from sec_role_permission_infos where route_name='save.or.update.stripe.config'), 1, 1, 1, NULL, '2022-04-14 02:04:15', NULL)");


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
