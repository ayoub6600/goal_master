<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;

class InsertSecResourcesAndPermissions extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Inserting into sec_resources
        DB::table('sec_resources')->insert([
            [
                'id' => '47',
                'name' => 'card_system',
                'display_name' => 'Card System',
                'sec_resource_id' => null,
                'sec_module_id' => '1',
                'status' => '1',
                'serial' => '3',
                'level' => '1',
                'method' => '',
                'icon' => 'fas fa-credit-card',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => '2024-10-21 14:25:52',
                'updated_at' => null,
            ],
            [
                'id' => '48',
                'name' => 'cards',
                'display_name' => 'Generate New Cards',
                'sec_resource_id' => '47',
                'sec_module_id' => '1',
                'status' => '1',
                'serial' => '3',
                'level' => '2',
                'method' => 'card',
                'icon' => 'fas fa-card',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => '2024-10-21 14:32:34',
                'updated_at' => null,
            ],
            [
                'id' => '49',
                'name' => 'View Cards',
                'display_name' => 'View Cards',
                'sec_resource_id' => '47',
                'sec_module_id' => '1',
                'status' => '1',
                'serial' => '3',
                'level' => '2',
                'method' => 'getcards',
                'icon' => null,
                'created_by' => null,
                'updated_by' => null,
                'created_at' => null,
                'updated_at' => null,
            ],
        ]);

        // Inserting into sec_resource_permissions
        DB::table('sec_resource_permissions')->insert([
            [
                'display_name' => 'Card System',
                'sec_resource_id' => '47',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => '2024-10-21 14:33:05',
                'updated_at' => null,
            ],
            [
                'display_name' => 'Generate New Cards',
                'sec_resource_id' => '48',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => '2024-10-21 14:33:21',
                'updated_at' => null,
            ],
            [
                'display_name' => 'View All Cards',
                'sec_resource_id' => '49',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => null,
                'updated_by' => null,
                'created_at' => null,
                'updated_at' => null,
            ],
        ]);

        // Inserting into sec_role_permission_infos
        DB::table('sec_role_permission_infos')->insert([
            [
                'sec_resource_id' => '48',
                'permission_name' => 'create-cards',
                'route_name' => 'create-cards',
                'status' => '1',
                'created_by' => '1',
                'created_at' => null,
                'updated_at' => null,
            ],
            [
                'sec_resource_id' => '48',
                'permission_name' => 'getcards',
                'route_name' => 'getcards',
                'status' => '1',
                'created_by' => '1',
                'created_at' => null,
                'updated_at' => null,
            ],
            [
                'sec_resource_id' => '48',
                'permission_name' => 'cards.pdf',
                'route_name' => 'cards.pdf',
                'status' => '1',
                'created_by' => '1',
                'created_at' => null,
                'updated_at' => null,
            ],
        ]);

        // Inserting into sec_role_permissions
        DB::table('sec_role_permissions')->insert([
            [
                'sec_role_permission_info_id' => '90',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => null,
                'updated_at' => null,
            ],
            [
                'sec_role_permission_info_id' => '89',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => null,
                'updated_at' => null,
            ],
            [
                'sec_role_permission_info_id' => '88',
                'sec_role_id' => '1',
                'status' => '1',
                'created_by' => '1',
                'updated_by' => null,
                'created_at' => null,
                'updated_at' => null,
            ],
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // You can add code here to drop or remove the inserted data if needed
        DB::table('sec_resources')->whereIn('id', [47, 48, 49])->delete();
        DB::table('sec_resource_permissions')->whereIn('sec_resource_id', [47, 48, 49])->delete();
        DB::table('sec_role_permission_infos')->where('sec_resource_id', '48')->delete();
        DB::table('sec_role_permissions')->whereIn('sec_role_permission_info_id', [90, 89, 88])->delete();
    }
}
