<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class InsertUpdateVersionUpdatedDataDependency1 extends Migration
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
        (39, 'E-Commerce', 'E-Commerce', NULL, 1, 1, 8, 1, '', 'fas fa-cart-arrow-down', 1, NULL, '2022-06-03 13:24:07', '2022-06-03 13:24:07'),
        (40, 'coupon.blade.php', 'Coupon', 39, 1, 1, 1, 2, 'coupons', '', 1, NULL, '2022-06-03 13:26:22', '2022-06-03 13:26:22'),
        (41, 'order.blade.php', 'Order Info', 39, 1, 1, 2, 2, 'orders.index', '', 1, 1, '2022-06-03 13:31:52', '2022-06-11 11:52:50'),
        (42, 'salaries.blade.php', 'Salary', 15, 1, 1, 2, 2, 'employee.salaries', '', 1, NULL, '2022-06-03 14:00:39', '2022-06-03 14:00:39'),
        (43, 'product.blade.php', 'Product', 39, 1, 1, 3, 2, 'products.index', '', 1, NULL, '2022-06-11 11:53:34', '2022-06-11 11:53:34');");

        DB::unprepared("INSERT INTO `sec_resource_permissions` (`display_name`, `sec_resource_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ('E-Commerce', 39, 1, 1, 1, NULL, '2022-06-03 13:50:36', NULL),
        ('Coupon', 40, 1, 1, 1, NULL, '2022-06-03 13:50:36', NULL),
        ('Order Info', 41, 1, 1, 1, NULL, '2022-06-03 13:50:36', NULL),
        ('Salary', 42, 1, 1, 1, NULL, '2022-06-03 14:00:53', NULL),
        ('Product', 43, 1, 1, 1, NULL, '2022-06-11 11:54:10', NULL)");

        DB::unprepared("INSERT INTO `sec_role_permission_infos` (`sec_resource_id`, `permission_name`, `route_name`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
        (43, 'Add', 'products.store', 1, 1, '2022-06-11 11:56:56', '2022-06-13 13:22:45'),
        (41, 'Details', 'orders.show', 1, 1, '2022-06-11 12:03:49', '2022-06-11 12:08:10'),
        (41, 'Update', 'orders.update', 1, 1, '2022-06-11 12:10:03', '2022-06-11 12:10:03'),
        (40, 'Add', 'coupons.store', 1, 1, '2022-06-13 13:17:19', '2022-06-13 13:17:19'),
        (40, 'Update', 'coupons.update', 1, 1, '2022-06-13 13:17:44', '2022-06-13 13:17:44'),
        (40, 'Delete', 'coupons.destroy', 1, 1, '2022-06-13 13:17:59', '2022-06-13 13:17:59'),
        (43, 'Delete', 'products.destroy', 1, 1, '2022-06-13 13:22:59', '2022-06-13 13:22:59'),
        (43, 'Update', 'products.update', 1, 1, '2022-06-13 13:23:19', '2022-06-13 13:23:19')");

        DB::unprepared("INSERT INTO `sec_role_permissions` (`sec_role_permission_info_id`, `sec_role_id`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ((select id from sec_role_permission_infos where route_name='products.store'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ((select id from sec_role_permission_infos where route_name='orders.show'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='orders.update'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='coupons.store'), 1, 1, 1, NULL, '2022-03-24 23:30:52', NULL),
        ( (select id from sec_role_permission_infos where route_name='coupons.update'), 1, 1, 1, NULL, '2022-03-25 00:30:54', NULL),
        (  (select id from sec_role_permission_infos where route_name='coupons.destroy'), 1, 1, 1, NULL, '2022-04-14 01:04:39', NULL),
        ( (select id from sec_role_permission_infos where route_name='products.destroy'), 1, 1, 1, NULL, '2022-04-14 02:04:15', NULL),
        ( (select id from sec_role_permission_infos where route_name='products.update'), 1, 1, 1, NULL, '2022-04-14 02:04:15', NULL)");

        DB::unprepared("INSERT INTO `site_menus` (`name`, `site_menu_id`, `order`, `route`, `remarks`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
        ('Vouchers', 0, 4, 'site.vouchers', '', 1, 1, NULL, '2022-06-11 12:00:06', '2022-06-11 12:00:06');");
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
